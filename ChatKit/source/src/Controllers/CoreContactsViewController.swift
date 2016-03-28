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


public class CoreContactsViewController: MMTableViewController, UISearchBarDelegate, UIGestureRecognizerDelegate, ContactsCellDelegate, ContactsBubbleViewDelegate {
    
    
    //MARK: Public Variables
    
    
    public var canSearch : Bool? {
        didSet {
            updateSearchBar()
        }
    }
    
    public var contactsBubbleViewShouldMove : Bool = false
    public internal(set) var selectedUsers : [MMUser] = []
    //searchBar will be auto generated and inserted into the tableview header if not connected to an outlet
    //to hide set canSearch = false
    @IBOutlet public var searchBar : UISearchBar?
    
    
    //MARK: Internal Variables
    
    
    internal var availableRecipients = [UserLetterGroup]()
    internal var currentUserCount = 0
    internal var ignoredUsers : [String : MMUser] = [:]
    internal var startPoint : CGPoint = CGPointZero
    weak internal var generatedSearchBar : UISearchBar?
    @IBOutlet var generatedSearchBarHeight : NSLayoutConstraint?
    
    
    //MARK: IBOutlets
    
    
    @IBOutlet internal var contactsViewScrollView : ContactsView?
    
    
    //MARK: Overrides
    
    
    public override init() {
        super.init(nibName: String(CoreContactsViewController.self), bundle: NSBundle(forClass: CoreContactsViewController.self))
        
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        var nib = UINib.init(nibName: "ContactsCell", bundle: NSBundle(forClass: CoreContactsViewController.self))
        self.tableView.registerNib(nib, forCellReuseIdentifier: "UserCellIdentifier")
        nib = UINib.init(nibName: "LoadingCell", bundle: NSBundle(forClass: CoreContactsViewController.self))
        self.tableView.registerNib(nib, forCellReuseIdentifier: "LoadingCellIdentifier")
        
        initializeSearchBar()
        
        self.tableView.layer.masksToBounds = true
        if self.canSearch == nil {
            self.canSearch = true
        }
        
        infiniteLoading.onUpdate() { [weak self] in
            if let weakSelf = self {
                weakSelf.loadMore(weakSelf.searchBar?.text, offset: weakSelf.currentUserCount)
            }
        }
        self.automaticallyAdjustsScrollViewInsets = false
        self.tableView.contentInset = UIEdgeInsetsZero
    }
    
    override public func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        updateContactsView(self.selectedUsers)
    }
    
    override public func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        resignSearchBar()
    }
    
    
    //MARK: public Methods
    
    
    public func append(unfilteredUsers : [MMUser]) {
        currentUserCount += unfilteredUsers.count
        let users = self.filterOutUsers(unfilteredUsers)
        
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
            }
        }
        
        if !hasMore() {
            infiniteLoading.stopUpdating()
        } else {
            infiniteLoading.startUpdating()
            if users.count == 0 {
                infiniteLoading.setNeedsUpdate()
            }
        }
        
        infiniteLoading.finishUpdating()
        self.tableView.reloadData()
    }
    
    internal func cellDidCreate(cell : UITableViewCell) { }
    
    internal func cellForUser(user : MMUser, indexPath : NSIndexPath) -> UITableViewCell?{
        return nil
    }
    
    internal func cellHeightForUser(user : MMUser, indexPath : NSIndexPath) -> CGFloat {
        return 50
    }
    
    internal func didSelectUserAvatar(user : MMUser) { }
    
    internal func endSearch() {
        if let searchBar = self.searchBar {
            if searchBar.isFirstResponder() {
                searchBar.resignFirstResponder()
            }
        }
    }
    
    internal func hasMore() -> Bool {
        return false
    }
    
    internal func heightForFooter(index : Int) -> CGFloat {
        return 0.0
    }
    
    internal func imageForUser(imageView : UIImageView, user : MMUser) {
        var fName : String?
        var lName : String?
        let nameComponents = Utils.displayNameForUser(user).componentsSeparatedByString(" ")
        if let lastName = nameComponents.last where nameComponents.count > 1 {
            lName = lastName
        }
        
        if let firstName = nameComponents.first {
            fName = firstName
        }
        let defaultImage = Utils.noAvatarImageForUser(fName, lastName: lName)
        Utils.loadImageWithUrl(user.avatarURL(), toImageView: imageView, placeholderImage:defaultImage)
    }
    
    internal func loadMore(searchText : String?, offset : Int) { }
    
    internal func numberOfFooters() -> Int { return 0 }
    
    internal func shouldShowIndexTitles() -> Bool {
        return true
    }
    
    internal func shouldShowHeaderTitles() -> Bool {
        return true
    }
    
    internal func shouldUpdateSearchContinuously() -> Bool {
        return true
    }
    
    internal func onUserSelected(user : MMUser) { }
    
    internal func onUserDeselected(user : MMUser) { }
    
    internal func reset() {
        self.availableRecipients = []
        self.currentUserCount = 0
        self.tableView.reloadData()
        var searchText = self.searchBar?.text
        if searchText?.characters.count == 0 {
            searchText = nil
        }
        self.loadMore(searchText, offset: self.currentUserCount)
    }
    
    internal func tableViewFooter(index : Int) -> UIView {
        return UIView()
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
    
    
    //MARK: ContactsCellDelegate
    
    
    func didSelectContactsCellAvatar(cell: ContactsCell) {
        if let user = cell.user {
            self.didSelectUserAvatar(user)
        }
    }
    
    //MARK: BubbleViewDelegate
    
    
    func didSelectBubbleViewAvatar(view: ContactsBubbleView) {
        if let user = view.user {
            self.didSelectUserAvatar(user)
        }
    }
}

