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


//Mark: MagnetChatListViewController


public class MMXChatListViewController: CoreChatListViewController, ContactsControllerDelegate,  Define_MMXChatListViewController {
    
    
    //MARK: Private Variables
    
    
    private var requestNumber : Int = 0
    
    
    //MARK: Public Variables
    
    
    public var chooseContacts : Bool = true
    
    public var datasource : ChatListControllerDatasource? {
        willSet {
            if let datasource = self.datasource as? DefaultChatListControllerDatasource {
                datasource.controller = nil
            }
        }
        didSet {
            if let datasource = self.datasource as? DefaultChatListControllerDatasource {
                datasource.controller = self
                self.reset()
            }
        }
    }
    
    public var delegate : ChatListControllerDelegate? {
        didSet {
            if let delegate = self.delegate as? DefaultChatListControllerDelegate {
                delegate.controller = self
            }
        }
    }
    
    
    //These can be overridden to inject datasources, delegates and other customizations into the variable on didSet
    
    
    public weak var currentChatViewController : MMXChatViewController?
    public weak var currentContactsViewController : MMXContactsPickerController?
    
    
    
    //MARK: Overrides
    
    
    override public func setupViewController() {
        super.setupViewController()
        
        if let user = MMUser.currentUser() {
            self.title = "\(user.firstName ?? "") \(user.lastName ?? "")"
        }
        
        if self.title?.characters.count == 1 {
            self.title = MMUser.currentUser()?.userName
        }
        
        self.view.tintColor = self.appearance.tintColor
        
        navigationController?.setNavigationBarHidden(false, animated: true)
        if self.datasource == nil {
            self.datasource = DefaultChatListControllerDatasource()
        }
        
        if self.delegate == nil {
            self.delegate = DefaultChatListControllerDelegate()
        }
        
        self.datasource?.mmxListRegisterCells?(tableView)
        self.canSearch = false
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.tintColor = self.appearance.tintColor
    }
    
    public override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        assert(self.navigationController != nil, "MMXChatListViewController must be presented using a Navagation Controller")
        
