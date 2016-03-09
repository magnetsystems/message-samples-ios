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

public class SubscribersDatasource : DefaultContactsPickerControllerDatasource, ContactsControllerDelegate {
    
    
    public var channel : MMXChannel?
    public  var chatViewController : MMXChatViewController?
    
    
    //MARK: ContactsPickerControllerDatasource
    
    
    override public func mmxControllerLoadMore(searchText : String?, offset : Int) {
        self.hasMoreUsers = offset == 0 ? true : self.hasMoreUsers
        //get request context
        let loadingContext = self.magnetPicker?.loadingContext()
        
        self.channel?.subscribersWithLimit(Int32(self.limit), offset: Int32(offset), success: { (num, users) -> Void in
            if loadingContext != self.magnetPicker?.loadingContext() {
                return
            }
            
            if users.count == 0 {
                self.hasMoreUsers = false
                self.magnetPicker?.reloadData()
                return
            }
            
            if let picker = self.magnetPicker {
                //append users, reload data or insert data
                picker.append(users)
            }
            }, failure: { _ in
                self.magnetPicker?.reloadData()
        })
    }
    
    override public func mmxContactsControllerShowsSectionIndexTitles() -> Bool {
        return false
    }
    override public func mmxContactsControllerShowsSectionsHeaders() -> Bool {
        return false
    }
    
    func mmxTableViewFooter() -> UIView? {
        let button = UIButton(type: .Custom)
        button.setTitleColor(UIColor.darkGrayColor(), forState: .Normal)
        button.setTitle("Add Contacts +", forState: .Normal)
        button.titleLabel?.textAlignment = .Center
        button.addTarget(self, action: "addContacts", forControlEvents: .TouchUpInside)
        return button
    }
    
    func addContacts() {
        
        self.channel?.subscribersWithLimit(1000, offset: 0, success: { (num, users) -> Void in
            let contacts = MMXContactsPickerController(disabledUsers: users)
            contacts.delegate = self
            self.chatViewController?.navigationController?.pushViewController(contacts, animated: true)
            
            }, failure: { error in
                
        })
    }
    
    
    //MARK: ContactsControllerDelegate
    
    
    public func mmxContactsControllerDidFinish(with selectedUsers: [MMUser]) {
        if selectedUsers.count > 0 {
            self.channel?.addSubscribers(selectedUsers, success: { _ in
                if let chatViewController = self.chatViewController {
                    chatViewController.title = CKStrings.kStr_Group
                    chatViewController.navigationController?.popToViewController(chatViewController, animated: true)
                }
                }, failure: {error in
                    
            })
        }
    }
}