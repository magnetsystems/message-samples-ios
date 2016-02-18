//
//  EventsViewController.swift
//  Messenger
//
//  Created by Vladimir Yevdokimov on 2/9/16.
//  Copyright © 2016 Magnet Systems, Inc. All rights reserved.
//

import UIKit
import MagnetMax

class EventsViewController: UITableViewController, ContactsViewControllerDelegate {

    var hackatonChannels: [MMXChannelDetailResponse] = [];
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if let revealVC = self.revealViewController() {
            self.view.addGestureRecognizer(revealVC.panGestureRecognizer())
            self.view.addGestureRecognizer(revealVC.tapGestureRecognizer())
        }
        
        tableView.registerNib(UINib(nibName: Utils.name(EventChannelTableViewCell.classForCoder()), bundle: nil), forCellReuseIdentifier: Utils.name(EventChannelTableViewCell.classForCoder()))
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
        return hackatonChannels.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Utils.name(EventChannelTableViewCell.classForCoder()), forIndexPath: indexPath) as! EventChannelTableViewCell
        cell.detailResponse = hackatonChannels[indexPath.row]
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if let chatVC = self.storyboard?.instantiateViewControllerWithIdentifier(vc_id_Chat) as? ChatViewController,let cell = tableView.cellForRowAtIndexPath(indexPath) as? EventChannelTableViewCell {
            chatVC.chat = cell.detailResponse.channel
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
    
    //MARK: - Actions

    @IBAction func createNewChat (sender: UIBarButtonItem) {
        
        if let navigationVC = self.storyboard?.instantiateViewControllerWithIdentifier(vc_id_ContactsNav) as? UINavigationController {
            if let contactsVC = navigationVC.topViewController as? ContactsViewController {
                contactsVC.delegate = self
                contactsVC.title = kStr_NewMessage
                
                self.navigationController?.presentViewController(navigationVC, animated: true, completion: nil)
            }
        }

    }
    
    @IBAction func refreshChannelDetail() {
        loadDetails()
    }

    @IBAction func showSideMenu(sender: UIBarButtonItem) {
        self.revealViewController().revealToggleAnimated(true)        
    }
    //MARK: - Private

    private func loadDetails() {
        // Get all channels the current user is subscribed to
        
        refreshControl?.beginRefreshing()
        
        MMXChannel.findByTags(Set(["hackathon"]), limit: 100, offset: 0, success: { (total, eventChannels) -> Void in
            
            if eventChannels.count > 0 {
                
                MMXChannel.channelDetails(eventChannels, numberOfMessages: 10, numberOfSubcribers: 1000, success: { detailResponses in
                    ChannelManager.sharedInstance.eventChannels = eventChannels
                    if eventChannels.count > 0 {
                        // Get details
                        MMXChannel.channelDetails(eventChannels, numberOfMessages: 10, numberOfSubcribers: 1000, success: { detailResponses in
                            let sortedDetails = detailResponses.sort({ (detail1, detail2) -> Bool in
                                return (detail1.channel.creationDate.timeIntervalSince1970 > detail2.channel.creationDate.timeIntervalSince1970)
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
                        self.endRefreshing()

                    }
                    }) { [weak self] error in
                        self?.endRefreshing()
                        print(error)
                }
            } else {
                self.endRefreshing()
            }
            
            
            }) { (error) -> Void in
                self.endRefreshing()
        }
        
    }
    
    private func endRefreshing() {
        refreshControl?.endRefreshing()
        tableView.reloadData()
    }
}
