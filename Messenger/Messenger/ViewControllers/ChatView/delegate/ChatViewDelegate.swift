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

public class ChatViewDelegate : DefaultChatViewControllerDelegate {
    
    override public func mmxAvatarDidClick(user: MMUser) {
        guard user != MMUser.currentUser() else {
            return
        }
        
        let alert = UIAlertController(title: kStr_Options, message: "", preferredStyle: .ActionSheet)
        let button = UIAlertAction(title: kStr_Close, style: .Cancel, handler: nil)
        alert.addAction(button)
        let buttonBlock = UIAlertAction(title: kStr_BlockUser, style: .Destructive, handler: { action in
            let confirmationAlert = BlockedUserManager.confirmBlock(user, completion: { blocked in
                if blocked {
                    let confirmation = BlockedUserManager.msg(kStr_BlockSuceeded.stringByReplacingOccurrencesOfString(kStr_Escape_Value, withString: ChatKit.Utils.displayNameForUser(user)), title:kStr_BlockUser, closeTitle: kStr_Ok, handler:  { action in
                        if let viewControllers = self.controller?.navigationController?.viewControllers where viewControllers.count > 1 {
                            if let chatListController = viewControllers[viewControllers.count - 2] as? MMXChatListViewController {
                                if let channel = self.controller?.channel {
                                    chatListController.refreshDataForChannel(channel)
                                }
                            }
                        }
                        
                        self.controller?.resetData()
                    })
                    self.controller?.presentViewController(confirmation, animated: false, completion: nil)
                } else {
                    let confirmation = BlockedUserManager.msg(kStr_BlockFailed, title:kStr_Failed, closeTitle: kStr_Ok)
                    self.controller?.presentViewController(confirmation, animated: false, completion: nil)
                }
            })
            self.controller?.presentViewController(confirmationAlert, animated: false, completion: nil)
        })
        alert.addAction(buttonBlock)
        self.controller?.presentViewController(alert, animated: false, completion: nil)
    }
    
}
