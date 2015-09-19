//
//  MessagesViewController.swift
//  Hola
//
//  Created by Pritesh Shah on 9/8/15.
//  Copyright (c) 2015 Magnet Systems, Inc. All rights reserved.
//

import Foundation
import JSQMessagesViewController
import MMX

class MessagesViewController : JSQMessagesViewController, UIActionSheetDelegate {
    
	var messages = [JSQMessageData]()
	var recipients = Set<MMXUser>()
    var avatars = Dictionary<String, UIImage>()
    var outgoingBubbleImageView = JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleLightGrayColor())
    var incomingBubbleImageView = JSQMessagesBubbleImageFactory().incomingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleBlueColor())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        senderId = MMXUser.currentUser().username
        senderDisplayName = MMXUser.currentUser().displayName
        
        showLoadEarlierMessagesHeader = true
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
		if recipients.count == 1 {
			let user = recipients.first
			navigationItem.title = user?.displayName
		} else {
			navigationItem.title = "Group"
		}
        // 8. Receive the message
        // Indicate that you are ready to receive messages now!
        MMX.start()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didReceiveMessage:", name: MMXDidReceiveMessageNotification, object: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func didReceiveMessage(notification: NSNotification) {

        /**
         *  Show the typing indicator to be shown
         */
        showTypingIndicator = !self.showTypingIndicator
        
        /**
         *  Scroll to actually view the indicator
         */
        scrollToBottomAnimated(true)
        
        /**
         *  Upon receiving a message, you should:
         *
         *  1. Play sound (optional)
         *  2. Add new id<JSQMessageData> object to your data source
         *  3. Call `finishReceivingMessage`
         */
        let tmp : [NSObject : AnyObject] = notification.userInfo!
        let mmxMessage = tmp[MMXMessageKey] as! MMXMessage
        
        /**
         *  Allow typing indicator to show
         */
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (Int64)(1.0 * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), {
            let message = Message(message: mmxMessage)
            self.messages.append(message)
            JSQSystemSoundPlayer.jsq_playMessageReceivedSound()
            self.finishReceivingMessageAnimated(true)
            
            if message.isMediaMessage() {
                
                switch message.type {
                case .Text:
                    //return nil
                    print("Text")
                case .Location:
                    let location = CLLocation(latitude: (mmxMessage.messageContent["latitude"] as! NSString).doubleValue, longitude: (mmxMessage.messageContent["longitude"] as! NSString).doubleValue)
                    let locationMediaItem = JSQLocationMediaItem()
                    locationMediaItem.setLocation(location) {
                        self.collectionView?.reloadData()
                    }
                    message.mediaContent = locationMediaItem
                case .Photo:
                    let photoURL = NSURL(string: mmxMessage.messageContent["url"] as! String)
                    DownloadManager.sharedInstance.downloadImage(photoURL, completionHandler: { (image, error) -> Void in
                        if error == nil {
                            let photo = JSQPhotoMediaItem(image: image!)
                            message.mediaContent = photo
                            self.collectionView?.reloadData()
                        }
                    })
                    
                case .Video:
                    let videoURL = NSURL(string: mmxMessage.messageContent["url"] as! String)
                    DownloadManager.sharedInstance.downloadVideo(videoURL, completionHandler: { (url, error) -> Void in
                        if error == nil {
                            let video = JSQVideoMediaItem()
                            video.fileURL = url
                            video.isReadyToPlay = true
                            message.mediaContent = video
                            self.collectionView?.reloadData()
                        }
                    })
                }
            }
        })
    }
    
    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!) {
        
        /**
         *  Sending a message. Your implementation of this method should do *at least* the following:
         *
         *  1. Play sound (optional)
         *  2. Add new id<JSQMessageData> object to your data source
         *  3. Call `finishSendingMessage`
         */
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        
        let messageContent = [
            "type": MessageType.Text.rawValue,
            "message": text,
        ]
        let mmxMessage = MMXMessage(toRecipients: recipients, messageContent: messageContent)
        mmxMessage.sendWithSuccess( { () -> Void in
            let message = Message(message: mmxMessage)
            self.messages.append(message)
            self.finishSendingMessageAnimated(true)
        }) { (error) -> Void in
            print(error)
        }
    }
    
    override func didPressAccessoryButton(sender: UIButton!) {
        
        let alertController = UIAlertController(title: "Media messages", message: nil, preferredStyle: .Alert)
        
        let sendPhotoAction = UIAlertAction(title: "Send photo", style: .Default) { (_) in
            self.addPhotoMediaMessage()
        }
        let twoAction = UIAlertAction(title: "Send location", style: .Default) { (_) in
            self.addLocationMediaMessageCompletion()
        }
        let threeAction = UIAlertAction(title: "Send video", style: .Default) { (_) in
            self.addVideoMediaMessage()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (_) in }
        
        alertController.addAction(sendPhotoAction)
        alertController.addAction(twoAction)
        alertController.addAction(threeAction)
        alertController.addAction(cancelAction)
        
        self.presentViewController(alertController, animated: true) {
            // ...
        }
        
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
        let message = messages[indexPath.item]
        if let avatar = avatars[message.senderId()] {
            return JSQMessagesAvatarImageFactory.avatarImageWithImage(avatar, diameter: UInt(kJSQMessagesCollectionViewAvatarSizeDefault))
        } else {
            let avatarURL = NSURL(string: "https://graph.facebook.com/v2.2/\(message.senderId())/picture?type=large")
            DownloadManager.sharedInstance.downloadImage(avatarURL, completionHandler: { (image, error) -> Void in
                if error == nil {
                    self.avatars[message.senderId()] = image
                    collectionView.reloadItemsAtIndexPaths([indexPath])
                }
            })
        }
        
        let nameParts = message.senderDisplayName().componentsSeparatedByString(" ")
        let initials = (nameParts.map{($0 as NSString).substringToIndex(1)}.joinWithSeparator("") as NSString).substringToIndex(min(nameParts.count, 2)).uppercaseString
        
        return JSQMessagesAvatarImageFactory.avatarImageWithUserInitials(initials, backgroundColor: UIColor(white: 0.85, alpha: 1.0), textColor: UIColor(white: 0.65, alpha: 1.0), font: UIFont.systemFontOfSize(14.0), diameter: UInt(kJSQMessagesCollectionViewAvatarSizeDefault))
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
        
        /**
         *  iOS7-style sender name labels
         */
        if message.senderId() == senderId {
            return nil
        }
        
        if indexPath.item - 1 > 0 {
            let previousMessage = messages[indexPath.item - 1]
            if previousMessage.senderId()  == message.senderId() {
                return nil
            }
        }
        
        /**
         *  Don't specify attributes to use the defaults.
         */
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
            
            // FIXME: 1
            cell.textView!.linkTextAttributes = [
                NSForegroundColorAttributeName : cell.textView?.textColor as! AnyObject,
                NSUnderlineStyleAttributeName : NSUnderlineStyle.StyleSingle.rawValue | NSUnderlineStyle.PatternSolid.rawValue
            ]
        }
        
        return cell
    }
    
    // MARK: JSQMessagesCollectionViewDelegateFlowLayout methods
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellTopLabelAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        /**
         *  Each label in a cell has a `height` delegate method that corresponds to its text dataSource method
         */
        
        /**
         *  This logic should be consistent with what you return from `attributedTextForCellTopLabelAtIndexPath:`
         *  The other label height delegate methods should follow similarly
         *
         *  Show a timestamp for every 3rd message
         */
        if indexPath.item % 3 == 0 {
            return kJSQMessagesCollectionViewCellLabelHeightDefault
        }
        
        return 0.0
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForMessageBubbleTopLabelAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        /**
         *  iOS7-style sender name labels
         */
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
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, didTapCellAtIndexPath indexPath: NSIndexPath!, touchLocation: CGPoint) {
        print("Tapped cell at \(touchLocation)")
    }
    
    // MARK: Helper methods
    
    func currentRecipient() -> MMXUser {
        let currentRecipient = MMXUser()
        currentRecipient.username = "echo_bot"
        
        return currentRecipient
    }
    
    func addLocationMediaMessageCompletion() {
        let ferryBuildingInSF = CLLocation(latitude: 37.795313, longitude: -122.393757)

        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        
        let messageContent = [
            "type": MessageType.Location.rawValue,
            "latitude": "\(ferryBuildingInSF.coordinate.latitude)",
            "longitude": "\(ferryBuildingInSF.coordinate.longitude)"
        ]
        let mmxMessage = MMXMessage(toRecipients: recipients, messageContent: messageContent)
        mmxMessage.sendWithSuccess( { () -> Void in
            let message = Message(message: mmxMessage)
            let locationMediaItem = JSQLocationMediaItem()
            locationMediaItem.setLocation(ferryBuildingInSF) {
            }
            message.mediaContent = locationMediaItem
            self.messages.append(message)
            self.finishSendingMessageAnimated(true)
            }) { (error) -> Void in
                print(error)
        }
    }
    
    func addPhotoMediaMessage() {
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        
        let messageContent = [
            "type": MessageType.Photo.rawValue,
        ]
        let mmxMessage = MMXMessage(toRecipients: recipients, messageContent: messageContent)
        let imageName = "goldengate"
        let imageType = "png"
        let imagePath = NSBundle.mainBundle().pathForResource(imageName, ofType: imageType)
        mmxMessage.sendWithFileAttachment(imagePath, saveToS3Path: "/magnet_test/\(MMXUser.currentUser().username)/\(imageName).\(imageType)", progress: { (progress) -> Void in
            //
        }, success: { (url) -> Void in
            let message = Message(message: mmxMessage)
            let photo = JSQPhotoMediaItem(image: UIImage(data: NSData(contentsOfFile: imagePath!)!))
            message.mediaContent = photo
            self.messages.append(message)
            self.finishSendingMessageAnimated(true)
        }) { (error) -> Void in
            print(error)
        }
    }
    
    func addVideoMediaMessage() {
        
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        
        let messageContent = [
            "type": MessageType.Video.rawValue,
        ]
        
        let mmxMessage = MMXMessage(toRecipients: recipients, messageContent: messageContent)
        let videoName = "small"
        let videoType = "mp4"
        let videoPath = NSBundle.mainBundle().pathForResource(videoName, ofType: videoType)
        mmxMessage.sendWithFileAttachment(videoPath, saveToS3Path: "/magnet_test/\(MMXUser.currentUser().username)/\(videoName).\(videoType)", progress: { (progress) -> Void in
            //
            }, success: { (url) -> Void in
                let message = Message(message: mmxMessage)
                let video = JSQVideoMediaItem()
                video.fileURL = NSBundle.mainBundle().URLForResource(videoName, withExtension: videoType)
                video.isReadyToPlay = true
                message.mediaContent = video
                self.messages.append(message)
                self.finishSendingMessageAnimated(true)
            }) { (error) -> Void in
                print(error)
        }
    }
}
