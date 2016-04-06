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

class BlockedUserManager : NSObject {
    
    internal private(set) var blockedUsers : [MMUser]?
    private var successBlocks : [((users : [MMUser]) -> Void)] = []
    private var failureBlocks : [((error : NSError) -> Void)] = []
    
    override init() {
        super.init()
        
        resetBlockedUsers()
    }
    
    func getBlockedUsers(success : ((users : [MMUser]) -> Void), failure : ((error : NSError) -> Void)?) {
        
        if let blockedUsers = self.blockedUsers {
            success(users: blockedUsers)
        } else if successBlocks.count == 0 {
            successBlocks.append(success)
            if let failureBlock = failure {
                failureBlocks.append(failureBlock)
            }
            MMUser.blockedUsersWithSuccess({ users in
                self.blockedUsers = users.sort({$0.0.userID < $0.1.userID})
                self.successWith(users)
                }, failure: {error in
                    self.failureWith(error)
            })
        } else {
            successBlocks.append(success)
            if let failureBlock = failure {
                failureBlocks.append(failureBlock)
            }
        }
    }
    
    func resetBlockedUsers() {
        self.blockedUsers = nil
        self.getBlockedUsers({_ in
            //did Retrieve Blocked Users
            }, failure:nil)
    }
    
    func isUserBlocked(user : MMUser) -> Bool {
        if let blocked = self.blockedUsers {
            if blocked.contains(user) {
                return true
            }
        }
        return false
    }
    
    func isUserBlockedWithId(userId : String) -> Bool {
        if let blocked = self.blockedUsers {
            if blocked.map({$0.userID}).contains(userId) {
                return true
            }
        }
        return false
    }
    
    private func failureWith(error : NSError) {
        while let first = failureBlocks.first {
            first(error: error)
            let _ = failureBlocks.removeAtIndex(0)
        }
    }
    
    private func successWith(users : [MMUser]) {
        while let first = successBlocks.first {
            first(users: users)
            let _ = successBlocks.removeAtIndex(0)
        }
    }
}

class ContactsViewController: MMXContactsPickerController {
    
    
    var blockedUserManager : BlockedUserManager = BlockedUserManager()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.datasource = ContactsViewControllerDatasource()
    }
    
}
