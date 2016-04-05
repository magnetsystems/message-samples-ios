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


class AskMagnetDatasource : DefaultChatListControllerDatasource {
    
    func mmxListShouldAppendNewChannel(channel: MMXChannel) -> Bool {
        return isAskMagnetChannel(channel)
    }
    
    func isAskMagnetChannel(channel : MMXChannel) -> Bool {
        return channel.name.hasPrefix(kAskMagnetChannel) && channel.ownerUserID != MMUser.currentUser()?.userID
    }
    
    func mmxListCellForChannel(tableView: UITableView, channel: MMXChannel, channelDetails: MMXChannelDetailResponse, indexPath: NSIndexPath) -> UITableViewCell? {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("ChatListCell", forIndexPath: indexPath) as! ChatListCell
        cell.detailResponse = channelDetails
        if let imageView = cell.avatarView {
            self.mmxListImageForChannelDetails(imageView, channelDetails: channelDetails)
        }
        let subscribers : [MMUserProfile] = channelDetails.subscribers.filter({ $0.userId == channel.ownerUserID })
        cell.lblSubscribers?.text = subscribers.first?.displayName
        
        return cell
    }
    
    func mmxListSortChannelDetails(channelDetails: [MMXChannelDetailResponse]) -> [MMXChannelDetailResponse] {
        return channelDetails.sort({ (detail1, detail2) -> Bool in
            let formatter = ChannelManager.sharedInstance.formatter
            return formatter.dateForStringTime(detail1.lastPublishedTime)?.timeIntervalSince1970 > formatter.dateForStringTime(detail2.lastPublishedTime)?.timeIntervalSince1970
        })
    }
    
    override func subscribedChannels(completion : ((channels : [MMXChannel]) -> Void)) {
        MMXChannel.subscribedChannelsWithSuccess({ ch in
            var cV : [MMXChannel] = ch.filter({ return self.isAskMagnetChannel($0) && $0.numberOfMessages > 0})
            cV = self.sortChannelsByDate(cV)
            completion(channels: cV)
        }) { error in
            print(error)
            completion(channels: [])
        }
    }
}