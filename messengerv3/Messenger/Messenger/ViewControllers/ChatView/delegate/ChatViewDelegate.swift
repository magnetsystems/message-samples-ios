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

public class ChatViewDelegate : DefaultChatViewControllerDelegate {
    
    override public func mmxAvatarDidClick(user: MMUser) {
        let alert = UIAlertController(title: "Options", message: "", preferredStyle: .ActionSheet)
        let button = UIAlertAction(title: "Close", style: .Cancel, handler: nil)
        alert.addAction(button)
        let buttonBlock = UIAlertAction(title: "Block User", style: .Destructive, handler: { action in
            self.confirmBlock(user)
        })
        alert.addAction(buttonBlock)
        self.controller?.presentViewController(alert, animated: false, completion: nil)
    }
    
    func confirmBlock(user : MMUser) {
        let alert = UIAlertController(title: "Block User", message: "Are you sure you want to block \(ChatKit.Utils.displayNameForUser(user))?", preferredStyle: .Alert)
        let button = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        alert.addAction(button)
        let buttonConfirm = UIAlertAction(title: "Ok", style: .Default, handler: { action in
            
            MMUser.blockUsers(Set([user]), success: {
                
                self.showAlert("\(ChatKit.Utils.displayNameForUser(user).capitalizedString) has been blocked.", title:"Blocked", closeTitle: "Ok", handler:  { action in
                    self.controller?.dismissAnimated()
                })
                
                }, failure: {error in
                    self.showAlert("Could not block user please try again.", title:"Failed to Block", closeTitle: "Ok")
            })
            
        })
        alert.addAction(buttonConfirm)
        self.controller?.presentViewController(alert, animated: false, completion: nil)
    }
    
    func showAlert(message :String, title :String, closeTitle :String, handler:((UIAlertAction) -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let button = UIAlertAction(title: closeTitle, style: .Cancel, handler: handler)
        alert.addAction(button)
        self.controller?.navigationController?.topViewController?.presentViewController(alert, animated: false, completion: nil)
    }
    
}
