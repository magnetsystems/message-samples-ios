/*
* Copyright (c) 2015 Magnet Systems, Inc.
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

class NavigationNotifier: NSObject {
    
    var indicatorView : UIView?
    private var channel : MMXChannel?
    private var _count = 0
    var count : Int {
        set {
            _count = newValue
            reload()
        }
        get {
            return _count
        }
    }
    
    var label : UILabel?
    
    static let MAXCOUNT : Int = 99
    
    override init() {
        super.init()
    }
    
    init(viewController : UIViewController, exceptFor : MMXChannel?) {
        
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
        self.subscribeToIncomingMessages()
    }
    
    func subscribeToIncomingMessages() {
      ChannelManager.sharedInstance.addChannelMessageObserver(self, channel:nil, selector: "didReceiveMessage:")
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
        }
        return false
    }
    
    func notifierCount() -> String {
        return "\(count <= NavigationNotifier.MAXCOUNT ? "\(count)" : "\(NavigationNotifier.MAXCOUNT)+")"
    }
    
    func didReceiveMessage(mmxMessage: MMXMessage) {
        if !shouldNotifyFor(mmxMessage) {
            return
        }
        
        count++
    }
    
    deinit {
        ChannelManager.sharedInstance.removeChannelMessageObserver(self)
    }
}
