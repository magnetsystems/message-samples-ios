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

class ChatViewController: MMXChatViewController, ContactsControllerDelegate {
    
    override func detailsAction() {
        
        if let currentUser = MMUser.currentUser() {
            let detailsViewController = ContactsViewController(ignoredUsers: [currentUser])
            
            detailsViewController.barButtonNext = nil
            let subDatasource = ChatViewDetails()
            
            detailsViewController.tableView.allowsSelection = false
            detailsViewController.canSearch = false
            detailsViewController.title = CKStrings.kStr_Subscribers
            detailsViewController.delegate = self
            self.chatDetailsViewController = detailsViewController
            self.chatDetailsDataSource = subDatasource
            
            if let detailsVC = self.chatDetailsViewController {
                self.navigationController?.pushViewController(detailsVC, animated: true)
            }
        }
    }
    
    func mmxAvatarDidClick(user: MMUser) {
            if BlockedUserManager.isUserBlocked(user) {
                let confirmUnblock =  BlockedUserManager.confirmUnblock(user, completion: { unblocked in
                    if unblocked {
                        self.showAlert("\(ChatKit.Utils.displayNameForUser(user).capitalizedString) has been unblocked.", title:"Unblocked", closeTitle: "Ok", handler: { action in
                            self.chatDetailsViewController?.dismiss()
                            if let controllers = self.navigationController?.viewControllers {
                                for controller in controllers {
                                    if let _ = controller as? MMXChatListViewController {
                                        self.navigationController?.popToViewController(controller, animated: false)
                                        return
                                    }
                                }
                            }
                            
                            self.chatDetailsViewController?.resetData()
                        })
                    } else {
                        self.showAlert("Could not unblock user please try again.", title:"Failed to Unblock", closeTitle: "Ok")
                    }
                })
                self.presentViewController(confirmUnblock, animated: false, completion: nil)
        }
    }
}
