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
import UIScrollView_InfiniteScroll

//MARK: UserLetterGroup


public class UserLetterGroup : NSObject {
    var letter : Character  = "0"
    var users : [UserModel] = []
}


//MARK: UserModel


public class UserModel : NSObject {
    var user : MMUser?
}


//MARK: Contacts Class


public class ContactsViewController: MMTableViewController, UISearchBarDelegate, UIGestureRecognizerDelegate {
    
    
    //MARK: Public Variables
    
    public var canSearch : Bool? {
        didSet {
            updateSearchBar()
        }
    }
    
    public var iconViewShouldMove : Bool = false
    public internal(set) var selectedUsers : [MMUser] = []
    public private(set) var searchBar = UISearchBar()
    
    
    //MARK: Internal Variables
    
    
    internal var availableRecipients = [UserLetterGroup]()
    internal var currentUserCount = 0
    internal var disabledUsers : [String : MMUser] = [:]
    internal var startPoint : CGPoint = CGPointZero
    internal var topGuide : NSLayoutConstraint?
    
    
    //MARK: IBOutlets
    
    
    @IBOutlet internal var contactsView : UIView!
    @IBOutlet internal var contactsViewScrollView : UIScrollView!
    
    
    //MARK: Overrides
    
    
    override public func loadView() {
        super.loadView()
        let nib = UINib.init(nibName: "ContactsViewController", bundle: NSBundle(forClass: self.dynamicType))
        nib.instantiateWithOwner(self, options: nil)
    }
    
    public override func viewDidLoad() {
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
        if self.shouldUpdateSearchContinuously() {
            searchBar.returnKeyType = .Done
        }
        searchBar.setShowsCancelButton(false, animated: false)
        searchBar.delegate = self
        tableView.tableHeaderView = searchBar
        tableView.reloadData()
        self.tableView.layer.masksToBounds = true
        if self.canSearch == nil {
            self.canSearch = true
        }
    }
    
    override public func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        updateContactsView(self.selectedUsers)
    }
    
    override public func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        resignSearchBar()
    }
    
    override public func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        if self.topGuide == nil {
            if self.tableView.contentInset != UIEdgeInsetsZero {
                let topGuide = NSLayoutConstraint(item: contactsView, attribute: .Top, relatedBy: .Equal, toItem: self.view, attribute: .Top, multiplier: 1, constant: self.tableView.contentInset.top)
                self.view.addConstraint(topGuide)
                self.topGuide = topGuide
                
            } else {
                let topGuide = NSLayoutConstraint(item: contactsView, attribute: .Top, relatedBy: .Equal, toItem: self.topLayoutGuide, attribute: .Bottom, multiplier: 1, constant: 0)
                self.view.addConstraint(topGuide)
                self.topGuide = topGuide
            }
            
            contactsView.translatesAutoresizingMaskIntoConstraints = false
            self.automaticallyAdjustsScrollViewInsets = false
            self.tableView.contentInset = UIEdgeInsetsZero
        }
    }
    
    
    //MARK: public Methods
    
    
    public func appendUsers(users : [MMUser]) {
        appendUsers(users, reloadTable: true)
    }
    
    public func appendUsers(unfilteredUsers : [MMUser], reloadTable : Bool) {
        currentUserCount += unfilteredUsers.count
        let users = self.filterOutUsers(unfilteredUsers)
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
            let index = self.availableRecipients.searchrSortedArray({$0.letter}, object: initial)
            
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
                let userDisplayName = Utils.displayNameForUser(user).lowercaseString.componentsSeparatedByString(" ").reduce("", combine: {"\($1) \($0)"})
                row = self.availableRecipients[section].users.findInsertionIndexForSortedArray({Utils.displayNameForUser($0.user!).lowercaseString.componentsSeparatedByString(" ").reduce("", combine: {"\($1) \($0)"})}, object: userDisplayName)
                
                self.availableRecipients[section].users.insert(userModel, atIndex: row)
                
            } else { //is new
                
                row = 0
                let userGroup = UserLetterGroup()
                userGroup.letter = initial
                userGroup.users = [userModel]
                
                //find where to insert
                section = self.availableRecipients.findInsertionIndexForSortedArray({$0.letter}, object: userGroup.letter)
                
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
        
        tableView.finishInfiniteScroll()
        tableView.removeInfiniteScroll()
        if hasMore()  {
            tableView.addInfiniteScrollWithHandler({[weak self] _ in
                if let weakSelf = self {
                    weakSelf.loadMore(weakSelf.searchBar.text, offset: weakSelf.currentUserCount)
                }
                })
        }
    }
    
    public func endSearch() {
        if searchBar.isFirstResponder() {
            searchBar.resignFirstResponder()
        }
    }
    
    public func hasMore() -> Bool {
        return false
    }
    
    public func imageForUser(imageView : UIImageView, user : MMUser) {
        let defaultImage = Utils.noAvatarImageForUser(user.firstName, lastName: user.lastName)
        Utils.loadImageWithUrl(user.avatarURL(), toImageView: imageView, placeholderImage:defaultImage)
    }
    
    public func loadMore(searchText : String?, offset : Int) { }
    
    public func shouldShowIndexTitles() -> Bool {
        return true
    }
    
    public func shouldShowHeaderTitles() -> Bool {
        return true
    }
    
    public func shouldUpdateSearchContinuously() -> Bool {
        return true
    }
    
    public func onUserSelected(user : MMUser) { }
    
    public func onUserDeselected(user : MMUser) { }
    
    public func reset() {
        self.tableView.removeInfiniteScroll()
        self.availableRecipients = []
        self.currentUserCount = 0
        self.tableView.reloadData()
        self.loadMore(self.searchBar.text, offset: self.currentUserCount)
    }
    
    
    // MARK: - UISearchResultsUpdating
    
    
    public func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }
    
    public func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchBar.setShowsCancelButton(false, animated: true)
    }
    
    public func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.characters.count == 0 {
            self.search("")
            return
        }
        
        if self.shouldUpdateSearchContinuously() {
            self.search(searchText)
        }
    }
    
    public func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        self.search(searchBar.text)
        self.resignSearchBar()
    }
    
}

