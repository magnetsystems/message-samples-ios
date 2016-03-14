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

import UIKit

protocol ContactsCellDelegate : class {
    func didSelectContactsCellAvatar(cell : ContactsCell)
}

class ContactsCell: UITableViewCell {
    
    
    //MARK: Public Properties
    
    
    @IBOutlet var avatar : UIImageView?
    weak var delegate : ContactsCellDelegate?
    @IBOutlet var userName : UILabel?
    var user : MMUser?
    
    
    //MARK: Actions
    
    
    func didSelectAvatar() {
        self.delegate?.didSelectContactsCellAvatar(self)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let tap = UITapGestureRecognizer(target: self, action: "didSelectAvatar")
        tap.cancelsTouchesInView = true
        tap.delaysTouchesBegan = true
        self.avatar?.userInteractionEnabled = true
        self.avatar?.addGestureRecognizer(tap)
        
        if let avatar = self.avatar {
            avatar.layer.cornerRadius = avatar.frame.size.width / 2.0
            avatar.clipsToBounds = true
        }
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
