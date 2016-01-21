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

class ChannelCell: UITableViewCell {
    
    
    // MARK: Outlets
    
    
    @IBOutlet weak var ivPrivate: UIImageView!
    @IBOutlet weak var lblChannelName: UILabel!
    @IBOutlet weak var lblLastTime: UILabel!
    @IBOutlet weak var lblTags: UILabel!
    
    
    // MARK: Public properties
    
    
    var channel : MMXChannel! {
        didSet {
            lblChannelName.text = channel.name
            ivPrivate.image = channel.isPublic ? nil : UIImage(named: "lock-7.png")
            
            let formatter = NSDateFormatter()
            formatter.timeStyle = .ShortStyle
            lblLastTime.text = formatter.stringFromDate(channel.lastTimeActive)
            
            channel.tagsWithSuccess({ (tags) -> Void in
                var stringForTags = ""
                for tag in tags {
                    stringForTags.appendContentsOf("\(tag) ")
                }
                self.lblTags.text = stringForTags
            }) { (error) -> Void in
                print(error)
            }
        }
    }

    
    // MARK: Overrides
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
