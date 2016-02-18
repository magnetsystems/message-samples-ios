/*
* Copyright (c) 2015 Magnet Systems, Inc.
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
