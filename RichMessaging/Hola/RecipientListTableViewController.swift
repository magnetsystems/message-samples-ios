//
//  RecipientListTableViewController.swift
//  Hola
//
//  Created by Jason Ferguson on 9/15/15.
//  Copyright © 2015 Magnet Systems, Inc. All rights reserved.
//

import UIKit
import MMX
import JSQMessagesViewController

class RecipientListTableViewController: UITableViewController {

	var availableRecipients = [MMXUser]()
	
	override func viewDidLoad() {
        super.viewDidLoad()
		tableView.allowsMultipleSelection = true
		self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Message Screen", style: .Plain, target: self, action: "goToMessageView")

		//Get available recipients
		updateRecipientList()
		
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	// MARK: - Get Recipients
	func updateRecipientList() {
		MMXUser.findByDisplayName("%", limit: 100, success: { (availableCount, userList) -> Void in
			self.availableRecipients = userList as! [MMXUser]
			self.tableView.reloadData()
			}, failure: { (error) -> Void in
				print("updateRecipientList error = \(error)")
		})
	}
	
	func goToMessageView() {
		if let selectedRows : [NSIndexPath] = tableView.indexPathsForSelectedRows {
			if selectedRows.count > 0 {
				self.performSegueWithIdentifier("showMessagesSegue", sender: self)
			}
		}
	}

	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if segue.identifier == "showMessagesSegue"
		{
			if let destinationVC = segue.destinationViewController as? MessagesViewController {
				destinationVC.recipients = Set(selectedUsers())
			}
		}
	}
	
	func selectedUsers() -> [MMXUser] {
		let selectedRows : [NSIndexPath] = tableView.indexPathsForSelectedRows!
		var userArray = [MMXUser](count: selectedRows.count, repeatedValue: MMXUser.currentUser())
		var index = 0
		for indexPath in selectedRows {
			userArray[index] = availableRecipients[indexPath.row]
			index++
		}
		return userArray
	}
	
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return availableRecipients.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)

        // Configure the cell...
		let user = availableRecipients[indexPath.row] as MMXUser
		if let displayName = user.displayName {
			cell.textLabel?.text = displayName
		} else {
			cell.textLabel?.text = user.username
		}
		
        return cell
    }

}
