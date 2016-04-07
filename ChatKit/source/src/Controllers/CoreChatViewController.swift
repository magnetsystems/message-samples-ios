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
import MobileCoreServices
import NYTPhotoViewer



//MARK: ChatViewController


public class CoreChatViewController: MMJSQViewController {
    
    
    //MARK: Public Properties
    
    
    public var currentMessageCount = 0
    public var incomingBubbleImageView = JSQMessagesBubbleImageFactory().incomingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleLightGrayColor())
    public private(set) var infiniteLoading : InfiniteLoading = InfiniteLoading()
    
    public var mmxMessages : [MMXMessage] {
        get {
            return self.messages.map({$0.underlyingMessage})
        }
    }
    
    public var navigationBarNotifier : NavigationNotifier?
    public var outgoingBubbleImageView = JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleBlueColor())
    public internal(set) var recipients : [MMUser]?
    
    
    //MARK: Internal properties
    
    
    internal var chat : MMXChannel? {
        didSet {
            //Register for a notification to receive the message
            if let channel = chat {
                //  notifier = NavigationNotifier(viewController: self, exceptFor: channel)
                ChannelManager.sharedInstance.addChannelMessageObserver(self, channel:channel, selector: "didReceiveMessage:")
            }
        }
    }
    
    internal var activityIndicator : UIActivityIndicatorView?
    internal var avatars = Dictionary<String, UIImage>()
    internal var avatarsDownloading = Dictionary<String, MMUser>()
    internal var canLeaveChat = false
    internal var messages = [Message]()
    
    
    // MARK: - overrides
    
    
    deinit {
        // Save the last channel show
        ChannelManager.sharedInstance.removeChannelMessageObserver(self)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        var newMessages:[Message] = []
        for message in messages {
            newMessages.append(Message(message: message.underlyingMessage))
        }
        messages = newMessages
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        guard let user = MMUser.currentUser() else {
            return
        }
        self.title = "chat"
        let activityIndicator = UIActivityIndicatorView.init(activityIndicatorStyle: .Gray)
        activityIndicator.hidesWhenStopped = true
        let indicator = UIBarButtonItem(customView: activityIndicator)
        navigationItem.rightBarButtonItems = [indicator]
        self.activityIndicator = activityIndicator
        
        senderId = user.userID
        senderDisplayName = user.firstName
        saveLastTimeViewed()
        
        infiniteLoading.onUpdate() {
            [weak self] in
            if let weakSelf = self {
                weakSelf.loadMore(weakSelf.chat, offset: weakSelf.currentMessageCount)
            }
        }
        
        // Indicate that you are ready to receive messages now!
        MMX.start()
        // Handling disconnection
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didDisconnect:", name: MMUserDidReceiveAuthenticationChallengeNotification, object: nil)
    }
    
    override public func viewWillAppear(animated: Bool) {
        // Prevent bottom scrolling in super class before appearing
        self.automaticallyScrollsToMostRecentMessage = false
        super.viewWillAppear(animated)
        self.automaticallyScrollsToMostRecentMessage = true
        self.navigationBarNotifier?.label?.textColor = self.view.tintColor
        self.collectionView?.loadEarlierMessagesHeaderTextColor = self.view.tintColor
    }
    
    override public func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        if let textView = self.inputToolbar?.contentView?.textView where textView.isFirstResponder() {
            self.inputToolbar?.contentView?.textView?.resignFirstResponder()
        }
        saveLastTimeViewed()
    }
    
    
    // MARK: - Public methods
    
    
    public func append(mmxMessages : [MMXMessage]) {
        if mmxMessages.count > 0 {
            currentMessageCount += mmxMessages.count
            let mappedMessages : [Message] = mmxMessages.map({
                let message = Message(message: $0)
                if message.isMediaMessage() {
                    message.mediaCompletionBlock = { [weak self, weak message] () in
                        if let weakSelf = self, let weakMessage = message {
                            weakSelf.collectionView.reloadData()
                        }
                    }
                }
                return message
            })
            self.messages.appendContentsOf(mappedMessages)
            self.messages = self.sort(messages)
        }
        
        collectionView?.reloadData()
        self.showLoadEarlierMessagesHeader = self.hasMore()
        self.infiniteLoading.finishUpdating()
        if !self.hasMore() {
            self.infiniteLoading.stopUpdating()
        } else {
            infiniteLoading.startUpdating()
        }
    }
    
    internal func didSelectUserAvatar(user : MMUser) { }
    
    internal func hasMore() -> Bool { return false }
    
    internal func hideSpinner() {
        if let activityIndicator = self.activityIndicator {
            activityIndicator.tag = max(activityIndicator.tag - 1, 0)
            if activityIndicator.tag == 0 {
                activityIndicator.stopAnimating()
            }
        }
    }
    
    internal func loadMore(channel : MMXChannel?, offset: Int) { }
    
    internal func onChannelCreated(mmxChannel: MMXChannel) { }
    
    internal func onMessageRecived(mmxMessage: MMXMessage) { }
    
    internal func onMessageSent(mmxMessage: MMXMessage) { }
    
    internal func reset() {
        self.currentMessageCount = 0
        self.messages = []
        self.collectionView.reloadData()
        self.collectionView.collectionViewLayout.invalidateLayout()
        loadMore(self.chat, offset: self.currentMessageCount)
    }
    
    internal func saveLastTimeViewed() {
        if let chat = self.chat, let lastMessage = messages.last?.underlyingMessage {
            ChannelManager.sharedInstance.saveLastViewTimeForChannel(chat, message: lastMessage, date:NSDate.init())
        } else  if let chat = self.chat {
            ChannelManager.sharedInstance.saveLastViewTimeForChannel(chat, date:NSDate.init())
        }
    }
    
    internal func showSpinner() {
        self.activityIndicator?.tag++
        self.activityIndicator?.startAnimating()
    }
    
    internal func sort(messages : [Message]) -> [Message] {
        return messages.sort({
            if let date = $0.0.underlyingMessage.timestamp, let date1 = $0.1.underlyingMessage.timestamp {
                return date.timeIntervalSince1970 < date1.timeIntervalSince1970
            }
            return false
        })
    }
    
    
    // MARK: - Notifications
    
    
    @objc private func didReceiveMessage(mmxMessage: MMXMessage) {
        //Show the typing indicator to be shown
        // Scroll to actually view the indicator
        scrollToBottomAnimated(true)
        
        let finishedMessageClosure : () -> Void = {
            self.onMessageRecived(mmxMessage)
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
    
    
    // MARK: - Notification handler
    
    
    private func didDisconnect(notification: NSNotification) {
        MMX.stop()
    }
    
    
    //MARK: Actions
    
    
    override public func didPressAccessoryButton(sender: UIButton!) {
        
        self.inputToolbar!.contentView!.textView?.resignFirstResponder()
        
        let alertController = UIAlertController(title: CKStrings.kStr_MediaMessages, message: nil, preferredStyle: .ActionSheet)
        
        let sendFromCamera = UIAlertAction(title: CKStrings.kStr_TakePhotoOrVideo, style: .Default) { (_) in
            self.addMediaMessageFromCamera()
        }
        let sendFromLibrary = UIAlertAction(title: CKStrings.kStr_PhotoLib, style: .Default) { (_) in
            self.addMediaMessageFromLibrary()
        }
        let sendLocationAction = UIAlertAction(title: CKStrings.kStr_SendLoc, style: .Default) { (_) in
            self.addLocationMediaMessage()
        }
        let cancelAction = UIAlertAction(title: CKStrings.kStr_Cancel, style: .Cancel) { (_) in }
        
        alertController.addAction(sendFromCamera)
        alertController.addAction(sendFromLibrary)
        
        if LocationManager.sharedInstance.canLocationServicesBeEnabled() {
            alertController.addAction(sendLocationAction)
        }
        
        alertController.addAction(cancelAction)
        
        sendLocationAction.enabled = LocationManager.sharedInstance.isLocationServicesEnabled()
        
        LocationManager.sharedInstance.onAuthorizationUpdate = {[weak sendLocationAction] in
            sendLocationAction?.enabled = LocationManager.sharedInstance.isLocationServicesEnabled()
        }
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    override public func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!) {
        
        guard let channel = self.chat else {
            if let recipients = self.recipients where recipients.count > 0 {
                createNewChatWithRecipients(recipients, completion: {error in
                    if error == nil {
                        self.didPressSendButton(button, withMessageText: text, senderId: senderId, senderDisplayName: senderDisplayName, date: date)
                    }
                })
            }
            return
        }
        
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        let forcedString: String = text
        let messageContent = [
            Constants.ContentKey.Type: MessageType.Text.rawValue,
            Constants.ContentKey.Message: forcedString,
            ]
        
        button.userInteractionEnabled = false
        
        showSpinner()
        let mmxMessage = MMXMessage(toChannel: channel, messageContent: messageContent)
        mmxMessage.sendWithSuccess( { [weak self, weak mmxMessage] _ in
            if let message = mmxMessage {
                self?.onMessageSent(message)
            }
            button.userInteractionEnabled = true
            self?.hideSpinner()
        }) { error in
            button.userInteractionEnabled = true
            self.hideSpinner()
            print(error)
        }
        finishSendingMessageAnimated(true)
    }
    
    internal func sendImage(image : UIImage) {
        guard let chat = self.chat else {
            if let recipients = self.recipients where recipients.count > 0 {
                createNewChatWithRecipients(recipients, completion: {error in
                    if error == nil {
                        self.sendImage(image)
                    }
                })
            }
            return
        }
        
        let messageContent = [Constants.ContentKey.Type: MessageType.Photo.rawValue]
        let mmxMessage = MMXMessage(toChannel: chat, messageContent: messageContent)
        
        if let data = UIImageJPEGRepresentation(image, 0.8) {
            
            let attachment = MMAttachment(data: data, mimeType: "image/jpg")
            mmxMessage.addAttachment(attachment)
            self.showSpinner()
            mmxMessage.sendWithSuccess({ [weak self, weak mmxMessage] _ in
                if let message = mmxMessage {
                    self?.onMessageSent(message)
                }
                self?.hideSpinner()
            }) { error in
                self.hideSpinner()
                print(error)
            }
            finishSendingMessageAnimated(true)
            
        }
    }
}


private extension CoreChatViewController {
    
    
    // MARK: Private Methods
    
    
    private func addLocationMediaMessage() {
        guard let chat = self.chat else {
            if let recipients = self.recipients where recipients.count > 0 {
                createNewChatWithRecipients(recipients, completion: {error in
                    if error == nil {
                        self.addLocationMediaMessage()
                    }
                })
            }
            return
        }
        
        LocationManager.sharedInstance.getLocation { [weak self] location in
            
            JSQSystemSoundPlayer.jsq_playMessageSentSound()
            
            let messageContent = [
                Constants.ContentKey.Type: MessageType.Location.rawValue,
                Constants.ContentKey.Latitude: "\(location.coordinate.latitude)",
                Constants.ContentKey.Longitude: "\(location.coordinate.longitude)"
            ]
            self?.showSpinner()
            let mmxMessage = MMXMessage(toChannel: chat, messageContent: messageContent)
            mmxMessage.sendWithSuccess( {[weak mmxMessage] _ in
                if let message = mmxMessage {
                    self?.onMessageSent(message)
                }
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
    
    private func createNewChatWithRecipients(users : [MMUser], completion : ((error : NSError?) -> Void)) {
        let id = NSUUID().UUIDString
        MMXChannel.createWithName(id, summary: "[CHAT KIT]", isPublic: false, publishPermissions: .Anyone, subscribers: Set(users), success: { (channel) -> Void in
            self.chat = channel
            self.onChannelCreated(channel)
            completion(error: nil)
        }) { (error) -> Void in
            completion(error: error)
            print("[ERROR] \(error.localizedDescription)")
        }
    }
}

