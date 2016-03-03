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


public class HomeViewController: MMTableViewController, UISearchResultsUpdating {
    
    
    //MARK: Internal Variables
    
    
    internal var detailResponses : [MMXChannelDetailResponse] = []
    internal var filteredDetailResponses : [MMXChannelDetailResponse] = []
    internal let searchController = UISearchController(searchResultsController: nil)
    
    
    //MARK: Overrides
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override public func loadView() {
        super.loadView()
        let nib = UINib.init(nibName: "HomeViewController", bundle: NSBundle(forClass: self.dynamicType))
        nib.instantiateWithOwner(self, options: nil)
    }
    
    override public func viewDidLoad() {
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
        registerCells(self.tableView)
        
        refreshControl?.addTarget(self, action: "refreshChannelDetail", forControlEvents: .ValueChanged)
    }
    
    override public func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        loadDetails()
        ChannelManager.sharedInstance.addChannelMessageObserver(self, channel:nil, selector: "didReceiveMessage:")
    }
    
    override public func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        ChannelManager.sharedInstance.removeChannelMessageObserver(self)
    }
    
    
    // MARK: Public Methods
    
    
    public func registerCells(tableView: UITableView) { }
    
    public func canLeaveChannel(channel : MMXChannel, channelDetails : MMXChannelDetailResponse) -> Bool {
        return true
    }
    
    public func cellForMMXChannel(tableView: UITableView, channel : MMXChannel, channelDetails : MMXChannelDetailResponse, row : Int) -> UITableViewCell? {
        return nil
    }
    
    public func cellHeightForChannel(channel : MMXChannel, channelDetails : MMXChannelDetailResponse, row : Int) -> CGFloat {
        return 80
    }
    
    public func loadChannels(channelBlock : ((channels :[MMXChannel]) -> Void)) {}
    
    public func onChannelDidLeave(channel : MMXChannel, channelDetails : MMXChannelDetailResponse) { }
    
    public func onChannelDidSelect(channel : MMXChannel, channelDetails : MMXChannelDetailResponse) { }
    
    
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
    
    
    //MARK: Search Controller Delegate
    
    
    public func updateSearchResultsForSearchController(searchController: UISearchController) {
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


public extension HomeViewController {
    // MARK: - Table view data source
    
    
    override public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.active {
            return filteredDetailResponses.count
        }
        return detailResponses.count
    }
    
    override public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let detailResponse = detailsForIndexPath(indexPath)
        
        if let cell : UITableViewCell = cellForMMXChannel(tableView,channel :detailResponse.channel, channelDetails : detailResponse, row : indexPath.row) {
            return cell
        }
        let cell = tableView.dequeueReusableCellWithIdentifier("SummaryResponseCell", forIndexPath: indexPath) as! SummaryResponseCell
        cell.detailResponse = detailResponse
        
        return cell
    }
    
    public func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return canLeaveChannel(detailsForIndexPath(indexPath).channel, channelDetails : detailsForIndexPath(indexPath))
    }
    
    public func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let detailResponse = detailsForIndexPath(indexPath)
        
        let leave = UITableViewRowAction(style: .Normal, title: "Leave") { [weak self] action, index in
            if let chat = detailResponse.channel {
                chat.unSubscribeWithSuccess({ _ in
                    self?.detailResponses.removeAtIndex(index.row)
                    tableView.deleteRowsAtIndexPaths([index], withRowAnimation: .Fade)
                    self?.onChannelDidLeave(detailResponse.channel, channelDetails : detailResponse)
                    self?.endRefreshing()
                    }, failure: { error in
                        print(error)
                })
            }
        }
        leave.backgroundColor = UIColor.orangeColor()
        return [leave]
    }
    
    public func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    public func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return cellHeightForChannel(detailsForIndexPath(indexPath).channel, channelDetails : detailsForIndexPath(indexPath), row : indexPath.row)
    }
    
    public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        onChannelDidSelect(detailsForIndexPath(indexPath).channel, channelDetails : detailsForIndexPath(indexPath))
    }
}


private extension HomeViewController {
    
    
    // MARK: - Private Methods
    
    
    private func detailsForIndexPath(indexPath : NSIndexPath) -> MMXChannelDetailResponse {
        return searchController.active ? filteredDetailResponses[indexPath.row] : detailResponses[indexPath.row]
    }
    
    private func endRefreshing() {
        refreshControl?.endRefreshing()
        tableView.reloadData()
    }
    
    private func loadDetails() {
        loadChannels({ channels in
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
    
}

