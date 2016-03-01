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


@objc public protocol ChatListControllerDatasource : class {
    func chatListLoadChannels(channels : (([MMXChannel]) ->Void))
    optional func chatListRegisterCells(tableView : UITableView)
    optional func chatListCellForMMXChannel(tableView : UITableView,channel : MMXChannel, channelDetails : MMXChannelDetailResponse, row : Int) -> UITableViewCell?
    optional func chatListCellHeightForMMXChannel(channel : MMXChannel, row : Int) -> CGFloat
}


//Mark: ChatListControllerDelegate


@objc public protocol ChatListControllerDelegate : class {
    func chatListDidSelectChannel(channel : MMXChannel, channelDetails : MMXChannelDetailResponse)
    func chatListCanLeaveChannel(channel : MMXChannel, channelDetails : MMXChannelDetailResponse) -> Bool
    optional func chatListDidLeaveChannel(channel : MMXChannel, channelDetails : MMXChannelDetailResponse)
}


//Mark: MagnetChatListViewController


public class MagnetChatListViewController: MagnetViewController, ContactsPickerControllerDelegate, HomeViewControllerDatasource, HomeViewControllerDelegate {
    
    
    //MARK: Private Variables
    
    
    private var chooseContacts : Bool = true
    private var underlyingHomeViewController = HomeViewController.init()
    
    
    //MARK: Public Variables
    
    
    public var canChooseContacts :Bool? {
        didSet {
            if let can = canChooseContacts {
                chooseContacts = can
                generateNavBars()
            }
        }
    }
    
    public var contactsPickerDelegate : ContactsPickerControllerDelegate?
    public var datasource : ChatListControllerDatasource = DefaultChatListControllerDatasource()
    public var delegate : ChatListControllerDelegate?
    
    
    //MARK: Overrides
    
    
    override func setupViewController() {
        if let user = MMUser.currentUser() {
            self.title = "\(user.firstName ?? "") \(user.lastName ?? "")"
        }
        
        if self.title?.characters.count == 1 {
            self.title = MMUser.currentUser()?.userName
        }
        
        underlyingHomeViewController.datasource = self
        underlyingHomeViewController.delegate = self
        
        if let datasource = self.datasource as? DefaultChatListControllerDatasource {
            datasource.chatList = self
        }
        
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override internal func underlyingViewController() -> UIViewController? {
        return underlyingHomeViewController
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view
    }
    
    override public func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        generateNavBars()
    }
    
    override public func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
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
    
    
    //MARK: Public Methods
    
    public func reloadData() {
        underlyingHomeViewController.refreshChannelDetail()
    }
    
    
    //MARK: - HomeViewControllerDatasource
    
    
    func homeViewLoadChannels(channels : (([MMXChannel]) ->Void)) {
        self.datasource.chatListLoadChannels(channels)
    }
    
    func homeViewRegisterCells(tableView : UITableView) {
        self.datasource.chatListRegisterCells?(tableView)
    }
    
    func homeViewCellForMMXChannel(tableView : UITableView,channel : MMXChannel, channelDetails : MMXChannelDetailResponse, row : Int) -> UITableViewCell? {
        return self.datasource.chatListCellForMMXChannel?(tableView, channel : channel, channelDetails : channelDetails, row : row)
    }
    
    func homeViewCellHeightForMMXChannel(channel : MMXChannel, row : Int) -> CGFloat {
        if let height  = self.datasource.chatListCellHeightForMMXChannel?(channel, row : row) {
            return height
        }
        return 80
    }
    
    
    //MARK: - HomeViewControllerDelegate
    
    
    func homeViewCanLeaveChannel(channel: MMXChannel, channelDetails : MMXChannelDetailResponse) -> Bool {
        if let canLeave = self.delegate?.chatListCanLeaveChannel(channel, channelDetails : channelDetails) {
            return canLeave
        }
        
        return true
    }
    
    func homeViewDidLeaveChannel(channel: MMXChannel, channelDetails : MMXChannelDetailResponse) {
        self.delegate?.chatListDidLeaveChannel?(channel,channelDetails : channelDetails)
    }
    
    func homeViewDidSelectChannel(channel: MMXChannel, channelDetails : MMXChannelDetailResponse) {
        self.delegate?.chatListDidSelectChannel(channel,channelDetails : channelDetails)
    }
    
    
    //MARK: - ContactsViewControllerDelegate
    
    
    public func contactsControllerDidFinish(with selectedUsers: [MMUser]) { }
    
    
    // MARK: Actions
    
    
    func addContactAction() {
        let c = MagnetContactsPickerController(disabledUsers: [MMUser.currentUser()!])
        c.pickerDelegate = contactsPickerDelegate
        if c.pickerDelegate == nil {
            c.pickerDelegate = self
        }
        if let nav = navigationController {
            nav.pushViewController(c, animated: true)
        } else {
            self.presentViewController(c, animated: true, completion: nil)
        }
    }
    
    public override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
