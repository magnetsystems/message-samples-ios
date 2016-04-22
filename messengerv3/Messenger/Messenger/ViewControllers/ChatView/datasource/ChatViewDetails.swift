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
    
    var muteButton : UIButton?
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
    
    func updateMuteStatus() {
        if let channel = self.chatViewController?.channel {
            if channel.isMuted {
                self.muteButton?.tag = 1
                self.muteButton?.setTitle("Unmute Push Notifications", forState: .Normal)
            } else {
                self.muteButton?.tag = 0
                self.muteButton?.setTitle("Mute Push Notifications", forState: .Normal)
            }
        }
    }
    
    // MARK: Mute/unmute actions
    
    func handleMute(button : UIButton) {
        if button.tag == 1 {
            unMuteAction()
        } else {
            muteAction()
        }
    }
    
    func muteAction() {
        if let channel = self.chatViewController?.channel {
            let aYearFromNow = NSCalendar.currentCalendar().dateByAddingUnit(.Year, value: 1, toDate: NSDate(), options: .MatchNextTime)
            self.muteButton?.enabled = false
            channel.muteUntil(aYearFromNow, success: { [weak self] in
                self?.updateMuteStatus()
                self?.muteButton?.enabled = true
                }, failure: { [weak self] error in
                    self?.muteButton?.enabled = true
                })
        }
    }
    
    func unMuteAction() {
        if let channel = self.chatViewController?.channel {
            self.muteButton?.enabled = false
            channel.unMuteWithSuccess({ [weak self] in
                self?.updateMuteStatus()
                self?.muteButton?.enabled = true
            }) { [weak self] error in
                self?.muteButton?.enabled = true
            }
        }
    }
    
    //MARK: Datasource
    
    override func mmxTableViewNumberOfFooters() -> Int {
        return 1 + super.mmxTableViewNumberOfFooters()
    }
    
    override func mmxTableViewFooter(index : Int) -> UIView {
        if index == 0 {
            return super.mmxTableViewFooter(index)
        }
        let button = UIButton(type: .Custom)
        button.setTitleColor(UIColor.darkGrayColor(), forState: .Normal)
        button.setTitle("Mute", forState: .Normal)
        button.titleLabel?.textAlignment = .Center
        button.addTarget(self, action: #selector(ChatViewDetails.handleMute(_:)), forControlEvents: .TouchUpInside)
        self.muteButton = button
        updateMuteStatus()
        return button
    }
    
    override func mmxControllerLoadMore(searchText: String?, offset: Int) {
        let context = self.controller?.loadingContext()
        BlockedUserManager.getBlockedUsers({ _ in
            guard context == self.controller?.loadingContext() else {
                return
            }
            super.mmxControllerLoadMore(searchText, offset: 0)
            }, failure: { _ in
                guard context == self.controller?.loadingContext() else {
                    return
                }
                super.mmxControllerLoadMore(searchText, offset: 0)
        })
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
            let alert = UIAlertController(title: kStr_Options, message: "", preferredStyle: .ActionSheet)
            let button = UIAlertAction(title: kStr_Close, style: .Cancel, handler: nil)
            alert.addAction(button)
            let buttonBlock = UIAlertAction(title: kStr_UnblockUser, style: .Destructive, handler: { action in
                let confirmationAlert = BlockedUserManager.confirmUnblock(user, completion: { blocked in
                    if blocked {
                        let confirmation = BlockedUserManager.msg( kStr_UnblockSuceeded.stringByReplacingOccurrencesOfString(kStr_Escape_Value, withString: ChatKit.Utils.displayNameForUser(user)), title:kStr_UnblockUser, closeTitle: kStr_Ok, handler:  { action in
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
                        let confirmation = BlockedUserManager.msg(kStr_UnblockFailed, title:kStr_Failed, closeTitle: kStr_Ok)
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
