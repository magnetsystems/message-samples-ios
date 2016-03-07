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


//Mark: MagnetChatListViewController


public class MMXChatListViewController: HomeViewController, ContactsControllerDelegate {
    
    
    //MARK: Private Variables
    
    
    private var chooseContacts : Bool = true
    private var contactsController : MMXContactsPickerController?
    private var requestNumber : Int = 0
    
    
    //MARK: Public Variables
    
    
    public var contactsPickerDelegate : ContactsControllerDelegate?
    public var datasource : ChatListControllerDatasource?
    public var delegate : ChatListControllerDelegate?
    
    
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
        self.datasource = DefaultChatListControllerDatasource()
        self.delegate = DefaultChatListControllerDelegate()
        if let datasource = self.datasource as? DefaultChatListControllerDatasource {
            datasource.chatList = self
        }
        if let delegate = self.delegate as? DefaultChatListControllerDelegate {
            delegate.chatList = self
        }
        self.reset()
        self.canSearch = false
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.tintColor = self.appearance.tintColor
    }
    
    public override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        generateNavBars()
    }
    
    
    //MARK: Private Methods
    
    
    private func generateNavBars() {
        if chooseContacts {
            let rightBtn = UIBarButtonItem.init(barButtonSystemItem: .Add, target: self, action: "addContactAction")
            if self.navigationController != nil {
                navigationItem.rightBarButtonItem = rightBtn
            } else {
                self.setMagnetNavBar(leftItems: nil, rightItems: [rightBtn], title: self.title)
            }
        }
    }
    
    public func loadingContext() -> Int {
        return self.requestNumber
    }
    
    private func newLoadingContext() {
        self.requestNumber++
    }
    
    private func presentChatViewController(chatViewController : MMXChatViewController, users : [MMUser]) {
        let myId = MMUser.currentUser()?.userID
        
        let subscribers = users.filter({$0.userID !=  myId})
        
        if subscribers.count > 1 {
            chatViewController.title = "Group"
        } else {
            chatViewController.title = subscribers.map({Utils.displayNameForUser($0)}).reduce("", combine: {$0 == "" ? $1 : $0 + ", " + $1})
        }
        chatViewController.outgoingBubbleImageView = JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImageWithColor(self.view.tintColor)
        self.contactsController?.dismiss()
        self.delegate?.mmxListWillShowChatController?(chatViewController)
        if let nav = navigationController {
            nav.pushViewController(chatViewController, animated: true)
        } else {
            self.presentViewController(chatViewController, animated: true, completion: nil)
        }
        
    }
    
    
    //MARK: Public Methods
    
    
    public func reloadData() {
        self.appendChannels([])
    }
    
    
    //MARK: - Data Method Overrides
    
    
    override public func canLeaveChannel(channel: MMXChannel, channelDetails : MMXChannelDetailResponse) -> Bool {
        if let canLeave = self.delegate?.mmxListCanLeaveChannel(channel, channelDetails : channelDetails) {
            return canLeave
        }
        
        return true
    }
    
    override public func cellForMMXChannel(tableView : UITableView,channel : MMXChannel, channelDetails : MMXChannelDetailResponse, row : Int) -> UITableViewCell? {
        return self.datasource?.mmxListCellForMMXChannel?(tableView, channel : channel, channelDetails : channelDetails, row : row)
    }
    
    override public func cellHeightForChannel(channel: MMXChannel, channelDetails: MMXChannelDetailResponse, row: Int) -> CGFloat {
        if let height  = self.datasource?.mmxListCellHeightForMMXChannel?(channel, channelDetails: channelDetails, row : row) {
            return height
        }
        return 80
    }
    
    override public func imageForChannelDetails(imageView : UIImageView, channelDetails : MMXChannelDetailResponse) {
        if let imgForDetails = self.datasource?.mmxListImageForChannelDetails {
            imgForDetails(imageView, channelDetails: channelDetails)
        } else {
            super.imageForChannelDetails(imageView, channelDetails: channelDetails)
        }
    }
    
    override public func hasMore() -> Bool {
        if let listDatasource = self.datasource {
            return listDatasource.mmxControllerHasMore()
        }
        return false
    }
    
    override public func loadMore(searchText: String?, offset: Int) {
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
    
    override public func onChannelDidLeave(channel: MMXChannel, channelDetails: MMXChannelDetailResponse) {
        self.delegate?.mmxListDidLeaveChannel?(channel,channelDetails : channelDetails)
    }
    
    override public func onChannelDidSelect(channel: MMXChannel, channelDetails: MMXChannelDetailResponse) {
        self.delegate?.mmxListDidSelectChannel(channel,channelDetails : channelDetails)
    }
    
    override public func registerCells(tableView : UITableView) {
        self.datasource?.mmxListRegisterCells?(tableView)
    }
    
    override public func shouldUpdateSearchContinuously() -> Bool {
        if let datasource = self.datasource {
            return datasource.mmxControllerSearchUpdatesContinuously()
        }
        return false
    }
    
    //MARK: - ContactsViewControllerDelegate
    
    
    public func mmxContactsControllerDidFinish(with selectedUsers: [MMUser]) {
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
        let c = MMXContactsPickerController(disabledUsers: [MMUser.currentUser()!])
        
        if contactsPickerDelegate == nil {
            contactsPickerDelegate = self
        }
        c.delegate = contactsPickerDelegate
        
        if let nav = navigationController {
            nav.pushViewController(c, animated: true)
        } else {
            self.presentViewController(c, animated: true, completion: nil)
        }
        self.contactsController = c
    }
    
    public override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
