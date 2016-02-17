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
    
    @IBOutlet weak var lblSubscribers : UILabel!
    @IBOutlet weak var lblLastTime : UILabel!
    @IBOutlet weak var lblMessage : UILabel!
    @IBOutlet weak var ivMessageIcon : UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        ivMessageIcon.layer.cornerRadius = ivMessageIcon.bounds.width / 2
        ivMessageIcon.clipsToBounds = true
    }
    
    override var detailResponse : MMXChannelDetailResponse! {
        didSet {
            super.detailResponse = self.detailResponse
            
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
            if self.detailResponse.channelName != kAskMagnetChannel {
                lblSubscribers.text = subscribersTitle
            } else {
                lblSubscribers.text = "Ask Magnet"
            }
            
            if let messages = detailResponse.messages, content = messages.last?.messageContent {
                lblMessage.text = content[Constants.ContentKey.Message] ?? kStr_AttachmentFile
            } else {
                lblMessage.text = ""
            }
            
            lblLastTime.text = ChannelManager.sharedInstance.formatter.displayTime(detailResponse.lastPublishedTime!)
            if detailResponse.subscribers.count > 2 {
                ivMessageIcon.image = UIImage(named: "user_group.png")
            } else if let userProfile = subscribers.first {
                MMUser.usersWithUserIDs([userProfile.userId], success: { [weak self] users in
                    if let user = users.first {
                        self?.ivMessageIcon.image = Utils.noAvatarImageForUser(user)
                        if let url = user.avatarURL() {
                            self?.ivMessageIcon.setImageWithURL(url)
                        }
                    }
                    }, failure: { error in
                        print("[ERROR]: \(error)")
                })
            }
        }
    }
}
