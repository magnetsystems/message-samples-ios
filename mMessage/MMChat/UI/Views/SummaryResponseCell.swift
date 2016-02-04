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

class SummaryResponseCell: UITableViewCell {
    
    @IBOutlet weak var vNewMessageIndicator : UIView!
    @IBOutlet weak var lblSubscribers : UILabel!
    @IBOutlet weak var lblLastTime : UILabel!
    @IBOutlet weak var lblMessage : UILabel!
    @IBOutlet weak var ivMessageIcon : UIImageView!
    
    var detailResponse : MMXChannelDetailResponse! {
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
                lblMessage.text = content[Constants.ContentKey.Message] ?? "Attachment file"
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
        if let lastViewTime = ChannelManager.sharedInstance.getLastViewTimeForChannel(detailResponse.channelName) {
            if let lastPublishedTime = ChannelManager.sharedInstance.formatter.dateForStringTime(detailResponse.lastPublishedTime!) {
                let result = lastViewTime.compare(lastPublishedTime)
                if result == .OrderedAscending {
                    return true
                } else {
                    return false
                }
            }
        } else if detailResponse.messages.count > 0 {
            return true
        }
        
        return false
    }
    
}
