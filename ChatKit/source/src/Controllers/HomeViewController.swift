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


public class HomeViewController: MMTableViewController, UISearchBarDelegate {
    
    
    //MARK: Public Variables
    
    
    public var canSearch : Bool? {
        didSet {
            updateSearchBar()
        }
    }
    
    public private(set) var searchBar = UISearchBar()
    
    
    //MARK: Internal Variables
    
    
    internal var currentDetailCount = 0
    internal var detailResponses : [MMXChannelDetailResponse] = []
    
    
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
        
        var nib = UINib.init(nibName: "SummaryResponseCell", bundle: NSBundle(forClass: self.dynamicType))
        self.tableView.registerNib(nib, forCellReuseIdentifier: "SummaryResponseCell")
        nib = UINib.init(nibName: "LoadingCell", bundle: NSBundle(forClass: self.dynamicType))
        self.tableView.registerNib(nib, forCellReuseIdentifier: "LoadingCellIdentifier")
        
        // Add search bar
        searchBar.sizeToFit()
        searchBar.returnKeyType = .Search
        if self.shouldUpdateSearchContinuously() {
            searchBar.returnKeyType = .Done
        }
        searchBar.setShowsCancelButton(false, animated: false)
        searchBar.delegate = self
        tableView.tableHeaderView = searchBar
        self.tableView.layer.masksToBounds = true
        if self.canSearch == nil {
            self.canSearch = true
        }
        
        registerCells(self.tableView)
        ChannelManager.sharedInstance.addChannelMessageObserver(self, channel:nil, selector: "didReceiveMessage:")
        refreshControl?.addTarget(self, action: "refreshChannelDetail", forControlEvents: .ValueChanged)
        
        infiniteLoading.onUpdate() { [weak self] in
            if let weakSelf = self {
                weakSelf.loadMore(weakSelf.searchBar.text, offset: weakSelf.currentDetailCount)
            }
        }
    }
    
    override public func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override public func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        resignSearchBar()
    }
    
    
    // MARK: Public Methods
    
    
    public func appendChannels(mmxChannels : [MMXChannel]) {
        if mmxChannels.count > 0 {
            self.beginRefreshing()
            // Get all channels the current user is subscribed to
            MMXChannel.channelDetails(mmxChannels, numberOfMessages: 10, numberOfSubcribers: 10, success: { detailResponses in
                self.currentDetailCount += mmxChannels.count
                self.detailResponses.appendContentsOf(detailResponses)
                self.detailResponses = self.sortChannelDetails(self.detailResponses)
                self.endDataLoad()
                }, failure: { error in
                    self.endDataLoad()
                    print(error)
            })
        } else {
            self.endDataLoad()
        }
    }
    
    public func canLeaveChannel(channel : MMXChannel, channelDetails : MMXChannelDetailResponse) -> Bool {
        return true
    }
    
    public func cellForMMXChannel(tableView: UITableView, channel : MMXChannel, channelDetails : MMXChannelDetailResponse, row : Int) -> UITableViewCell? {
        return nil
    }
    
    public func cellHeightForChannel(channel : MMXChannel, channelDetails : MMXChannelDetailResponse, row : Int) -> CGFloat {
        return 80
    }
    
    public func imageForChannelDetails(imageView : UIImageView, channelDetails : MMXChannelDetailResponse) {
        imageView.image = nil
    }
    
    public func hasMore()->Bool {
        return false
    }
    
    public func loadMore(searchText : String?, offset : Int) { }
    
    public func onChannelDidLeave(channel : MMXChannel, channelDetails : MMXChannelDetailResponse) { }
    
    public func onChannelDidSelect(channel : MMXChannel, channelDetails : MMXChannelDetailResponse) { }
    
    public func registerCells(tableView: UITableView) { }
    
    public func reset() {
        self.detailResponses = []
        self.currentDetailCount = 0
        self.loadMore(self.searchBar.text, offset: self.currentDetailCount)
    }
    
    public func shouldUpdateSearchContinuously() -> Bool {
        return true
    }
    
    public func sortChannelDetails(channelDetails : [MMXChannelDetailResponse]) -> [MMXChannelDetailResponse] {
        return detailsOrderByDate(channelDetails)
    }
    
    
    //MARK: Notifications
    
    
    func didReceiveMessage(mmxMessage: MMXMessage) {
        if let channel = mmxMessage.channel {
            var hasChannel = false
            for var i = 0; i < detailResponses.count; i++ {
                let details = detailResponses[i]
                if details.channel.channelID == channel.channelID {
                    hasChannel = true
                    let channelID = details.channel.channelID
                    MMXChannel.channelDetails([channel], numberOfMessages: 10, numberOfSubcribers: 10, success: { responses in
                        if let channelDetail = responses.first {
                            let oldChannelDetail = self.detailResponses[i]
                            if channelDetail.channel.channelID == channelID && oldChannelDetail.channel.channelID ==  channelID {
                                self.detailResponses.removeAtIndex(i)
                                self.detailResponses.insert(channelDetail, atIndex: i)
                                self.detailResponses = self.sortChannelDetails(self.detailResponses)
                            }
                        }
                        self.tableView.reloadData()
                        }, failure: { (error) -> Void in
                            //Error
                    })
                    break
                }
            }
            
            if !hasChannel {
                self.appendChannels([channel])
            }
        }
    }
    
    
    //MARK: Actions
    
    
    @IBAction func refreshChannelDetail() {
        reset()
    }
    
    
    // MARK: - Notification handler
    
    
    private func didDisconnect(notification: NSNotification) {
        MMX.stop()
    }
    
    
    // MARK: - UISearchResultsUpdating
    
    
    public func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }
    
    public func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchBar.setShowsCancelButton(false, animated: true)
    }
    
    public func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.characters.count == 0 {
            self.search("")
            return
        }
        
        if self.shouldUpdateSearchContinuously() {
            self.search(searchText)
        }
    }
    
    public func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchBar.setShowsCancelButton(false, animated: true)
        self.search(searchBar.text)
    }
    
}



