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

import JSQMessagesViewController
import MagnetMax
import UIKit

class EventChannelTableViewCell: ChannelDetailBaseTVCell {
    
    
    //MARK: Public properties
    
    
    @IBOutlet weak var channelDesrL: UILabel!
    @IBOutlet weak var totalSubscribersL: UILabel!
    @IBOutlet weak var backgroundIV: UIImageView!
    
    
    //MARK: Overridden Properties
    
    
    override var detailResponse : MMXChannelDetailResponse! {
        didSet {
            super.detailResponse = self.detailResponse
            
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
    
    
    //MARK: Overrides
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}
