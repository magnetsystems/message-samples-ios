//
//  ContactsCell.swift
//  
//
//  Created by Lorenzo Stanton on 2/11/16.
//
//

import UIKit

class ContactsCell: UITableViewCell {
    @IBOutlet var userName : UILabel?
    @IBOutlet var avatar : UIImageView?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        if let avatar = self.avatar {
        avatar.layer.cornerRadius = avatar.frame.size.width / 2.0
        avatar.clipsToBounds = true
        }
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
