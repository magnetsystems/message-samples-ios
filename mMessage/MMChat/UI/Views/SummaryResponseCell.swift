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
    
    var summaryResponse : MMXChannelSummaryResponse! {
        didSet {
            if var subscribers = summaryResponse.subscribers as? [MMXUserInfo] {
                var subscribersTitle = ""
                var index: Int?
                subscribers.forEach({ user in
                    if user.userId == MMUser.currentUser()?.userID {
                        index = subscribers.indexOf(user)!
                    }
                })
                // Exclude currentUser
                if let _ = index { subscribers.removeAtIndex(index!) }
                
                for user in subscribers {
                    subscribersTitle += (subscribers.indexOf(user) == subscribers.count - 1) ? user.displayName! : "\(user.displayName!), "
                }
                lblSubscribers.text = subscribersTitle
            }
            if let messages = summaryResponse.messages as? [MMXPubSubItemChannel], content = messages.last?.content as! [String : String]! {
                lblMessage.text = content[Constants.ContentKey.Message] ?? "Attachment file"
            } else {
                lblMessage.text = ""
            }
            
            lblLastTime.text = ChannelManager.sharedInstance.formatter.displayTime(summaryResponse.lastPublishedTime!)
            ivMessageIcon.image = (summaryResponse.subscribers.count > 2) ? UIImage(named: "messages.png") : UIImage(named: "message.png")
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
        if let lastViewTime = ChannelManager.sharedInstance.getLastViewTimeForChannel(summaryResponse.channelName) {
            if let lastPublishedTime = ChannelManager.sharedInstance.formatter.dateForStringTime(summaryResponse.lastPublishedTime!) {
                let result = lastViewTime.compare(lastPublishedTime)
                if result == .OrderedAscending {
                    return true
                } else {
                    return false
                }
            }
        } else if summaryResponse.messages.count > 0 {
            return true
        }
        
        return false
    }

}
