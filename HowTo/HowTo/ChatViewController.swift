/*
* Copyright (c) 2015 Magnet Systems, Inc.
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
import MBProgressHUD

class ChatViewController: UIViewController {
    
    
    // MARK: Outlets
    
    
    @IBOutlet weak var shouldAddAttachment: UISwitch!
    @IBOutlet weak var messagesTableView: UITableView!
    @IBOutlet weak var messageTextField: UITextField!
    
    
    // MARK: public properties
    
    
    var attachments: [String : UIImage] = Dictionary()
    var myChatChannel: MMXChannel?
    var recentMessages: [MMXMessage] = []
    
    
    // MARK: public implementations
    
    // Ensure channel with current user's userName exists!
    func getChannel() {
        guard let currentUser = MMUser.currentUser() else {
            return
        }
        self.showSpinner()
        let name = currentUser.userName
        MMXChannel.channelForName(name, isPublic: false, success: { [weak self] channel in
            self?.myChatChannel = channel
            self?.hideSpinner()
            }, failure: { error in
                // Since channel is not found, attempt to create it
                let recipients: Set<MMUser> = [currentUser]
                let summary = "Chat channel for myself"
                MMXChannel.createWithName(name, summary: summary, isPublic: false, publishPermissions: .Subscribers, subscribers: recipients, success: { [weak self] channel in
                    self?.hideSpinner()
                    self?.myChatChannel = channel
                    }, failure: { error in
                        self.hideSpinner()
                        print(error)
                })
        })
    }
    
    
    // MARK: Overrides
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Indicate that you are ready to receive messages now!
        MMX.start()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didReceiveMessage:", name: MMXDidReceiveMessageNotification, object: nil)
        
        getChannel()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    
    // MARK: Notifications
    
    
    func didReceiveMessage(notification: NSNotification) {
        let userInfo = notification.userInfo!
        let message = userInfo[MMXMessageKey] as! MMXMessage
        var messageContent = message.messageContent["content"]! as String
        
        if let attachment = message.attachments?.first {
            let data = attachment.downloadURL?.absoluteString;
            messageContent = messageContent + "\n" + (data != nil ? "(has attachment)" : "")
        }
        let messageReceivedAlert = UIAlertController(title: "Message received", message: messageContent, preferredStyle: .Alert)
        let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
        messageReceivedAlert.addAction(defaultAction)
        
        presentViewController(messageReceivedAlert, animated: true, completion: nil)
        
        //add message
        self.insertNewMessage(message)
    }
    
    
    // MARK: Actions
    
    
    @IBAction func sendMessage(sender: UIBarButtonItem) {
        // Hide keyboard
        messageTextField.resignFirstResponder()
        
        if let messageText = messageTextField.text where (messageText.isEmpty == false) {
            let content = ["content": messageText]
            // Build the message
            let message = MMXMessage(toChannel: myChatChannel!, messageContent: content)
            
            if shouldAddAttachment.on {
                let imageURL = self.fileURL()
                let attachment = MMAttachment(fileURL: imageURL, mimeType: "image/jpg")
                message.addAttachment(attachment)
            }
            self.showSpinner()
            myChatChannel?.publishMessage(message, success: {
                self.hideSpinner()
                // do something
                }, failure: { error in
                    self.hideSpinner()
                    print(error)
            })
        }
    }
    
    @IBAction func messageHistory() {
        let limit: Int32 = 10
        let offset: Int32 = 0
        
        let now = NSDate()
        let aDayAgo = now.dateByAddingTimeInterval(-(60 * 60 * 24))
        let ascending = false
        self.showSpinner()
        myChatChannel?.messagesBetweenStartDate(aDayAgo, endDate: now, limit: limit, offset: offset, ascending: ascending, success: { [weak self] totalCount, messages in
            self?.hideSpinner()
            self?.recentMessages = messages
            self?.messagesTableView.reloadData()
            self?.downloadAttachments()
            }, failure: { error in
                self.hideSpinner()
                print(error)
        })
        messageTextField.resignFirstResponder()
    }
    
    
    //MARK: - private implementations
    
    
    private func downloadAttachments() -> Void {
        for message in recentMessages {
            if let attachment = message.attachments?.first {
                attachment.downloadDataWithSuccess({[weak self] data in
                    // Save data
                    if let image = UIImage(data: data) {
                        self?.attachments.updateValue(image, forKey: (attachment.downloadURL?.absoluteString)!)
                        self?.messagesTableView.reloadData()
                    }
                    }, failure: { (error) -> Void in
                        print(error)
                })
            }
        }
    }
    
    private func fileURL() -> NSURL {
        //random image
        let imageNumber = Int(arc4random_uniform(2) + 1)
        let imageName = "GoldenGateBridge\(imageNumber)"
        let imageExtension = "jpg"
        let imageURL = NSBundle.mainBundle().URLForResource(imageName, withExtension: imageExtension)
        return imageURL!
    }
    
    private func hideSpinner() -> Void {
        self.view.userInteractionEnabled = true
        MBProgressHUD.hideHUDForView(self.view, animated: true);
    }
    
    private func insertNewMessage(message : MMXMessage) -> Void {
        if message.attachments?.count > 0 {
            if let attachment = message.attachments?.first {
                attachment.downloadDataWithSuccess({[weak self] data in
                    self?.recentMessages.insert(message, atIndex: 0)
                    // Save data
                    if let image = UIImage(data: data) {
                        self?.attachments.updateValue(image, forKey: (attachment.downloadURL?.absoluteString)!)
                        self?.messagesTableView.insertRowsAtIndexPaths([NSIndexPath.init(forRow: 0, inSection: 0)], withRowAnimation: .Top)
                    }
                    }, failure: { (error) -> Void in
                        print(error)
                })
            }
        } else {
            self.recentMessages.insert(message, atIndex: 0)
            self.messagesTableView.insertRowsAtIndexPaths([NSIndexPath.init(forRow: 0, inSection: 0)], withRowAnimation: .Top)
        }
    }
    
    private func showSpinner() -> Void {
        self.view.userInteractionEnabled = false
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
    }
    
}

extension ChatViewController: UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recentMessages.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("HistoryCellIdentifier", forIndexPath: indexPath)
        cell.imageView?.image = nil
        
        let message = recentMessages[indexPath.row]
        //show thumbnail for message with attachment
        if let attachment = message.attachments?.first {
            let image = self.attachments[(attachment.downloadURL?.absoluteString)!]
            cell.imageView?.image = image
        }
        
        let messageText = message.messageContent["content"]! as String
        cell.textLabel?.text = messageText
        
        return cell
    }
}
