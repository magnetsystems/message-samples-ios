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

class ChatViewController: JSQMessagesViewController {
    
    var messages = [JSQMessageData]()
    var avatars = Dictionary<String, UIImage>()
    let outgoingBubbleImageView = JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleLightGrayColor())
    let incomingBubbleImageView = JSQMessagesBubbleImageFactory().incomingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleBlueColor())
    
    var chat : MMXChannel? {
        didSet {
            loadMessages()
        }
    }
    
    var recipients : [MMUser]! {
        didSet {
            if recipients.count == 1 {
                navigationItem.title = MMUser.currentUser()?.firstName
            } else if recipients.count == 2 {
                var users = recipients
                if let currentUser = MMUser.currentUser(), index = users.indexOf(currentUser) {
                    users.removeAtIndex(index)
                }
                navigationItem.title = users.first?.firstName!
            } else {
                navigationItem.title = "Group"
            }
        }
    }
    
    // MARK: - View
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let user = MMUser.currentUser() else {
            return
        }
        
        //Register for a notification to receive the message
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didReceiveMessage:", name: MMXDidReceiveMessageNotification, object: nil)
        
        senderId = user.userID
        senderDisplayName = user.firstName
//        showLoadEarlierMessagesHeader = true
        collectionView!.collectionViewLayout.incomingAvatarViewSize = CGSizeZero;
        collectionView!.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero;
        
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
    
    deinit {
        print("--------> deinit chat <---------")
        NSNotificationCenter.defaultCenter().removeObserver(self)
        // Save the last channel show
        if let _ = chat {
            ChannelManager.sharedInstance.saveLastViewTimeForChannel(chat!.name)
        }
    }
    
    // MARK: - Public methods
    
    func addSubscribers(newSubscribers: [MMUser]) {
        
        guard let _ = recipients, let _ = chat else {
            print("Add subscribers error")
            return
        }
        
        let allSubscribers = Array(Set(newSubscribers + self.recipients))
        
        //Check if channel exists
        MMXChannel.findChannelsBySubscribers(allSubscribers, matchType: .EXACT_MATCH, success: { [weak self] channels in
            if channels.count == 1 {
                //FIXME: temporary solution
                let channelInfos : AnyObject = channels
                if let channelInfo = channelInfos as? [MMXChannelInfo] {
                    // Use existing channel
                    self?.chat = ChannelManager.sharedInstance.channelForName(channelInfo.first!.name)
                    self?.recipients = allSubscribers
                }
            } else if channels.count == 0 {
                self?.chat?.addSubscribers(newSubscribers, success: { [weak self] _ in
                    self?.recipients = allSubscribers
                }, failure: { error in
                    print("[ERROR]: can't add subscribers - \(error)")
                })
            }
        }, failure: { error in
            print("[ERROR]: \(error)")
        })
    }
    
    // MARK: - MMX methods
    
    func didReceiveMessage(notification: NSNotification) {
        
        let tmp : [NSObject : AnyObject] = notification.userInfo!
        let mmxMessage = tmp[MMXMessageKey] as! MMXMessage
        //Check if message is for current chat
        if chat?.name != mmxMessage.channel?.name { return }
        
        //Show the typing indicator to be shown
        showTypingIndicator = !self.showTypingIndicator
        
        // Scroll to actually view the indicator
        scrollToBottomAnimated(true)
        
        // Allow typing indicator to show
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (Int64)(1.0 * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), { [weak self] () in
            let message = Message(message: mmxMessage)
            self?.messages.append(message)
            JSQSystemSoundPlayer.jsq_playMessageReceivedSound()
            
            if message.isMediaMessage() {
                message.mediaCompletionBlock = { [weak self] in self?.collectionView?.reloadData() }
            }
            
            self?.finishReceivingMessageAnimated(true)
        })
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

        let mmxMessage = MMXMessage(toChannel: channel, messageContent: messageContent)
        mmxMessage.sendWithSuccess( { [weak self] _ in
            self?.finishSendingMessageAnimated(true)
        }) { error in
            print(error)
        }
    }
    
    override func didPressAccessoryButton(sender: UIButton!) {
        
        guard let _ = self.chat else { return }
        
        self.inputToolbar!.contentView!.textView?.resignFirstResponder()
        
        let alertController = UIAlertController(title: "Media messages", message: nil, preferredStyle: .ActionSheet)
        
        let sendPhotoAction = UIAlertAction(title: "Send photo", style: .Default) { (_) in
            self.addPhotoMediaMessage()
        }
        let sendLocationAction = UIAlertAction(title: "Send location", style: .Default) { (_) in
            self.addLocationMediaMessage()
        }
        let sendVideoAction = UIAlertAction(title: "Send video", style: .Default) { (_) in
            self.addVideoMediaMessage()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (_) in }
        
        alertController.addAction(sendPhotoAction)
        alertController.addAction(sendLocationAction)
        alertController.addAction(sendVideoAction)
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
                cell.textView!.textColor = UIColor.blackColor()
            } else {
                cell.textView!.textColor = UIColor.whiteColor()
            }
            
            cell.textView!.linkTextAttributes = [
                NSForegroundColorAttributeName : cell.textView?.textColor as! AnyObject,
                NSUnderlineStyleAttributeName : NSUnderlineStyle.StyleSingle.rawValue | NSUnderlineStyle.PatternSolid.rawValue
            ]
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
        let message = messages[indexPath.item] as! Message
        
        if message.isMediaMessage() {
            self.inputToolbar!.contentView!.textView?.resignFirstResponder()
            
            switch message.type {
            case .Text: break
            case .Location:
                self.performSegueWithIdentifier("showMapViewController", sender: message.media())
            case .Photo:
                let photoItem = message.media() as! JSQPhotoMediaItem
                let photo = Photo(photo: photoItem.image)
                let viewer = NYTPhotosViewController(photos: [photo])
                presentViewController(viewer, animated: true, completion: nil)
            case .Video:
                if let attachment = message.underlyingMessage.attachments?.first where attachment.name != nil {
                    let videoVC = VideoPlayerViewController(nibName: "VideoPlayerViewController", bundle: nil)
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
            let mmxMessage = MMXMessage(toChannel: (self?.chat)!, messageContent: messageContent)
            mmxMessage.sendWithSuccess( { _ in
                self?.finishSendingMessageAnimated(true)
            }) { error in
                print("[ERROR]: \(error)")
            }
        }
    }
    
    private func addPhotoMediaMessage() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .PhotoLibrary
        
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    private func addVideoMediaMessage() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .PhotoLibrary
        imagePicker.mediaTypes = [kUTTypeMovie as String]
        
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    private func getChannelBySubscribers(users: [MMUser]) {
        //Check if channel exists
        MMXChannel.findChannelsBySubscribers(users, matchType: .EXACT_MATCH, success: { [weak self] channels in
            if channels.count == 0 {
                //Create new chat
                let subscribers = Set(users)
                
                // Set channel name
                let name = "\(self!.senderDisplayName)_\(ChannelManager.sharedInstance.formatter.currentTimeStamp())"
                
                MMXChannel.createWithName(name, summary: "\(self!.senderDisplayName) private chat", isPublic: false, publishPermissions: .Subscribers, subscribers: subscribers, success: { [weak self] channel in
                    self?.chat = channel
                }, failure: { [weak self] error in
                    print("[ERROR]: \(error)")
                    let alert = Popup(message: error.localizedDescription, title: error.localizedFailureReason ?? "", closeTitle: "Close", handler: { _ in
                        self?.navigationController?.popViewControllerAnimated(true)
                    })
                    alert.presentForController(self!)
                })
            } else if channels.count == 1 {
                //FIXME: temp solution
                let info : AnyObject = channels
                if let channelInfo = info as? [MMXChannelInfo] {
                    self?.chat = ChannelManager.sharedInstance.channelForName(channelInfo.first!.name)
                }
                
                //Use existing
                //                self?.chat = channels.first
            }
            }) { error in
                print("[ERROR]: \(error)")
                let alert = Popup(message: error.localizedDescription, title: error.localizedFailureReason ?? "", closeTitle: "Close", handler: { _ in
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
        if segue.identifier == "showDetailsSegue" {
            if let detailVC = segue.destinationViewController as? DetailsViewController {
                detailVC.recipients = recipients
                detailVC.channel = chat
            }
        } else if segue.identifier == "showMapViewController" {
            if let locationItem = sender as? JSQLocationMediaItem {
                let mapVC = segue.destinationViewController as! MapViewController
                mapVC.location = locationItem.coordinate
            }
        }
    }
}

extension ChatViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {

        JSQSystemSoundPlayer.jsq_playMessageSentSound()

        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            
            let messageContent = [Constants.ContentKey.Type: MessageType.Photo.rawValue]
            let mmxMessage = MMXMessage(toChannel: chat!, messageContent: messageContent)
            if let data = UIImagePNGRepresentation(pickedImage) {
            
                let attachment = MMAttachment(data: data, mimeType: "image/*")
                mmxMessage.addAttachment(attachment)
                mmxMessage.sendWithSuccess({ [weak self] _ in
                    self?.finishSendingMessageAnimated(true)
                }) { error in
                    print(error)
                }
            }
        } else if let urlOfVideo = info[UIImagePickerControllerMediaURL] as? NSURL {
            let messageContent = [Constants.ContentKey.Type: MessageType.Video.rawValue]
            let name = urlOfVideo.lastPathComponent
            let mmxMessage = MMXMessage(toChannel: chat!, messageContent: messageContent)
            let attachment = MMAttachment(fileURL: urlOfVideo, mimeType: "video/quicktime", name: name, description: "Video file")
            mmxMessage.addAttachment(attachment)
            mmxMessage.sendWithSuccess({ [weak self] _ in
                self?.finishSendingMessageAnimated(true)
            }) { error in
                print(error)
            }
        }
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}
