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

public class MagnetChatViewController: MagnetViewController {
    private var underlyingChatViewController = ChatViewController.init()
    
    public private(set) var channel : MMXChannel? {
        set {
            underlyingChatViewController.chat = newValue
        }
        get {
            return underlyingChatViewController.chat
        }
    }
    
    public private(set) var recipients : [MMUser]? {
        set {
            underlyingChatViewController.recipients = newValue
        }
        get {
            return underlyingChatViewController.recipients
        }
    }
    
    public convenience init(recipients : [MMUser]) {
        self.init()
        self.recipients = recipients
    }
    
    public convenience init(channel : MMXChannel) {
        self.init()
        self.channel = channel
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override public func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        generateNavBars()
    }
    
    override public func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override internal func underlyingViewController() -> UIViewController? {
        return underlyingChatViewController
    }
    
    private func generateNavBars() {
        if self.title == nil {
            self.title = underlyingChatViewController.title
        }
        if self.navigationController == nil {
            let btnBack = UIBarButtonItem.init(title: "Back", style: .Plain, target: self, action: "dismiss")
            self.setMagnetNavBar(leftItems: [btnBack], rightItems: nil, title: self.title)
        }
    }
    
    override func setupViewController() {
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    public override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
