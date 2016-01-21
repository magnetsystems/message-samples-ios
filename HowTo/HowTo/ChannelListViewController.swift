/*
* Copyright (c) 2015 Magnet Systems, Inc.
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

import UIKit
import MagnetMax

class ChannelListViewController: UITableViewController {
    
    
    // MARK: Types
    
    
    enum ChannelType {
        case None
        case Subscribed
        case AllPublic
        case Private
    }
    
    
    // MARK: Public properties
    
    
    var channelType : ChannelType = .None
    
    var channels : [MMXChannel] = [] {
        didSet {
            let indicator = self.navigationItem.rightBarButtonItem?.customView as! UIActivityIndicatorView
            indicator.stopAnimating()
            
            if tableView.editing == false {
                tableView.reloadData()
            }
        }
    }
    
    
    // MARK: Overrides
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let indicator = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
        indicator.startAnimating()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: indicator)
        
        loadChannels()
    }
    
    
    // MARK: - Private implementation
    
    
    private func loadChannels() {
        switch channelType {
            case .Subscribed:
                MMXChannel.subscribedChannelsWithSuccess({ channels in
                    self.channels = channels
                }, failure: { error in
                    print("[ERROR]: \(error)")
                })
            case .AllPublic:
                MMXChannel.allPublicChannelsWithLimit(100, offset: 0, success: { (count, channels) in
                    self.channels = channels
                }, failure: { error in
                    print("[ERROR]: \(error)")
                })
            case .Private:
                MMXChannel.allPrivateChannelsWithLimit(100, offset: 0, success: { (count, channels) in
                    self.channels = channels
                }, failure: { error in
                    print("[ERROR]: \(error)")
                })
            default:break
        }
    }
    

    // MARK: - Table view data source

    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return channels.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ChannelCellIdentifier", forIndexPath: indexPath) as! ChannelCell

        cell.channel = channels[indexPath.row]
        
        return cell
    }

    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        let channel = channels[indexPath.row]
        // only allow the owner to delete a channel
        return channel.ownerUserID == MMUser.currentUser()?.userID
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60
    }

    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
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
            let cell = sender as! ChannelCell
            // set selected channel
            if let messagesVC = controllers?.first as? MessagesViewController {
                messagesVC.myChatChannel = cell.channel
            }
            if let subscribersVC = controllers?.last as? SubscribersViewController {
                subscribersVC.channel = cell.channel
            }
        }
    }

}
