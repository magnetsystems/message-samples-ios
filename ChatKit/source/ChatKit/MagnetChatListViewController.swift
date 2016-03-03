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


//Mark: ChatListControllerDatasource


@objc public protocol ChatListControllerDatasource : ChannelListDatasource {
    func listLoadChannels(channels : (([MMXChannel]) ->Void))
    optional func listRegisterCells(tableView : UITableView)
    optional func listCellForMMXChannel(tableView : UITableView, channel : MMXChannel, channelDetails : MMXChannelDetailResponse, row : Int) -> UITableViewCell?
    optional func listCellHeightForMMXChannel(channel : MMXChannel, row : Int) -> CGFloat
}


//Mark: ChatListControllerDelegate


@objc public protocol ChatListControllerDelegate : ChannelListDelegate {
    
    func listDidSelectChannel(channel : MMXChannel, channelDetails : MMXChannelDetailResponse)
    func listCanLeaveChannel(channel : MMXChannel, channelDetails : MMXChannelDetailResponse) -> Bool
    optional func listDidLeaveChannel(channel : MMXChannel, channelDetails : MMXChannelDetailResponse)
    
    optional func listWillShowChatController(chatController : MagnetChatViewController)
    optional func listChannelForSubscribers(subscribers : [MMUser]) -> MMXChannel?
    optional func listChannelForSubscribersWithBlock(subscribers : [MMUser], finished : ((channel : MMXChannel) -> Void)) -> Void
}


//Mark: MagnetChatListViewController


public class MagnetChatListViewController: HomeViewController, ContactsControllerDelegate, ChannelListDatasource, ChannelListDelegate {
    
    
    //MARK: Private Variables
    
    
    private var chooseContacts : Bool = true
    private var contactsController : MagnetContactsPickerController?
    
    
    //MARK: Public Variables
    
    
    public var contactsPickerDelegate : ContactsControllerDelegate?
    public var datasource : ChatListControllerDatasource = DefaultChatListControllerDatasource()
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
        if let datasource = self.datasource as? DefaultChatListControllerDatasource {
            datasource.chatList = self
        }
        
        navigationController?.setNavigationBarHidden(false, animated: true)
        self.delegateProxy = self
        self.datasourceProxy = self
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
    
    private func presentChatViewController(chatViewController : MagnetChatViewController, users : [MMUser]) {
        let myId = MMUser.currentUser()?.userID
        
        let subscribers = users.filter({$0.userID !=  myId})
        
        if subscribers.count > 1 {
            chatViewController.title = "Group"
        } else {
            chatViewController.title = subscribers.map({Utils.displayNameForUser($0)}).reduce("", combine: {$0 == "" ? $1 : $0 + ", " + $1})
        }
        
        self.contactsController?.dismiss()
        self.delegate?.listWillShowChatController?(chatViewController)
        if let nav = navigationController {
            nav.pushViewController(chatViewController, animated: true)
        } else {
            self.presentViewController(chatViewController, animated: true, completion: nil)
        }
        
    }
    
    
    //MARK: Public Methods
    
    
    public func reloadData() {
        self.refreshChannelDetail()
    }
    
    
    //MARK: - HomeViewControllerDatasource
    
    
    public func listLoadChannels(channels : (([MMXChannel]) ->Void)) {
        self.datasource.listLoadChannels(channels)
    }
    
    public func listRegisterCells(tableView : UITableView) {
        self.datasource.listRegisterCells?(tableView)
    }
    
    public func listCellForMMXChannel(tableView : UITableView,channel : MMXChannel, channelDetails : MMXChannelDetailResponse, row : Int) -> UITableViewCell? {
        return self.datasource.listCellForMMXChannel?(tableView, channel : channel, channelDetails : channelDetails, row : row)
    }
    
    public func listCellHeightForMMXChannel(channel : MMXChannel, row : Int) -> CGFloat {
        if let height  = self.datasource.listCellHeightForMMXChannel?(channel, row : row) {
            return height
        }
        return 80
    }
    
    
    //MARK: - HomeViewControllerDelegate
    
    
    public func listCanLeaveChannel(channel: MMXChannel, channelDetails : MMXChannelDetailResponse) -> Bool {
        if let canLeave = self.delegate?.listCanLeaveChannel(channel, channelDetails : channelDetails) {
            return canLeave
        }
        
        return true
    }
    
    public func listDidLeaveChannel(channel: MMXChannel, channelDetails : MMXChannelDetailResponse) {
        self.delegate?.listDidLeaveChannel?(channel,channelDetails : channelDetails)
    }
    
    public func listDidSelectChannel(channel: MMXChannel, channelDetails : MMXChannelDetailResponse) {
        self.delegate?.listDidSelectChannel(channel,channelDetails : channelDetails)
    }
    
    
    //MARK: - ContactsViewControllerDelegate
    
    
    public func contactsControllerDidFinish(with selectedUsers: [MMUser]) {
        var chatViewController : MagnetChatViewController!
        if let channel = self.delegate?.listChannelForSubscribers?(selectedUsers) {
            chatViewController = MagnetChatViewController.init(channel : channel)
        }else if let listDelegate = self.delegate?.listChannelForSubscribersWithBlock {
            listDelegate(selectedUsers, finished: { channel in
                chatViewController = MagnetChatViewController.init(channel : channel)
                self.presentChatViewController(chatViewController, users: selectedUsers)
            })
            return
        } else {
            chatViewController = MagnetChatViewController.init(recipients: selectedUsers)
        }
        self.presentChatViewController(chatViewController, users: selectedUsers)
    }
    
    
    // MARK: Actions
    
    
    func addContactAction() {
        let c = MagnetContactsPickerController(disabledUsers: [MMUser.currentUser()!])
        
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
