/*
 * Copyright (c) 2016 Magnet Systems, Inc.
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
import ChatKit

class ContactsViewControllerDatasource : DefaultContactsPickerControllerDatasource {
    
    override func mmxControllerLoadMore(searchText: String?, offset: Int) {
        if let contactsViewController = self.controller as? ContactsViewController {
            contactsViewController.blockedUserManager.getBlockedUsers({_ in
                super.mmxControllerLoadMore(searchText, offset: offset)
                }, failure: { _ in
                    super.mmxControllerLoadMore(searchText, offset: offset)
            })
        } else {
            super.mmxControllerLoadMore(searchText, offset: offset)
        }
    }
    
    func mmxContactsDidCreateCell(cell: UITableViewCell) {
        var blocked = false
        
        if let user = (cell as? ContactsCell)?.user, let cV = controller as? ContactsViewController {
            blocked = cV.blockedUserManager.isUserBlocked(user)
        }
        
        if blocked {
            cell.contentView.alpha = 0.5
        } else {
            cell.contentView.alpha = 1.0
        }
    }
}
