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
    
    
    //MARK : Public Variables
    
    
    weak var chatList : MagnetChatListViewController?
    public var hasMoreUsers : Bool = true
    
    // Public Functions
    
    
    public func createChat(from subscribers : [MMUser]) {
        let id = NSUUID().UUIDString
        
        MMXChannel.createWithName(id, summary: id, isPublic: false, publishPermissions: .Anyone, subscribers: Set(subscribers), success: { (channel) -> Void in
            self.chatList?.reloadData()
            }) { (error) -> Void in
                print("[ERROR] \(error.localizedDescription)")
        }
    }
    
    
    //Mark: ChatListControllerDatasource
    
    public  func mmxControllerHasMore() -> Bool {
        return self.hasMoreUsers
    }
    
    public func mmxControllerSearchUpdatesContinuously() ->Bool {
        return true
    }
    
    public func mmxControllerLoadMore(searchText : String?, offset : Int) {
        
        self.hasMoreUsers = offset == 0 ? true : self.hasMoreUsers
        //get request context
        let loadingContext = chatList?.loadingContext()
        MMXChannel.subscribedChannelsWithSuccess({ ch in
            //check if the request is still valid
            if loadingContext != self.chatList?.loadingContext() {
                return
            }
            
            self.hasMoreUsers = false
            self.chatList?.appendChannels(ch)
            }) { error in
                print(error)
        }
    }
    
    public func mmxListImageForChannelDetails(imageView: UIImageView, channelDetails: MMXChannelDetailResponse) {
        if channelDetails.subscriberCount > 2 {
            let image = UIImage(named: "user_group_clear.png", inBundle: NSBundle(identifier: "org.cocoapods.ChatKitUI"), compatibleWithTraitCollection: nil)
            imageView.backgroundColor = chatList?.appearance.tintColor
            imageView.image = image
        } else {
            if let userProfile = channelDetails.subscribers.first {
                let tmpUser = MMUser()
                tmpUser.extras = ["hasAvatar" : "true"]
                var firstName = ""
                var lastName = ""
                let nameComponents = userProfile.displayName.componentsSeparatedByString(" ")
                if let name = nameComponents.first {
                    firstName = name
                }
                
                if let name = nameComponents.last {
                    lastName = name
                }
                
                tmpUser.firstName = ""
                tmpUser.lastName = ""
                tmpUser.userName = userProfile.displayName
                tmpUser.userID = userProfile.userId
                let defaultImage = Utils.noAvatarImageForUser(firstName, lastName: lastName)
                Utils.loadImageWithUrl(tmpUser.avatarURL(), toImageView: imageView, placeholderImage:defaultImage)
            }
        }
    }
    
    public func mmxListCellForMMXChannel(tableView : UITableView,channel : MMXChannel, channelDetails : MMXChannelDetailResponse, row : Int) -> UITableViewCell? {
        return nil
    }
    
    public func mmxListCellHeightForMMXChannel(channel : MMXChannel, channelDetails : MMXChannelDetailResponse, row : Int) -> CGFloat {
        return 80
    }
    
    
    public func mmxListRegisterCells(tableView : UITableView) {
        //using standard cells
    }
}
