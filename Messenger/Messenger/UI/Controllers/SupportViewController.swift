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

import MagnetMax
import UIKit

class SupportViewController: UITableViewController {
    
    static let pageSize = 20
    
    //MARK: Public properties
    
    
    var supportChannels: [MMXChannel] = [];
    var supportChannelDetails: [MMXChannelDetailResponse] = [];
    var users = Set<MMUser>()
    var page = 1
    
    
    //MARK: Overrides
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        if let revealVC = self.revealViewController() {
            self.view.addGestureRecognizer(revealVC.panGestureRecognizer())
            self.view.addGestureRecognizer(revealVC.tapGestureRecognizer())
        }
        
        tableView.registerNib(UINib(nibName: Utils.name(SupportTableViewCell.classForCoder()), bundle: nil), forCellReuseIdentifier: Utils.name(SupportTableViewCell.classForCoder()))
        
        loadDetails(true)
        
        ChannelManager.sharedInstance.addChannelMessageObserver(self, channel:nil, selector: "didReceiveMessage:")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationItem.title = kStr_Support;
//        ChannelManager.sharedInstance.addChannelMessageObserver(self, channel:nil, selector: "didReceiveMessage:")
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
//        ChannelManager.sharedInstance.removeChannelMessageObserver(self)
    }
    
    deinit {
        ChannelManager.sharedInstance.removeChannelMessageObserver(self)
    }
    
    
    //MARK: - Notifications
    
    
    func didReceiveMessage(mmxMessage: MMXMessage) {
        
        if let chat = mmxMessage.channel where mmxMessage.messageType == .Channel && chat.name == kAskMagnetChannel {
            
            if let chatDetailResponse = channelDetailResponseForChannel(chat) {
                supportChannelDetails = supportChannelDetails.sort({ (detail1, detail2) -> Bool in
                    let formatter = ChannelManager.sharedInstance.formatter
                    return formatter.dateForStringTime(detail1.lastPublishedTime)?.timeIntervalSince1970 > formatter.dateForStringTime(detail2.lastPublishedTime)?.timeIntervalSince1970
                })
                chatDetailResponse.messages = [mmxMessage]
                chatDetailResponse.lastPublishedTime = ChannelManager.sharedInstance.formatter.stringFromDate(chat.lastTimeActive)
                
                tableView.reloadData()
                
            } else {
                MMXChannel.channelDetails([chat], numberOfMessages: 1, numberOfSubcribers: 20, success: { [weak self] details in
                    if details.count == 1 {
                        self?.supportChannels.insert(chat, atIndex: 0)
                        self?.supportChannelDetails.insert(details.first!, atIndex: 0)
                        self?.tableView.reloadData()
                    }
                    }, failure: { error in
                        //
                })
            }
        }
    }
    
    
    //MARK: - TableView Delegate
    
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return supportChannelDetails.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Utils.name(SupportTableViewCell.classForCoder()), forIndexPath: indexPath) as! SupportTableViewCell
        cell.detailResponse = supportChannelDetails[indexPath.row]
        if let user = userForChannelDetail(supportChannelDetails[indexPath.row]) {
            cell.lblAsker.text = "\(user.firstName ?? "") \(user.lastName ?? "")"

            let placeHolderImage = Utils.noAvatarImageForUser(user)
            
            if let avatarImage = cell.ivAvatarImage {
                Utils.loadImageWithUrl(user.avatarURL(), toImageView: avatarImage, placeholderImage: placeHolderImage)
            }
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if let chatVC = self.storyboard?.instantiateViewControllerWithIdentifier(vc_id_Chat) as? ChatViewController,let cell = tableView.cellForRowAtIndexPath(indexPath) as? SupportTableViewCell {
            chatVC.chat = cell.detailResponse.channel
            chatVC.delegate = self
            self.navigationController?.pushViewController(chatVC, animated: true)
        }
    }
    
    
    //MARK: Actions
    
    
    @IBAction func refreshChannelDetail() {
        loadDetails(true)
    }
    
    @IBAction func showSideMenu(sender: UIBarButtonItem) {
        self.revealViewController().revealToggleAnimated(true)
    }
    
    
    //MARK: - Private Methods
    
    
    private func endRefreshing() {
        refreshControl?.endRefreshing()
        tableView.reloadData()
    }
    
    private func channelDetailResponseForChannel(channel: MMXChannel) -> MMXChannelDetailResponse? {
        var chatDetailResponse: MMXChannelDetailResponse? = nil
        
        if let indexOfChat = supportChannelDetails.indexOf ({ detailResponse in
            detailResponse.channel == channel
        }) {
            chatDetailResponse = supportChannelDetails[indexOfChat]
        }
        
        return chatDetailResponse
    }

    
    private func loadDetails(shouldResetResults: Bool) {
        if shouldResetResults {
            supportChannelDetails.removeAll()
            page = 1
        } else {
            page++
        }
        
        // Get all Ask Magnet channels with > 0 messages, sorted by publish date desc
        
        refreshControl?.beginRefreshing()
        
        MMXChannel.subscribedChannelsWithSuccess({ [weak self] allChannels in
            let channels = allChannels.filter({ $0.name == kAskMagnetChannel && $0.numberOfMessages != 0 }).sort { $0.lastTimeActive.timeIntervalSince1970 > $1.lastTimeActive.timeIntervalSince1970 }
            self?.supportChannels = channels
            if channels.count > 0 {
                guard let page = self?.page, pageSize = self?.dynamicType.pageSize else {
                    fatalError("page should be set here!")
                }
                let paginatedChannels = Array(channels[((page - 1) * pageSize)..<(min(page * pageSize, channels.count))])
                
                let IDs = (paginatedChannels as NSArray).valueForKey("ownerUserID") as! [String]
                MMUser.usersWithUserIDs(IDs, success: { [weak self] users in
                    self?.users.unionInPlace(users)
                    
                    MMXChannel.channelDetails(paginatedChannels, numberOfMessages: 1, numberOfSubcribers: 3, success: { detailResponses in
                        
                        let sortedDetails = detailResponses.sort({ (detail1, detail2) -> Bool in
                            let formatter = ChannelManager.sharedInstance.formatter
                            return formatter.dateForStringTime(detail1.lastPublishedTime)?.timeIntervalSince1970 > formatter.dateForStringTime(detail2.lastPublishedTime)?.timeIntervalSince1970
                        })
                        
                        self?.supportChannelDetails.appendContentsOf(sortedDetails)
                        self?.endRefreshing()
                        
                        self?.tableView.removeInfiniteScroll()
                        if self?.supportChannelDetails.count < self?.supportChannels.count {
                            // Add infinite scroll handler
                            self?.tableView.addInfiniteScrollWithHandler { scrollView in
                                let tableView = scrollView as! UITableView
                                
                                //
                                // fetch your data here, can be async operation,
                                // just make sure to call finishInfiniteScroll in the end
                                //
                                self?.loadDetails(false)
                                
                                // make sure you reload tableView before calling -finishInfiniteScroll
                                tableView.reloadData()
                                
                                // finish infinite scroll animation
                                tableView.finishInfiniteScroll()
                            }
                        }
                        
                    }, failure: { error in
                        print("[ERROR]: \(error)")
                        self?.endRefreshing()
                    })
                }) { (error) -> Void in
                    print("[ERROR]: \(error)")
                    self?.endRefreshing()
                }
            }
            }) { [weak self] error in
                print("[ERROR]: \(error)")
                self?.endRefreshing()
        }
    }
    
    private func userForChannelDetail(detail: MMXChannelDetailResponse) -> MMUser? {
        
        var user: MMUser?
        for usr in users {
            if usr.userID == detail.channel.ownerUserID {
                user = usr
            }
        }
        
        return user
    }
    
}

extension SupportViewController: ChatViewControllerDelegate {
    
    // MARK: - ChatViewControllerDelegate
    
    func chatViewControllerDidFinish(with chat: MMXChannel, lastMessage: MMXMessage?, date: NSDate?) {
        tableView.reloadData()
    }
}

