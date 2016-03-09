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

public class DefaultChatListControllerDelegate : NSObject, ChatListControllerDelegate {
    
    
    //MARK : Public Variables
    
    
    weak var chatList : MMXChatListViewController?
    
    
    //MARK: ChatListControllerDelegate
    
    
    public func mmxListDidSelectChannel(channel : MMXChannel, channelDetails : MMXChannelDetailResponse) {
        
        let chatViewController = MMXChatViewController.init(channel : channel)
        chatViewController.view.tintColor = chatList?.view.tintColor
        
        let myId = MMUser.currentUser()?.userID
        
        let subscribers = channelDetails.subscribers.filter({$0.userId !=  myId})
        
        if subscribers.count > 1 {
            chatViewController.title = CKStrings.kStr_Group
        } else {
            chatViewController.title = subscribers.map({$0.displayName}).reduce("", combine: {$0 == "" ? $1 : $0 + ", " + $1})
        }
        chatViewController.outgoingBubbleImageView = JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImageWithColor(self.chatList?.view.tintColor)
        
        //Delays cell deselection from reloading data - not necessary
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (Int64)(0.3 * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), {() in
            self.chatList?.reloadData()
        })
        
        if self.chatList?.navigationController != nil {
            self.chatList?.navigationController?.pushViewController(chatViewController, animated: true)
        } else {
            self.chatList?.presentViewController(chatViewController, animated: true, completion: nil)
        }
    }
    
    public func mmxListCanLeaveChannel(channel : MMXChannel, channelDetails : MMXChannelDetailResponse) -> Bool {
        return true
    }
    
    func mmxContactsControllerDidFinish(with selectedUsers: [MMUser]) {
        
    }
    
    public func mmxListWillShowChatController(chatController : MMXChatViewController) {
    }
    
    
}