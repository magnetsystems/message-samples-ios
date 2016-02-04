//
//  NavigationNotifier.swift
//  MMChat
//
//  Created by Lorenzo Stanton on 2/3/16.
//  Copyright © 2016 Kostya Grishchenko. All rights reserved.
//

import UIKit
import MagnetMax

class NavigationNotifier: NSObject {
    
    private var indicatorView : UIView
    private var channel : MMXChannel
    
    init(viewController : UIViewController, exceptFor : (MMXChannel)) {
        
        channel = exceptFor
        let parent = UIView.init(frame: CGRect.init(x: 0, y: 0, width: 10, height: 10))
        let view = UIView.init(frame: CGRect.init(x: 0, y: 0, width: 10, height: 10))
        view.backgroundColor = UIColor(red: 0 / 255.0, green: 122 / 255.0, blue: 255 / 255.0, alpha: 1.0)
        view.layer.cornerRadius = view.frame.size.width / 2.0
        view.clipsToBounds = true
        view.transform = CGAffineTransformMakeTranslation(-5, -5)
        parent.addSubview(view)
        let left = UIBarButtonItem.init(customView: parent)
        viewController.navigationItem.leftItemsSupplementBackButton = true
        viewController.navigationItem.leftBarButtonItems = [left]
        parent.hidden = true
        indicatorView = parent
        
        super.init()
        
        ChannelManager.sharedInstance.addChannelMessageObserver(self, channel:nil, selector: "didReceiveMessage:")
    }
    
    func didReceiveMessage(mmxMessage: MMXMessage) {
        if mmxMessage.channel?.name == channel.name {
            return
        }
       indicatorView.hidden = false
    }
}
