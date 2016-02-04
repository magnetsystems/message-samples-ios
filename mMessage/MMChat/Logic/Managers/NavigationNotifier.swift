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
        let view = UIView.init(frame: CGRect.init(x: 0, y: 0, width: 5, height: 5))
        view.backgroundColor = UIColor(red: 0 / 255.0, green: 122 / 255.0, blue: 255 / 255.0, alpha: 1.0)
        view.layer.cornerRadius = view.frame.size.width / 2.0
        view.clipsToBounds = true
        view.transform = CGAffineTransformMakeTranslation(-10, 0)
        parent.addSubview(view)
        
        label = UILabel.init(frame: CGRect.init(x: 0, y: 0, width: 40, height: 20))
        label.text = ""
        label.font = UIFont.systemFontOfSize(14)
        label.textColor = viewController.view.tintColor
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
        if mmxMessage.channel?.name == channel.name {
            return
        }
        count++
        indicatorView.hidden = false
        label.text = "(\(count <= NavigationNotifier.MAXCOUNT ? "\(count)" : "\(NavigationNotifier.MAXCOUNT)+"))"
    }
}
