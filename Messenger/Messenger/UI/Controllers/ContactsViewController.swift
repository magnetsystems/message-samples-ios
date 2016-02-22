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

import AFNetworking
import MagnetMax
import UIKit


//MARK: Constants


let userCellId = "UserCellIdentifier"


//MARK: Protocol


protocol ContactsViewControllerDelegate: class {
    func contactsControllerDidFinish(with selectedUsers: [MMUser])
}


class UserLetterGroup : NSObject {
    var letter : String  = ""
    var users : [MMUser] = []
}


class ContactsViewController: UITableViewController, UISearchResultsUpdating, UISearchBarDelegate {
    
    
    //MARK: Public properties
    
    
    var availableRecipients = [UserLetterGroup]()
    weak var delegate: ContactsViewControllerDelegate?
    var filteredRecipients = [MMUser]()
    let placeholderAvatarImage = UIImage(named: "user_default")
    let resultSearchController = UISearchController(searchResultsController: nil)
    var selectedUsers : [MMUser] = []
    
    
    //MARK: Overrides
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        resultSearchController.searchResultsUpdater = self
        resultSearchController.dimsBackgroundDuringPresentation = false
        resultSearchController.searchBar.sizeToFit()
        resultSearchController.searchBar.returnKeyType = .Done
        resultSearchController.searchBar.setShowsCancelButton(false, animated: false)
        resultSearchController.searchBar.delegate = self
        updateNextButton()
        tableView.tableHeaderView = resultSearchController.searchBar
        tableView.reloadData()
        
        let searchQuery = "userName:*"
        MMUser.searchUsers(searchQuery, limit: 100, offset: 0, sort: "userName:asc", success: { [weak self] users in
            var tempUsers = users
            if let index = tempUsers.indexOf(MMUser.currentUser()!) {
                tempUsers.removeAtIndex(index)
            }
            self?.availableRecipients = self!.createAlphabetDictionary(tempUsers)
            self?.tableView.reloadData()
            }, failure: { error in
                print("[ERROR]: \(error.localizedDescription)")
        })
    }
    
    
    //MARK: Actions
    
    
    @IBAction func cancelAction() {
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func nextAction() {
        
        delegate?.contactsControllerDidFinish(with: selectedUsers)
        
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        resultSearchController.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    // MARK: - Table view data source
    
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if resultSearchController.active {
            return 1
        }
        return availableRecipients.count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if resultSearchController.active {
            return filteredRecipients.count
        }
        let users = availableRecipients[section].users
        return users.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(userCellId, forIndexPath: indexPath) as! ContactsTableViewCell
        
        var user: MMUser!
        if resultSearchController.active {
            user = filteredRecipients[indexPath.row]
        } else {
            let users = availableRecipients[indexPath.section].users
            user = users[indexPath.row]
        }
        
        let selectedUsers = self.selectedUsers.filter({
            if $0 === user {
                return true
            }
            return false
        })
        
        if selectedUsers.count > 0 && !cell.highlighted {
            tableView.selectRowAtIndexPath(indexPath, animated: false, scrollPosition:.None)
        }
        
        let attributes = [NSFontAttributeName : UIFont.boldSystemFontOfSize((cell.textLabel?.font.pointSize)!)]
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
        
        cell.profileText?.attributedText = title
        let borderSize:CGFloat = 37.0
        let placeHolderImage = Utils.noAvatarImageForUser(user)
        
        if let avatarImage = cell.avatarImage {
            Utils.loadImageWithUrl(user.avatarURL(), toImageView: avatarImage, placeholderImage: placeHolderImage)
        }
        
        
        cell.avatarImage?.superview?.layer.cornerRadius = borderSize / 2.0
        cell.avatarImage?.superview?.layer.masksToBounds = true
        cell.avatarImage?.superview?.translatesAutoresizingMaskIntoConstraints = false
        
        return cell
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if resultSearchController.active {
            return ""
        }
        let letter = availableRecipients[section]
        return letter.letter
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if resultSearchController.active {
            let user = filteredRecipients[indexPath.row]
            addSelectedUser(user)
        } else {
            
            let users = availableRecipients[indexPath.section].users
            let user = users[indexPath.row]
            addSelectedUser(user)
        }
        updateNextButton()
    }
    
    override func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        if resultSearchController.active {
            let user = filteredRecipients[indexPath.row]
            removeSelectedUser(user)
        } else {
            let users = availableRecipients[indexPath.section].users
            let user = users[indexPath.row]
            removeSelectedUser(user)
        }
        updateNextButton()
    }
    
    
    // MARK: - UISearchResultsUpdating
    
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        if let userArrays = (availableRecipients as NSArray).valueForKey("users") as? [[MMUser]] {
            var allUsers = [MMUser]()
            for userArray in userArrays {
                allUsers += userArray
            }
            filteredRecipients = allUsers.filter { user in
                let searchString = searchController.searchBar.text!.lowercaseString
                return (user.firstName != nil && user.firstName.lowercaseString.containsString(searchString)) || (user.lastName != nil && user.lastName.lowercaseString.containsString(searchString))
            }
            
            tableView.reloadData()
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 63.0
    }
    
    
    // MARK: - Private Methods
    
    
    private func addSelectedUser(selectedUser : MMUser) {
        removeSelectedUser(selectedUser)
        selectedUsers.append(selectedUser)
    }
    
    func createAlphabetDictionary(users: [MMUser]) -> [UserLetterGroup] {
        var tempFirstLetterArray = [String]()
        for user in users {
            var letterString = ""
            if let lastName = user.lastName where lastName.isEmpty == false {
                let index: String.Index = lastName.startIndex.advancedBy(1)
                letterString = lastName.substringToIndex(index).uppercaseString
            } else if let firstName = user.firstName where firstName.isEmpty == false {
                let index: String.Index = firstName.startIndex.advancedBy(1)
                letterString = firstName.substringToIndex(index).uppercaseString
            }
            if tempFirstLetterArray.contains(letterString) == false {
                tempFirstLetterArray.append(letterString)
            }
        }
        tempFirstLetterArray.sortInPlace()
        
        var letterGroups : [UserLetterGroup] = []
        for letter in tempFirstLetterArray {
            var usersBeginWithLetter = [MMUser]()
            for user in users {
                if let lastName = user.lastName where lastName.isEmpty == false{
                    if lastName.hasPrefix(letter.uppercaseString) || lastName.hasPrefix(letter.lowercaseString) {
                        usersBeginWithLetter.append(user)
                    }
                } else if let firstName = user.firstName where firstName.isEmpty == false{
                    if firstName.hasPrefix(letter.uppercaseString) || firstName.hasPrefix(letter.lowercaseString) {
                        usersBeginWithLetter.append(user)
                    }
                }
            }
            let letterGroup = UserLetterGroup()
            letterGroup.letter = letter
            letterGroup.users = usersBeginWithLetter
            letterGroups.append(letterGroup)
        }
        
        return letterGroups
    }
    
    private func removeSelectedUser(selectedUser : MMUser) {
        selectedUsers = selectedUsers.filter({
            if $0 !== selectedUser {
                return true
            }
            
            return false
        })
    }
    
    private func updateNextButton() {
        self.navigationItem.rightBarButtonItem?.enabled = selectedUsers.count > 0
    }
}
