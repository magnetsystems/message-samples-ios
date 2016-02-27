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

class UserLetterGroup : NSObject {
    var letter : Character  = "0"
    var users : [UserModel] = []
}

class UserModel : NSObject {
    var user : MMUser?
}

public protocol ControllerDatasource: class {
    func controllerLoadMore(searchText : String?, offset : Int)
    func controllerHasMore() -> Bool
    func controllerSearchUpdatesContinuously() ->Bool
}

class ContactsViewController: UITableViewController, UISearchBarDelegate {
    
    weak var delegate : ContactsPickerControllerDelegate?
    weak var dataSource : ControllerDatasource?
    var availableRecipients = [UserLetterGroup]()
    var selectedUsers : [MMUser] = []
    var rightNavBtn : UIBarButtonItem?
    var searchBar = UISearchBar()
    var currentUserCount = 0
    var isWaitingForData : Bool = false
    
    override func loadView() {
        super.loadView()
        let nib = UINib.init(nibName: "ContactsViewController", bundle: NSBundle(forClass: self.dynamicType))
        nib.instantiateWithOwner(self, options: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if MMUser.sessionStatus() != .LoggedIn {
            assertionFailure("MUST LOGIN USER FIRST")
        }
        
        var nib = UINib.init(nibName: "ContactsCell", bundle: NSBundle(forClass: self.dynamicType))
        self.tableView.registerNib(nib, forCellReuseIdentifier: "UserCellIdentifier")
        nib = UINib.init(nibName: "LoadingCell", bundle: NSBundle(forClass: self.dynamicType))
        self.tableView.registerNib(nib, forCellReuseIdentifier: "LoadingCellIdentifier")
        
        searchBar.sizeToFit()
        searchBar.returnKeyType = .Search
        if let dataSource = self.dataSource where dataSource.controllerSearchUpdatesContinuously() {
            searchBar.returnKeyType = .Done
        }
        searchBar.setShowsCancelButton(false, animated: false)
        searchBar.delegate = self
        tableView.tableHeaderView = searchBar
        tableView.reloadData()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        updateNextButton()
    }
    
    func appendUsers(users : [MMUser]) {
        appendUsers(users, reloadTable: true)
    }
    
    func appendUsers(users : [MMUser], reloadTable : Bool) {
        isWaitingForData = false
        currentUserCount += users.count
        var indexPaths : [NSIndexPath] = []
        
        if !reloadTable {
            self.tableView.beginUpdates()
        }
        
        for user in users {
            let char = charForUser(user)
            
            guard let initial = char else {
                
                continue
            }
            
            let userModel = UserModel()
            userModel.user = user
            
            //search for user group index
            let index = self.availableRecipients.find() {
                if $0.letter == initial {
                    return nil
                }
                return $0.letter > initial
            }
            
            var section = Int.max
            var row = Int.max
            let isNewSection = index == nil
            
            //if table wont be reloaded and a new section will be created, insert and flush current IndexPaths
            if !reloadTable {
                if isNewSection {
                    if indexPaths.count > 0 {
                        self.tableView.insertRowsAtIndexPaths(indexPaths, withRowAnimation: .None)
                        self.tableView.endUpdates()
                        self.tableView.beginUpdates()
                        indexPaths.removeAll()
                    }
                }
            }
            
            if !isNewSection { //not new section
                //is contained
                if let ind = index {
                    section = ind
                }
                
                //find where to insert
                row = self.availableRecipients[section].users.findInsertionIndex() {
                    return self.nameForUser($0.user!) > self.nameForUser(user)
                }
                
                self.availableRecipients[section].users.insert(userModel, atIndex: row)
                
            } else { //is new
                
                row = 0
                let userGroup = UserLetterGroup()
                userGroup.letter = initial
                userGroup.users = [userModel]
                
                //find where to insert
                section = self.availableRecipients.findInsertionIndex() {
                    return $0.letter > userGroup.letter
                }
                
                self.availableRecipients.insert(userGroup, atIndex: section)
                
                if !reloadTable {
                    self.tableView.insertSections(NSIndexSet(index: section), withRowAnimation: .None)
                }
            }
            
            //insert indexPath for cell
            indexPaths.append(NSIndexPath(forRow: row, inSection: section))
            
        }
        
        if reloadTable {
            self.tableView.reloadData()
        } else if indexPaths.count > 0 {
            self.tableView.insertRowsAtIndexPaths(indexPaths, withRowAnimation: .Fade)
            self.tableView.endUpdates()
        }
        
        if let dataSource = self.dataSource where dataSource.controllerHasMore()  {
            let indexPath = NSIndexPath(forRow: 0, inSection: self.availableRecipients.count)
            tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .None)
        }
    }
    
    func charForUser(user : MMUser) -> Character? {
        return nameForUser(user).lowercaseString.characters.first
    }
    