public extension CoreContactsViewController {
    
    
    // MARK: - Table view data source
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        self.footers = ["LOADING"]
        for var i = 0; i < self.numberOfFooters(); i++ {
            self.footers.insert( "USER_DEFINED", atIndex: 0)
        }
        
        return availableRecipients.count + self.footers.count
    }
    
    func sectionIndexTitlesForTableView(tableView: UITableView) -> [String]? {
        var indexTitles : [String]? = nil
        if shouldShowIndexTitles() {
            indexTitles = availableRecipients.map({ "\($0.letter)" })
        }
        return indexTitles
    }
    
    override public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFooterSection(section) {
            return 0
        }
        return availableRecipients[section].users.count
    }
    
    override public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if (isWithinLoadingBoundary()) {
            infiniteLoading.setNeedsUpdate()
        }
        
        var cell = tableView.dequeueReusableCellWithIdentifier("UserCellIdentifier") as! ContactsCell?
        
        if cell == nil {
            cell = ContactsCell(style: .Default, reuseIdentifier: "UserCellIdentifier")
        }
        cell?.backgroundColor = cellBackgroundColor
        
        
        let users = availableRecipients[indexPath.section].users
        let userModel : UserModel = users[indexPath.row]
        let user: MMUser = userModel.user!
        
        if let cell : UITableViewCell = cellForUser(user, indexPath : indexPath) {
            cellDidCreate(cell)
            
            return cell
        }
        
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
        let nameComponents = Utils.displayNameForUser(user).componentsSeparatedByString(" ").reverse()
        
        if let lastName = nameComponents.first {
            title = NSAttributedString(string: lastName, attributes: attributes)
        }
        
        if let firstName = nameComponents.last where nameComponents.count > 1 {
            let firstPart = NSMutableAttributedString(string: "\(firstName) ")
            firstPart.appendAttributedString(title)
            title = firstPart
        }
        
        cell?.userName?.attributedText = title
        if let imageView = cell?.avatar {
            imageForUser(imageView, user: user)
        }
        cell?.delegate = self
        cell?.user = user
        cellDidCreate(cell!)
        
        return cell!
    }
    
    public func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        let users = availableRecipients[indexPath.section].users
        let userModel : UserModel = users[indexPath.row]
        let user: MMUser = userModel.user!
        
        return cellHeightForUser(user, indexPath : indexPath)
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if isFooterSection(section) || !shouldShowHeaderTitles()  {
            return nil
        }
        let letter = availableRecipients[section]
        return String(letter.letter).uppercaseString
    }
    
    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if identifierForFooterSection(section) == "LOADING"  &&  !infiniteLoading.isFinished {
            let view = LoadingView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
            view.indicator?.startAnimating()
            return view
        } else if identifierForFooterSection(section) == "USER_DEFINED" {
            if let index = footerSectionIndex(section) {
                return tableViewFooter(index)
            }
        }
        
        return nil
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if identifierForFooterSection(section) == "LOADING" &&  !infiniteLoading.isFinished {
            return 50.0
        } else if identifierForFooterSection(section) == "USER_DEFINED" {
            if let index = footerSectionIndex(section) {
                return self.heightForFooter(index)
            }
        }
        
        return 0.0
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


