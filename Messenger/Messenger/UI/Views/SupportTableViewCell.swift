//
//  SupportTableViewCell.swift
//  Messenger
//
//  Created by Kostya Grishchenko on 2/16/16.
//  Copyright © 2016 Magnet Systems, Inc. All rights reserved.
//

import UIKit
import MagnetMax

class SupportTableViewCell: ChannelDetailBaseTVCell {
    
    @IBOutlet weak var lblAsker : UILabel!
    @IBOutlet weak var lblLastTime : UILabel!
    @IBOutlet weak var lblMessage : UILabel!
    @IBOutlet weak var ivAvatarImage : UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let borderSize:CGFloat = 40.0
        ivAvatarImage.layer.cornerRadius = borderSize / 2.0
        ivAvatarImage.layer.masksToBounds = true
        ivAvatarImage.translatesAutoresizingMaskIntoConstraints = false
    }
    
    override var detailResponse : MMXChannelDetailResponse! {
        didSet {
            super.detailResponse = self.detailResponse
            
            let subscribers : [MMUserProfile] = detailResponse.subscribers.filter({ $0.userId == detailResponse.channel.ownerUserID })
            lblAsker.text = subscribers.first?.displayName
            
            if let messages = detailResponse.messages, content = messages.last?.messageContent {
                lblMessage.text = content[Constants.ContentKey.Message] ?? kStr_AttachmentFile
            } else {
                lblMessage.text = ""
            }
            
            lblLastTime.text = ChannelManager.sharedInstance.formatter.displayTime(detailResponse.lastPublishedTime!)
        }
    }

}
