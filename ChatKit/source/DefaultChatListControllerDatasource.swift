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

public class DefaultChatListControllerDatasource : NSObject, ChatListControllerDatasource {
    
    public func chatListLoadChannels(channels : (([MMXChannel]) ->Void)) {
        MMXChannel.subscribedChannelsWithSuccess({ ch in
            // set channels
            channels(ch)
            }) { error in
                print(error)
        }
    }
    
    public func chatListRegisterCells(tableView : UITableView) {
        //using standard cells
    }
    
    public func chatListCellForMMXChannel(tableView : UITableView,channel : MMXChannel, channelDetails : MMXChannelDetailResponse, row : Int) -> UITableViewCell? {
        return nil
    }
    
    public func chatListCellHeightForMMXChannel(channel : MMXChannel, row : Int) -> CGFloat {
        if row == 0 {
            return 125
        }
        return 80
    }
}
