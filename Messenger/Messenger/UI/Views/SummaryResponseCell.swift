//
//  SummaryResponseCell.swift
//  MMChat
//
//  Created by Kostya Grishchenko on 1/4/16.
//  Copyright © 2016 Kostya Grishchenko. All rights reserved.
//

import UIKit
import MagnetMax
import JSQMessagesViewController

class SummaryResponseCell: ChannelDetailBaseTVCell {
    
    @IBOutlet weak var vNewMessageIndicator : UIView!
    @IBOutlet weak var lblSubscribers : UILabel!
    @IBOutlet weak var lblLastTime : UILabel!
    @IBOutlet weak var lblMessage : UILabel!
    @IBOutlet weak var ivMessageIcon : UIImageView!
    
    override var detailResponse : MMXChannelDetailResponse! {
        didSet {
            var subscribers : [MMUserProfile] = detailResponse.subscribers
            
            subscribers = subscribers.filter({
                if $0.userId != MMUser.currentUser()?.userID {
                    return true
                }
                return false
            })
            var subscribersTitle = ""
            
            for user in subscribers {
                if let displayName = user.displayName {
                subscribersTitle += (subscribers.indexOf(user) == subscribers.count - 1) ? displayName : "\(displayName), "
                }
            }
            lblSubscribers.text = subscribersTitle
            
            if let messages = detailResponse.messages, content = messages.last?.messageContent {
                lblMessage.text = content[Constants.ContentKey.Message] ?? kStr_AttachmentFile
            } else {
                lblMessage.text = ""
            }
            
            lblLastTime.text = ChannelManager.sharedInstance.formatter.displayTime(detailResponse.lastPublishedTime!)
            ivMessageIcon.image = (detailResponse.subscribers.count > 2) ? UIImage(named: "messages.png") : UIImage(named: "message.png")
            vNewMessageIndicator.hidden = !hasNewMessagesFromLastTime()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        vNewMessageIndicator.layer.cornerRadius = vNewMessageIndicator.bounds.width / 2
        vNewMessageIndicator.clipsToBounds = true
    }
    
    // MARK: - Helpers
    
    private func hasNewMessagesFromLastTime() -> Bool {
        if let lastMessageID = ChannelManager.sharedInstance.getLastMessageForChannel(detailResponse.channelName) {
         return lastMessageID != detailResponse.messages.last?.messageID
        }
        if let lastViewTime = ChannelManager.sharedInstance.getLastViewTimeForChannel(detailResponse.channelName) {
        if let lastPublishedTime = detailResponse.lastPublishedTime {
        
            return lastViewTime.timeIntervalSince1970 < ChannelManager.sharedInstance.formatter.dateForStringTime(lastPublishedTime)?.timeIntervalSince1970
        
        }
        }
        
        return false
    }
    
}