    func nameForUser(user : MMUser) -> String {
        //create username
        var name = user.userName
        if user.lastName != nil {
            name = user.lastName
        } else if user.firstName != nil {
            name = user.firstName
        }
        return name
    }
    
    
    func selectContacts() {
        
        delegate?.contactsControllerDidFinish(with: selectedUsers)
    }
    
    func reset() {
        self.availableRecipients = []
        self.currentUserCount = 0
        self.tableView.reloadData()
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return availableRecipients.count + 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView.numberOfSections - 1 == section {
            return 1
        }
        return availableRecipients[section].users.count
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if tableView.numberOfSections - 1 == indexPath.section {
            var loadingCell = tableView.dequeueReusableCellWithIdentifier("LoadingCellIdentifier") as? LoadingCell
            if loadingCell == nil {
                loadingCell = LoadingCell(style: .Default, reuseIdentifier: "LoadingCellIdentifier")
            }
            if let dS = dataSource where dS.controllerHasMore() {
                loadingCell?.indicator?.startAnimating()
                
                if !isWaitingForData {
                    isWaitingForData = true
                    let text = searchBar.text?.characters.count > 0 ? searchBar.text : nil
                    dataSource?.controllerLoadMore(text, offset: currentUserCount)
                }
                
            } else {
                loadingCell?.indicator?.stopAnimating()
            }
            
            return loadingCell!
        }
        
        var cell = tableView.dequeueReusableCellWithIdentifier("UserCellIdentifier") as! ContactsCell?
        
        if cell == nil {
            cell = ContactsCell(style: .Default, reuseIdentifier: "UserCellIdentifier")
        }
        
        var user: MMUser!
        var userModel : UserModel
        let users = availableRecipients[indexPath.section].users
        userModel = users[indexPath.row]
        user = userModel.user
        let selectedUsers = self.selectedUsers.filter({
            if $0.userID == user.userID {
                return true
            }
            return false
        })
        
        if selectedUsers.count > 0 && !cell!.highlighted {
            tableView.selectRowAtIndexPath(indexPath, animated: false, scrollPosition:.None)
        }
        
        let attributes = [NSFontAttributeName : UIFont.boldSystemFontOfSize((cell?.userName?.font.pointSize)!)]
        var title = NSAttributedString()
        if let lastName = user.lastName where lastName.isEmpty == false {
            title = NSAttributedString(string: lastName, attributes: attributes)
        }
        if let firstName = user.firstName where firstName.isEmpty == false {
            if let lastName = user.lastName where lastName.isEmpty == false{
                let firstPart = NSMutableAttributedString(string: "\(firstName) ")
                firstPart.appendAttributedString(title)
                title = firstPart
            } else {
                title = NSAttributedString(string: firstName, attributes: attributes)
            }
        }
        
        cell?.userName?.attributedText = title
        
        let defaultImage = Utils.noAvatarImageForUser(user.firstName, lastName: user.lastName)
        if let imageView = cell?.avatar {
            Utils.loadImageWithUrl(user.avatarURL(), toImageView: imageView, placeholderImage:defaultImage)
        }
        
        return cell!
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if tableView.numberOfSections - 1 == section {
            return nil
        }
        
        let letter = availableRecipients[section]
        return String(letter.letter).uppercaseString
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == tableView.numberOfSections - 1 {
            return
        }
        
        let users = availableRecipients[indexPath.section].users
        if  let user = users[indexPath.row].user {
            addSelectedUser(user)
        }
        updateNextButton()
    }
    
    override func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == tableView.numberOfSections - 1 {
            return
        }
        let users = availableRecipients[indexPath.section].users
        if let user = users[indexPath.row].user {
            removeSelectedUser(user)
        }
        updateNextButton()
    }
    
    
    //MARK : UISCrollViewDelegate
    
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        
        if searchBar.isFirstResponder() {
            searchBar.resignFirstResponder()
        }
    }
    
    
    // MARK: - UISearchResultsUpdating
    
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.characters.count == 0 {
            self.search("")
            return
        }
        
        if let dataSource = self.dataSource where dataSource.controllerSearchUpdatesContinuously() {
            self.search(searchText)
        }
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        self.search(searchBar.text)
    }
    
    // MARK: - Private Methods
    
    private func addSelectedUser(selectedUser : MMUser) {
        removeSelectedUser(selectedUser)
        selectedUsers.append(selectedUser)
    }
    
    private func removeSelectedUser(selectedUser : MMUser) {
        selectedUsers = selectedUsers.filter({
            if $0 !== selectedUser {
                return true
            }
            
            return false
        })
    }
    
    private func search(searchString : String?) {
        var text : String? = searchString?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        if let txt = text where txt.characters.count == 0 {
            text = nil
        }
        self.isWaitingForData = true
        self.reset()
        dataSource?.controllerLoadMore(text, offset: 0)
    }
    
    private func updateNextButton() {
        rightNavBtn?.enabled = selectedUsers.count > 0
    }
}
