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


//MARK: MagnetChatViewControllerDelegate


@objc public protocol MagnetChatViewControllerDelegate : class {
    optional func chatViewDidCreateChannel(channel : MMXChannel)
    optional func chatViewDidSendMessage(message : MMXMessage)
    optional func chatViewDidRecieveMessage(message : MMXMessage)
}


//MARK: MagnetChatViewController


public class MagnetChatViewController: MagnetViewController, ChatViewControllerDelegate, MagnetChatViewControllerDelegate {
    
    
    //MARK : Private Variables
    
    
    private var underlyingChatViewController = ChatViewController.init()
    
    
    //MARK: Public Variables
    
    
    public private(set) var channel : MMXChannel? {
        set {
            underlyingChatViewController.chat = newValue
        }
        get {
            return underlyingChatViewController.chat
        }
    }
    
    public var delegate : MagnetChatViewControllerDelegate?
    
    public private(set) var recipients : [MMUser]? {
        set {
            underlyingChatViewController.recipients = newValue
        }
        get {
            return underlyingChatViewController.recipients
        }
    }
    
    
    //MARK: Init
    
    
    public convenience init(channel : MMXChannel) {
        self.init()
        self.channel = channel
    }
    
    public convenience init(recipients : [MMUser]) {
        self.init()
        self.recipients = recipients
    }
    
    
    //MARK: Overrides
    
    
    override func setupViewController() {
        navigationController?.setNavigationBarHidden(false, animated: true)
        underlyingChatViewController.delegate = self
    }
    
    override internal func underlyingViewController() -> UIViewController? {
        return underlyingChatViewController
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
    
    
    // Private Methods
    
    
    private func generateNavBars() {
        if self.title == nil {
            self.title = underlyingChatViewController.title
        }
        if self.navigationController == nil {
            let btnBack = UIBarButtonItem.init(title: "Back", style: .Plain, target: self, action: "dismiss")
            self.setMagnetNavBar(leftItems: [btnBack], rightItems: nil, title: self.title)
        }
    }
    
    
    //MARK:  ChatViewControllerDelegate
    
    
    func controllerDidCreateChannel(channel : MMXChannel) {
        self.delegate?.chatViewDidCreateChannel?(channel)
    }
    
    func controllerDidSendMessage(message : MMXMessage) {
        self.delegate?.chatViewDidSendMessage?(message)
    }
    
    func controllerDidRecieveMessage(message : MMXMessage) {
        self.delegate?.chatViewDidRecieveMessage?(message)
    }
}
