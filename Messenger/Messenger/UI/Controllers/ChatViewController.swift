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

import JSQMessagesViewController
import MagnetMax
import MobileCoreServices
import NYTPhotoViewer
import UIKit

//MARK: Protocol


protocol ChatViewControllerDelegate: class {
    func chatViewControllerDidFinish(with chat: MMXChannel, lastMessage: MMXMessage?, date: NSDate?)
}

class ChatViewController: JSQMessagesViewController {
    
    
    //MARK: Public properties
    
    
    var activityIndicator : UIActivityIndicatorView?
    var avatars = Dictionary<String, UIImage>()
    var avatarsDownloading = Dictionary<String, MMUser>()
    var canLeaveChat = false
    let incomingBubbleImageView = JSQMessagesBubbleImageFactory().incomingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleLightGrayColor())
    var messages = [Message]()
    var notifier : NavigationNotifier?
    let outgoingBubbleImageView = JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleBlueColor())
    var delegate: ChatViewControllerDelegate?
    
    
    //MARK: Overridden Properties
    
    
    var chat : MMXChannel? {
        didSet {
            //Register for a notification to receive the message
            if let channel = chat {
                if chat != nil && chat!.summary!.containsString("Ask") {
                    navigationItem.title = "Ask Magnet"
                } else if chat != nil && chat!.summary!.containsString("Forum") {
                    navigationItem.title = "Forum"
                }
                notifier = NavigationNotifier(viewController: self, exceptFor: channel)
                ChannelManager.sharedInstance.addChannelMessageObserver(self, channel:channel, selector: "didReceiveMessage:")
            }
            loadMessages()
        }
    }
    
    var isAskMagnetChannel = false {
        didSet {
            if isAskMagnetChannel {
                let isPublic = false
                MMXChannel.channelForName(kAskMagnetChannel, isPublic: isPublic, success: { [weak self] channel in
                    self?.chat = channel
                    }, failure: { error in
                        // Since channel is not found, attempt to create it
                        // Magnet Employees will have the magnetsupport tag
                        // Subscribe all Magnet employees
                        MMUser.searchUsers("tags:\(kMagnetSupportTag)", limit: 50, offset: 0, sort: "firstName:asc", success: { users in
                            let summary: String
                            if let userName = MMUser.currentUser()?.userName {
                                summary = "Ask Magnet for \(userName)"
                            } else {
                                // We should never be here!
                                summary = "Ask Magnet for anonymous"
                            }
                            MMXChannel.createWithName(kAskMagnetChannel, summary: summary, isPublic: isPublic, publishPermissions: .Subscribers, subscribers: Set(users), success: { [weak self] channel in
                                self?.chat = channel
                                }, failure: { error in
                                    print("[ERROR]: \(error.localizedDescription)")
                            })
                            }, failure: { error in
                                print("[ERROR]: \(error.localizedDescription)")
                        })
                })
            }
        }
    }
    
    var recipients : [MMUser]! {
        didSet {
            
            if chat != nil && chat!.summary!.containsString("Ask") {
                navigationItem.title = "Ask Magnet"
            } else if chat != nil && chat!.summary!.containsString("Forum") {
                navigationItem.title = "Forum"
            } else {
                
                if recipients.count == 1 {
                    navigationItem.title = MMUser.currentUser()?.firstName
                } else if recipients.count == 2 {
                    var users = recipients
                    if let currentUser = MMUser.currentUser(), index = users.indexOf(currentUser) {
                        users.removeAtIndex(index)
                    }
                    navigationItem.title = users.first?.firstName
                } else {
                    navigationItem.title = kStr_Group
                }
            }
        }
    }
    
    
    // MARK: - overrides
    
    
    deinit {
        // Save the last channel show
        ChannelManager.sharedInstance.removeChannelMessageObserver(self)
        print("--------> deinit chat <---------")
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        var newMessages:[Message] = []
        for message in messages {
            newMessages.append(Message(message: message.underlyingMessage))
        }
        messages = newMessages
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let user = MMUser.currentUser() else {
            return
        }
        
        let activityIndicator = UIActivityIndicatorView.init(activityIndicatorStyle: .Gray)
        activityIndicator.hidesWhenStopped = true
        let indicator = UIBarButtonItem(customView: activityIndicator)
        var rightItems = navigationItem.rightBarButtonItems
        rightItems?.append(indicator)
        navigationItem.rightBarButtonItems = rightItems
        self.activityIndicator = activityIndicator
        
        senderId = user.userID
        senderDisplayName = user.firstName
        
        // Find recipients
        if chat != nil {
            chat?.subscribersWithLimit(100, offset: 0, success: { [weak self] count, users in
                self?.recipients = users
                }, failure: { error in
                    print("[ERROR]: \(error)")
            })
        } else if recipients != nil {
            getChannelBySubscribers(recipients)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        // Prevent bottom scrolling in super class before appearing
        self.automaticallyScrollsToMostRecentMessage = false
        super.viewWillAppear(animated)
        self.automaticallyScrollsToMostRecentMessage = true
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        if let textView = self.inputToolbar?.contentView?.textView where textView.isFirstResponder() {
            self.inputToolbar?.contentView?.textView?.resignFirstResponder()
        }
        let now = NSDate()
        if let chat = self.chat, let lastMessage = messages.last?.underlyingMessage {
            ChannelManager.sharedInstance.saveLastViewTimeForChannel(chat, message: lastMessage, date:now) { [weak self] in
                self?.delegate?.chatViewControllerDidFinish(with: chat, lastMessage: lastMessage, date: now)
            }
        } else  if let chat = self.chat {
            ChannelManager.sharedInstance.saveLastViewTimeForChannel(chat, date:now) { [weak self] in
                self?.delegate?.chatViewControllerDidFinish(with: chat, lastMessage: nil, date: now)
            }
        }
    }
    
    
    // MARK: - Public methods
    
    
    func addSubscribers(newSubscribers: [MMUser]) {
        
        guard let _ = recipients, let currentChat = chat else {
            print("Add subscribers error")
            return
        }
        
        let allSubscribers = Array(Set(newSubscribers + self.recipients))
        
        currentChat.addSubscribers(newSubscribers, success: { [weak self] _ in
            self?.recipients = allSubscribers
            }, failure: { error in
                print("[ERROR]: can't add subscribers - \(error)")
        })
    }
    
    func hideSpinner() {
        if let activityIndicator = self.activityIndicator {
            activityIndicator.tag = max(activityIndicator.tag - 1, 0)
            if activityIndicator.tag == 0 {
                activityIndicator.stopAnimating()
            }
        }
    }
    
    func showSpinner() {
        self.activityIndicator?.tag++
        self.activityIndicator?.startAnimating()
    }
    
    
    // MARK: - Notifications
    
    
    func didReceiveMessage(mmxMessage: MMXMessage) {
        //Show the typing indicator to be shown
        // Scroll to actually view the indicator
        scrollToBottomAnimated(true)
        
        let finishedMessageClosure : () -> Void = {
            let message = Message(message: mmxMessage)
            self.messages.append(message)
            JSQSystemSoundPlayer.jsq_playMessageReceivedSound()
            
            if message.isMediaMessage() {
                message.mediaCompletionBlock = { [weak self] in self?.collectionView?.reloadData() }
            }
            
            self.finishReceivingMessageAnimated(true)
        }
        
        if  mmxMessage.sender != MMUser.currentUser() {
            showTypingIndicator = true
            // Allow typing indicator to show
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (Int64)(1.0 * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), {() in
                finishedMessageClosure()
            })
        } else {
            finishedMessageClosure()
        }
    }
    
    
    //MARK: Actions
    
    
    override func didPressAccessoryButton(sender: UIButton!) {
        
        guard let _ = self.chat else { return }
        
        self.inputToolbar!.contentView!.textView?.resignFirstResponder()
        
        let alertController = UIAlertController(title: kStr_MediaMessages, message: nil, preferredStyle: .ActionSheet)
        
        let sendFromCamera = UIAlertAction(title: kStr_TakePhotoOrVideo, style: .Default) { (_) in
            self.addMediaMessageFromCamera()
        }
        let sendFromLibrary = UIAlertAction(title: kStr_PhotoLib, style: .Default) { (_) in
            self.addMediaMessageFromLibrary()
        }
        let sendLocationAction = UIAlertAction(title: kStr_SendLoc, style: .Default) { (_) in
            self.addLocationMediaMessage()
        }
        let cancelAction = UIAlertAction(title: kStr_Cancel, style: .Cancel) { (_) in }
        
        alertController.addAction(sendFromCamera)
        alertController.addAction(sendFromLibrary)
        alertController.addAction(sendLocationAction)
        alertController.addAction(cancelAction)
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!) {
        
        guard let channel = self.chat else { return }
        
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        let forcedString: String = text
        let messageContent = [
            Constants.ContentKey.Type: MessageType.Text.rawValue,
            Constants.ContentKey.Message: forcedString,
        ]
        
        button.userInteractionEnabled = false
        
        showSpinner()
        let mmxMessage = MMXMessage(toChannel: channel, messageContent: messageContent)
        mmxMessage.sendWithSuccess( { [weak self] _ in
            button.userInteractionEnabled = true
            self?.hideSpinner()
            }) { error in
                button.userInteractionEnabled = true
                self.hideSpinner()
                print(error)
        }
        finishSendingMessageAnimated(true)
    }
    
    
    // MARK: Private Methods
    
    
    private func addLocationMediaMessage() {
        
        LocationManager.sharedInstance.getLocation { [weak self] location in
            JSQSystemSoundPlayer.jsq_playMessageSentSound()
            
            let messageContent = [
                Constants.ContentKey.Type: MessageType.Location.rawValue,
                Constants.ContentKey.Latitude: "\(location.coordinate.latitude)",
                Constants.ContentKey.Longitude: "\(location.coordinate.longitude)"
            ]
            self?.showSpinner()
            let mmxMessage = MMXMessage(toChannel: (self?.chat)!, messageContent: messageContent)
            mmxMessage.sendWithSuccess( { _ in
                self?.hideSpinner()
                self?.finishSendingMessageAnimated(true)
                }) { error in
                    self?.hideSpinner()
                    print("[ERROR]: \(error)")
            }
        }
    }
    
    private func addMediaMessageFromCamera() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .Camera
        imagePicker.mediaTypes = [kUTTypeImage as String]
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    private func addMediaMessageFromLibrary() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .PhotoLibrary
        imagePicker.mediaTypes = [kUTTypeImage as String]
        presentViewController(imagePicker, animated: true, completion: nil)
    }

    private func getChannelBySubscribers(users: [MMUser]) {
        //Check if channel exists
        MMXChannel.findChannelsBySubscribers(users, matchType: .EXACT_MATCH, success: { [weak self] allChannels in
            let channels = allChannels.filter { !$0.name.hasPrefix("global_") }
            if channels.count != 1 {
                //Create new chat
                let subscribers = Set(users)
                let name = NSUUID().UUIDString
                
                MMXChannel.createWithName(name, summary: "\(self!.senderDisplayName) private chat", isPublic: false, publishPermissions: .Subscribers, subscribers: subscribers, success: { [weak self] channel in
                    self?.chat = channel
                    }, failure: { [weak self] error in
                        print("[ERROR]: \(error)")
                        let alert = Popup(message: error.localizedDescription, title: error.localizedFailureReason ?? "", closeTitle: "Close", handler: { _ in
                            self?.navigationController?.popViewControllerAnimated(true)
                        })
                        alert.presentForController(self!)
                    })
            } else {
                self?.chat = channels.first
            }
            }) { error in
                print("[ERROR]: \(error)")
                let alert = Popup(message: error.localizedDescription, title: error.localizedFailureReason ?? "", closeTitle: kStr_Close, handler: { _ in
                    self.navigationController?.popViewControllerAnimated(true)
                })
                alert.presentForController(self)
        }
    }
    
    private func loadMessages() {
        
        guard let channel = self.chat else { return }
        
        let dateComponents = NSDateComponents()
        dateComponents.year = -1
        
        let theCalendar = NSCalendar.currentCalendar()
        let now = NSDate()
        let dayAgo = theCalendar.dateByAddingComponents(dateComponents, toDate: now, options: NSCalendarOptions(rawValue: 0))
        
        channel.messagesBetweenStartDate(dayAgo, endDate: now, limit: 100, offset: 0, ascending: true, success: { [weak self] _ , messages in
            self?.messages = messages.map({ mmxMessage in
                let message = Message(message: mmxMessage)
                if message.isMediaMessage() {
                    message.mediaCompletionBlock = { [weak self] () in
                        self?.collectionView?.reloadItemsAtIndexPaths([NSIndexPath(forItem: messages.indexOf(mmxMessage)!, inSection: 0)])
                    }
                }
                return message
            })
            self?.collectionView?.reloadData()
            self?.scrollToBottomAnimated(false)
            }, failure: { error in
                print("[ERROR]: \(error)")
        })
    }
    
    
    // MARK: - Navigation
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == kSegueShowDetails {
            if let detailVC = segue.destinationViewController as? DetailsViewController {
                detailVC.channel = chat
                detailVC.canLeave = self.canLeaveChat
            }
        } else if segue.identifier == kSegueShowMap {
            if let locationItem = sender as? JSQLocationMediaItem {
                let mapVC = segue.destinationViewController as! MapViewController
                mapVC.location = locationItem.coordinate
            }
        }
    }
}

