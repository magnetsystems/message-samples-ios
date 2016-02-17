//
//  ChatViewController.swift
//  MMChat
//
//  Created by Kostya Grishchenko on 1/5/16.
//  Copyright © 2016 Kostya Grishchenko. All rights reserved.
//

import UIKit
import MagnetMax
import JSQMessagesViewController
import MobileCoreServices
import NYTPhotoViewer
//import Toucan

class ChatViewController: JSQMessagesViewController {
    
    var notifier : NavigationNotifier?
    var messages = [Message]()
    var avatars = Dictionary<String, UIImage>()
    var avatarsDownloading = Dictionary<String, MMUser>()
    let outgoingBubbleImageView = JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleBlueColor())
    let incomingBubbleImageView = JSQMessagesBubbleImageFactory().incomingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleLightGrayColor())
    var activityIndicator : UIActivityIndicatorView?
    var canLeaveChat = false
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
                            //                    MMUser.searchUsers("email:*\(kMagnetEmailDomain)", limit: 50, offset: 0, sort: "firstName:asc", success: { users in
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
    
    // MARK: - View
    
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
        //        showLoadEarlierMessagesHeader = true
        //        collectionView!.collectionViewLayout.incomingAvatarViewSize = CGSizeZero;
        //        collectionView!.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero;
        
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
        if let chat = self.chat, let lastMessage = messages.last?.underlyingMessage, let timestamp = lastMessage.timestamp {
            ChannelManager.sharedInstance.saveLastViewTimeForChannel(chat, message: lastMessage, date:timestamp)
        } else  if let chat = self.chat {
            ChannelManager.sharedInstance.saveLastViewTimeForChannel(chat, date:NSDate.init())
        }
    }
    
    deinit {
        // Save the last channel show
        ChannelManager.sharedInstance.removeChannelMessageObserver(self)
        print("--------> deinit chat <---------")
        NSNotificationCenter.defaultCenter().removeObserver(self)
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
    
    // MARK: - MMX methods
    
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
    
    //MARK: - overriden JSQMessagesViewController methods
    
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
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
        return messages[indexPath.item]
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, didDeleteMessageAtIndexPath indexPath: NSIndexPath!) {
        messages.removeAtIndex(indexPath.item)
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageBubbleImageDataSource! {
        
        let message = messages[indexPath.item]
        if message.senderId() == senderId {
            return outgoingBubbleImageView
        }
        
        return incomingBubbleImageView
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageAvatarImageDataSource! {
        return nil
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, attributedTextForCellTopLabelAtIndexPath indexPath: NSIndexPath!) -> NSAttributedString! {
        if indexPath.item % 3 == 0 {
            let message = messages[indexPath.item]
            return JSQMessagesTimestampFormatter.sharedFormatter().attributedTimestampForDate(message.date())
        }
        
        return nil
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, attributedTextForMessageBubbleTopLabelAtIndexPath indexPath: NSIndexPath!) -> NSAttributedString! {
        let message = messages[indexPath.item]
        
        if message.senderId() == senderId {
            return nil
        }
        
        if indexPath.item - 1 > 0 {
            let previousMessage = messages[indexPath.item - 1]
            if previousMessage.senderId() == message.senderId() {
                return nil
            }
        }
        
        // Don't specify attributes to use the defaults.
        
        return NSAttributedString(string: message.senderDisplayName())
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, attributedTextForCellBottomLabelAtIndexPath indexPath: NSIndexPath!) -> NSAttributedString! {
        return nil
    }
    
    // MARK: UICollectionView DataSource
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAtIndexPath: indexPath) as! JSQMessagesCollectionViewCell
        let message = messages[indexPath.item]
        
        if !message.isMediaMessage() {
            if message.senderId() == senderId {
                cell.textView!.textColor = UIColor.whiteColor()
            } else {
                cell.textView!.textColor = UIColor.blackColor()
            }
            
            cell.textView!.linkTextAttributes = [
                NSForegroundColorAttributeName : cell.textView?.textColor as! AnyObject,
                NSUnderlineStyleAttributeName : NSUnderlineStyle.StyleSingle.rawValue | NSUnderlineStyle.PatternSolid.rawValue
            ]
            
        }
        
        if cell.avatarImageView?.image == nil {
            cell.avatarImageView?.layer.masksToBounds = true
            cell.avatarImageView?.contentMode = UIViewContentMode.ScaleAspectFill
        }
        //cell.avatarImageView!.image = avatar
        if let layout = collectionView.collectionViewLayout as? JSQMessagesCollectionViewFlowLayout {
            cell.avatarImageView?.layer.cornerRadius = layout.incomingAvatarViewSize.width/2.0
        }
        if let user = message.underlyingMessage.sender {
            Utils.loadUserAvatar(user, toImageView: cell.avatarImageView!, placeholderImage: Utils.noAvatarImageForUser(user))
        }
        
        return cell
    }
    
    // MARK: JSQMessagesCollectionViewDelegateFlowLayout methods
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellTopLabelAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        //Each label in a cell has a `height` delegate method that corresponds to its text dataSource method
        
        /**
        *  This logic should be consistent with what you return from `attributedTextForCellTopLabelAtIndexPath:`
        *  The other label height delegate methods should follow similarly
        *  Show a timestamp for every 3rd message
        */
        if indexPath.item % 3 == 0 {
            return kJSQMessagesCollectionViewCellLabelHeightDefault
        }
        
        return 0.0
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForMessageBubbleTopLabelAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        
        let currentMessage = messages[indexPath.item]
        if currentMessage.senderId() == senderId {
            return 0.0
        }
        
        if indexPath.item - 1 > 0 {
            let previousMessage = messages[indexPath.item - 1]
            if previousMessage.senderId() == currentMessage.senderId() {
                return 0.0
            }
        }
        
        return kJSQMessagesCollectionViewCellLabelHeightDefault
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellBottomLabelAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        return 0.0
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, header headerView: JSQMessagesLoadEarlierHeaderView!, didTapLoadEarlierMessagesButton sender: UIButton!) {
        print("Load earlier messages!")
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, didTapAvatarImageView avatarImageView: UIImageView!, atIndexPath indexPath: NSIndexPath!) {
        print("Tapped avatar!")
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, didTapMessageBubbleAtIndexPath indexPath: NSIndexPath!) {
        print("Tapped message bubble!")
        let message = messages[indexPath.item]
        
        if message.isMediaMessage() && message.isDownloaded {
            self.inputToolbar!.contentView!.textView?.resignFirstResponder()
            
            switch message.type {
            case .Text: break
            case .Location:
                self.performSegueWithIdentifier(kSegueShowMap, sender: message.media())
            case .Photo:
                let photoItem = message.media() as! JSQPhotoMediaItem
                let photo = Photo(photo: photoItem.image)
                let viewer = NYTPhotosViewController(photos: [photo])
                presentViewController(viewer, animated: true, completion: nil)
            case .Video:
                if let attachment = message.underlyingMessage.attachments?.first where attachment.name != nil {
                    let videoVC = VideoPlayerViewController(nibName: vc_id_VideoPlayer, bundle: nil)
                    videoVC.attachment = attachment
                    presentViewController(videoVC, animated: true, completion: nil)
                }
            }
        }
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, didTapCellAtIndexPath indexPath: NSIndexPath!, touchLocation: CGPoint) {
    }
    
    // MARK: Helper methods
    
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
    
    private func addMediaMessageFromLibrary() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .PhotoLibrary
        imagePicker.mediaTypes = [kUTTypeMovie as String, kUTTypeImage as String]
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    private func addMediaMessageFromCamera() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .Camera
        imagePicker.mediaTypes = [kUTTypeMovie as String, kUTTypeImage as String]
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    private func getChannelBySubscribers(users: [MMUser]) {
        //Check if channel exists
        MMXChannel.findChannelsBySubscribers(users, matchType: .EXACT_MATCH, success: { [weak self] allChannels in
            let channels = allChannels.filter { !$0.name.hasPrefix("global_") }
            if channels.count != 1 {
                //Create new chat
                let subscribers = Set(users)
                
                // Set channel name
                //                let name = "\(self!.senderDisplayName)_\(ChannelManager.sharedInstance.formatter.currentTimeStamp())"
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
    
    private func showSpinner() {
        self.activityIndicator?.tag++
        self.activityIndicator?.startAnimating()
    }
    
    private func hideSpinner() {
        if let activityIndicator = self.activityIndicator {
            activityIndicator.tag = max(activityIndicator.tag - 1, 0)
            if activityIndicator.tag == 0 {
                activityIndicator.stopAnimating()
            }
        }
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        var newMessages:[Message] = []
        for message in messages {
            newMessages.append(Message(message: message.underlyingMessage))
        }
        messages = newMessages
    }
}

extension ChatViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            
            let messageContent = [Constants.ContentKey.Type: MessageType.Photo.rawValue]
            let mmxMessage = MMXMessage(toChannel: chat!, messageContent: messageContent)
            
            if let data = UIImageJPEGRepresentation(pickedImage, 0.8) {
                
                let attachment = MMAttachment(data: data, mimeType: "image/jpg")
                mmxMessage.addAttachment(attachment)
                showSpinner()
                mmxMessage.sendWithSuccess({ [weak self] _ in
                    self?.hideSpinner()
                    }) { error in
                        self.hideSpinner()
                        print(error)
                }
                finishSendingMessageAnimated(true)
            }
        } else if let urlOfVideo = info[UIImagePickerControllerMediaURL] as? NSURL {
            let messageContent = [Constants.ContentKey.Type: MessageType.Video.rawValue]
            let name = urlOfVideo.lastPathComponent
            let mmxMessage = MMXMessage(toChannel: chat!, messageContent: messageContent)
            let attachment = MMAttachment(fileURL: urlOfVideo, mimeType: "video/quicktime", name: name, description: "Video file")
            showSpinner()
            mmxMessage.addAttachment(attachment)
            mmxMessage.sendWithSuccess({ [weak self] _ in
                self?.hideSpinner()
                }) { error in
                    self.hideSpinner()
                    print(error)
            }
            finishSendingMessageAnimated(true)
        }
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}

