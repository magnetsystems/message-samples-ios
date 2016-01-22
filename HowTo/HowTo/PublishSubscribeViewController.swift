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

class PublishSubscribeViewController: UITableViewController {

    
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
