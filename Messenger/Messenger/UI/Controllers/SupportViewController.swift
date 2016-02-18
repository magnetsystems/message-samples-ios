//
//  SupportViewController.swift
//  Messenger
//
//  Created by Kostya Grishchenko on 2/15/16.
//  Copyright © 2016 Magnet Systems, Inc. All rights reserved.
//

import UIKit
import MagnetMax

class SupportViewController: UITableViewController {
    
    var supportChannels: [MMXChannel] = [];
    var supportChannelDetails: [MMXChannelDetailResponse] = [];
    var users: [MMUser] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        if let revealVC = self.revealViewController() {
            self.view.addGestureRecognizer(revealVC.panGestureRecognizer())
            self.view.addGestureRecognizer(revealVC.tapGestureRecognizer())
        }
        
        tableView.registerNib(UINib(nibName: Utils.name(SupportTableViewCell.classForCoder()), bundle: nil), forCellReuseIdentifier: Utils.name(SupportTableViewCell.classForCoder()))
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationItem.title = kStr_Support;
        self.loadDetails()
    }

    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return supportChannelDetails.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Utils.name(SupportTableViewCell.classForCoder()), forIndexPath: indexPath) as! SupportTableViewCell
        cell.detailResponse = supportChannelDetails[indexPath.row]
        if let user = userForChannelDetail(supportChannelDetails[indexPath.row]) {
            cell.lblAsker.text = "\(user.firstName ?? "") \(user.lastName ?? "")"

            let placeHolderImage = Utils.noAvatarImageForUser(user)
            
            if let avatarImage = cell.ivAvatarImage {
                Utils.loadImageWithUrl(user.avatarURL(), toImageView: avatarImage, placeholderImage: placeHolderImage)
            }
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if let chatVC = self.storyboard?.instantiateViewControllerWithIdentifier(vc_id_Chat) as? ChatViewController,let cell = tableView.cellForRowAtIndexPath(indexPath) as? SupportTableViewCell {
            chatVC.chat = cell.detailResponse.channel
            self.navigationController?.pushViewController(chatVC, animated: true)
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
        // Get all Ask Magnet channels
        
        refreshControl?.beginRefreshing()
        
        MMXChannel.subscribedChannelsWithSuccess({ [weak self] allChannels in
            let channels = allChannels.filter({ $0.name == kAskMagnetChannel})
            if channels.count > 0 {
                self?.supportChannels = channels
                MMXChannel.channelDetails(channels, numberOfMessages: 10, numberOfSubcribers: 1000, success: { detailResponses in
                    
                    let formatter = ChannelManager.sharedInstance.formatter
                    let sortedDetails = detailResponses.sort({
                        formatter.dateForStringTime($0.lastPublishedTime)?.timeIntervalSince1970 > formatter.dateForStringTime($1.lastPublishedTime)?.timeIntervalSince1970
                    })
                    
                    self?.supportChannelDetails = sortedDetails.filter { $0.messages.count != 0 }
                    
                    let IDs = (channels as NSArray).valueForKey("ownerUserID") as! [String]
                    MMUser.usersWithUserIDs(IDs, success: { [weak self] users in
                        self?.users = users
                        self?.endRefreshing()
                        }) { (error) -> Void in
                            print("[ERROR]: \(error)")
                            self?.endRefreshing()
                    }
                    
                    }, failure: { error in
                        print("[ERROR]: \(error)")
                        self?.endRefreshing()
                })
            }
            }) { [weak self] error in
                print("[ERROR]: \(error)")
                self?.endRefreshing()
        }
    }
    
    private func endRefreshing() {
        refreshControl?.endRefreshing()
        tableView.reloadData()
    }
    
    private func userForChannelDetail(detail: MMXChannelDetailResponse) -> MMUser? {
        
        var user: MMUser?
        for usr in users {
            if usr.userID == detail.channel.ownerUserID {
                user = usr
            }
        }
        
        return user
    }
    
}
