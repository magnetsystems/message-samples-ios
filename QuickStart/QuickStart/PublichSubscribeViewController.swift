//
//  PublichSubscribeViewController.swift
//  KitchenSink
//
//  Created by Kostya Grishchenko on 12/24/15.
//  Copyright © 2015 Magnet Systems, Inc. All rights reserved.
//

import UIKit

class PublichSubscribeViewController: UITableViewController {

    
    // MARK: - Navigation

    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let listController = segue.destinationViewController as? ChannelListViewController {
            let cell = sender as? UITableViewCell
            listController.title = cell?.textLabel?.text
            
            if let indexPath = tableView.indexPathForCell(cell!) {
                switch indexPath.row {
                    case 1: listController.channelType = .Subscribed
                    case 2: listController.channelType = .AllPublic
                    case 3: listController.channelType = .Private
                    default: listController.channelType = .None
                }
            }
        }
    }

}
