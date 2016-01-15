//
//  PushViewController.swift
//  KitchenSink
//
//  Created by Kostya Grishchenko on 12/17/15.
//  Copyright © 2015 Magnet Systems, Inc. All rights reserved.
//

import UIKit
import MagnetMax

class PushViewController: UIViewController {
    
    
    // MARK: Outlets
    
    
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var shouldAddBadge: UISwitch!
    @IBOutlet weak var shouldAddSound: UISwitch!
    
    
    // MARK: public properties
    
    
    var bgTaskIdentifier : UIBackgroundTaskIdentifier = 0
    
    
    // MARK: Actions
    
    
    @IBAction func sendMessage(sender: UIBarButtonItem) {
        let delay : NSTimeInterval = 5.0
        
        // Start background task
        bgTaskIdentifier = UIApplication.sharedApplication().beginBackgroundTaskWithExpirationHandler { [weak self] in
            self?.endBackgroundTask()
        }
        let alert = UIAlertController(title: "Sending push", message: "Sending push in \(delay) sec(s)\n Please put app in background.", preferredStyle: .Alert)
        let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alert.addAction(defaultAction)
        
        presentViewController(alert, animated: true, completion: nil)
        
        self.performSelector(Selector("sendMessageAfterDelay"), withObject: nil, afterDelay: delay)
    }
    
    
    // MARK: public implementations
    
    
    func sendMessageAfterDelay() {
        if let messageText = messageTextField.text {
            guard let currentUser = MMUser.currentUser() else {
                return
            }
            // Build the push message
            let recipients : Set <MMUser> = [currentUser]
            let title = "MMX Push Message"
            let sound : String? = shouldAddSound.on ? "default" : nil
            let badge : NSNumber? = shouldAddBadge.on ? 1 : nil
            let pushMessage : MMXPushMessage = MMXPushMessage.pushMessageWithRecipients(recipients, body: messageText, title: title, sound: sound, badge: badge, userDefinedObjects: ["SenderKey" : currentUser.userName])
            
            pushMessage.sendPushMessage({ [weak self] in
                print("Push message sent successfully")
                self?.endBackgroundTask()
            }, failure: { [weak self] error in
                print(error)
                self?.endBackgroundTask()
            })
        }
    }
    
    func endBackgroundTask() {
        print("Background task ended.")
        UIApplication.sharedApplication().endBackgroundTask(bgTaskIdentifier)
        bgTaskIdentifier = UIBackgroundTaskInvalid
    }

}
