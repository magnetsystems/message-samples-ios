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


//MARK: MMXAvatarDelegate


@objc public protocol MMXAvatarDelegate: class {
    
    
    optional func mmxAvatarDidClick(user : MMUser)
    
    
}


//MARK: ContactsControllerDelegate


@objc public protocol ContactsControllerDelegate: class, MMXAvatarDelegate {
    
    
    optional func mmxContactsCanSelectUser(user: MMUser) -> Bool
    optional func mmxContactsControllerDidFinish(with selectedUsers: [MMUser])
    optional func mmxContactsControllerSelectedUser(user: MMUser)
    optional func mmxContactsControllerUnSelectedUser(user: MMUser)
    
    
}


//MARK: Generic ControllerDatasource


@objc public protocol ControllerDatasource: class {
    
    
    func mmxControllerHasMore() -> Bool
    func mmxControllerLoadMore(searchText : String?, offset : Int)
    optional func mmxControllerPrefersSoftResets() -> Bool
    func mmxControllerSearchUpdatesContinuously() -> Bool
    
    
}


//MARK: ContactsControllerDatasource


@objc public protocol ContactsControllerDatasource: ControllerDatasource, MMTableViewFooterDatasource {
    
    
    optional func mmxContactsCellForUser(tableView : UITableView, user : MMUser, indexPath : NSIndexPath) -> UITableViewCell?
    optional func mmxContactsCellHeightForUser(user : MMUser, indexPath : NSIndexPath) -> CGFloat
    optional func mmxContactsControllerImageForUser(imageView : UIImageView, user : MMUser)
    optional func mmxContactsDidCreateCell(cell : UITableViewCell) -> Void
    optional func mmxContactsControllerRegisterCells(tableView : UITableView)
    optional func mmxContactsControllerShowsSectionIndexTitles() -> Bool
    optional func mmxContactsControllerShowsSectionsHeaders() -> Bool
    optional func mmxContactsControllerPreselectedUsers() -> [MMUser]
    
}


//Mark: MMTableViewFooterDatasource


@objc public protocol MMTableViewFooterDatasource {
    
    
    optional func mmxTableViewFooter(index : Int) -> UIView
    optional func mmxTableViewFooterHeight(index : Int) -> CGFloat
    optional func mmxTableViewNumberOfFooters() -> Int
    
    
}


//MARK: ChannelListDatasource


@objc public protocol ChatListControllerDatasource : ControllerDatasource, MMTableViewFooterDatasource {
    
    optional func mmxListCellForChannel(tableView : UITableView, channel : MMXChannel, channelDetails : MMXChannelDetailResponse, indexPath : NSIndexPath) -> UITableViewCell?
    optional func mmxListDidCreateCell(cell : UITableViewCell) -> Void
    optional func mmxListDidLoadChannelDetails(channelDetails : [MMXChannelDetailResponse], offset : Int) -> Void
    optional func mmxListCellHeightForChannel(channel : MMXChannel, channelDetails : MMXChannelDetailResponse, indexPath : NSIndexPath) -> CGFloat
    optional func mmxListFilterChannelDetails(channelDetails: [MMXChannelDetailResponse]) -> [MMXChannelDetailResponse]
    optional func mmxListImageForChannelDetails(imageView : UIImageView, channelDetails : MMXChannelDetailResponse)
    optional func mmxListRegisterCells(tableView : UITableView)
    optional func mmxListSortChannelDetails(channelDetails: [MMXChannelDetailResponse]) -> [MMXChannelDetailResponse]
    optional func mmxListShouldAppendNewChannel(channel : MMXChannel) -> Bool
    
    
}


//Mark: ChatListControllerDelegate


@objc public protocol ChatListControllerDelegate : class, MMXAvatarDelegate {
    
    
    func mmxListDidSelectChannel(channel : MMXChannel, channelDetails : MMXChannelDetailResponse)
    func mmxListCanEditChannel(channel : MMXChannel, channelDetails : MMXChannelDetailResponse) -> Bool
    
    optional func mmxListChannelEditActions(channel : MMXChannel, channelDetails : MMXChannelDetailResponse) -> [UITableViewRowAction]?
    optional func mmxListDidLeaveChannel(channel : MMXChannel, channelDetails : MMXChannelDetailResponse)
    optional func mmxListWillShowChatController(chatController : MMXChatViewController)
    optional func mmxListChannelForSubscribers(subscribers : [MMUser]) -> MMXChannel?
    optional func mmxListChannelForSubscribersWithBlock(subscribers : [MMUser], completionBlock : ((channel : MMXChannel) -> Void)) -> Void
    
    
}


//MARK: ChatViewControllerDelegate


@objc public protocol ChatViewControllerDatasource {
    
    func mmxControllerLoadMore(channel : MMXChannel?, offset : Int)
    func mmxControllerHasMore() -> Bool
    optional func mmxControllerPrefersSoftResets() -> Bool
    optional func mmxChatViewImageForUser(imageView : UIImageView, user : MMUser)
    //Attachments
    optional func mmxAttachmentTypes() -> [Int]
    optional func mmxDisplayNameForAttachmentType(attachmentType : Int) -> String
}


//MARK: ChatViewControllerDelegate


public protocol ChatViewControllerDelegate : class, MMXAvatarDelegate {
    
    
    func mmxChatDidCreateChannel(channel : MMXChannel)
    func mmxChatDidSendMessage(message : MMXMessage)
    func mmxChatDidRecieveMessage(message : MMXMessage)
    
    
}
