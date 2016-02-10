//
//  EventChannelTableViewCell.swift
//  Messenger
//
//  Created by Vladimir Yevdokimov on 2/10/16.
//  Copyright © 2016 Magnet Systems, Inc. All rights reserved.
//

import UIKit
import MagnetMax
import JSQMessagesViewController

class EventChannelTableViewCell: ChannelDetailBaseTVCell {

    @IBOutlet weak var channelDesrL: UILabel!
    @IBOutlet weak var totalSubscribersL: UILabel!
    @IBOutlet weak var backgroundIV: UIImageView!

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    override var detailResponse : MMXChannelDetailResponse! {
        didSet {
            
            if detailResponse.channel.summary!.containsString("Week") {
                backgroundIV.image = UIImage(named: "bg_img_1")
            } else if detailResponse.channel.summary!.containsString("Disrupt") {
                backgroundIV.image = UIImage(named: "bg_img_2")
            } else if detailResponse.channel.summary!.containsString("AnDevCon") {
                backgroundIV.image = UIImage(named: "bg_img_3");
            }
            
            channelDesrL.text = detailResponse.channel.summary
            
            let subscribers : [MMUserProfile] = detailResponse.subscribers
            
            totalSubscribersL.text = "\(subscribers.count) Subscribers"
            
        }
    }

//    private func hasNewMessagesFromLastTime() -> Bool {
//        if let lastMessageID = ChannelManager.sharedInstance.getLastMessageForChannel(detailResponse.channelName) {
//            return lastMessageID != detailResponse.messages.last?.messageID
//        }
//        if let lastViewTime = ChannelManager.sharedInstance.getLastViewTimeForChannel(detailResponse.channelName) {
//            if let lastPublishedTime = detailResponse.lastPublishedTime {
//                
//                return lastViewTime.timeIntervalSince1970 < ChannelManager.sharedInstance.formatter.dateForStringTime(lastPublishedTime)?.timeIntervalSince1970
//                
//            }
//        }
//        
//        return false
//    }
}
