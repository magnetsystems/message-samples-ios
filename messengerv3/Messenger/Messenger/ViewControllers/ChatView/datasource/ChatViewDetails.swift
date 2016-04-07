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

class ChatViewDetails: SubscribersDatasource {
    
    override var currentContactsPickerViewController: MMXContactsPickerController? {
        set {
            if let currentUser = MMUser.currentUser() {
                let controller = ContactsViewController(ignoredUsers:[currentUser])
                controller.delegate = self
                
                super.currentContactsPickerViewController = controller
            }
        }
        get {
            return super.currentContactsPickerViewController
        }
    }
    
    func mmxContactsDidCreateCell(cell: UITableViewCell) {
        var blocked = false
        
        if let user = (cell as? ContactsCell)?.user {
            blocked = BlockedUserManager.isUserBlocked(user)
        }
        
        if blocked {
            cell.contentView.alpha = MMXBlockContactsCellAlpha
        } else {
            cell.contentView.alpha = 1.0
        }
    }
    
    func mmxAvatarDidClick(user: MMUser) {
        guard user != MMUser.currentUser() else {
            return
        }
        
        if BlockedUserManager.isUserBlocked(user) {
            let alert = UIAlertController(title: "Options", message: "", preferredStyle: .ActionSheet)
            let button = UIAlertAction(title: "Close", style: .Cancel, handler: nil)
            alert.addAction(button)
            let buttonBlock = UIAlertAction(title: "Unblock User", style: .Destructive, handler: { action in
                let confirmationAlert = BlockedUserManager.confirmUnblock(user, completion: { blocked in
                    if blocked {
                        let confirmation = BlockedUserManager.msg("\(ChatKit.Utils.displayNameForUser(user).capitalizedString) has been unblocked.", title:"Unblocked", closeTitle: "Ok", handler:  { action in
                            if let controllers = self.controller?.navigationController?.viewControllers {
                                for controller in controllers {
                                    if let chatListController = controller as? MMXChatListViewController {
                                        if let channel = self.chatViewController?.channel {
                                            chatListController.refreshDataForChannel(channel)
                                        }
                                        return
                                    }
                                }
                            }
                            self.currentContactsPickerViewController?.resetData()
                            self.controller?.resetData()
                        })
                        self.controller?.presentViewController(confirmation, animated: false, completion: nil)
                    } else {
                        let confirmation = BlockedUserManager.msg("Could not unblock user please try again.", title:"Failed to Block", closeTitle: "Ok")
                        self.controller?.presentViewController(confirmation, animated: false, completion: nil)
                    }
                })
                self.controller?.presentViewController(confirmationAlert, animated: false, completion: nil)
            })
            alert.addAction(buttonBlock)
            self.controller?.presentViewController(alert, animated: false, completion: nil)
        }
    }
}
