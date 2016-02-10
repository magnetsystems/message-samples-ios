//
//  EventsViewController.swift
//  Messenger
//
//  Created by Vladimir Yevdokimov on 2/9/16.
//  Copyright © 2016 Magnet Systems, Inc. All rights reserved.
//

import UIKit
import MagnetMax

class EventsViewController: UITableViewController, UISearchResultsUpdating, ContactsViewControllerDelegate {

    let searchController = UISearchController(searchResultsController: nil)
    var hackatonChannels: [MMXChannelDetailResponse] = [];
    var filteredChannels: [MMXChannelDetailResponse] = [];
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if let revealVC = self.revealViewController() {
            self.view.addGestureRecognizer(revealVC.panGestureRecognizer())
            self.view.addGestureRecognizer(revealVC.tapGestureRecognizer())
        }

        // Add search bar
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.sizeToFit()
//        searchController.searchBar.backgroundImage = UIImage(named:"input_search")
//        searchController.searchBar.searchBarStyle = UISearchBarStyle.Prominent;
        tableView.tableHeaderView = searchController.searchBar
        tableView.reloadData()
        
        tableView.registerNib(UINib(nibName: Utils.name(EventChannelTableViewCell.classForCoder()), bundle: nil), forCellReuseIdentifier: Utils.name(EventChannelTableViewCell.classForCoder()))
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        let searchString = searchController.searchBar.text!.lowercaseString
        filteredChannels = hackatonChannels.filter {
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
    
    override func viewWillAppear(animated: Bool) {
        self.navigationItem.title = kStr_Events;
        if ((ChannelManager.sharedInstance.eventChannelDetails?.count) != nil) {
            hackatonChannels = ChannelManager.sharedInstance.eventChannelDetails!
            tableView.reloadData()
        }
        self.loadDetails();
        
    }
    
    //MARK: - UITableView

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 150
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.active {
            return filteredChannels.count
        }
        return hackatonChannels.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Utils.name(EventChannelTableViewCell.classForCoder()), forIndexPath: indexPath) as! EventChannelTableViewCell
        cell.detailResponse = searchController.active ? filteredChannels[indexPath.row] : hackatonChannels[indexPath.row]
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        searchController.active = false
        
        if let chatVC = self.storyboard?.instantiateViewControllerWithIdentifier(vc_id_Chat) as? ChatViewController,let cell = tableView.cellForRowAtIndexPath(indexPath) as? EventChannelTableViewCell {
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
    
    //MARK: - Actions

    @IBAction func refreshChannelDetail() {
        loadDetails()
    }

    @IBAction func showSideMenu(sender: UIBarButtonItem) {
        self.revealViewController().revealToggleAnimated(true)        
    }
    //MARK: - Private

    private func loadDetails() {
        // Get all channels the current user is subscribed to
        
        MMXChannel.allPublicChannelsWithLimit(100, offset: 0, success: { (total, channels) -> Void in
            print("channels total \(total) \(channels)")
            
            var eventChannels = channels;
            
            for channel:MMXChannel in channels {
                channel.subscribeWithSuccess(nil, failure: nil)
                if channel.summary!.containsString("Ask") {
                    eventChannels .removeAtIndex(channels.indexOf(channel)!)
                }
            }
            
            MMXChannel.channelDetails(eventChannels, numberOfMessages: 10, numberOfSubcribers: 1000, success: { detailResponses in
                ChannelManager.sharedInstance.eventChannels = eventChannels
                if eventChannels.count > 0 {
                    // Get details
                    MMXChannel.channelDetails(eventChannels, numberOfMessages: 10, numberOfSubcribers: 1000, success: { detailResponses in
                        let sortedDetails = detailResponses.sort({ (detail1, detail2) -> Bool in
                            let formatter = ChannelManager.sharedInstance.formatter
                            return formatter.dateForStringTime(detail1.lastPublishedTime)?.timeIntervalSince1970 > formatter.dateForStringTime(detail2.lastPublishedTime)?.timeIntervalSince1970
                        })
                        
                        ChannelManager.sharedInstance.eventChannelDetails = sortedDetails
                        
                        self.hackatonChannels = sortedDetails
                        self.endRefreshing()
                        }, failure: { error in
                            self.endRefreshing()
                            print(error)
                    })
                } else {
                    ChannelManager.sharedInstance.eventChannelDetails?.removeAll()
                }

                }) { [weak self] error in
                    self?.endRefreshing()
                    print(error)
            }
            }) { (error) -> Void in
                print("error \(error)")
        }
    }
    
    private func endRefreshing() {
        refreshControl?.endRefreshing()
        tableView.reloadData()
    }
}
