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
   optional func contactsControllerDidFinish(with selectedUsers: [MMUser])
   optional func contactsControllerSelectedUser(user: MMUser)
   optional func contactsControllerUnSelectedUser(user: MMUser)
}


//MARK: Generic ControllerDatasource


@objc public protocol ControllerDatasource: class {
    func controllerLoadMore(searchText : String?, offset : Int)
    func controllerHasMore() -> Bool
    func controllerSearchUpdatesContinuously() -> Bool
}


//MARK: ContactsControllerDatasource


@objc public protocol ContactsControllerDatasource: ControllerDatasource {
    optional func contactControllerShowsSectionIndexTitles() -> Bool
    optional func contactControllerShowsSectionsHeaders() -> Bool
}


//MARK: ChannelListDatasource


@objc public protocol ChannelListDatasource: class {
    func  listLoadChannels(channels : (([MMXChannel]) ->Void))
    optional func listRegisterCells(tableView : UITableView)
    optional func listCellForMMXChannel(tableView : UITableView, channel : MMXChannel, channelDetails : MMXChannelDetailResponse, row : Int) -> UITableViewCell?
    optional func listCellHeightForMMXChannel(channel : MMXChannel, row : Int) -> CGFloat
}


//MARK: ChannelListDelegate


@objc public protocol ChannelListDelegate: class {
    func listDidSelectChannel(channel : MMXChannel, channelDetails : MMXChannelDetailResponse)
    func listCanLeaveChannel(channel : MMXChannel, channelDetails : MMXChannelDetailResponse) -> Bool
    optional func listDidLeaveChannel(channel : MMXChannel, channelDetails : MMXChannelDetailResponse)
}


//MARK: ChatViewControllerDelegate


public protocol ChatViewControllerDelegate {
    func chatDidCreateChannel(channel : MMXChannel)
    func chatDidSendMessage(message : MMXMessage)
    func chatDidRecieveMessage(message : MMXMessage)
}
