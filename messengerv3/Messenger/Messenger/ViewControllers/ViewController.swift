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


extension ContactsControllerDelegate {
    
    public func mmxContactsCanSelectUser(user: MMUser) {
        
    }
    
    public func mmxAvatarDidClick(user: MMUser) {
        
    }
    
    
    func confirmUnBlock(user : MMUser) {
        let alert = UIAlertController(title: "Unblock User", message: "Are you sure you want to unblock \(ChatKit.Utils.displayNameForUser(user))?", preferredStyle: .Alert)
        let button = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        alert.addAction(button)
        let buttonConfirm = UIAlertAction(title: "Ok", style: .Default, handler: { action in
            
            MMUser.unblockUsers(Set([user]), success: {
                self.showAlert("\(ChatKit.Utils.displayNameForUser(user).capitalizedString) has been unblocked.", title:"Unblocked", closeTitle: "Ok")
                }, failure: {error in
                    self.showAlert("Could not unblock user please try again.", title:"Failed to Unblock", closeTitle: "Ok")
            })
            
        })
        alert.addAction(buttonConfirm)
        let controller = UIApplication.sharedApplication().keyWindow?.rootViewController
        controller?.presentViewController(alert, animated: false, completion: nil)
    }
    
    func showAlert(message :String, title :String, closeTitle :String, handler:((UIAlertAction) -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let button = UIAlertAction(title: closeTitle, style: .Cancel, handler: handler)
        alert.addAction(button)
        let controller = UIApplication.sharedApplication().keyWindow?.rootViewController
        controller?.presentViewController(alert, animated: false, completion: nil)
    }
}


//MARK: custom chat list controller


class ViewController: MMXChatListViewController, AskMagnetCounterDelegate {
    
    //MARK: Internal Variables
    
    
    @IBOutlet var menuButton : UIButton?
    var menuAlertImageView : UIImageView?
    
    
    //MARK: Private Variables
    
    
    private var revealLoaded : Bool = false
    
    
    //MARK: Overrides
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        AskMagnetCounter.sharedCounter.notifyForNewAskMessages = true
        AskMagnetCounter.sharedCounter.delegate = self
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
