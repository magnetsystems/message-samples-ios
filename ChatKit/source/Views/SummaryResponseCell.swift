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

import MagnetMax
import UIKit

class SummaryResponseCell: ChannelDetailBaseTVCell {
    
    
    //MARK: Static properties
    
    
    static var images : [String : UIImage] = [:]
    
    
    //MARK: Public properties
    
    
    @IBOutlet weak var ivMessageIcon : UIImageView?
    @IBOutlet weak var lblSubscribers : UILabel?
    @IBOutlet weak var lblLastTime : UILabel?
    @IBOutlet weak var lblMessage : UILabel?
    
    
    //MARK: Overridden Properties
    
    
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
            
            lblSubscribers?.text = subscribersTitle
            
            if let messages = detailResponse.messages, content = messages.last?.messageContent {
                lblMessage?.text = content[Constants.ContentKey.Message] ?? kStr_AttachmentFile
            } else {
                lblMessage?.text = ""
            }
            
            lblLastTime?.text = ChannelManager.sharedInstance.formatter.displayTime(detailResponse.lastPublishedTime!)
            if detailResponse.subscribers.count > 2 {
                ivMessageIcon?.image = UIImage(named: "user_group.png")
            } else if let userProfile = subscribers.first {
                let tmpUser = MMUser()
                tmpUser.extras = ["hasAvatar" : "true"]
                tmpUser.firstName = ""
                tmpUser.lastName = ""
                tmpUser.userName = userProfile.displayName
                tmpUser.userID = userProfile.userId
                let nameComponents = userProfile.displayName.componentsSeparatedByString(" ")
                if let firstName = nameComponents.first {
                    tmpUser.firstName = firstName
                }
                
                if nameComponents.count > 1 {
                    tmpUser.lastName = nameComponents[1]
                }
                
                if let avatarImage = self.ivMessageIcon {
                    if let image = SummaryResponseCell.images[tmpUser.userID] {
                        avatarImage.image = image
                    } else {
                        avatarImage.image = nil
                        let placeHolderImage = Utils.noAvatarImageForUser(tmpUser)
                        if let url = tmpUser.avatarURL() {
                            Utils.loadImageWithUrl(url, toImageView: avatarImage, placeholderImage: placeHolderImage, onlyShowAfterDownload: true, completion: { image in
                                SummaryResponseCell.images[tmpUser.userID] = image
                            })
                        } else {
                            avatarImage.image = placeHolderImage
                        }
                    }
                }
            }
        }
    }
    
    
    //MARK: Overrides
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        if let ivMessageIcon = ivMessageIcon {
            ivMessageIcon.layer.cornerRadius = ivMessageIcon.bounds.width / 2
            ivMessageIcon.clipsToBounds = true
        }
    }
}
