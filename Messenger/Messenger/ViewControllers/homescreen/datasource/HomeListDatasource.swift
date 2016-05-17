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
import ChatKit


//MARK: datasource for first screen


class HomeListDatasource : DefaultChatListControllerDatasource {
    
    
    //MARK: Internal Variables
    
    
    var loadingGroup : dispatch_group_t = dispatch_group_create()
    var eventChannels : [MMXChannel] = []
    var askMagnet : MMXChannel?
    
    
    //MARK: custom overrides
    
    
    func mmxListShouldAppendNewChannel(channel: MMXChannel) -> Bool {
        return !channel.name.hasPrefix("global_") && !channel.name.hasPrefix(kAskMagnetChannel) && channel.numberOfMessages > 0
    }
    
    
    func mmxListSortChannelDetails(channelDetails: [MMXChannelDetailResponse]) -> [MMXChannelDetailResponse] {
        
        let eventChannels = channelDetails.filter({$0.channelName.hasPrefix("global_") && !$0.channelName.hasPrefix(kAskMagnetChannel)})
        let askMagnetChannel = channelDetails.filter({$0.channelName.hasPrefix(kAskMagnetChannel)}).first
        let otherChannels = channelDetails.filter({!$0.channelName.hasPrefix("global_") && !$0.channelName.hasPrefix(kAskMagnetChannel)})
        
        var results : [MMXChannelDetailResponse] = []
        
        if eventChannels.count > 0 {
            results.appendContentsOf(sort(eventChannels))
        }
        
        if let askMagnet = askMagnetChannel {
            results.append(askMagnet)
        }
        
        if otherChannels.count > 0 {
            results.appendContentsOf(sort(otherChannels))
        }
        
        return results
    }
    
    func sort(channelDetails: [MMXChannelDetailResponse]) -> [MMXChannelDetailResponse]  {
        return channelDetails.sort({ (detail1, detail2) -> Bool in
            let formatter = ChannelManager.sharedInstance.formatter
            return formatter.dateForStringTime(detail1.lastPublishedTime)?.timeIntervalSince1970 > formatter.dateForStringTime(detail2.lastPublishedTime)?.timeIntervalSince1970
        })
    }
    
    override func mmxListRegisterCells(tableView: UITableView) {
        let nib = UINib.init(nibName: "EventsTableViewCell", bundle: NSBundle(forClass: HomeListDatasource.self))
        tableView.registerNib(nib, forCellReuseIdentifier: "EventsTableViewCell")
        
        let nib2 = UINib.init(nibName: "AskMagnetTableViewCell", bundle: NSBundle(forClass: HomeListDatasource.self))
        tableView.registerNib(nib2, forCellReuseIdentifier: "AskMagnetTableViewCell")
    }
    
    func mmxListCellHeightForChannel(channel: MMXChannel, channelDetails: MMXChannelDetailResponse, indexPath: NSIndexPath) -> CGFloat {
        if channelDetails.channelName.hasPrefix("global_") {
            return 170.0
        }
        return 80.0
    }
    
    func mmxListCellForChannel(tableView: UITableView, channel: MMXChannel, channelDetails: MMXChannelDetailResponse, indexPath: NSIndexPath) -> UITableViewCell? {
        if channelDetails.channelName.hasPrefix("global_") {
            if let cell = tableView.dequeueReusableCellWithIdentifier("EventsTableViewCell", forIndexPath: indexPath) as? EventsTableViewCell {
                cell.eventImage?.backgroundColor = UIColor.whiteColor()
                cell.eventDescriptionLabel?.text = channelDetails.channel.summary
                cell.eventImage?.image = nil
                cell.eventSubtitleLabel?.text = "\(channelDetails.subscriberCount) subscribers"
                
                if let summary = channelDetails.channel.summary where summary.containsString("Week") {
                    cell.eventImage?.image = UIImage(named: "bg_img_1_2.png")
                }
                
                cell.detailResponse = channelDetails
                
                return cell
            }
        } else if let summary = channelDetails.channel.summary where summary.containsString("Ask Magnet") {
            if let cell = tableView.dequeueReusableCellWithIdentifier("AskMagnetTableViewCell", forIndexPath: indexPath) as? AskMagnetTableViewCell {
                cell.detailResponse = channelDetails
                
                return cell
            }
        }
        
        return nil
    }
    
    func mmxListDidCreateCell(cell : UITableViewCell) -> Void {
        if let listCell = cell as? ChatListCell {
            if let channel = listCell.detailResponse.channel {
                if (channel.isMuted) {
                   listCell.ivRightIcon?.image = UIImage(named: "speakerOff")
                } else {
                   listCell.ivRightIcon?.image = nil
                }
            }
        }
    }
    
