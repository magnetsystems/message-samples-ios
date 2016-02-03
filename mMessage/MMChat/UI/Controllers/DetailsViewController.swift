//
//  DetailsViewController.swift
//  MMChat
//
//  Created by Kostya Grishchenko on 1/5/16.
//  Copyright © 2016 Kostya Grishchenko. All rights reserved.
//

import UIKit
import MagnetMax

class DetailsViewController: UITableViewController, ContactsViewControllerDelegate {
    
    var recipients : [MMUser]?
    var channel : MMXChannel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
   
   channel.subscribersWithLimit(200, offset: 0, success: { (total, users) -> Void in
    self.recipients = users
    self.tableView.reloadData()
    
    }) { (error) -> Void in
        //error
        }
    }
    
    @IBAction func leaveAction() {
        if channel != nil {
            channel.unSubscribeWithSuccess({ [weak self] in
                ChannelManager.sharedInstance.removeLastViewTimeForChannel((self?.channel.name)!)
                self?.navigationController?.popToRootViewControllerAnimated(true)
            }, failure: { error in
                print("[ERROR]: \(error)")
            })
        }
    }

    // MARK: - Table view data source

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let i = recipients?.count else {
            
            return 1
        }
        
        return i + 1
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("RecipientsCellIdentifier", forIndexPath: indexPath)

        if indexPath.row == recipients?.count {
            let color = ChannelManager.sharedInstance.isOwnerForChat(channel.name) != nil ? self.view.tintColor : UIColor.blackColor()
            cell.textLabel?.attributedText = NSAttributedString(string: "+ Add Contact",
                                                            attributes: [NSForegroundColorAttributeName : color,
                                                                         NSFontAttributeName : UIFont.systemFontOfSize((cell.textLabel?.font.pointSize)!)])
        } else if let recipients = self.recipients {
            let attributes = [NSFontAttributeName : UIFont.boldSystemFontOfSize((cell.textLabel?.font.pointSize)!),
                              NSForegroundColorAttributeName : UIColor.blackColor()]
            var title = NSAttributedString()
            let user = recipients[indexPath.row]
            if let lastName = user.lastName where lastName.isEmpty == false {
                title = NSAttributedString(string: lastName, attributes: attributes)
            }
            if let firstName = user.firstName where firstName.isEmpty == false {
                if let lastName = user.lastName where lastName.isEmpty == false{
                    let firstPart = NSMutableAttributedString(string: "\(firstName) ")
                    firstPart.appendAttributedString(title)
                    title = firstPart
                } else {
                    title = NSAttributedString(string: firstName, attributes: attributes)
                }
            }
            
            cell.textLabel?.attributedText = title
        }

        return cell
    }
    
    // MARK: - Table view delegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if (indexPath.row == recipients?.count) && ChannelManager.sharedInstance.isOwnerForChat(channel.name) != nil {
            // Show contact selector
            if let navigationVC = self.storyboard?.instantiateViewControllerWithIdentifier("ContactsNavigationController") as? UINavigationController {
                if let contactsVC = navigationVC.topViewController as? ContactsViewController {
                    contactsVC.delegate = self
                    contactsVC.title = "Add a contact"
                    self.presentViewController(navigationVC, animated: true, completion: nil)
                }
            }
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    //MARK: - ContactsViewControllerDelegate
    
    func contactsControllerDidFinish(with selectedUsers: [MMUser]) {
        // Show chat after selection of recipients
        if let navigationVC = self.navigationController {
            navigationVC.popViewControllerAnimated(false)
            // Add subscriberst to chat
            if let chatVC = navigationVC.topViewController as? ChatViewController {
                chatVC.addSubscribers(selectedUsers)
            }
        }
    }
    
}
