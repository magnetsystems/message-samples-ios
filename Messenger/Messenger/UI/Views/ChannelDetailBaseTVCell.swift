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

    var detailResponse : MMXChannelDetailResponse?

    static func cellHeight() -> CGFloat {
        
        let nibs : [AnyObject]! = NSBundle.mainBundle().loadNibNamed(Utils.name(self.classForCoder()), owner: self, options: nil)
        
        let cellView = nibs.first as! UIView;
        
        return cellView.frame.size.height;
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
