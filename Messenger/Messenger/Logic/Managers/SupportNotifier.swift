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
    
    var stopped = false
    private var indicatorView : UIView
    private var count : Int = 0
    private var label : UILabel
    
    static func hideAllSupportNotifiers() {
        NSNotificationCenter.defaultCenter().postNotificationName(kNotificationHideNotifiers, object: nil)
    }
    
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
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("hideNotifier"), name: kNotificationHideNotifiers, object: nil)
    }
    
    init(viewController : UIViewController) {
        
        let leftBarButtonItem = viewController.navigationItem.leftBarButtonItem!
        
        let button = UIButton(type: .Custom)
        button.setImage(leftBarButtonItem.image, forState: .Normal)
        button.frame = CGRectMake(0, 0, leftBarButtonItem.image!.size.width, leftBarButtonItem.image!.size.height)
        button.addTarget(leftBarButtonItem.target, action: leftBarButtonItem.action, forControlEvents: .TouchUpInside)
        let customItem = UIBarButtonItem.init(customView: button)
        
        viewController.navigationItem.leftBarButtonItem = customItem
        
        indicatorView = UIImageView(image: UIImage(named: "icon_alert.png"))
        indicatorView.frame = CGRectMake(-10, -5, 20, 20)
        indicatorView.hidden = true
        button.addSubview(indicatorView)
        
        label = UILabel.init()
        
        super.init()
        
        ChannelManager.sharedInstance.addChannelMessageObserver(self, channel:nil, selector: "didReceiveMessage:")
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("hideNotifier"), name: kNotificationHideNotifiers, object: nil)
    }
    
    func didReceiveMessage(mmxMessage: MMXMessage) {
        
        guard let ch = mmxMessage.channel where ch.name.lowercaseString == kAskMagnetChannel.lowercaseString && !stopped else {
            return
        }
        
        count++
        indicatorView.hidden = false
        label.text = "\(count) new"
    }
    
    func hideNotifier() {
        count = 0
        indicatorView.hidden = true
    }
    
    deinit {
        ChannelManager.sharedInstance.removeChannelMessageObserver(self)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

}
