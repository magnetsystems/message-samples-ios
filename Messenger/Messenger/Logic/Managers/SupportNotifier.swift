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

import MagnetMax
import UIKit

class NewSupportMessages {
    static var count = 0
}


class SupportNotifier: NavigationNotifier {
    
    
    //MARK: Public properties
    
    
    override var count : Int {
        didSet {
            NewSupportMessages.count = count
        }
    }
    
    var stopped = false
    
    
    //MARK: Static Methods
    
    
    static func hideSupportNotifiers() {
        NSNotificationCenter.defaultCenter().postNotificationName(kNotificationHideSupportNotifiers, object: nil)
    }
    
    
    //MARK: Overrides
    
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func didReceiveMessage(mmxMessage: MMXMessage) {
        super.didReceiveMessage(mmxMessage)
    }

    init(view : UIView) {
        super.init()
        
        indicatorView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: 100, height: 20))
        indicatorView?.center = CGPointMake(150, view.center.y)
        
        let image = UIImageView(image: UIImage(named: "icon_alert.png"))
        image.frame = CGRect.init(x: 0, y: 0, width: 20, height: 20)
        indicatorView?.addSubview(image)
        
        label = UILabel.init(frame: CGRect.init(x: 30, y: 0, width: 70, height: 20))
        label?.text = ""
        label?.font = UIFont.systemFontOfSize(15)
        label?.textColor = view.tintColor
        if let lbl = label {
            indicatorView?.addSubview(lbl)
        }
        indicatorView?.hidden = true
        if let indView = indicatorView {
            view.addSubview(indView)
        }
        
        self.subscribeToIncomingMessages()
    }
    
    init(viewController : UIViewController) {
        super.init()
        
        let leftBarButtonItem = viewController.navigationItem.leftBarButtonItem!
        
        let button = UIButton(type: .Custom)
        button.setImage(leftBarButtonItem.image, forState: .Normal)
        button.frame = CGRectMake(0, 0, leftBarButtonItem.image!.size.width, leftBarButtonItem.image!.size.height)
        button.addTarget(leftBarButtonItem.target, action: leftBarButtonItem.action, forControlEvents: .TouchUpInside)
        let customItem = UIBarButtonItem.init(customView: button)
        
        viewController.navigationItem.leftBarButtonItem = customItem
        
        indicatorView = UIImageView(image: UIImage(named: "icon_alert.png"))
        indicatorView?.frame = CGRectMake(-10, -5, 20, 20)
        indicatorView?.hidden = true
        
        if let indView = indicatorView {
            button.addSubview(indView)
        }
        
        self.subscribeToIncomingMessages()
    }
    
    override func shouldNotifyFor(mmxMessage: MMXMessage) -> Bool {
        if let ch = mmxMessage.channel where ch.name.lowercaseString == kAskMagnetChannel.lowercaseString && !stopped {
            return true
        }
        return false
    }
    
    override func subscribeToIncomingMessages() {
        super.subscribeToIncomingMessages()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "resetCount", name: kNotificationHideSupportNotifiers, object: nil)
    }
    
    override func reload() {
        super.reload()
        
        if count > 0 {
            indicatorView?.hidden = false
            label?.text = "\(notifierCount()) new"
        }
    }
    
}
