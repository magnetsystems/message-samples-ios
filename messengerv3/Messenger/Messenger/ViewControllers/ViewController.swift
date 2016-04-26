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
import ChatKit


//MARK: custom chat list controller


class ViewController: MMXChatListViewController, AskMagnetCounterDelegate {
    
    //MARK: Internal Variables
    
    
    @IBOutlet var menuButton : UIButton?
    var menuAlertImageView : UIImageView?
    
    var _currentContactsViewController: MMXContactsPickerController?
    override var currentContactsViewController: MMXContactsPickerController? {
        set {
            if let currentUser = MMUser.currentUser() {
                let contactsViewController = ContactsViewController(ignoredUsers: [currentUser])
                contactsViewController.delegate = self
                _currentContactsViewController = contactsViewController
            }
        }
        get {
            return _currentContactsViewController
        }
    }
    
    
    //MARK: Private Variables
    
    
    private var revealLoaded : Bool = false
    
    
    //MARK: Overrides
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if Utils.isMagnetEmployee() {
        AskMagnetCounter.sharedCounter.notifyForNewAskMessages = true
        AskMagnetCounter.sharedCounter.delegate = self
        } else {
            AskMagnetCounter.sharedCounter.notifyForNewAskMessages = false
            AskMagnetCounter.sharedCounter.delegate = nil
        }
        updateAskMagnetDisplay()
        
        if !revealLoaded {
            revealLoaded = true
            if self.revealViewController() != nil {
                menuButton?.addTarget(self.revealViewController(), action: #selector(self.revealViewController().revealToggle(_:)), forControlEvents: .TouchUpInside)
                self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
            }
        }
        
        if let rightItem = navigationItem.rightBarButtonItem {
            let newRightItem = UIBarButtonItem(image: UIImage(named: "new_message@2x.png"), style: .Plain, target: rightItem.target, action: rightItem.action)
            navigationItem.rightBarButtonItem = newRightItem
        }
        
        MMX.start()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.channelDetailsSubscribersLimit = 4
        self.channelDetailsMessagesLimit = 1
        self.datasource = HomeListDatasource()
        self.delegate = HomeListDelegate()
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: UIBarButtonItemStyle.Plain, target: nil, action: nil)
        
        if let width = self.menuButton?.bounds.size.width {
            let size : CGFloat = 18.0
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: size, height: size))
            imageView.transform = CGAffineTransformMakeTranslation(CGFloat(width - size + 4.0), 4.0)
            menuButton?.addSubview(imageView)
            menuAlertImageView = imageView
        }
    }
    
    override func presentChatViewController(chatViewController: MMXChatViewController, users: [MMUser]) {
        
        guard let channel = chatViewController.channel else {
            super.presentChatViewController(chatViewController, users: users)
            
            return
        }
        
        let customChatViewController = ChatViewController(channel: channel)
        super.presentChatViewController(customChatViewController, users: users)
    }
    
    func mmxAvatarDidClick(user: MMUser) {
        if BlockedUserManager.isUserBlocked(user) {
            let confirmUnblock =  BlockedUserManager.confirmUnblock(user, completion: { unblocked in
                if unblocked {
                    self.showAlert( kStr_UnblockSuceeded.stringByReplacingOccurrencesOfString(kStr_Escape_Value, withString: ChatKit.Utils.displayNameForUser(user)), title:kStr_UnblockUser, closeTitle: kStr_Ok)
                    self.currentContactsViewController?.resetData()
                    self.resetData()
                } else {
                    self.showAlert(kStr_UnblockFailed, title:kStr_Failed, closeTitle: kStr_Ok)
                }
            })
            self.presentViewController(confirmUnblock, animated: false, completion: nil)
        }
    }
    
    func mmxContactsCanSelectUser(user: MMUser) -> Bool {
        return !BlockedUserManager.isUserBlocked(user)
    }
    
    func didUpdateAskMagnetCounter(counter: AskMagnetCounter) {
        updateAskMagnetDisplay()
    }
    
    func updateAskMagnetDisplay() {
        if AskMagnetCounter.sharedCounter.newAskMagnetMessageCount > 0 {
            self.menuAlertImageView?.image = UIImage(named: "icon_alert")
        } else {
            self.menuAlertImageView?.image = nil
        }
    }
}
