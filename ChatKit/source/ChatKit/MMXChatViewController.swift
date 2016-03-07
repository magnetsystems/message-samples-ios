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


//MARK: MagnetChatViewController


public class MMXChatViewController: ChatViewController {
    
    
    //MARK: Public Variables
    
    
    public var channel : MMXChannel? {
        get {
            return chat
        }
    }
    
    public var delegate : ChatViewControllerDelegate?
    
    
    //MARK: Init
    
    
    public convenience init(channel : MMXChannel) {
        self.init()
        self.chat = channel
    }
    
    public convenience init(recipients : [MMUser]) {
        self.init()
        self.recipients = recipients
    }
    
    
    //MARK: Overrides
    
    
    override public func setupViewController() {
        super.setupViewController()
        
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.tintColor = self.appearance.tintColor
    }
    
    override public func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        generateNavBars()
    }
    
    
    // Private Methods
    
    
    public func generateNavBars() {
        if self.navigationController == nil {
            let btnBack = UIBarButtonItem.init(title: "Back", style: .Plain, target: self, action: "dismiss")
            self.setMagnetNavBar(leftItems: [btnBack], rightItems: nil, title: self.title)
        }
    }
    
    
    //MARK:  DataMethod Overrides
    
    
    override public func onChannelCreated(mmxChannel: MMXChannel) {
        self.delegate?.mmxChatDidCreateChannel(mmxChannel)
    }
    
    override public func onMessageRecived(mmxMessage: MMXMessage) {
        self.delegate?.mmxChatDidRecieveMessage(mmxMessage)
    }
    
    override public func onMessageSent(mmxMessage: MMXMessage) {
        self.delegate?.mmxChatDidSendMessage(mmxMessage)
    }
}