public extension HomeViewController {
    
    
    // MARK: - Table view data source
    
    
    public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        let sections = 1 + (infiniteLoading.isFinished ? 0 : 1)
        
        return sections
    }
    
    override public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isLastSection(section) && !infiniteLoading.isFinished {
            return 1
        }
        return detailResponses.count
    }
    
    override public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if !infiniteLoading.isFinished && isLastSection(indexPath.section) {
            var cell = tableView.dequeueReusableCellWithIdentifier("LoadingCellIdentifier") as! LoadingCell?
            if cell == nil {
                cell = LoadingCell(style: .Default, reuseIdentifier: "LoadingCellIdentifier")
            }
            cell?.indicator?.startAnimating()
            return cell!
        }
        
        if (isWithinLoadingBoundary()) {
            infiniteLoading.setNeedsUpdate()
        }
        
        let detailResponse = detailsForIndexPath(indexPath)
        if let cell : UITableViewCell = cellForMMXChannel(tableView,channel :detailResponse.channel, channelDetails : detailResponse, row : indexPath.row) {
            return cell
        }
        let cell = tableView.dequeueReusableCellWithIdentifier("SummaryResponseCell", forIndexPath: indexPath) as! SummaryResponseCell
        cell.detailResponse = detailResponse
        
        if let imageView = cell.avatarView {
            imageForChannelDetails(imageView, channelDetails: detailResponse)
        }
        
        return cell
    }
    
    public func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if isLastSection(indexPath.section) && !infiniteLoading.isFinished {
            return false
        }
        return canLeaveChannel(detailsForIndexPath(indexPath).channel, channelDetails : detailsForIndexPath(indexPath))
    }
    
    public func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        if isLastSection(indexPath.section) && !infiniteLoading.isFinished {
            return nil
        }
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
        if isLastSection(indexPath.section) && !infiniteLoading.isFinished {
            return
        }
        
        //TODO: Handle action
    }
    
    public func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if isLastSection(indexPath.section) && !infiniteLoading.isFinished {
            return 80
        }
        
        return cellHeightForChannel(detailsForIndexPath(indexPath).channel, channelDetails : detailsForIndexPath(indexPath), row : indexPath.row)
    }
    
    public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if isLastSection(indexPath.section) && !infiniteLoading.isFinished {
            return
        }
        onChannelDidSelect(detailsForIndexPath(indexPath).channel, channelDetails : detailsForIndexPath(indexPath))
    }
    
    public override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        if searchBar.isFirstResponder() {
            searchBar.resignFirstResponder()
        }
    }
}


private extension HomeViewController {
    
    
    // MARK: - Private Methods
    
    
    private func beginRefreshing() {
        self.refreshControl?.beginRefreshing()
    }
    
    private func detailsForIndexPath(indexPath : NSIndexPath) -> MMXChannelDetailResponse {
        return  detailResponses[indexPath.row]
    }
    
    private func detailsOrderByDate(channelDetails : [MMXChannelDetailResponse]) -> [MMXChannelDetailResponse] {
        let sortedDetails = channelDetails.sort({ (detail1, detail2) -> Bool in
            let formatter = ChannelManager.sharedInstance.formatter
            return formatter.dateForStringTime(detail1.lastPublishedTime)?.timeIntervalSince1970 > formatter.dateForStringTime(detail2.lastPublishedTime)?.timeIntervalSince1970
        })
        return sortedDetails
    }
    
    private func endDataLoad() {
        if !self.hasMore() {
            infiniteLoading.stopUpdating()
        } else {
            infiniteLoading.startUpdating()
        }
        
        infiniteLoading.finishUpdating()
        self.endRefreshing()
    }
    
    private func endRefreshing() {
        refreshControl?.endRefreshing()
        tableView.reloadData()
    }
    
    private func resignSearchBar() {
        if searchBar.isFirstResponder() {
            searchBar.resignFirstResponder()
        }
        searchBar.setShowsCancelButton(false, animated: true)
    }
    
    private func search(searchString : String?) {
        var text : String? = searchString?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        if let txt = text where txt.characters.count == 0 {
            text = nil
        }
        self.reset()
    }
    
    private func updateSearchBar() {
        if let canSearch = self.canSearch where canSearch == true {
            tableView.tableHeaderView = searchBar
        } else {
            tableView.tableHeaderView = nil
        }
    }
}

