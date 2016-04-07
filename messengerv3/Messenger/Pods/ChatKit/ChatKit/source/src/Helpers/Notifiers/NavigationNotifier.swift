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

import MagnetMax

public class NotifierListener : NSObject {
    override init() {
        super.init()
        
        ChannelManager.sharedInstance.addChannelMessageObserver(self, channel:nil, selector: "didReceiveMessage:")
    }
    
    func didReceiveMessage(mmxMessage: MMXMessage) { }
}

public class NavigationNotifier: NotifierListener {
    
    
    //MARK: Static properties
    
    
    static let MAXCOUNT : Int = 99
    
    
    //MARK: Public properties
    
    
    var count : Int {
        set {
            _count = newValue
            reload()
        }
        get {
            return _count
        }
    }
    
    var indicatorView : UIView?
    var label : UILabel?
    
    public var channelException : MMXChannel? {
        set {
            channel = newValue
        }
        get {
            return channel
        }
    }
    
    
    //MARK: Private properties
    
    
    private var channel : MMXChannel?
    private var _count = 0
    
    
    //MARK: Overrides
    
    
    deinit {
        ChannelManager.sharedInstance.removeChannelMessageObserver(self)
    }
    
    override init() {
        super.init()
    }
    
   public init(viewController : UIViewController, exceptFor : MMXChannel?) {
        
        channel = exceptFor
        let parent = UIView.init(frame: CGRect.init(x: 0, y: 0, width: 40, height: 20))
        
        label = UILabel.init(frame: CGRect.init(x: 0, y: 0, width: 40, height: 20))
        label?.text = ""
        label?.font = UIFont.systemFontOfSize(14)
        label?.textColor = viewController.view.tintColor
        if let lbl = label {
            parent.addSubview(lbl)
        }
        let left = UIBarButtonItem.init(customView: parent)
        viewController.navigationItem.leftItemsSupplementBackButton = true
        viewController.navigationItem.leftBarButtonItems = [left]
        parent.hidden = true
        indicatorView = parent
        
        super.init()
        setIndicatorOffset(-5)
    }
    
    
    //MARK: - Public implementation
    
    
    override func didReceiveMessage(mmxMessage: MMXMessage) {
        if !shouldNotifyFor(mmxMessage) {
            return
        }
        
        count++
    }
    
    func notifierCount() -> String {
        return "\(count <= NavigationNotifier.MAXCOUNT ? "\(count)" : "\(NavigationNotifier.MAXCOUNT)+")"
    }
    
    func reload() {
        if count > 0 {
            indicatorView?.hidden = false
            label?.text = "(\(notifierCount()))"
        } else {
            indicatorView?.hidden = true
            label?.text = ""
        }
    }
    
    func resetCount() {
        count = 0
        indicatorView?.hidden = true
        label?.text = ""
    }
    
    
    func setIndicatorOffset(offset : CGFloat) {
        label?.transform = CGAffineTransformMakeTranslation(offset, 0)
    }
    
    func shouldNotifyFor(mmxMessage : MMXMessage) -> Bool {
        if let ch = mmxMessage.channel, let channel = self.channel where ch.name.lowercaseString != channel.name.lowercaseString {
            return true
        } else if channel == nil {
          return true
        }
        
        return false
    }
    
}
