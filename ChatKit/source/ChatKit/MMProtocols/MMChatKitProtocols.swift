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


//MARK: ContactsControllerDelegate


@objc public protocol ContactsControllerDelegate: class {
    optional func mmxContactsControllerDidFinish(with selectedUsers: [MMUser])
    optional func mmxContactsControllerSelectedUser(user: MMUser)
    optional func mmxContactsControllerUnSelectedUser(user: MMUser)
}


//MARK: Generic ControllerDatasource


@objc public protocol ControllerDatasource: class {
    func mmxControllerLoadMore(searchText : String?, offset : Int)
    func mmxControllerHasMore() -> Bool
    func mmxControllerSearchUpdatesContinuously() -> Bool
}


//MARK: ContactsControllerDatasource


@objc public protocol ContactsControllerDatasource: ControllerDatasource {
    optional func mmxContactsCellForUser(tableView : UITableView, user : MMUser, indexPath : NSIndexPath) -> UITableViewCell?
    optional func mmxContactsCellHeightForUser(user : MMUser, indexPath : NSIndexPath) -> CGFloat
    optional func mmxContactsControllerImageForUser(imageView : UIImageView, user : MMUser)
    optional func mmxContactsControllerShowsSectionIndexTitles() -> Bool
    optional func mmxContactsControllerShowsSectionsHeaders() -> Bool
    optional func mmxContactsControllerPreselectedUsers() -> [MMUser]
}


//MARK: ChannelListDatasource


@objc public protocol ChatListControllerDatasource : ControllerDatasource {
    
    optional func mmxListRegisterCells(tableView : UITableView)
    optional func mmxListCellForChannel(tableView : UITableView, channel : MMXChannel, channelDetails : MMXChannelDetailResponse, indexPath : NSIndexPath) -> UITableViewCell?
    optional func mmxListCellHeightForChannel(channel : MMXChannel, channelDetails : MMXChannelDetailResponse, indexPath : NSIndexPath) -> CGFloat
    optional func mmxListImageForChannelDetails(imageView : UIImageView, channelDetails : MMXChannelDetailResponse)
    optional func mmxListSortChannelDetails(channelDetails: [MMXChannelDetailResponse]) -> [MMXChannelDetailResponse]
}


//Mark: ChatListControllerDelegate


@objc public protocol ChatListControllerDelegate : class {
    func mmxListDidSelectChannel(channel : MMXChannel, channelDetails : MMXChannelDetailResponse)
    func mmxListCanLeaveChannel(channel : MMXChannel, channelDetails : MMXChannelDetailResponse) -> Bool
    
    optional func mmxListDidLeaveChannel(channel : MMXChannel, channelDetails : MMXChannelDetailResponse)
    optional func mmxListWillShowChatController(chatController : MMXChatViewController)
    optional func mmxListChannelForSubscribers(subscribers : [MMUser]) -> MMXChannel?
    optional func mmxListChannelForSubscribersWithBlock(subscribers : [MMUser], completionBlock : ((channel : MMXChannel) -> Void)) -> Void
}



//MARK: ChatViewControllerDelegate


public protocol ChatViewControllerDelegate {
    func mmxChatDidCreateChannel(channel : MMXChannel)
    func mmxChatDidSendMessage(message : MMXMessage)
    func mmxChatDidRecieveMessage(message : MMXMessage)
}
