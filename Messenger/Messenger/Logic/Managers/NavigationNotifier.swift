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
        
        guard let ch = mmxMessage.channel where ch.name.lowercaseString != channel.name.lowercaseString else {
            return
        }
        
        count++
        indicatorView.hidden = false
        label.text = "(\(count <= NavigationNotifier.MAXCOUNT ? "\(count)" : "\(NavigationNotifier.MAXCOUNT)+"))"
    }
}
