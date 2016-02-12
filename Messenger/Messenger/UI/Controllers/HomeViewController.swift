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

    
    var actualEvents : [MMXChannelDetailResponse] = []
    var askMagnet : [MMXChannelDetailResponse] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        definesPresentationContext = true
        
        if let revealVC = self.revealViewController() {
            self.view.addGestureRecognizer(revealVC.panGestureRecognizer())
            self.view.addGestureRecognizer(revealVC.tapGestureRecognizer())
        }
        
        self.view.addKeyboardPanningWithActionHandler(nil)
        navigationController?.setNavigationBarHidden(false, animated: true)
        
        // Add search bar
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.sizeToFit()
        searchController.searchBar.placeholder = "Search message by user"
        tableView.tableHeaderView = searchController.searchBar
        tableView.reloadData()
        
        tableView.registerNib(UINib(nibName: Utils.name(SummaryResponseCell.classForCoder()), bundle: nil), forCellReuseIdentifier: Utils.name(SummaryResponseCell.classForCoder()))
        tableView.registerNib(UINib(nibName: Utils.name(EventChannelTableViewCell.classForCoder()), bundle: nil), forCellReuseIdentifier: Utils.name(EventChannelTableViewCell.classForCoder()))
        tableView.registerNib(UINib(nibName: Utils.name(AskMagnetTableViewCell.classForCoder()), bundle: nil), forCellReuseIdentifier: Utils.name(AskMagnetTableViewCell.classForCoder()))
        tableView.registerNib(UINib(nibName: Utils.name(CreateChatCell.classForCoder()), bundle: nil), forCellReuseIdentifier: Utils.name(CreateChatCell.classForCoder()))
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        loadEventChannels()
        // Magnet Employees will have the magnetsupport tag
        // Hide the Ask Magnet option for Magnet employees
        askMagnet = [MMXChannelDetailResponse()]
        if !isMagnetEmployee() {
//            self.loadAskMagnetChannel()
                
        }
        loadDetails()
        ChannelManager.sharedInstance.addChannelMessageObserver(self, channel:nil, selector: "didReceiveMessage:")
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if let user = MMUser.currentUser() {
            self.title = "\(user.firstName ?? "") \(user.lastName ?? "")"
        }
        
        if NSUserDefaults.standardUserDefaults().boolForKey(kUserDefaultsShowProfile) {
            NSUserDefaults.standardUserDefaults().removeObjectForKey(kUserDefaultsShowProfile)
            self.navigationController!.presentViewController((self.storyboard?.instantiateViewControllerWithIdentifier(vc_id_UserProfile))!, animated: true, completion: nil)
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.title = nil
        
        ChannelManager.sharedInstance.removeChannelMessageObserver(self)
    }
    
    func loadEventChannels(){
        
        MMXChannel.findByTags( Set(["active"]), limit: 5, offset: 0, success: { (total, channels) -> Void in
            if channels.count > 0 {
                let channel = channels.first
                channel?.subscribeWithSuccess({ () -> Void in
                    MMXChannel.channelDetails(channels, numberOfMessages: 100, numberOfSubcribers: 1000, success: { (responseDetails) -> Void in
                        self.actualEvents = responseDetails
                        self.endRefreshing()
                        }, failure: { (error) -> Void in
                    })
                    }, failure: { (error) -> Void in
                      print("subscribe global error \(error)")
                })
            }
            }) { (error) -> Void in
        }
    }
    
    func loadAskMagnetChannel() {
        MMXChannel.findByTags( Set(["global"]), limit: 5, offset: 0, success: { (total, channels) -> Void in
            if channels.count > 0 {
                let channel = channels.first
                channel?.subscribeWithSuccess({ () -> Void in
                    MMXChannel.channelDetails(channels, numberOfMessages: 10, numberOfSubcribers: 1000, success: { (responseDetails) -> Void in
                        self.askMagnet = responseDetails
                        self.endRefreshing()
                        }, failure: { (error) -> Void in
                    })
                    }, failure: { (error) -> Void in
                        print("subscribe ask error \(error)")
                })
            }
            }) { (error) -> Void in
        }
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

    // MARK: - Table view data source

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        switch indexPath.section {
        case 0: return EventChannelTableViewCell.cellHeight()
        case 1 : return AskMagnetTableViewCell.cellHeight()
        case 2 :
            if detailResponses.count > 0 {return SummaryResponseCell.cellHeight()}
            else { return CreateChatCell.cellHeight()}
        default : return 44
        }
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch section {
        case 0: return actualEvents.count
        case 1: return askMagnet.count
        case 2:
            if detailResponses.count > 0 {
                if searchController.active {return filteredDetailResponses.count}
                else {return detailResponses.count}}
            else { return 1}
            
        default : return 0
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var channelDetail: MMXChannelDetailResponse = MMXChannelDetailResponse()
        var identifier = ""
        
        switch indexPath.section {
        case 0:
            identifier = Utils.name(EventChannelTableViewCell.classForCoder())
            channelDetail = self.actualEvents.first!
        case 1:
            identifier = Utils.name(AskMagnetTableViewCell.classForCoder())
            channelDetail = self.askMagnet.first!
        case 2:
            if detailResponses.count > 0 {
                identifier = Utils.name(SummaryResponseCell.classForCoder())
                if searchController.active {
                    channelDetail = filteredDetailResponses[indexPath.row]
                } else {
                    channelDetail = detailResponses[indexPath.row]
                }
            } else {
                identifier = Utils.name(CreateChatCell.classForCoder())
            }
        default:break;
        }
        
        let cell = tableView.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath) as! ChannelDetailBaseTVCell
        cell.detailResponse = channelDetail
        return cell
    }

    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if indexPath.section != 2 {
            return false
        }
        return true
    }
    
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        
        if indexPath.section != 2 {
            return nil
        }
        
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
                        if let channelIndexToRemove = self?.detailResponses.indexOf({$0.channelName == detailResponse.channelName}) {
                            self?.detailResponses.removeAtIndex(channelIndexToRemove)
                        }
                        if let channelIndexToRemove = self?.filteredDetailResponses.indexOf({$0.channelName == detailResponse.channelName}) {
                            self?.filteredDetailResponses.removeAtIndex(channelIndexToRemove)
                        }
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
                    if let channelIndexToRemove = self?.detailResponses.indexOf({$0.channelName == detailResponse.channelName}) {
                        self?.detailResponses.removeAtIndex(channelIndexToRemove)
                    }
                    if let channelIndexToRemove = self?.filteredDetailResponses.indexOf({$0.channelName == detailResponse.channelName}) {
                        self?.filteredDetailResponses.removeAtIndex(channelIndexToRemove)
                    }
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
        
        if indexPath.section == 2 && self.detailResponses.count == 0 {
            self.performSegueWithIdentifier(kSegueShowContactSelector, sender: nil)
        } else {
 
            if let chatVC = self.storyboard?.instantiateViewControllerWithIdentifier(vc_id_Chat) as? ChatViewController,let cell = tableView.cellForRowAtIndexPath(indexPath) as? ChannelDetailBaseTVCell {
                if indexPath.section != 2 {
                    // Ask Magnet channel
                    if indexPath.section == 1 {
                        chatVC.isAskMagnetChannel = true
                    }
                    chatVC.chat = cell.detailResponse?.channel
                    chatVC.canLeaveChat = false
                } else {
                    chatVC.chat = ChannelManager.sharedInstance.channelForName(cell.detailResponse!.channelName)
                    chatVC.canLeaveChat = true
                }
                self.navigationController?.pushViewController(chatVC, animated: true)
            }
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
        
        refreshControl?.beginRefreshing()
        
        // Get all channels the current user is subscribed to
        MMXChannel.subscribedChannelsWithSuccess({ [weak self] allChannels in
            let channels = allChannels.filter { !$0.name.hasPrefix("global_") && ( $0.name != "askMagnet" || (self != nil && self!.isMagnetEmployee()) ) }
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
                self?.detailResponses.removeAll()
                self?.endRefreshing()
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
    
    private func isMagnetEmployee() -> Bool {
        print(MMUser.currentUser())
        if let currentUser = MMUser.currentUser() where ( currentUser.email != nil && currentUser.email.hasSuffix(kMagnetEmailDomain) ) {
            return true
        }
        return false
    }

}

