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

let MMXBlockContactsCellAlpha : CGFloat = 0.6

class ContactsViewControllerDatasource : DefaultContactsPickerControllerDatasource {
    
    override func mmxControllerLoadMore(searchText: String?, offset: Int) {
            BlockedUserManager.getBlockedUsers({_ in
                super.mmxControllerLoadMore(searchText, offset: offset)
                }, failure: { _ in
                    super.mmxControllerLoadMore(searchText, offset: offset)
            })
    }
    
    func mmxContactsDidCreateCell(cell: UITableViewCell) {
        var blocked = false
        
        if let user = (cell as? ContactsCell)?.user {
            blocked = BlockedUserManager.isUserBlocked(user)
        }
        
        if blocked {
            cell.contentView.alpha = MMXBlockContactsCellAlpha
        } else {
            cell.contentView.alpha = 1.0
        }
    }
}
