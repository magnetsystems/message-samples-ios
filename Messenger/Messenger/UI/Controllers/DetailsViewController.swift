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

import MagnetMax
import UIKit


//MARK: Constants


let recipientCellIdentifier = "RecipientsCellIdentifier"

class DetailsViewController: UITableViewController, ContactsViewControllerDelegate {
    
    
    //MARK: Public properties
    
    
    var canLeave = false
    var channel : MMXChannel!
    var recipients : [MMUser]?
   
    
    //MARK: Overrides
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if !canLeave {
            navigationItem.rightBarButtonItem = nil
        }
   
        channel.subscribersWithLimit(200, offset: 0, success: { (total, users) -> Void in
        self.recipients = users
        self.tableView.reloadData()
        
        }) { (error) -> Void in
            //error
        }
    }
    
    
    //MARK: Actions
    
    
    @IBAction func leaveAction() {
        if channel != nil {
            channel.unSubscribeWithSuccess({ [weak self] in
                self?.navigationController?.popToRootViewControllerAnimated(true)
            }, failure: { error in
                print("[ERROR]: \(error)")
            })
        }
    }

    
    //MARK: Public methods
    
    
    func isOwner() -> Bool {
        return MMUser.currentUser()?.userID == channel.ownerUserID
    }
    
    
    // MARK: - Table view data source

    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let i = recipients?.count else {
            
            return 1
        }
        
        if !isOwner() {
          return i
        }
        
        return i + 1
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(recipientCellIdentifier, forIndexPath: indexPath)

        if indexPath.row == recipients?.count && isOwner()  {
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
            if let navigationVC = self.storyboard?.instantiateViewControllerWithIdentifier(vc_id_ContactsNav) as? UINavigationController {
                if let contactsVC = navigationVC.topViewController as? ContactsViewController {
                    contactsVC.delegate = self
                    contactsVC.title = kStr_AddContact
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