public extension ContactsViewController {
    
    
    // MARK: - Table view data source
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return availableRecipients.count
    }
    
    func sectionIndexTitlesForTableView(tableView: UITableView) -> [String]? {
        var indexTitles : [String]? = nil
        if shouldShowIndexTitles() {
            indexTitles = availableRecipients.map({ "\($0.letter)" })
        }
        return indexTitles
    }
    
    override public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return availableRecipients[section].users.count
    }
    
    override public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
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
        if let imageView = cell?.avatar {
        imageForUser(imageView, user: user)
        }
        return cell!
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if !shouldShowHeaderTitles() {
            return nil
        }
        let letter = availableRecipients[section]
        return String(letter.letter).uppercaseString
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let users = availableRecipients[indexPath.section].users
        if  let user = users[indexPath.row].user {
            addSelectedUser(user)
        }
        updateContactsView(selectedUsers)
    }
    
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        let users = availableRecipients[indexPath.section].users
        if let user = users[indexPath.row].user {
            removeSelectedUser(user)
        }
        updateContactsView(selectedUsers)
    }
}


private extension ContactsViewController {
    
    
    //MARK: Actions
    
    
    @objc private func didPanView(gesture : UILongPressGestureRecognizer) {
        let loc = gesture.locationInView(self.view)
        if gesture.state == .Began {
            if let gestureView = gesture.view {
                let gesturePoint = self.view.convertRect(gestureView.frame, fromView: gestureView)
                startPoint = CGPoint(x: loc.x + contactsViewScrollView.contentOffset.x , y:CGRectGetMaxY(gesturePoint))
                iconViewShouldMove = false
            }
        } else if gesture.state == .Changed {
            if let container = contactsViewScrollView where !CGRectContainsPoint(container.frame, loc) {
                iconViewShouldMove = true
                contactsViewScrollView.scrollEnabled = false
                contactsViewScrollView.scrollEnabled = true
            }
            if iconViewShouldMove {
                let offsetPoint = CGPoint(x: loc.x - startPoint.x + contactsViewScrollView.contentOffset.x, y: loc.y - startPoint.y)
                
                let translate = CGAffineTransformMakeTranslation(offsetPoint.x, offsetPoint.y)
                let scaleTrans = CGAffineTransformScale(translate, 0.8, 0.8)
                gesture.view?.transform = scaleTrans
                gesture.view?.alpha = 0.8
            }
        } else if gesture.state == .Ended {
            if let iconView = gesture.view as? IconView, let imageView = iconView.imageView {
                let center = self.view.convertPoint(imageView.center, fromView: iconView)
                
                startPoint = CGPointZero
                iconView.alpha = 1
                iconView.transform = CGAffineTransformIdentity
                if let container = contactsViewScrollView where !CGRectContainsPoint(container.frame, center) {
                    if let user = iconView.user {
                        removeSelectedUser(user)
                        updateContactsView(selectedUsers)
                        self.tableView.beginUpdates()
                        self.tableView.reloadData()
                        self.tableView.endUpdates()
                    }
                }
            }
        }
    }
    
    
    // MARK: - Private Methods
    
    
    private func addSelectedUser(selectedUser : MMUser) {
        removeSelectedUser(selectedUser)
        selectedUsers.append(selectedUser)
        onUserSelected(selectedUser)
    }
    
