//
//  MessagesViewController.swift
//  KitchenSink
//
//  Created by Kostya Grishchenko on 12/25/15.
//  Copyright © 2015 Magnet Systems, Inc. All rights reserved.
//

import UIKit

class MessagesViewController: ChatViewController {
    
    
    // MARK: Overrides

    
     override func getChannel() {
        // channel is already set for MessagesViewController
        messageHistory()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if let tabBarVC = self.tabBarController {
            tabBarVC.navigationItem.title = myChatChannel?.name
            tabBarVC.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Send", style: .Plain, target: self, action: Selector("sendMessage:"))
            //disabled if no permissions
            tabBarVC.navigationItem.rightBarButtonItem?.enabled = myChatChannel!.canPublish
        }
    }

}
