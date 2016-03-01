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

@objc protocol HomeViewControllerDatasource: class {
    func homeViewLoadChannels(channels : (([MMXChannel]) ->Void))
    
    optional func homeViewRegisterCells(tableView : UITableView)
    optional func homeViewCellForMMXChannel(tableView : UITableView, channel : MMXChannel, channelDetails : MMXChannelDetailResponse, row : Int) -> UITableViewCell?
    optional func homeViewCellHeightForMMXChannel(channel : MMXChannel, row : Int) -> CGFloat
}

@objc  protocol HomeViewControllerDelegate: class {
    func homeViewDidSelectChannel(channel : MMXChannel, channelDetails : MMXChannelDetailResponse)
    func homeViewCanLeaveChannel(channel : MMXChannel, channelDetails : MMXChannelDetailResponse) -> Bool
    optional func homeViewDidLeaveChannel(channel : MMXChannel, channelDetails : MMXChannelDetailResponse)
}

class HomeViewController: UITableViewController, UISearchResultsUpdating {
    
    
    //MARK: Public Variables
    
    
    var datasource : HomeViewControllerDatasource?
    var delegate : HomeViewControllerDelegate?
    var detailResponses : [MMXChannelDetailResponse] = []
    var filteredDetailResponses : [MMXChannelDetailResponse] = []
    let searchController = UISearchController(searchResultsController: nil)
    
    
    //MARK: Overrides
    
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
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
        self.datasource?.homeViewRegisterCells?(self.tableView)
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
    
    
    //MARK: Notifications
    
    
    func didReceiveMessage(mmxMessage: MMXMessage) {
        loadDetails()
    }
    
    
    //MARK: Actions
    
    
    @IBAction func refreshChannelDetail() {
        loadDetails()
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
        let detailResponse = detailsForIndexPath(indexPath)
        
        if let cell : UITableViewCell = self.datasource?.homeViewCellForMMXChannel?(tableView,channel :detailResponse.channel, channelDetails : detailResponse, row : indexPath.row) {
            return cell
        }
        let cell = tableView.dequeueReusableCellWithIdentifier("SummaryResponseCell", forIndexPath: indexPath) as! SummaryResponseCell
        cell.detailResponse = detailResponse
        
        return cell
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if let canLeave = self.delegate?.homeViewCanLeaveChannel(detailsForIndexPath(indexPath).channel, channelDetails : detailsForIndexPath(indexPath)) {
            return canLeave
        }
        return true
    }
    
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let detailResponse = detailsForIndexPath(indexPath)
        
        let leave = UITableViewRowAction(style: .Normal, title: "Leave") { [weak self] action, index in
            if let chat = detailResponse.channel {
                chat.unSubscribeWithSuccess({ _ in
                    self?.detailResponses.removeAtIndex(index.row)
                    tableView.deleteRowsAtIndexPaths([index], withRowAnimation: .Fade)
                    self?.delegate?.homeViewDidLeaveChannel?(detailResponse.channel, channelDetails : detailResponse)
                    self?.endRefreshing()
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
        if let height = self.datasource?.homeViewCellHeightForMMXChannel?(detailsForIndexPath(indexPath).channel, row : indexPath.row) {
            return height
        }
        return 80.0
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.delegate?.homeViewDidSelectChannel(detailsForIndexPath(indexPath).channel, channelDetails : detailsForIndexPath(indexPath))
    }
    
    
    // MARK: - Private Methods
    
    
    private func detailsForIndexPath(indexPath : NSIndexPath) -> MMXChannelDetailResponse {
        return searchController.active ? filteredDetailResponses[indexPath.row] : detailResponses[indexPath.row]
    }
    
    private func endRefreshing() {
        refreshControl?.endRefreshing()
        tableView.reloadData()
    }
    
    private func loadDetails() {
        self.datasource?.homeViewLoadChannels({ channels in
            if channels.count > 0 {
                // Get all channels the current user is subscribed to
                MMXChannel.channelDetails(channels, numberOfMessages: 10, numberOfSubcribers: 10, success: { detailResponses in
                    let sortedDetails = detailResponses.sort({ (detail1, detail2) -> Bool in
                        let formatter = ChannelManager.sharedInstance.formatter
                        return formatter.dateForStringTime(detail1.lastPublishedTime)?.timeIntervalSince1970 > formatter.dateForStringTime(detail2.lastPublishedTime)?.timeIntervalSince1970
                    })
                    self.detailResponses = sortedDetails
                    self.endRefreshing()
                    }, failure: { error in
                        self.endRefreshing()
                        print(error)
                })
            } else {
                
            }
        })
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
    
}

