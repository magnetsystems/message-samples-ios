//
//  ChannelCell.swift
//  KitchenSink
//
//  Created by Kostya Grishchenko on 12/25/15.
//  Copyright © 2015 Magnet Systems, Inc. All rights reserved.
//

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
