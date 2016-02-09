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
    private var count : Int = 0
    private var label : UILabel
    static let MAXCOUNT : Int = 99
    
    init(viewController : UIViewController, exceptFor : (MMXChannel)) {
        
        channel = exceptFor
        let parent = UIView.init(frame: CGRect.init(x: 0, y: 0, width: 40, height: 20))
        
        label = UILabel.init(frame: CGRect.init(x: 0, y: 0, width: 40, height: 20))
        label.text = ""
        label.font = UIFont.systemFontOfSize(14)
        label.textColor = viewController.view.tintColor
        label.transform = CGAffineTransformMakeTranslation(-5, 0)
        parent.addSubview(label)
        
        let left = UIBarButtonItem.init(customView: parent)
        viewController.navigationItem.leftItemsSupplementBackButton = true
        viewController.navigationItem.leftBarButtonItems = [left]
        parent.hidden = true
        indicatorView = parent
        
        
        super.init()
        
        ChannelManager.sharedInstance.addChannelMessageObserver(self, channel:nil, selector: "didReceiveMessage:")
    }
    
    func didReceiveMessage(mmxMessage: MMXMessage) {
        
        guard let ch = mmxMessage.channel where ch.name != channel.name else {
            return
        }
        
        count++
        indicatorView.hidden = false
        label.text = "(\(count <= NavigationNotifier.MAXCOUNT ? "\(count)" : "\(NavigationNotifier.MAXCOUNT)+"))"
    }
}
