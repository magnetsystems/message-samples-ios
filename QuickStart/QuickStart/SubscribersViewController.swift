//
//  SubscribersViewController.swift
//  KitchenSink
//
//  Created by Kostya Grishchenko on 12/25/15.
//  Copyright © 2015 Magnet Systems, Inc. All rights reserved.
//

import UIKit
import MagnetMax

class SubscribersViewController: UITableViewController {
    
    
    // MARK: Public properties
    
    
    var channel : MMXChannel!
    var subscribers : [MMUser] = []
    
    
    // MARK: Overrides
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let limit: Int32 = 10
        let offset: Int32 = 0
        
        channel.subscribersWithLimit(limit, offset: offset, success: { [weak self] (count, users) in
            self?.subscribers = users
            self?.tableView.reloadData()
        }, failure: { (error) -> Void in
            print("[ERROR]: \(error)")
        })
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if let tabBarVC = self.tabBarController {
            tabBarVC.navigationItem.title = "Subscribers"
            tabBarVC.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Invite", style: .Plain, target: self, action: Selector("inviteUserAction"))
        }
        
        //for receiving incoming invites
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didReceiveChannelInvite:", name: MMXDidReceiveChannelInviteNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didReceiveChannelInviteResponse:", name: MMXDidReceiveChannelInviteResponseNotification, object: nil)
        
        // Indicate that you are ready to receive messages now!
        MMX.start()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    
    // MARK: Public implementation
    
    
    func inviteUserAction() {
        //Show popup
        let invitePopup = UIAlertController(title: "Invite user", message: "", preferredStyle: .Alert)
        invitePopup.addTextFieldWithConfigurationHandler { txtfUserName in
            txtfUserName.placeholder = "User name"
            txtfUserName.text = MMUser.currentUser()?.userName
        }
        let close = UIAlertAction(title: "Cancel", style: .Destructive, handler: nil)
        let invite = UIAlertAction(title: "Send", style: .Default) { [weak self] _ in
            if let userName = invitePopup.textFields?.first?.text where (userName.isEmpty == false) {
                //Find user with name
                MMUser.usersWithUserNames([userName], success: { users in
                    // Invite founded user
                    if let user = users.first {
                        self?.channel.inviteUser(user, comments: "Subscribe to the \(self?.channel.name)", success: { invite in
                            print("Invited")
                        }, failure: { error in
                            print("[ERROR]: \(error)")
                        })
                    }
                }, failure: { error in
                    print("[ERROR]: \(error)")
                })
            }
        }
        invitePopup.addAction(close)
        invitePopup.addAction(invite)
        self.presentViewController(invitePopup, animated: true, completion: nil)
    }
    
    
    // MARK: - Notification handlers
    
    
    func didReceiveChannelInvite(notification: NSNotification) {
        let userInfo : [NSObject : AnyObject] = notification.userInfo!
        let invite = userInfo[MMXInviteKey] as! MMXInvite
        //Show popup
        let inviteResponse = UIAlertController(title: "Invite", message: "You were invited to \(invite.channel.name)", preferredStyle: .Alert)
        let decline = UIAlertAction(title: "Decline", style: .Default) { _ in
            invite.declineWithComments("No, thanks", success: nil, failure: { error in
                print("[ERROR]: \(error)")
            })
        }
        let accept = UIAlertAction(title: "Accept", style: .Default) { _ in
            invite.acceptWithComments("Hello!", success: nil, failure: { (error) -> Void in
                print("[ERROR]: \(error)")
            })
        }
        inviteResponse.addAction(decline)
        inviteResponse.addAction(accept)
        self.presentViewController(inviteResponse, animated: true, completion: nil)
    }
    
    func didReceiveChannelInviteResponse(notification: NSNotification) {
        let userInfo : [NSObject : AnyObject] = notification.userInfo!
        let inviteResponse = userInfo[MMXInviteResponseKey] as! MMXInviteResponse
        let message: String?
        if inviteResponse.accepted {
            message = "accepted"
        } else {
            message = "declined"
        }
        print("\(inviteResponse.sender.userName) \(message) invite to join \(inviteResponse.channel.name)")
    }

    
    // MARK: - Table view data source

    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return subscribers.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("SubscriberCellIdentifier", forIndexPath: indexPath)
        let user = subscribers[indexPath.row]
        cell.textLabel?.text = user.userName

        return cell
    }

}