    override func mmxControllerPrefersSoftResets() -> Bool {
        return true
    }
    
    func loadAskMagnetChannel() {
        
        guard !Utils.isMagnetEmployee() else {
            return
        }
        
        dispatch_group_enter(self.loadingGroup)
        MMXChannel.channelForName(kAskMagnetChannel, isPublic: false, success: { channel in
            self.askMagnet = channel
            dispatch_group_leave(self.loadingGroup)
            }, failure: { error in
                // Since channel is not found, attempt to create it
                // Magnet Employees will have the magnetsupport tag
                // Subscribe all Magnet employees
                MMUser.searchUsers("tags:\(kMagnetSupportTag)", limit: 50, offset: 0, sort: "firstName:asc", success: { users in
                    let summary: String
                    if let userName = MMUser.currentUser()?.userName {
                        summary = "Ask Magnet for \(userName)"
                    } else {
                        // We should never be here!
                        summary = "Ask Magnet for anonymous"
                    }
                    print("Sumary \(summary)")
                    MMXChannel.createWithName(kAskMagnetChannel, summary: summary, isPublic: false, publishPermissions: .Subscribers, subscribers: Set(users), success: { channel in
                        self.askMagnet = channel
                        dispatch_group_leave(self.loadingGroup)
                        }, failure: { error in
                            print("[ERROR]: \(error.localizedDescription)")
                            dispatch_group_leave(self.loadingGroup)
                    })
                    }, failure: { error in
                        print("[ERROR]: \(error.localizedDescription)")
                        dispatch_group_leave(self.loadingGroup)
                })
        })
    }
    
    func loadEventChannels() {
        dispatch_group_enter(self.loadingGroup)
        MMXChannel.findByTags( Set(["active"]), limit: 5, offset: 0, success: { total, channels in
            if channels.count > 0 {
                let lock = NSLock()
                self.eventChannels = []
                for  channel in channels {
                    
                    guard !channel.isSubscribed else {
                        self.eventChannels.append(channel)
                        continue
                    }
                    
                    dispatch_group_enter(self.loadingGroup)
                    channel.subscribeWithSuccess({
                        print("Subscribed - \(channel.name)")
                        lock.lock()
                        self.eventChannels.append(channel)
                        lock.unlock()
                        
                        dispatch_group_leave(self.loadingGroup)
                        }, failure: { (error) -> Void in
                            print("subscribe global error \(error)")
                            dispatch_group_leave(self.loadingGroup)
                    })
                }
            }
            dispatch_group_leave(self.loadingGroup)
        }) { (error) -> Void in
            dispatch_group_leave(self.loadingGroup)
        }
    }
    
    override func subscribedChannels(completion : ((channels : [MMXChannel]) -> Void)) {
        let op = MMXChannel.subscriptionsWithSuccess({ ch in
            var cV = ch.filter({ return !$0.name.hasPrefix("global_") && !$0.name.hasPrefix(kAskMagnetChannel) && $0.numberOfMessages > 0})
            cV = self.sortChannelsByDate(cV)
            if let ask = self.askMagnet {
                cV.insert(ask, atIndex: 0)
            }
            cV.insertContentsOf(self.eventChannels, at: 0)
            completion(channels: cV)
        }) { error in
            print(error)
            var array : [MMXChannel] = []
            if let ask = self.askMagnet {
                array.insert(ask, atIndex: 0)
            }
            array.insertContentsOf(self.eventChannels, at: 0)
            completion(channels: array)
        }//?.cancel()
        OperationQueue().addOperation(op!)
    }
    
    override func mmxControllerLoadMore(searchText: String?, offset: Int) {
        if offset == 0 {
            self.askMagnet = nil
            self.eventChannels = []
            self.loadEventChannels()
            
        }
        if self.askMagnet == nil {
            self.loadAskMagnetChannel()
        }
        
        let loadingContext = self.controller?.loadingContext()
        dispatch_group_notify(loadingGroup, dispatch_get_main_queue(),{
            if loadingContext != self.controller?.loadingContext() {
                return
            }
            self.hasMoreUsers = offset == 0 ? true : self.hasMoreUsers
            //get request context
            
            self.subscribedChannels({ channels in
                if loadingContext != self.controller?.loadingContext() {
                    return
                }
                var offsetChannels : [MMXChannel] = []
                
                if offset < channels.count && channels.count > 0 {
                    offsetChannels = Array(channels[offset..<min((offset + self.limit), channels.count)])
                }
                
                self.hasMoreUsers = offset + self.limit < channels.count - 1
                self.controller?.append(offsetChannels)
            })
        })
    }
    
    override func mmxControllerSearchUpdatesContinuously() -> Bool {
        return false
    }
}