    private func charForUser(user : MMUser) -> Character? {
        return Utils.nameForUser(user).lowercaseString.characters.first
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
    
    private func resignSearchBar() {
        if searchBar.isFirstResponder() {
            searchBar.resignFirstResponder()
        }
        searchBar.setShowsCancelButton(false, animated: true)
    }
    
    private func removeSelectedUser(selectedUser : MMUser) {
        selectedUsers = selectedUsers.filter({
            if $0.userID != selectedUser.userID {
                return true
            }
            
            return false
        })
        
        onUserDeselected(selectedUser)
    }
    
    private func search(searchString : String?) {
        var text : String? = searchString?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        if let txt = text where txt.characters.count == 0 {
            text = nil
        }
        self.reset()
        loadMore(text, offset: 0)
    }
    
    private func updateContactsView(users : [MMUser]) {
        
        var leftView = contactsView
        var leftAttribute : NSLayoutAttribute = .Leading
        
        for sub in contactsView.subviews {
            sub.removeFromSuperview()
        }
        
        var iconViews : [IconView] = []
        for user in users.reverse() {
            let view = IconView.newIconView()
            iconViews.append(view)
            let defaultImage = Utils.noAvatarImageForUser(user.firstName, lastName: user.lastName)
            if let imageView = view.imageView {
                Utils.loadImageWithUrl(user.avatarURL(), toImageView: imageView, placeholderImage:defaultImage)
                view.title?.text = Utils.displayNameForUser(user)
            }
            let top = NSLayoutConstraint(item: view, attribute: .Top, relatedBy: .Equal, toItem: contactsView, attribute: .Top, multiplier: 1, constant: 8)
            let left = NSLayoutConstraint(item: view, attribute: .Leading, relatedBy: .Equal, toItem: leftView, attribute: leftAttribute, multiplier: 1, constant: 8)
            let bottom = NSLayoutConstraint(item: view, attribute: .Bottom, relatedBy: .Equal, toItem: contactsView, attribute: .Bottom, multiplier: 1, constant: -8)
            let width = NSLayoutConstraint(item: view, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 70)
            contactsView.addSubview(view)
            contactsView.addConstraints([top,left,bottom,width])
            leftView = view
            leftAttribute = .Trailing
            let longPress = UILongPressGestureRecognizer(target: self, action: "didPanView:")
            longPress.minimumPressDuration = 0.0
            longPress.delegate = view
            view.addGestureRecognizer(longPress)
            view.user = user
        }
        if leftView != contactsView {
            let right = NSLayoutConstraint(item: leftView, attribute: .Right, relatedBy: .Equal, toItem: contactsView, attribute: .Right, multiplier: 1, constant: -8)
            contactsView.addConstraint(right)
        }
        
        if let iconView = iconViews.first {
            UIView.animateWithDuration(0.2, animations: { () -> Void in
                iconView.transform = CGAffineTransformMakeScale(1.1, 1.1)
                }, completion: { (_) -> Void in
                    UIView.animateWithDuration(0.4, animations: { () -> Void in
                        iconView.transform = CGAffineTransformIdentity
                    })
            })
        }
        if let scrollView = contactsViewScrollView {
            scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
        }
    }
    
    private func updateSearchBar() {
        if let canSearch = self.canSearch where canSearch == true {
            tableView.tableHeaderView = searchBar
        } else {
            tableView.tableHeaderView = nil
        }
    }
}

