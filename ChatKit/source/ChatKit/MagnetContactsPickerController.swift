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

@objc public protocol MagnetContactsControllerDatasource: ContactsControllerDatasource {
    func controllerLoadMore(searchText : String?, offset : Int)
    func controllerHasMore() -> Bool
    func controllerSearchUpdatesContinuously() -> Bool
    optional func contactControllerShowsSectionIndexTitles() -> Bool
    optional func contactControllerShowsSectionsHeaders() -> Bool
    optional func contactControllerPreselectedUsers() -> [MMUser]
}


//MARK: MagnetContactsPickerController


public class MagnetContactsPickerController: ContactsViewController, ContactsControllerDatasource,ContactsControllerDelegate {
    
    
    //Private Variables
    
    
    private var requestNumber : Int = 0
    
    
    //MARK: Public Variables
    
    
    public var barButtonCancel : UIBarButtonItem?
    public var barButtonNext : UIBarButtonItem?
    public weak var delegate : ContactsControllerDelegate?
    public var datasource : MagnetContactsControllerDatasource? = DefaultContactsPickerControllerDatasource()
    
    //MARK: Init
    
    
    convenience public init(disabledUsers: [MMUser]) {
        self.init()
        var hash  : [String : MMUser] = [:]
        for user in disabledUsers {
            if let userId = user.userID {
                hash[userId] = user
            }
        }
        self.disabledUsers = hash
    }
    
    
    //MARK: Overrides
    
    
    override public func setupViewController() {
        self.refreshControl = nil
        
        super.setupViewController()
        
        self.title = "Contacts"
        let btnNext = UIBarButtonItem.init(title: "Next", style: .Plain, target: self, action: "nextAction")
        let btnCancel = UIBarButtonItem.init(title: "Cancel", style: .Plain, target: self, action: "cancelAction")
        barButtonCancel = btnCancel
        barButtonNext = btnNext
        
        if let dataSource = self.datasource as? DefaultContactsPickerControllerDatasource {
            dataSource.magnetPicker = self
        }
        self.delegateProxy = self
        self.datasourceProxy = self
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        if let selectedUsers = self.datasource?.contactControllerPreselectedUsers?() {
            self.selectedUsers = selectedUsers
        }
        self.view.tintColor = self.appearance.tintColor
        self.controllerLoadMore(nil, offset: 0)
    }
    
    override public func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        generateNavBars()
        self.updateButtonItems()
    }
    
    
    //MARK : Private Methods
    
    
    private func generateNavBars() {
        if let btnCancel = barButtonCancel, let btnNext = barButtonNext {
            if self.navigationController != nil {
                navigationItem.rightBarButtonItem = btnNext
                navigationItem.leftBarButtonItem = btnCancel
            } else {
                self.setMagnetNavBar(leftItems: [btnCancel], rightItems: [btnNext], title: self.title)
            }
        }
    }
    
    
    private func newLoadingContext() {
        self.requestNumber++
    }
    
    private func updateButtonItems() {
        self.magnetNavigationItem?.rightBarButtonItem?.enabled = self.selectedUsers.count > 0
        self.navigationItem.rightBarButtonItem?.enabled = self.selectedUsers.count > 0
    }
    
    
    //Public Methods
    
    
    public func contacts() -> [[String : [MMUser]?]] {
        return self.availableRecipients.map({ (group) -> [String : [MMUser]?] in
            let letter = "\(group.letter)"
            let users = group.users.map({$0.user}) as? [MMUser]
            return [letter : users]
        })
    }
    
    public func loadingContext() -> Int {
        return self.requestNumber
    }
    
    public func reloadData() {
        self.appendUsers([])
    }
    
    
    //MARK: Actions
    
    
    func cancelAction() {
        self.dismiss()
    }
    
    func nextAction() {
        self.delegate?.contactsControllerDidFinish?(with: self.selectedUsers)
        cancelAction()
    }
    
    
    //MARK: ControllerDelegate
    
    
    public func contactsControllerSelectedUser(user: MMUser) {
        self.updateButtonItems()
        self.delegate?.contactsControllerSelectedUser?(user)
    }
    
    public func contactsControllerUnSelectedUser(user: MMUser) {
        self.updateButtonItems()
        self.delegate?.contactsControllerUnSelectedUser?(user)
    }
    
    
    //MARK: ControllerDatasouce
    
    
    public func controllerLoadMore(searchText : String?, offset : Int) {
        newLoadingContext()
        if searchText != nil {
            let loadingContext = self.loadingContext()
            //cool down
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (Int64)(0.3 * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), {() in
                if loadingContext != self.loadingContext() {
                    return
                }
                self.datasource?.controllerLoadMore(searchText, offset : offset)
            })
        } else {
            self.datasource?.controllerLoadMore(searchText, offset : offset)
        }
    }
    
    public func controllerHasMore() -> Bool {
        if let pickerDatasource = self.datasource {
            return pickerDatasource.controllerHasMore()
        }
        return false
    }
    
    public func controllerSearchUpdatesContinuously() -> Bool {
        if let pickerDatasource = self.datasource {
            return pickerDatasource.controllerSearchUpdatesContinuously()
        }
        return false
    }
    
    public func contactControllerShowsSectionIndexTitles() -> Bool {
        if let pickerDatasource = self.datasource {
            if let shows = pickerDatasource.contactControllerShowsSectionIndexTitles?() {
                return shows
            }
        }
        return false
    }
    
    public func contactControllerShowsSectionsHeaders() -> Bool {
        if let pickerDatasource = self.datasource {
            if let shows = pickerDatasource.contactControllerShowsSectionsHeaders?() {
                return shows
            }
        }
        return false
    }
    
    
}
