//
//  SupportNotifier.swift
//  Messenger
//
//  Created by Kostya Grishchenko on 2/16/16.
//  Copyright © 2016 Magnet Systems, Inc. All rights reserved.
//

import UIKit
import MagnetMax

class SupportNotifier: NSObject {
    
    private var indicatorView : UIView
    private var count : Int = 0
    private var label : UILabel
    
    init(cell : UITableViewCell) {
        
        indicatorView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: 100, height: 20))
        indicatorView.center = CGPointMake(150, cell.contentView.center.y)
        
        let image = UIImageView(image: UIImage(named: "icon_alert.png"))
        image.frame = CGRect.init(x: 0, y: 0, width: 20, height: 20)
        indicatorView.addSubview(image)
        
        label = UILabel.init(frame: CGRect.init(x: 30, y: 0, width: 70, height: 20))
        label.text = ""
        label.font = UIFont.systemFontOfSize(15)
        label.textColor = cell.tintColor
        indicatorView.addSubview(label)
        indicatorView.hidden = true
        cell.contentView.addSubview(indicatorView)
        
        super.init()
        
        ChannelManager.sharedInstance.addChannelMessageObserver(self, channel:nil, selector: "didReceiveMessage:")
    }
    
    func didReceiveMessage(mmxMessage: MMXMessage) {
        
        guard let ch = mmxMessage.channel where ch.name != kAskMagnetChannel else {
            return
        }
        
        count++
        indicatorView.hidden = false
        label.text = "\(count) new"
    }
    
    func setToZero() {
        count = 0
        indicatorView.hidden = true
    }

}
