//
//  UsersViewController.swift
//  SmartShopper
//
//  Created by Pritesh Shah on 9/17/15.
//  Copyright © 2015 Magnet Systems, Inc. All rights reserved.
//

import Foundation
import UIKit
import MMX
import JGProgressHUD

class UsersViewController: UITableViewController {
    
    var product: Product?

    var users = [MMXUser]()
    var selectedUsers = Set<MMXUser>() {
        didSet {
            if selectedUsers.count > 0 {
                navigationItem.rightBarButtonItem?.enabled = true
            } else {
                navigationItem.rightBarButtonItem?.enabled = false
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = product?.name
        
        fetchUsers()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Share", style: .Done, target: self, action: "shareProduct")
        navigationItem.rightBarButtonItem?.enabled = false
    }
    
    // MARK: Private implementation
    func fetchUsers() {
        MMXUser.allUsersWithLimit(20, offset:0, success: { (totalCount, records) -> Void in
            self.users = records as! [MMXUser]
            self.tableView.reloadData()
        }) { (error) -> Void in
            print("Could not fetch users: \(error)")
        }
    }
    
    func shareProduct() {
        
        let message = MMXMessage(toRecipients: selectedUsers, messageContent: product?.toDictionary())
        message.sendWithSuccess( {
            JGProgressHUD.showText("Success!", view: self.navigationController?.view)
            print("Shared product successfully!")
            self.navigationController?.popViewControllerAnimated(true)
        }) { (error) -> Void in
            print("Could not share product: \(error)")
        }
        
    }
}

extension UsersViewController {
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier("UserCell", forIndexPath: indexPath) as UITableViewCell
        
        let user = users[indexPath.row]
        
        // Configure the cell
        cell.textLabel!.text = user.displayName
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let user = users[indexPath.row]
        if selectedUsers.contains(user) {
            tableView.cellForRowAtIndexPath(indexPath)?.accessoryType = .None
            selectedUsers.remove(user)
        } else {
            tableView.cellForRowAtIndexPath(indexPath)?.accessoryType = .Checkmark
            selectedUsers.insert(user)
        }
    }
}
