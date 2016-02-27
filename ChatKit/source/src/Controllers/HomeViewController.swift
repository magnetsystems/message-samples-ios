/*
* Copyright (c) 2016 Magnet Systems, Inc.
* All rights reserved.
*
* Licensed under the Apache License, Version 2.0 (the "License"); you
* may not use this file except in compliance with the License. You
* may obtain a copy of the License at
*
* http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
* implied. See the License for the specific language governing
* permissions and limitations under the License.
*/

import UIKit
import MagnetMax

class HomeViewController: UITableViewController, UISearchResultsUpdating {
    
    let searchController = UISearchController(searchResultsController: nil)
    var detailResponses : [MMXChannelDetailResponse] = []
    var filteredDetailResponses : [MMXChannelDetailResponse] = []
    
    override func loadView() {
        super.loadView()
        let nib = UINib.init(nibName: "HomeViewController", bundle: NSBundle(forClass: self.dynamicType))
        nib.instantiateWithOwner(self, options: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if MMUser.sessionStatus() != .LoggedIn {
            assertionFailure("MUST LOGIN USER FIRST")
        }
        
        self.tableView.allowsMultipleSelection = false
        // Indicate that you are ready to receive messages now!
        MMX.start()
        // Handling disconnection
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didDisconnect:", name: MMUserDidReceiveAuthenticationChallengeNotification, object: nil)
        
        let nib = UINib.init(nibName: "SummaryResponseCell", bundle: NSBundle(forClass: self.dynamicType))
        self.tableView.registerNib(nib, forCellReuseIdentifier: "SummaryResponseCell")
        
        // Add search bar
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.sizeToFit()
        tableView.tableHeaderView = searchController.searchBar
        tableView.reloadData()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        loadDetails()
        ChannelManager.sharedInstance.addChannelMessageObserver(self, channel:nil, selector: "didReceiveMessage:")
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        ChannelManager.sharedInstance.removeChannelMessageObserver(self)
    }
    
    func didReceiveMessage(mmxMessage: MMXMessage) {
        loadDetails()
    }
    
    @IBAction func refreshChannelDetail() {
        loadDetails()
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    
    // MARK: - Notification handler
    
    
    private func didDisconnect(notification: NSNotification) {
        MMX.stop()
    }
    
    
    // MARK: - Table view data source
    
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.active {
            return filteredDetailResponses.count
        }
        return detailResponses.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("SummaryResponseCell", forIndexPath: indexPath) as! SummaryResponseCell
        cell.detailResponse = searchController.active ? filteredDetailResponses[indexPath.row] : detailResponses[indexPath.row]
        
        return cell
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let detailResponse = detailResponses[indexPath.row]
        var isLastPersonInChat = false
        if detailResponse.messages.count > 0 {
            isLastPersonInChat = detailResponse.messages.last?.sender?.userID == MMUser.currentUser()?.userID
        }
        
        if isLastPersonInChat {
            // Current user must be the owner of the channel to delete it
            if let chat = ChannelManager.sharedInstance.isOwnerForChat(detailResponse.channelName) {
                let delete = UITableViewRowAction(style: .Normal, title: "Delete") { [weak self] action, index in
                    chat.deleteWithSuccess({ _ in
                        self?.detailResponses.removeAtIndex(index.row)
                        tableView.deleteRowsAtIndexPaths([index], withRowAnimation: .Fade)
                        }, failure: { error in
                            print(error)
                    })
                }
                delete.backgroundColor = UIColor.redColor()
                return [delete]
            }
        }
        
        // Unsubscribe
        let leave = UITableViewRowAction(style: .Normal, title: "Leave") { [weak self] action, index in
            if let chat = ChannelManager.sharedInstance.channelForName(detailResponse.channelName) {
                chat.unSubscribeWithSuccess({ _ in
                    self?.detailResponses.removeAtIndex(index.row)
                    tableView.deleteRowsAtIndexPaths([index], withRowAnimation: .Fade)
                    }, failure: { error in
                        print(error)
                })
            }
        }
        leave.backgroundColor = UIColor.orangeColor()
        return [leave]
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 80.0
    }
    
    
    // MARK: - Helpers
    
    
    private func loadDetails() {
        // Get all channels the current user is subscribed to
        MMXChannel.subscribedChannelsWithSuccess({ [weak self] channels in
            ChannelManager.sharedInstance.channels = channels
            if channels.count > 0 {
                // Get details
                MMXChannel.channelDetails(channels, numberOfMessages: 10, numberOfSubcribers: 10, success: { detailResponses in
                    let sortedDetails = detailResponses.sort({ (detail1, detail2) -> Bool in
                        let formatter = ChannelManager.sharedInstance.formatter
                        return formatter.dateForStringTime(detail1.lastPublishedTime)?.timeIntervalSince1970 > formatter.dateForStringTime(detail2.lastPublishedTime)?.timeIntervalSince1970
                    })
                    
                    ChannelManager.sharedInstance.channelDetails = sortedDetails
                    self?.detailResponses = sortedDetails
                    self?.endRefreshing()
                    }, failure: { error in
                        self?.endRefreshing()
                        print(error)
                })
            } else {
                ChannelManager.sharedInstance.channelDetails?.removeAll()
            }
            }) { [weak self] error in
                self?.endRefreshing()
                print(error)
        }
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        let searchString = searchController.searchBar.text!.lowercaseString
        filteredDetailResponses = detailResponses.filter {
            for subscriber in $0.subscribers {
                let name = subscriber.displayName
                if name.lowercaseString.containsString(searchString.lowercaseString) || searchString.characters.count == 0 {
                    return true
                }
            }
            
            return false
        }
        
        tableView.reloadData()
    }
    
    private func endRefreshing() {
        refreshControl?.endRefreshing()
        tableView.reloadData()
    }
    
}

