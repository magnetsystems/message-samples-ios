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

public class UserLetterGroup : NSObject {
    var letter : Character  = "0"
    var users : [UserModel] = []
}

public class UserModel : NSObject {
    var user : MMUser?
}

public protocol ControllerDatasource: class {
    func controllerLoadMore(searchText : String?, offset : Int)
    func controllerHasMore() -> Bool
    func controllerSearchUpdatesContinuously() -> Bool
    func controllShowsSectionIndexTitles() -> Bool
}

public class IconView : UIView, UIGestureRecognizerDelegate {
    var imageView : UIImageView?
    var title : UILabel?
    weak var user : MMUser?
    
    static func newIconView() -> IconView {
        let view = IconView(frame: CGRect(x: 0, y: 0, width: 50, height: 0))
        view.translatesAutoresizingMaskIntoConstraints = false
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        imageView.layer.cornerRadius = imageView.frame.size.width / 2.0
        imageView.clipsToBounds = true
        imageView.contentMode = .ScaleAspectFill
        imageView.autoresizingMask = [.FlexibleHeight, .FlexibleWidth]
        let imageContainer = UIView(frame: CGRect(x: 0, y: 5, width: imageView.frame.size.width, height: imageView.frame.size.height))
        imageContainer.addSubview(imageView)
        imageContainer.translatesAutoresizingMaskIntoConstraints = false
        
        let label = UILabel(frame: CGRect(x: 0, y: CGRectGetMaxY(imageContainer.frame), width: 0, height: 16))
        label.textAlignment = .Center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFontOfSize(10)
        label.textColor = UIColor.grayColor()
        
        let centerX = NSLayoutConstraint(item: imageContainer, attribute: .CenterX, relatedBy: .Equal, toItem: view, attribute: .CenterX, multiplier: 1, constant: 0)
        let imageYSpace = NSLayoutConstraint(item: imageContainer, attribute: .Top, relatedBy: .Equal, toItem: view, attribute: .Top, multiplier: 1, constant: 0)
        let imageWidth = NSLayoutConstraint(item: imageContainer, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: imageContainer.frame.size.width)
        let imageHeight = NSLayoutConstraint(item: imageContainer, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: imageContainer.frame.size.height)
        
        let labelYSpace = NSLayoutConstraint(item: label, attribute: .Top, relatedBy: .Equal, toItem: imageContainer, attribute: .Bottom, multiplier: 1, constant: 0)
        let labelBottom = NSLayoutConstraint(item: label, attribute: .Bottom, relatedBy: .Equal, toItem: view, attribute: .Bottom, multiplier: 1, constant: 0)
        let labelLeading = NSLayoutConstraint(item: label, attribute: .Leading, relatedBy: .Equal, toItem: view, attribute: .Leading, multiplier: 1, constant: 0)
        let labelTrailing = NSLayoutConstraint(item: label, attribute: .Trailing, relatedBy: .Equal, toItem: view, attribute: .Trailing, multiplier: 1, constant: 0)
        let labelHeight =  NSLayoutConstraint(item: label, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: label.frame.size.height)
        //label constraints
        view.addSubview(imageContainer)
        view.addSubview(label)
        view.addConstraints([centerX, imageYSpace, imageWidth, imageHeight, labelYSpace, labelBottom, labelLeading, labelTrailing,labelHeight])
        view.title = label
        view.imageView = imageView
        return view
    }
    
    public func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

class ContactsViewController: MMTableViewController, UISearchBarDelegate {
    
    weak var delegate : ContactsPickerControllerDelegate?
    weak var dataSource : ControllerDatasource?
    var availableRecipients = [UserLetterGroup]()
    var selectedUsers : [MMUser] = []
    var rightNavBtn : UIBarButtonItem?
    var searchBar = UISearchBar()
    var currentUserCount = 0
    var isWaitingForData : Bool = false
    var topGuide : NSLayoutConstraint?
    var startPoint : CGPoint = CGPointZero
    var iconViewShouldMove : Bool = false
    
    @IBOutlet var contactsView : UIView!
    @IBOutlet var contactsViewScrollView : UIScrollView!
    
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
        self.tableView.layer.masksToBounds = true
        
    }
    
    override func viewWillLayoutSubviews() {
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
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        updateContactsView(self.selectedUsers)
        updateNextButton()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func updateContactsView(users : [MMUser]) {
        
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
                view.title?.text = displayNameForUser(user)
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
                    UIView.animateWithDuration(0.2, animations: { () -> Void in
                        iconView.transform = CGAffineTransformIdentity
                    })
            })
        }
        if let scrollView = contactsViewScrollView {
            scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
        }
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
            let index = self.availableRecipients.searchrSortedArrayWithBlock(greaterThan: {
                if $0.letter == initial {
                    return nil
                }
                return $0.letter > initial
            })
            
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
                row = self.availableRecipients[section].users.findInsertionIndexForSortedArrayWithBlock() {
                    return self.displayNameForUser($0.user!).lowercaseString.componentsSeparatedByString(" ").reduce("", combine: {"\($1) \($0)"}) > self.displayNameForUser(user).lowercaseString.componentsSeparatedByString(" ").reduce("", combine: {"\($1) \($0)"})
                }
                
                self.availableRecipients[section].users.insert(userModel, atIndex: row)
                
            } else { //is new
                
                row = 0
                let userGroup = UserLetterGroup()
                userGroup.letter = initial
                userGroup.users = [userModel]
                
                //find where to insert
                section = self.availableRecipients.findInsertionIndexForSortedArrayWithBlock() {
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
    
    func didPanView(gesture : UILongPressGestureRecognizer) {
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
                        updateNextButton()
                        self.tableView.beginUpdates()
                        self.tableView.reloadData()
                        self.tableView.endUpdates()
                    }
                }
            }
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
    
    func displayNameForUser(user : MMUser) -> String {
        //create username
        var name : String = ""
        if user.firstName != nil {
            name = "\(user.firstName) "
        }
        if user.lastName != nil {
            name += user.lastName
        }
        
        if name.characters.count == 0 {
            name = user.userName
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
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
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
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if tableView.numberOfSections - 1 == section {
            return nil
        }
        
        let letter = availableRecipients[section]
        return String(letter.letter).uppercaseString
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == tableView.numberOfSections - 1 {
            return
        }
        
        let users = availableRecipients[indexPath.section].users
        if  let user = users[indexPath.row].user {
            addSelectedUser(user)
        }
        updateNextButton()
        updateContactsView(selectedUsers)
    }
    
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == tableView.numberOfSections - 1 {
            return
        }
        let users = availableRecipients[indexPath.section].users
        if let user = users[indexPath.row].user {
            removeSelectedUser(user)
        }
        updateNextButton()
        updateContactsView(selectedUsers)
    }
    
    func sectionIndexTitlesForTableView(tableView: UITableView) -> [String]? {
        var indexTitles : [String]? = nil
        if let dataSource = self.dataSource where dataSource.controllShowsSectionIndexTitles() {
            indexTitles = availableRecipients.map({ "\($0.letter)" })
        }
        return indexTitles
    }
    
    
    //MARK : UISCrollViewDelegate
    
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        
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
            if $0.userID != selectedUser.userID {
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
