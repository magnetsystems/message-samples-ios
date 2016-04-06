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
    
    
    //MARK: Static Properties
    
    
    static internal private(set) var blockedUsers : [MMUser]?
    static  private var successBlocks : [((users : [MMUser]) -> Void)] = []
    static  private var failureBlocks : [((error : NSError) -> Void)] = []
    
    
    //MARK: Static Methods
    
    
    static func blockUser(user : MMUser, completion : ((blocked : Bool) -> Void)) {
        MMUser.blockUsers(Set(arrayLiteral: user), success: {
            completion(blocked: true)
            blockedUsers?.append(user)
            }, failure: { _ in
                completion(blocked: false)
        })
    }
    
    static func unblockUser(user : MMUser, completion : ((unblocked : Bool) -> Void)) {
        MMUser.unblockUsers(Set(arrayLiteral: user), success: {
            completion(unblocked: true)
            blockedUsers = blockedUsers?.filter({$0 != user})
            }, failure: { _ in
                completion(unblocked: false)
        })
    }
    
    static func getBlockedUsers(success : ((users : [MMUser]) -> Void), failure : ((error : NSError) -> Void)?) {
        
        if let blockedUsers = self.blockedUsers {
            success(users: blockedUsers)
        } else if successBlocks.count == 0 {
            successBlocks.append(success)
            if let failureBlock = failure {
                failureBlocks.append(failureBlock)
            }
            MMUser.blockedUsersWithSuccess({ users in
                self.blockedUsers = users
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
    
    static func resetBlockedUsers() {
        self.blockedUsers = nil
        self.getBlockedUsers({_ in
            //did Retrieve Blocked Users
            }, failure:nil)
    }
    
    static func isUserBlocked(user : MMUser) -> Bool {
        if let blocked = self.blockedUsers {
            if blocked.contains(user) {
                return true
            }
        }
        return false
    }
    
    static func isUserBlockedWithId(userId : String) -> Bool {
        if let blocked = self.blockedUsers {
            if blocked.map({$0.userID}).contains(userId) {
                return true
            }
        }
        return false
    }
    
    static private func failureWith(error : NSError) {
        while let first = failureBlocks.first {
            first(error: error)
            let _ = failureBlocks.removeAtIndex(0)
        }
    }
    
    static private func successWith(users : [MMUser]) {
        while let first = successBlocks.first {
            first(users: users)
            let _ = successBlocks.removeAtIndex(0)
        }
    }
    
    static func confirmBlock(user : MMUser, completion: ((blocked:Bool) -> Void), canceled : (() -> Void)? = nil) -> UIAlertController {
        let alert = UIAlertController(title: "Block User", message: "Are you sure you want to block \(ChatKit.Utils.displayNameForUser(user))?", preferredStyle: .Alert)
        let button = UIAlertAction(title: "Cancel", style: .Cancel, handler: { action in
            canceled?()
        })
        alert.addAction(button)
        let buttonConfirm = UIAlertAction(title: "Ok", style: .Default, handler: { action in
            
            BlockedUserManager.blockUser(user, completion : completion)
            
        })
        alert.addAction(buttonConfirm)
        return alert
    }
    
    static func confirmUnblock(user : MMUser, completion: ((unblocked:Bool) -> Void), canceled : (() -> Void)? = nil) -> UIAlertController {
        let alert = UIAlertController(title: "Unblock User", message: "Are you sure you want to unblock \(ChatKit.Utils.displayNameForUser(user))?", preferredStyle: .Alert)
        let button = UIAlertAction(title: "Cancel", style: .Cancel, handler: { action in
            canceled?()
        })
        alert.addAction(button)
        let buttonConfirm = UIAlertAction(title: "Ok", style: .Default, handler: { action in
            
            BlockedUserManager.unblockUser(user, completion : completion)
        })
        alert.addAction(buttonConfirm)
        return alert
    }
    
    static func msg(message :String, title :String, closeTitle :String, handler:((UIAlertAction) -> Void)? = nil) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let button = UIAlertAction(title: closeTitle, style: .Cancel, handler: handler)
        alert.addAction(button)
        return alert
    }
}