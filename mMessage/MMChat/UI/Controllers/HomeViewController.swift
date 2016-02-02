//
//  HomeViewController.swift
//  MMChat
//
//  Created by Kostya Grishchenko on 12/29/15.
//  Copyright © 2015 Kostya Grishchenko. All rights reserved.
//

import UIKit
import MagnetMax

class HomeViewController: UITableViewController, UISearchResultsUpdating, ContactsViewControllerDelegate {
    
    let searchController = UISearchController(searchResultsController: nil)
    var summaryResponses : [MMXChannelSummaryResponse] = []
    var filteredSummaryResponses : [MMXChannelSummaryResponse] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        if let revealVC = self.revealViewController() {
            let button = UIButton.init(type: .Custom)
            button.frame = CGRect.init(origin: CGPoint.init(x: 0, y: 0), size: CGSize.init(width: 40, height: 40))
            button.setTitle("≡", forState: .Normal)
            button.setTitleColor(UIColor(red: 0 / 255.0, green: 122 / 255.0, blue: 255 / 255.0, alpha: 1.0), forState: .Normal)
            button.titleLabel?.font = UIFont.systemFontOfSize(36)
            let menu = UIBarButtonItem(customView: button)
            button.addTarget(revealVC, action: "revealToggle:", forControlEvents: .TouchUpInside)
            navigationItem.leftBarButtonItem = menu
            self.view.addGestureRecognizer(revealVC.panGestureRecognizer())
        }
        
        
        
        // Indicate that you are ready to receive messages now!
        MMX.start()
        // Handling disconnection
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didDisconnect:", name: MMUserDidReceiveAuthenticationChallengeNotification, object: nil)

        
        // Add search bar
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.sizeToFit()
        tableView.tableHeaderView = searchController.searchBar
        tableView.reloadData()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if let user = MMUser.currentUser() {
            self.title = "\(user.firstName ?? "") \(user.lastName ?? "")"
        }
        
        loadSummaries()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.title = nil
    }
    
    @IBAction func refreshChannelSummary() {
        loadSummaries()
    }
    
    deinit {
        // Indicate that you are not ready to receive messages now!
        MMX.stop()
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    // MARK: - Notification handler
    
    private func didDisconnect(notification: NSNotification) {
        // Indicate that you are not ready to receive messages now!
        MMX.stop()
        
        // Redirect to the login screen
        if let revealVC = self.revealViewController() {
            revealVC.rearViewController.navigationController?.popToRootViewControllerAnimated(true)
        }
    }

    // MARK: - Table view data source

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.active {
            return filteredSummaryResponses.count
        }
        return summaryResponses.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("SummaryResponseCell", forIndexPath: indexPath) as! SummaryResponseCell
        cell.summaryResponse = searchController.active ? filteredSummaryResponses[indexPath.row] : summaryResponses[indexPath.row]
        
        return cell
    }

    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let summaryResponse = summaryResponses[indexPath.row]
        var isLastPersonInChat = false
        if summaryResponse.messages.count > 0 {
            isLastPersonInChat = (summaryResponse.messages.last as! MMXPubSubItemChannel).publisher.userId == MMUser.currentUser()?.userID
        }
        
        if isLastPersonInChat {
            // Current user must be the owner of the channel to delete it
            if let chat = ChannelManager.sharedInstance.isOwnerForChat(summaryResponse.channelName) {
                let delete = UITableViewRowAction(style: .Normal, title: "Delete") { [weak self] action, index in
                    chat.deleteWithSuccess({ _ in
                        self?.summaryResponses.removeAtIndex(index.row)
                        tableView.deleteRowsAtIndexPaths([index], withRowAnimation: .Fade)
                        ChannelManager.sharedInstance.removeLastViewTimeForChannel(summaryResponse.channelName)
                    }, failure: { error in
                        print(error)
                    })
                }
                delete.backgroundColor = UIColor.redColor()
                return [delete]
            }
        }
        
        // Unsubscribe
        let leave = UITableViewRowAction(style: .Normal, title: "Leave") { [weak self] action, index in
            if let chat = ChannelManager.sharedInstance.channelForName(summaryResponse.channelName) {
                chat.unSubscribeWithSuccess({ _ in
                    self?.summaryResponses.removeAtIndex(index.row)
                    tableView.deleteRowsAtIndexPaths([index], withRowAnimation: .Fade)
                    ChannelManager.sharedInstance.removeLastViewTimeForChannel(summaryResponse.channelName)
                }, failure: { error in
                    print(error)
                })
            }
        }
        leave.backgroundColor = UIColor.orangeColor()
        return [leave]
    }

    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
 
    }
    
    //MARK: - ContactsViewControllerDelegate
    
    func contactsControllerDidFinish(with selectedUsers: [MMUser]) {
        if let chatVC = self.storyboard?.instantiateViewControllerWithIdentifier("ChatViewController") as? ChatViewController {
            chatVC.recipients = selectedUsers + [MMUser.currentUser()!]
            self.navigationController?.pushViewController(chatVC, animated: false)
        }
    }

    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showChatFromChannelSummary" {
            searchController.active = false
            if let chatVC = segue.destinationViewController as? ChatViewController, let cell = sender as? SummaryResponseCell {
                chatVC.chat = ChannelManager.sharedInstance.channelForName(cell.summaryResponse.channelName)
            }
        } else if segue.identifier == "showContactsSelector" {
            if let navigationVC = segue.destinationViewController as? UINavigationController {
                if let contactsVC = navigationVC.topViewController as? ContactsViewController {
                    contactsVC.delegate = self
                    contactsVC.title = "New message"
                }
            }
        }
    }
    
    // MARK: - Helpers
    
    private func loadSummaries() {
        // Get all channels the current user is subscribed to
        MMXChannel.subscribedChannelsWithSuccess({ [weak self] channels in
            ChannelManager.sharedInstance.channels = channels
            // Get summaries
            let channelsSet = Set(channels)
            MMXChannel.channelSummary(channelsSet, numberOfMessages: 10, numberOfSubcribers: 10, success: { summaryResponses in
                ChannelManager.sharedInstance.channelSummaries = summaryResponses
                self?.summaryResponses = summaryResponses
                self?.endRefreshing()
            }, failure: { error in
                self?.endRefreshing()
                print(error)
            })
        }) { [weak self] error in
            self?.endRefreshing()
            print(error)
        }
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        let searchString = searchController.searchBar.text!.lowercaseString
        filteredSummaryResponses = summaryResponses.filter { summary in
            if let pubSubItems = summary.messages as? [MMXPubSubItemChannel] {
                for message in pubSubItems {
                    let content = message.content as! [String : String]!
                    if let text = content[Constants.ContentKey.Message] where text.containsString(searchString) {
                        return true
                    }
                }
            }
            
            return false
        }
        
        tableView.reloadData()
    }
    
    private func endRefreshing() {
        refreshControl?.endRefreshing()
        tableView.reloadData()
    }

}

