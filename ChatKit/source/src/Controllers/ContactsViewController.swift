//
//  ContactsViewController.swift
//  MMChat
//
//  Created by Kostya Grishchenko on 1/5/16.
//  Copyright © 2016 Kostya Grishchenko. All rights reserved.
//

import UIKit
import MagnetMax

class UserLetterGroup : NSObject {
    var letter : String  = ""
    var users : [UserModel] = []
}

protocol UserModelDelegate : class {
    func didDownloadMedia(userModel: UserModel)
}

class UserModel : NSObject {
    var user : MMUser?
    weak var delegate : UserModelDelegate?
    var indexPath : NSIndexPath?
    lazy var image : UIImage? = {
        var imageContent : UIImage?
//        var imageContent = UIImage.init(named: "user_default.png", inBundle: NSBundle(forClass: self.dynamicType), compatibleWithTraitCollection: nil)
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {
            if let data = NSData.init( contentsOfURL: (self.user?.avatarURL())!), let img = UIImage.init(data: data) {
                self.image = img
                dispatch_async(dispatch_get_main_queue(), {
                    self.delegate?.didDownloadMedia(self)
                })
            }
        })
        return imageContent
    }()
}

class ContactsViewController: UITableViewController, UISearchResultsUpdating, UISearchBarDelegate, UserModelDelegate {
    
    weak var delegate: ContactsPickerControllerDelegate?
    var availableRecipients = [UserLetterGroup]()
    var filteredRecipients = [UserModel]()
    var selectedUsers : [MMUser] = []
    let resultSearchController = UISearchController(searchResultsController: nil)
    private var disabledUsers : [MMUser] = []
    
    func reloadData() {
        self.selectedUsers = []
        self.tableView.reloadData()
        resultSearchController.searchBar.text = ""
        resultSearchController.searchBar.resignFirstResponder()
    }
    
    convenience init(disabledUsers : [MMUser]) {
        self.init()
        self.disabledUsers = disabledUsers
    }
    
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
        
        let nib = UINib.init(nibName: "ContactsCell", bundle: NSBundle(forClass: self.dynamicType))
        self.tableView.registerNib(nib, forCellReuseIdentifier: "UserCellIdentifier")
        
        resultSearchController.searchResultsUpdater = self
        resultSearchController.dimsBackgroundDuringPresentation = false
        resultSearchController.searchBar.sizeToFit()
        resultSearchController.searchBar.returnKeyType = .Done
        resultSearchController.searchBar.setShowsCancelButton(false, animated: false)
        resultSearchController.searchBar.delegate = self
        tableView.tableHeaderView = resultSearchController.searchBar
        tableView.reloadData()
        
        let searchQuery = "userName:*"
        MMUser.searchUsers(searchQuery, limit: 1000, offset: 0, sort: "userName:asc", success: { users in
            
            var hash  : [String : MMUser] = [:]
            
            for user in self.disabledUsers {
                if let userName = user.userName {
                    hash[userName] = user
                }
            }
            var tempUsers : [MMUser] = []
            for user in users {
                if let userName = user.userName where hash[userName] == nil {
                    tempUsers.append(user)
                }
            }
            
            self.availableRecipients = self.createAlphabetDictionary(tempUsers)
            self.tableView.reloadData()
            }, failure: { error in
                print("[ERROR]: \(error.localizedDescription)")
        })
        
        let btnNext = UIBarButtonItem.init(title: "Next", style: .Plain, target: self, action: "nextAction")
        let btnCancel = UIBarButtonItem.init(title: "Cancel", style: .Plain, target: self, action: "cancelAction")
        navigationItem.leftBarButtonItem = btnCancel
        navigationItem.rightBarButtonItem = btnNext
        updateNextButton()
    }
    
    func didDownloadMedia(userModel: UserModel) {
        if let indexPath = userModel.indexPath {
            self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else {
            self.tableView.reloadData()
        }
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        resultSearchController.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func cancelAction() {
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func nextAction() {
        
        delegate?.contactsControllerDidFinish(with: selectedUsers)
        
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
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
        var cell = tableView.dequeueReusableCellWithIdentifier("UserCellIdentifier") as! ContactsCell?
        
        if cell == nil {
            cell = ContactsCell.init(style: .Default, reuseIdentifier: "UserCellIdentifier")
        }
        
        var user: MMUser!
        var userModel : UserModel
        if resultSearchController.active {
            userModel = filteredRecipients[indexPath.row]
            user = userModel.user
        } else {
            let users = availableRecipients[indexPath.section].users
            userModel = users[indexPath.row]
            user = userModel.user
        }
        
        let selectedUsers = self.selectedUsers.filter({
            if $0 === user {
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
        //cell?.avatar?.image = userModel.image
        userModel.indexPath = indexPath
        
        return cell!
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
            if let user = filteredRecipients[indexPath.row].user {
                addSelectedUser(user)
            }
        } else {
            
            let users = availableRecipients[indexPath.section].users
            if  let user = users[indexPath.row].user {
                addSelectedUser(user)
            }
        }
        updateNextButton()
    }
    
    override func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        if resultSearchController.active {
            if let user = filteredRecipients[indexPath.row].user {
                removeSelectedUser(user)
            }
        } else {
            let users = availableRecipients[indexPath.section].users
            if let user = users[indexPath.row].user {
                removeSelectedUser(user)
            }
        }
        updateNextButton()
    }
    
    // MARK: - UISearchResultsUpdating
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        if let userArrays = (availableRecipients as NSArray).valueForKey("users") as? [[UserModel]] {
            var allUsers : [UserModel] = [UserModel]()
            for userArray in userArrays {
                allUsers += userArray
            }
            for userModel in allUsers {
                userModel.indexPath = nil
            }
            filteredRecipients = allUsers.filter { userModel in
                let searchString = searchController.searchBar.text!.lowercaseString
                if searchString.isEmpty {
                    return true
                }
                if let user = userModel.user {
                    var contains = false
                    if let firstName = user.firstName where firstName.lowercaseString.containsString(searchString)
                    {
                        contains = true
                    }else if let lastName = user.lastName where lastName.lowercaseString.containsString(searchString)
                    {
                        contains = true
                    }
                    
                    return contains
                }
                return false
            }
            
            tableView.reloadData()
        }
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
    
    private func updateNextButton() {
        self.navigationItem.rightBarButtonItem?.enabled = selectedUsers.count > 0
    }
    
    // MARK: - Helpers
    
    func createAlphabetDictionary(users: [MMUser]) -> [UserLetterGroup] {
        var tempFirstLetterArray = [String]()
        for user in users {
            if  user.firstName == nil && user.lastName == nil {
                user.firstName = user.userName
            }
            
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
            var usersBeginWithLetter = [UserModel]()
            for user in users {
                
                if let lastName = user.lastName where lastName.isEmpty == false{
                    if lastName.hasPrefix(letter.uppercaseString) || lastName.hasPrefix(letter.lowercaseString) {
                        let userModel = UserModel.init()
                        userModel.user = user
                        userModel.delegate = self
                        usersBeginWithLetter.append(userModel)
                        
                    }
                } else if let firstName = user.firstName where firstName.isEmpty == false {
                    if firstName.hasPrefix(letter.uppercaseString) || firstName.hasPrefix(letter.lowercaseString) {
                        let userModel = UserModel.init()
                        userModel.user = user
                        userModel.delegate = self
                        usersBeginWithLetter.append(userModel)
                        
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
    
}