        generateNavBars()
    }
    
    
    //MARK: Private Methods
    
    
    private func generateNavBars() {
        if chooseContacts && !didGenerateBars {
            didGenerateBars = true
            let rightBtn = UIBarButtonItem.init(barButtonSystemItem: .Add, target: self, action: "addContactAction")
            if self.navigationItem.rightBarButtonItems != nil {
                self.navigationItem.rightBarButtonItems?.append(rightBtn)
            } else {
                self.navigationItem.rightBarButtonItems = [rightBtn]
            }
        }
    }
    
    public func loadingContext() -> Int {
        return self.requestNumber
    }
    
    private func newLoadingContext() {
        self.requestNumber++
    }
    
    
    //MARK: Public Methods
    
    
    override public func append(mmxChannels: [MMXChannel]) {
        super.append(mmxChannels)
    }
    
    public func presentChatViewController(chatViewController : MMXChatViewController, users : [MMUser]) {
        
        chatViewController.view.tintColor = self.view.tintColor
        
        let myId = MMUser.currentUser()?.userID
        
        let subscribers = users.filter({$0.userID !=  myId})
        
        if subscribers.count > 1 {
            chatViewController.title = CKStrings.kStr_Group
        } else {
            chatViewController.title = subscribers.map({Utils.displayNameForUser($0)}).reduce("", combine: {$0 == "" ? $1 : $0 + ", " + $1})
        }
        chatViewController.outgoingBubbleImageView = JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImageWithColor(chatViewController.view.tintColor)
        
        self.currentChatViewController = chatViewController
        if let chatVC = self.currentChatViewController {
            self.delegate?.mmxListWillShowChatController?(chatVC)
            if let nav = navigationController {
                nav.pushViewController(chatVC, animated: true)
            }
        }
    }
    
    public func reloadData() {
        self.append([])
    }
    
    public func resetData() {
        self.reset()
    }
    
    
    //MARK: - Core Method Overrides
    
    
    override internal func canLeaveChannel(channel: MMXChannel, channelDetails : MMXChannelDetailResponse) -> Bool {
        if let canLeave = self.delegate?.mmxListCanLeaveChannel(channel, channelDetails : channelDetails) {
            return canLeave
        }
        
        return true
    }
    
    override internal func cellDidCreate(cell: UITableViewCell) {
        self.datasource?.mmxListDidCreateCell?(cell)
    }
    
    override internal func cellForChannel(channel : MMXChannel, channelDetails : MMXChannelDetailResponse, indexPath : NSIndexPath) -> UITableViewCell? {
        return self.datasource?.mmxListCellForChannel?(tableView, channel : channel, channelDetails : channelDetails, indexPath : indexPath)
    }
    
    override internal func cellHeightForChannel(channel: MMXChannel, channelDetails: MMXChannelDetailResponse, indexPath : NSIndexPath) -> CGFloat {
        if let height  = self.datasource?.mmxListCellHeightForChannel?(channel, channelDetails: channelDetails, indexPath : indexPath) {
            return height
        }
        return super.cellHeightForChannel(channel, channelDetails: channelDetails, indexPath: indexPath)
    }
    
    override internal func didSelectUserAvatar(user: MMUser) {
        self.delegate?.mmxAvatarDidClick?(user)
    }
    
    override func filterChannels(channelDetails: [MMXChannelDetailResponse]) -> [MMXChannelDetailResponse] {
        if let filtered = self.datasource?.mmxListFilterChannelDetails {
            return filtered(channelDetails)
        } else {
            return super.filterChannels(channelDetails)
        }
    }
    
    override internal func imageForChannelDetails(imageView : UIImageView, channelDetails : MMXChannelDetailResponse) {
        if let imgForDetails = self.datasource?.mmxListImageForChannelDetails {
            imgForDetails(imageView, channelDetails: channelDetails)
        } else {
            super.imageForChannelDetails(imageView, channelDetails: channelDetails)
        }
    }
    
    override internal func hasMore() -> Bool {
        if let listDatasource = self.datasource {
            return listDatasource.mmxControllerHasMore()
        }
        return false
    }
    
    override internal func heightForFooter(index: Int) -> CGFloat {
        if let height = self.datasource?.mmxTableViewFooterHeight?(index) {
            return height
        }
        
        return 0.0
    }
    
    override internal func loadMore(searchText: String?, offset: Int) {
        newLoadingContext()
        if searchText != nil {
            let loadingContext = self.loadingContext()
            //cool down
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (Int64)(0.3 * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), {() in
                if loadingContext != self.loadingContext() {
                    return
                }
                self.datasource?.mmxControllerLoadMore(searchText, offset : offset)
            })
        } else {
            self.datasource?.mmxControllerLoadMore(searchText, offset : offset)
        }
    }
    
    override internal func numberOfFooters() -> Int {
        if let number = self.datasource?.mmxTableViewNumberOfFooters?() {
            return number
        }
        
        return 0
    }
    
    override internal func onChannelDidLeave(channel: MMXChannel, channelDetails: MMXChannelDetailResponse) {
        self.delegate?.mmxListDidLeaveChannel?(channel,channelDetails : channelDetails)
    }
    
    override internal func onChannelDidSelect(channel: MMXChannel, channelDetails: MMXChannelDetailResponse) {
        self.delegate?.mmxListDidSelectChannel(channel,channelDetails : channelDetails)
    }
    
    override internal func sort(channelDetails: [MMXChannelDetailResponse]) -> [MMXChannelDetailResponse] {
        if let details = self.datasource?.mmxListSortChannelDetails?(channelDetails) {
            return details
        }
        
        return super.sort(channelDetails)
    }
    
    override internal func shouldAppendChannel(channel: MMXChannel) -> Bool {
        if let append = self.datasource?.mmxListShouldAppendNewChannel?(channel) {
            return append
        }
        
        return super.shouldAppendChannel(channel)
    }
    
    override internal func shouldUpdateSearchContinuously() -> Bool {
        if let datasource = self.datasource {
            return datasource.mmxControllerSearchUpdatesContinuously()
        }
        return false
    }
    
    override internal func tableViewFooter(index: Int) -> UIView {
        if let footer = self.datasource?.mmxTableViewFooter?(index) {
            return footer
        }
        
        return super.tableViewFooter(index)
    }
    
    
    //MARK: - ContactsViewControllerDelegate
    
    
    public func mmxContactsControllerDidFinish(with selectedUsers: [MMUser]) {
        
        self.currentContactsViewController?.dismiss()
        
        var chatViewController : MMXChatViewController!
        if let channel = self.delegate?.mmxListChannelForSubscribers?(selectedUsers) {
            chatViewController = MMXChatViewController.init(channel : channel)
        }else if let listDelegate = self.delegate?.mmxListChannelForSubscribersWithBlock {
            listDelegate(selectedUsers, completionBlock: { channel in
                chatViewController = MMXChatViewController.init(channel : channel)
                self.presentChatViewController(chatViewController, users: selectedUsers)
            })
            return
        } else {
            chatViewController = MMXChatViewController.init(recipients: selectedUsers)
        }
        self.presentChatViewController(chatViewController, users: selectedUsers)
    }
    
    
    // MARK: Actions
    
    
    func addContactAction() {
        
        if let currentUser = MMUser.currentUser() {
            let contactsViewController = MMXContactsPickerController(ignoredUsers: [currentUser])
            contactsViewController.delegate = self
            
            self.currentContactsViewController = contactsViewController
            
            if let nav = navigationController, let contactsVC = self.currentContactsViewController {
                nav.pushViewController(contactsVC, animated: true)
            }
            
        }
        
    }
    
    public override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
