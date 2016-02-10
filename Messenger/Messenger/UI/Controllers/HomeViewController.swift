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
    var detailResponses : [MMXChannelDetailResponse] = []
    var filteredDetailResponses : [MMXChannelDetailResponse] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let revealVC = self.revealViewController() {
            self.view.addGestureRecognizer(revealVC.panGestureRecognizer())
            self.view.addGestureRecognizer(revealVC.tapGestureRecognizer())
        }
        
        navigationController?.setNavigationBarHidden(false, animated: true)
        // Indicate that you are ready to receive messages now!
//        MMX.start()
//        // Handling disconnection
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didDisconnect:", name: MMUserDidReceiveAuthenticationChallengeNotification, object: nil)

        
        // Add search bar
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.sizeToFit()
        tableView.tableHeaderView = searchController.searchBar
        tableView.reloadData()
        
        tableView.registerNib(UINib(nibName: Utils.name(SummaryResponseCell.classForCoder()), bundle: nil), forCellReuseIdentifier: Utils.name(SummaryResponseCell.classForCoder()))
        tableView.registerNib(UINib(nibName: Utils.name(EventChannelTableViewCell.classForCoder()), bundle: nil), forCellReuseIdentifier: Utils.name(EventChannelTableViewCell.classForCoder()))
        tableView.registerNib(UINib(nibName: Utils.name(AskMagnetTableViewCell.classForCoder()), bundle: nil), forCellReuseIdentifier: Utils.name(AskMagnetTableViewCell.classForCoder()))
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if let user = MMUser.currentUser() {
            self.title = "\(user.firstName ?? "") \(user.lastName ?? "")"
        }
        
        
        
        loadDetails()
        ChannelManager.sharedInstance.addChannelMessageObserver(self, channel:nil, selector: "didReceiveMessage:")
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.title = nil
        
        ChannelManager.sharedInstance.removeChannelMessageObserver(self)
    }
    
    func didReceiveMessage(mmxMessage: MMXMessage) {
        loadDetails()
    }
    
    @IBAction func refreshChannelDetail() {
        loadDetails()
    }
    
    @IBAction func showSideMenu(sender: UIBarButtonItem) {
        self.revealViewController().revealToggleAnimated(true)
    }
    
    deinit {
        // Indicate that you are not ready to receive messages now!
//        MMX.stop()
//        
//        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    // MARK: - Notification handler
    
//    private func didDisconnect(notification: NSNotification) {
//        // Indicate that you are not ready to receive messages now!
//        MMX.stop()
//        
//        // Redirect to the login screen
//        if let revealVC = self.revealViewController() {
//            revealVC.rearViewController.navigationController?.popToRootViewControllerAnimated(true)
//        }
//    }

    // MARK: - Table view data source

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        var channelDetail: MMXChannelDetailResponse
        
        if searchController.active {
            channelDetail = filteredDetailResponses[indexPath.row]
        } else {
            channelDetail = detailResponses[indexPath.row]
        }
        
        if channelDetail.channel.summary!.containsString("Forum") {
            return 150
        } else if channelDetail.channel.summary!.containsString("Ask") {
            return 80
        }
        return 44
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.active {
            return filteredDetailResponses.count
        }
        return detailResponses.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var channelDetail: MMXChannelDetailResponse
        var identifier = ""
        
        if searchController.active {
            channelDetail = filteredDetailResponses[indexPath.row]
        } else {
            channelDetail = detailResponses[indexPath.row]
        }
        
        if channelDetail.channel.summary!.containsString("Forum") {
            identifier = Utils.name(EventChannelTableViewCell.classForCoder())
//           let cell = tableView.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath) as! EventChannelTableViewCell
//            cell.detailResponse = searchController.active ? filteredDetailResponses[indexPath.row] : detailResponses[indexPath.row]
//            return cell
        } else if channelDetail.channel.summary!.containsString("Ask") {
            identifier = Utils.name(AskMagnetTableViewCell.classForCoder())
//            let cell = tableView.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath) as! AskMagnetTableViewCell
//            cell.detailResponse = searchController.active ? filteredDetailResponses[indexPath.row] : detailResponses[indexPath.row]
//            return cell
        } else {
            identifier = Utils.name(SummaryResponseCell.classForCoder())
//            let cell = tableView.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath) as! SummaryResponseCell
//            cell.detailResponse = searchController.active ? filteredDetailResponses[indexPath.row] : detailResponses[indexPath.row]
//            return cell
        }
        let cell = tableView.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath) as! ChannelDetailBaseTVCell
        cell.detailResponse = searchController.active ? filteredDetailResponses[indexPath.row] : detailResponses[indexPath.row]
        return cell
    }

    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let detailResponse = detailResponses[indexPath.row]
        var isLastPersonInChat = false
        if detailResponse.messages.count > 0 {
            isLastPersonInChat = detailResponse.messages.last?.sender?.userID == MMUser.currentUser()?.userID
        }
        
        if isLastPersonInChat {
            // Current user must be the owner of the channel to delete it
            if let chat = ChannelManager.sharedInstance.isOwnerForChat(detailResponse.channelName) {
                let delete = UITableViewRowAction(style: .Normal, title: kStr_Delete) { [weak self] action, index in
                    chat.deleteWithSuccess({ _ in
                        self?.detailResponses.removeAtIndex(index.row)
                        tableView.deleteRowsAtIndexPaths([index], withRowAnimation: .Fade)
                    }, failure: { error in
                        print(error)
                    })
                }
                delete.backgroundColor = UIColor.redColor()
                return [delete]
            }
        }
        
        // Unsubscribe
        let leave = UITableViewRowAction(style: .Normal, title: kStr_Leave) { [weak self] action, index in
            if let chat = ChannelManager.sharedInstance.channelForName(detailResponse.channelName) {
                chat.unSubscribeWithSuccess({ _ in
                    self?.detailResponses.removeAtIndex(index.row)
                    tableView.deleteRowsAtIndexPaths([index], withRowAnimation: .Fade)
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
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        searchController.active = false

        if let chatVC = self.storyboard?.instantiateViewControllerWithIdentifier(vc_id_Chat) as? ChatViewController,let cell = tableView.cellForRowAtIndexPath(indexPath) as? ChannelDetailBaseTVCell {
            chatVC.chat = ChannelManager.sharedInstance.channelForName(cell.detailResponse.channelName)
            self.navigationController?.pushViewController(chatVC, animated: true)
        }
    }
    
    //MARK: - ContactsViewControllerDelegate
    
    func contactsControllerDidFinish(with selectedUsers: [MMUser]) {
        if let chatVC = self.storyboard?.instantiateViewControllerWithIdentifier(vc_id_Chat) as? ChatViewController {
            chatVC.recipients = selectedUsers + [MMUser.currentUser()!]
            self.navigationController?.pushViewController(chatVC, animated: false)
        }
    }

    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == kSegueShowContactSelector {
            if let navigationVC = segue.destinationViewController as? UINavigationController {
                if let contactsVC = navigationVC.topViewController as? ContactsViewController {
                    contactsVC.delegate = self
                    contactsVC.title = kStr_NewMessage
                }
            }
        }
    }
    
    // MARK: - Helpers
    
    private func loadDetails() {
        // Get all channels the current user is subscribed to
        MMXChannel.subscribedChannelsWithSuccess({ [weak self] channels in
            ChannelManager.sharedInstance.channels = channels
            if channels.count > 0 {
                // Get details
                MMXChannel.channelDetails(channels, numberOfMessages: 100, numberOfSubcribers: 10, success: { detailResponses in
                    let sortedDetails = detailResponses.sort({ (detail1, detail2) -> Bool in
                        let formatter = ChannelManager.sharedInstance.formatter
                        return formatter.dateForStringTime(detail1.lastPublishedTime)?.timeIntervalSince1970 > formatter.dateForStringTime(detail2.lastPublishedTime)?.timeIntervalSince1970
                    })

                    ChannelManager.sharedInstance.channelDetails = sortedDetails
                    self?.detailResponses = sortedDetails
                        self?.endRefreshing()
                }, failure: { error in
                    self?.endRefreshing()
                    print(error)
                })
            } else {
                ChannelManager.sharedInstance.channelDetails?.removeAll()
            }
        }) { [weak self] error in
            self?.endRefreshing()
            print(error)
        }
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        let searchString = searchController.searchBar.text!.lowercaseString
        filteredDetailResponses = detailResponses.filter {
                for subscriber in $0.subscribers {
                    let name = subscriber.displayName
                    if name.lowercaseString.containsString(searchString.lowercaseString) || searchString.characters.count == 0 {
                        return true
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

