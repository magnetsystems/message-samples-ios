//
//  FindChannelsViewController.swift
//  KitchenSink
//
//  Created by Kostya Grishchenko on 12/24/15.
//  Copyright © 2015 Magnet Systems, Inc. All rights reserved.
//

import UIKit
import MagnetMax

class FindChannelsViewController: UIViewController, UITableViewDataSource {
    
    
    // MARK: Outlets
    
    
    @IBOutlet weak var segCtrlSearchType: UISegmentedControl!
    @IBOutlet weak var tvChannels: UITableView!
    @IBOutlet weak var txtfSearchParameter: UITextField!
   
    
    // MARK: Public properties
    
    
    var channels : [MMXChannel] = [] {
        didSet {
            if tvChannels.editing == false {
                tvChannels.reloadData()
            }
        }
    }

    
    // MARK: Actions
    
    
    @IBAction func searchAction() {
        
        if let parameter = txtfSearchParameter.text where (parameter.isEmpty == false) {
            let limit: Int32 = 10
            let offset: Int32 = 0
            
            switch segCtrlSearchType.selectedSegmentIndex {
            case 0:
                MMXChannel.channelForName(parameter, isPublic: true, success: { [weak self] (channel) in
                    self?.channels = [channel]
                }, failure: { error in
                    print("[ERROR]: \(error)")
                })
            case 1:
                MMXChannel.channelsStartingWith(parameter, limit: limit, offset: offset, success: { [weak self] (count, channels) in
                    self?.channels = channels
                }, failure: { error in
                    print("[ERROR]: \(error)")
                })
            case 2:
                let tagsArray = parameter.componentsSeparatedByString(" ")
                let tagsSet = Set<String> (tagsArray)
                MMXChannel.findByTags(tagsSet, limit: limit, offset: offset, success: { [weak self] (count, channels) in
                    self?.channels = channels
                }, failure: { error in
                    print("[ERROR]: \(error)")
                })
                
            default: break
            }
        }
    }
    
    
    //MARK: TableView data source
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return channels.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ChannelCellIdentifier", forIndexPath: indexPath)
        
        let channel = channels[indexPath.row]
        cell.textLabel?.text = channel.name
        
        return cell
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        let channel = channels[indexPath.row]
        // only allow the owner to delete a channel
        return channel.ownerUserID == MMUser.currentUser()?.userID
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // delete channel
            let channel = channels[indexPath.row]
            channel.deleteWithSuccess({ [weak self] in
                print("Channel is deleted success")
                self?.channels.removeAtIndex(indexPath.row)
                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            }, failure: { error in
                print("[ERROR]: \(error)")
            })
        }
    }

    
    // MARK: - Navigation
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let tabVC = segue.destinationViewController as? UITabBarController {
            let controllers = tabVC.viewControllers
            let cell = sender as! UITableViewCell
            if let indexPath = tvChannels.indexPathForCell(cell) {
                let channel = channels[indexPath.row]
                // set selected channel
                if let messagesVC = controllers?.first as? MessagesViewController {
                    messagesVC.myChatChannel = channel
                }
                if let subscribersVC = controllers?.last as? SubscribersViewController {
                    subscribersVC.channel = channel
                }
            }
        }
    }
    
}
