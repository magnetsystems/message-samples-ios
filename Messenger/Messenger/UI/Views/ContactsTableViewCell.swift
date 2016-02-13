//
//  ContactsTableViewCell.swift
//  Messenger
//
//  Created by Lorenzo Stanton on 2/12/16.
//  Copyright © 2016 Magnet Systems, Inc. All rights reserved.
//

import UIKit

class ContactsTableViewCell: UITableViewCell {
    @IBOutlet var avatarImage : UIImageView?
    @IBOutlet var profileText : UILabel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
