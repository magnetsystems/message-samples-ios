//
//  ChannelDetailBaseTVCell.swift
//  Messenger
//
//  Created by Vladimir Yevdokimov on 2/10/16.
//  Copyright © 2016 Magnet Systems, Inc. All rights reserved.
//

import UIKit
import MagnetMax
import JSQMessagesViewController

class ChannelDetailBaseTVCell: UITableViewCell {
    
    @IBOutlet weak var vNewMessageIndicator : UIView?
    
    var detailResponse : MMXChannelDetailResponse? {
        didSet {
            vNewMessageIndicator?.hidden = !hasNewMessagesFromLastTime(useLastMessage : false)
        }
    }
    
    static func cellHeight() -> CGFloat {
        
        let nibs : [AnyObject]! = NSBundle.mainBundle().loadNibNamed(Utils.name(self.classForCoder()), owner: self, options: nil)
        
        let cellView = nibs.first as! UIView;
        
        return cellView.frame.size.height;
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        if let vNewMessageIndicator = self.vNewMessageIndicator {
            vNewMessageIndicator.layer.cornerRadius = vNewMessageIndicator.bounds.width / 2
            vNewMessageIndicator.clipsToBounds = true
        }
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    // MARK: - Helpers
    
    func hasNewMessagesFromLastTime(useLastMessage useLastMessage: Bool) -> Bool {
        if let detailResponse = self.detailResponse {
            if useLastMessage {
                if let lastMessageID = ChannelManager.sharedInstance.getLastMessageForChannel(detailResponse.channel) {
                    return lastMessageID != detailResponse.messages.last?.messageID
                }
            }
            
            if let lastViewTime = ChannelManager.sharedInstance.getLastViewTimeForChannel(detailResponse.channel) {
                if let sender = detailResponse.messages.last?.sender, let currentUser = MMUser.currentUser() where sender.userID  == currentUser.userID  {
                    return false
                }
                if let lastPublishedTime = detailResponse.lastPublishedTime {
                    
                    return lastViewTime.timeIntervalSince1970 < ChannelManager.sharedInstance.formatter.dateForStringTime(lastPublishedTime)?.timeIntervalSince1970
                    
                }
            }
        }
        
        return true
    }
    
    
}
