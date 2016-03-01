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

public protocol ContactsPickerControllerDelegate: class {
    func contactsControllerDidFinish(with selectedUsers: [MMUser])
}

@objc public protocol ContactsPickerControllerDatasource: class {
    func contactsControllerLoadMore(searchText : String?, offset : Int)
    func contactControllerHasMore() -> Bool
    func contactControllerSearchUpdatesContinuously() ->Bool
    
    optional func contactControllerPreselectedUsers() -> [MMUser]
    optional func contactControllerShowsSectionIndexTitles() -> Bool
}

public class MagnetContactsPickerController: MagnetViewController, ControllerDatasource {
    private let underlyingContactsViewController = ContactsViewController()
    public private(set) var barButtonCancel : UIBarButtonItem?
    public private(set) var barButtonNext : UIBarButtonItem?
    public weak var pickerDelegate : ContactsPickerControllerDelegate?
    public var pickerDatasource : ContactsPickerControllerDatasource? = DefaultContactsPickerControllerDatasource()
    
    public var tableView : UITableView {
        return underlyingContactsViewController.tableView
    }
    
    private var disabledUsers : [String : MMUser] = [:]
    private var requestNumber : Int = 0
    override public func viewDidLoad() {
        super.viewDidLoad()
        self.automaticallyAdjustsScrollViewInsets = false
        generateNavBars()
        underlyingContactsViewController.tableView.sectionIndexColor = self.appearance.tintColor
        if let selectedUsers = self.pickerDatasource?.contactControllerPreselectedUsers?() {
            underlyingContactsViewController.selectedUsers = selectedUsers
        }
       underlyingContactsViewController.delegate = pickerDelegate
    }
    
    private func generateNavBars() {
        if let btnCancel = barButtonCancel, let btnNext = barButtonNext {
            if self.navigationController != nil {
                navigationItem.rightBarButtonItem = btnNext
                navigationItem.leftBarButtonItem = btnCancel
            } else {
                self.setMagnetNavBar(leftItems: [btnCancel], rightItems: [btnNext], title: self.title)
            }
            underlyingContactsViewController.rightNavBtn = barButtonNext
        }
    }
    
    override func setupViewController() {
        self.title = "Contacts"
        let btnNext = UIBarButtonItem.init(title: "Next", style: .Plain, target: self, action: "nextAction")
        let btnCancel = UIBarButtonItem.init(title: "Cancel", style: .Plain, target: self, action: "cancelAction")
        barButtonCancel = btnCancel
        barButtonNext = btnNext
        if let dataSource = self.pickerDatasource as? DefaultContactsPickerControllerDatasource {
            dataSource.magnetPicker = self
        }
        
        self.underlyingContactsViewController.dataSource = self
        
    }
    
    override internal func underlyingViewController() -> UIViewController? {
        return underlyingContactsViewController
    }
    
    public func appendUsers(users : [MMUser]) {
        appendUsers(users, reloadTable : true)
    }
    
    private func appendUsers(users : [MMUser], reloadTable : Bool) {
        self.underlyingContactsViewController.appendUsers(self.filterOutUsers(users), reloadTable: reloadTable)
    }
    
    public func contacts() -> [[String : [MMUser]?]] {
        return underlyingContactsViewController.availableRecipients.map({ (group) -> [String : [MMUser]?] in
            let letter = "\(group.letter)"
            let users = group.users.map({$0.user}) as? [MMUser]
            return [letter : users]
        })
    }
    
    private func filterOutUsers(users : [MMUser]) -> [MMUser] {
        var tempUsers : [MMUser] = []
        for user in users {
            if let userId = user.userID where disabledUsers[userId] == nil {
                tempUsers.append(user)
            } else {
                print ("ommit \(user.lastName)")
            }
        }
        return tempUsers
    }
    
    public func loadingContext() -> Int {
        return self.requestNumber
    }
    
    private func newLoadingContext() {
        self.requestNumber++
    }
    
    public func reloadData() {
        self.appendUsers([])
    }
    
    public func reset() {
        underlyingContactsViewController.reset()
    }
    
    private func pageForNext() {
        pickerDatasource?.contactsControllerLoadMore(nil, offset : 0)
    }
    
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
    
    func cancelAction() {
        if self.navigationController != nil {
            self.navigationController?.popViewControllerAnimated(true)
        } else  {
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    func nextAction() {
        self.pickerDelegate?.contactsControllerDidFinish(with: underlyingContactsViewController.selectedUsers)
        cancelAction()
    }
    
    
    //MARK: ControllerDatasouce
    
    
    public func controllerLoadMore(searchText : String?, offset : Int) {
        newLoadingContext()
        if searchText != nil {
            let loadingContext = self.loadingContext()
            //cool down
           // dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (Int64)(0.3 * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), {() in
                if loadingContext != self.loadingContext() {
                    return
                }
                self.pickerDatasource?.contactsControllerLoadMore(searchText, offset : offset)
          //  })
        } else {
            self.pickerDatasource?.contactsControllerLoadMore(searchText, offset : offset)
        }
    }
    
    public func controllerHasMore() -> Bool {
        if let pickerDatasource = pickerDatasource {
            return pickerDatasource.contactControllerHasMore()
        }
        return false
    }
    
    public func controllerSearchUpdatesContinuously() -> Bool {
        if let pickerDatasource = pickerDatasource {
            return pickerDatasource.contactControllerSearchUpdatesContinuously()
        }
        return false
    }
    
    public func controllShowsSectionIndexTitles() -> Bool {
        if let pickerDatasource = self.pickerDatasource {
            if let shows = pickerDatasource.contactControllerShowsSectionIndexTitles?() {
                return shows
            }
        }
        return false
    }
}
