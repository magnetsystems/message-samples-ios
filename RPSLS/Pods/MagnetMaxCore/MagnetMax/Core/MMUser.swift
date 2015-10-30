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

import Foundation

public extension MMUser {
    
    /// The currently logged-in user or nil.
    static private var currentlyLoggedInUser: MMUser?
    
    /**
        Registers a new user.
     
        - Parameters:
            - success: A block object to be executed when the registration finishes successfully. This block has no return value and takes one argument: the newly created user.
            - failure: A block object to be executed when the registration finishes with an error. This block has no return value and takes one argument: the error object.
    */
    public func register(success: ((user: MMUser) -> Void)?, failure: ((error: NSError) -> Void)?) {

        assert(!userName.isEmpty && !password.isEmpty, "userName or password cannot be empty")
        
        MMCoreConfiguration.serviceAdapter.registerUser(self, success: { user -> Void in
            success?(user: user)
        }) { (error) -> Void in
            failure?(error: error)
        }.executeInBackground(nil)
    }
    
    /**
        Logs in as an user.
     
        - Parameters:
            - credential: A credential object containing the user's userName and password.
            - success: A block object to be executed when the login finishes successfully. This block has no return value and takes no arguments.
            - failure: A block object to be executed when the login finishes with an error. This block has no return value and takes one argument: the error object.
    */
    static public func login(credential: NSURLCredential, success: (() -> Void)?, failure: ((error: NSError) -> Void)?) {
        MMCoreConfiguration.serviceAdapter.loginWithUsername(credential.user, password: credential.password, success: { _ in
            // Get current user now
            MMCoreConfiguration.serviceAdapter.getCurrentUserWithSuccess({ user -> Void in
                currentlyLoggedInUser = user
                let userInfo = ["userID": user.userID, "deviceID": MMServiceAdapter.deviceUUID(), "token": MMCoreConfiguration.serviceAdapter.HATToken]
                NSNotificationCenter.defaultCenter().postNotificationName(MMServiceAdapterDidReceiveHATTokenNotification, object: self, userInfo: userInfo)
                success?()
            }, failure: { (error) -> Void in
                failure?(error: error)
            }).executeInBackground(nil)
            
        }) { (error) -> Void in
            failure?(error: error)
        }.executeInBackground(nil)
    }
    
    /**
        Logs out a currently logged-in user.
     
        - Parameters:
            - success: A block object to be executed when the logout finishes successfully. This block has no return value and takes no arguments.
            - failure: A block object to be executed when the logout finishes with an error. This block has no return value and takes one argument: the error object.
    */
    static public func logout(success: (() -> Void)?, failure: ((error: NSError) -> Void)?) {
        if currentUser() == nil {
            success?()
            return
        }
        MMCoreConfiguration.serviceAdapter.logoutWithSuccess({ _ in
            currentlyLoggedInUser = nil
            success?()
        }) { (error) -> Void in
            failure?(error: error)
        }.executeInBackground(nil)
    }
    
    /**
        Get the currently logged-in user.
     
        - Returns: The currently logged-in user or nil.
    */
    static public func currentUser() -> MMUser? {
        return currentlyLoggedInUser
    }
    
    /**
        Search for users based on some criteria.
     
        - Parameters:
            - query: The DSL can be found here: https://www.elastic.co/guide/en/elasticsearch/reference/current/query-dsl-query-string-query.html#query-string-syntax
            - take: The number of records to retrieve.
            - skip: The offset to start from.
            - sort: The sort criteria.
            - success: A block object to be executed when the call finishes successfully. This block has no return value and takes one argument: the list of users that match the specified criteria.
            - failure: A block object to be executed when the call finishes with an error. This block has no return value and takes one argument: the error object.
    */
    static public func searchUsers(query: String, take: Int, skip: Int, sort: String, success: (([MMUser]) -> Void)?, failure: ((error: NSError) -> Void)?) {
        
        let userService = MMUserService()
        userService.searchUsers(query, take: Int32(take), skip: Int32(skip), sort: sort, success: { (users) -> Void in
            success?(users)
        }) { (error) -> Void in
            failure?(error: error)
        }.executeInBackground(nil)
    }
    
    /**
        Get users with userNames.
     
        - Parameters:
            - userNames: A list of userNames to fetch users for.
            - success: A block object to be executed when the logout finishes successfully. This block has no return value and takes one argument: the list of users for the specified userNames.
            - failure: A block object to be executed when the logout finishes with an error. This block has no return value and takes one argument: the error object.
    */
    static public func usersWithUserNames(userNames:[String], success: (([MMUser]) -> Void)?, failure: ((error: NSError) -> Void)?) {
        
        let userService = MMUserService()
        userService.getUsersByUserNames(userNames, success: { (users) -> Void in
            success?(users)
        }) { (error) -> Void in
            failure?(error: error)
        }.executeInBackground(nil)
    }
    
    /**
        Get users with userIDs.
     
        - Parameters:
            - userNames: A list of userIDs to fetch users for.
            - success: A block object to be executed when the logout finishes successfully. This block has no return value and takes one argument: the list of users for the specified userIDs.
            - failure: A block object to be executed when the logout finishes with an error. This block has no return value and takes one argument: the error object.
    */
    static public func usersWithUserIDs(userIDs:[String], success: (([MMUser]) -> Void)?, failure: ((error: NSError) -> Void)?) {
        
        let userService = MMUserService()
        userService.getUsersByUserIds(userIDs, success: { (users) -> Void in
            success?(users)
            }) { (error) -> Void in
                failure?(error: error)
            }.executeInBackground(nil)
    }
}