private extension CoreContactsViewController {
    
    
    //MARK: Actions
    
    
    @objc private func didPanView(gesture : UILongPressGestureRecognizer) {
        if let contactsViewScrollView = self.contactsViewScrollView {
            let loc = gesture.locationInView(self.view)
            if gesture.state == .Began {
                if let gestureView = gesture.view {
                    let gesturePoint = self.view.convertRect(gestureView.frame, fromView: gestureView)
                    startPoint = CGPoint(x: loc.x + contactsViewScrollView.contentOffset.x , y:CGRectGetMaxY(gesturePoint))
                    contactsBubbleViewShouldMove = false
                }
            } else if gesture.state == .Changed {
                if !CGRectContainsPoint(contactsViewScrollView.frame, loc) {
                    contactsBubbleViewShouldMove = true
                    contactsViewScrollView.scrollEnabled = false
                    contactsViewScrollView.scrollEnabled = true
                }
                if contactsBubbleViewShouldMove {
                    let offsetPoint = CGPoint(x: loc.x - startPoint.x + contactsViewScrollView.contentOffset.x, y: loc.y - startPoint.y)
                    
                    let translate = CGAffineTransformMakeTranslation(offsetPoint.x, offsetPoint.y)
                    let scaleTrans = CGAffineTransformScale(translate, 0.8, 0.8)
                    gesture.view?.transform = scaleTrans
                    gesture.view?.alpha = 0.8
                }
            } else if gesture.state == .Ended {
                if let bubbleView = gesture.view as? ContactsBubbleView, let imageView = bubbleView.imageView {
                    let center = self.view.convertPoint(imageView.center, fromView: bubbleView)
                    
                    startPoint = CGPointZero
                    bubbleView.alpha = 1
                    bubbleView.transform = CGAffineTransformIdentity
                    if !CGRectContainsPoint(contactsViewScrollView.frame, center) {
                        if let user = bubbleView.user {
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
            if let userId = user.userID where ignoredUsers[userId] == nil {
                tempUsers.append(user)
            } else {
                print ("ommit \(user.lastName)")
            }
        }
        return tempUsers
    }
    
    private func initializeSearchBar() {
        if searchBar == nil {
            searchBar = UISearchBar()
            searchBar?.sizeToFit()
            tableView.tableHeaderView = searchBar
            generatedSearchBar = searchBar
        }
        
        searchBar?.returnKeyType = .Search
        if self.shouldUpdateSearchContinuously() {
            searchBar?.returnKeyType = .Done
        }
        searchBar?.setShowsCancelButton(false, animated: false)
        
        searchBar?.delegate = self
    }
    
    private func resignSearchBar() {
        if let searchBar = self.searchBar {
            if searchBar.isFirstResponder() {
                searchBar.resignFirstResponder()
            }
            searchBar.setShowsCancelButton(false, animated: true)
        }
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
        
        if let contactsView = self.contactsViewScrollView?.contentView {
            
            var leftView = contactsView
            var leftAttribute : NSLayoutAttribute = .Leading
            
            for sub in contactsView.subviews {
                sub.removeFromSuperview()
            }
            
            var bubbleViews : [ContactsBubbleView] = []
            for user in users.reverse() {
                let view = ContactsBubbleView.newBubbleView()
                bubbleViews.append(view)
                if let imageView = view.imageView {
                    imageForUser(imageView, user: user)
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
                view.delegate = self
            }
            
            if leftView != contactsView {
                let right = NSLayoutConstraint(item: leftView, attribute: .Right, relatedBy: .Equal, toItem: contactsView, attribute: .Right, multiplier: 1, constant: -8)
                contactsView.addConstraint(right)
            }
            
            if let bubbleView = bubbleViews.first {
                UIView.animateWithDuration(0.2, animations: { () -> Void in
                    bubbleView.transform = CGAffineTransformMakeScale(1.1, 1.1)
                    }, completion: { (_) -> Void in
                        UIView.animateWithDuration(0.4, animations: { () -> Void in
                            bubbleView.transform = CGAffineTransformIdentity
                        })
                })
            }
            if let scrollView = contactsViewScrollView {
                scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
            }
        }
    }
    
    private func updateSearchBar() {
        if generatedSearchBar != nil {
            if let canSearch = self.canSearch where canSearch == true {
                tableView.tableHeaderView = generatedSearchBar
            } else {
                tableView.tableHeaderView = nil
            }
        } else {
            if let canSearch = self.canSearch where canSearch == true {
                generatedSearchBarHeight?.priority = 250.0
            } else {
                generatedSearchBarHeight?.priority = 999.0
            }
        }
    }
}

