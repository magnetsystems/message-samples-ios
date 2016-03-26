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

import CocoaLumberjack
import MagnetMax

public class SubscribersDatasource : DefaultContactsPickerControllerDatasource, ContactsControllerDelegate {
    
    
    public var channel : MMXChannel?
    public weak var chatViewController : MMXChatViewController?
    public weak var chatListViewController : MMXChatListViewController?
    
    
    //These can be overridden to inject datasources, delegates and other customizations into the variable on didSet
    
    
    public var currentContactsPickerViewController : MMXContactsPickerController?
    
    
    //MARK: ContactsPickerControllerDatasource
    
    
    override public func mmxControllerLoadMore(searchText : String?, offset : Int) {
        self.hasMoreUsers = offset == 0 ? true : self.hasMoreUsers
        //get request context
        let loadingContext = self.controller?.loadingContext()
        
        self.channel?.subscribersWithLimit(Int32(self.limit), offset: Int32(offset), success: { (num, users) -> Void in
            if loadingContext != self.controller?.loadingContext() {
                return
            }
            
            if users.count == 0 {
                self.hasMoreUsers = false
                self.controller?.reloadData()
                return
            }
            
            if let picker = self.controller {
                //append users, reload data or insert data
                picker.append(users)
            }
            DDLogVerbose("[Append] - users appended \(users)")
            }, failure: { error in
                DDLogError("[Error] - Load More - \(error)")
                self.controller?.reloadData()
        })
    }
    
    override public func mmxContactsControllerShowsSectionIndexTitles() -> Bool {
        return false
    }
    override public func mmxContactsControllerShowsSectionsHeaders() -> Bool {
        return false
    }
    
    func addContacts() {
        
        self.channel?.subscribersWithLimit(1000, offset: 0, success: { (num, users) -> Void in
            let contacts = MMXContactsPickerController(ignoredUsers: users)
            contacts.delegate = self
            
            self.currentContactsPickerViewController = contacts
            
            self.chatViewController?.navigationController?.pushViewController(contacts, animated: true)
            DDLogVerbose("[Presenting Contacts]")
            }, failure: { error in
                DDLogError("[Error] - \(error.localizedDescription)")
        })
    }
    
    
    //MARK: MMTableViewFooterDatasource
    
    
    func mmxTableViewNumberOfFooters() -> Int {
        guard let channel = self.channel where channel.ownerUserID == MMUser.currentUser()?.userID else {
            return 0
        }
        
        return 1
    }
    
    func mmxTableViewFooterHeight(index: Int) -> CGFloat {
        return 50.0
    }
    
    func mmxTableViewFooter(index : Int) -> UIView {
        let button = UIButton(type: .Custom)
        button.setTitleColor(UIColor.darkGrayColor(), forState: .Normal)
        button.setTitle("Add Contacts +", forState: .Normal)
        button.titleLabel?.textAlignment = .Center
        button.addTarget(self, action: "addContacts", forControlEvents: .TouchUpInside)
        
        return button
    }
    
    
    //MARK: ContactsControllerDelegate
    
    
    public func mmxContactsControllerDidFinish(with selectedUsers: [MMUser]) {
        if selectedUsers.count > 0 {
            self.channel?.addSubscribers(selectedUsers, success: { _ in
                if let channel = self.channel {
                    self.chatListViewController?.refreshChannel(channel)
                }
                if let chatViewController = self.chatViewController {
                    chatViewController.title = CKStrings.kStr_Group
                    chatViewController.navigationController?.popToViewController(chatViewController, animated: true)
                }
                DDLogVerbose("[Added Users] - \(selectedUsers)")
                }, failure: {error in
                    DDLogError("[Error] - \(error.localizedDescription)")
            })
        }
    }
}