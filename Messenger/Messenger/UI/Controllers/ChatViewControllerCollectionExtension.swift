//ChatViewControllerCollectionExtension.swift
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
import NYTPhotoViewer
import MagnetMax

extension ChatViewController {
    
    
    //MARK: - overridden JSQMessagesViewController methods
    
    override func collectionView(collectionView: UICollectionView, shouldShowMenuForItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func collectionView(collectionView: UICollectionView, canPerformAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) -> Bool {
        if action == Selector("report:") && messages[indexPath.item].senderId() != MMUser.currentUser()?.userID {
            return true
        }
        
        return super.collectionView(collectionView, canPerformAction:action, forItemAtIndexPath:indexPath, withSender:sender)
    }
    
    override func collectionView(collectionView: UICollectionView, performAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) {
        if  action == Selector("report:"){
            print("REPORT THIS MESSAGE!!!")
            showAdditionalMessageOptions()
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
        if messages[indexPath.item].senderId() != MMUser.currentUser()?.userID {
            if let sender = messages[indexPath.item].underlyingMessage.sender {
                showAdditionalAvatarOptions(sender)
            }
        }
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
    
    // MARK: - Private implementation
    
    private func showAdditionalAvatarOptions(user: MMUser) {
        let alertController = UIAlertController(title: kStr_AdditionalOptions, message: nil, preferredStyle: .ActionSheet)
        
        let blockUser = UIAlertAction(title: kStr_BlockUser, style: .Destructive) { _ in
            let confirmationAlert = Popup(message: kStr_BlockUserConfirmation, title: kStr_BlockUser, closeTitle: kStr_No)
            let okAction = UIAlertAction(title: kStr_Yes, style: .Default) { _ in
                MMUser.blockUsers([user], success: { [weak self] in
                    print("blocked \(user.userName)")
                    self?.loadMessages()
                }, failure: { error in
                    //
                })
            }
            confirmationAlert.addAction(okAction)
            confirmationAlert.presentForController(self)
        }
        let cancelAction = UIAlertAction(title: kStr_Cancel, style: .Cancel) { _ in }
        
        alertController.addAction(blockUser)
        alertController.addAction(cancelAction)
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    private func showAdditionalMessageOptions() {
        let confirmationAlert = Popup(message: kStr_ReportConfirmation, title: kStr_Report, closeTitle: kStr_No)
        let okAction = UIAlertAction(title: kStr_Yes, style: .Default) { _ in
        }
        confirmationAlert.addAction(okAction)
        confirmationAlert.presentForController(self)
    }
}

