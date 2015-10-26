/**
 * Copyright (c) 2012-2015 Magnet Systems, Inc. All rights reserved.
 */

import Foundation

public extension MMUser {
    
    static private var currentlyLoggedInUser: MMUser?
    
    public func register(success: ((user: MMUser) -> Void)?, failure: ((error: NSError) -> Void)?) {
        MMCoreConfiguration.serviceAdapter.registerUser(self, success: { (user) -> Void in
            success?(user: user)
        }) { (error) -> Void in
            failure?(error: error)
        }.executeInBackground(nil)
    }
    
    static public func login(credential: NSURLCredential, success: (() -> Void)?, failure: ((error: NSError) -> Void)?) {
        MMCoreConfiguration.serviceAdapter.loginWithUsername(credential.user, password: credential.password, success: { _ in
            // Get current user now
            MMCoreConfiguration.serviceAdapter.getCurrentUserWithSuccess({ (user) -> Void in
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
    
    static public func currentUser() -> MMUser? {
        return currentlyLoggedInUser
    }
    
    static public func searchUsers(query: String, take: Int, skip: Int, sort: String, success: (([MMUser]) -> Void)?, failure: ((error: NSError) -> Void)?) {
        
        let userService = MMUserService()
        userService.searchUsers(query, take: Int32(take), skip: Int32(skip), sort: sort, success: { (users) -> Void in
            success?(users)
        }) { (error) -> Void in
            failure?(error: error)
        }.executeInBackground(nil)
    }
    
    static public func usersWithUserNames(userNames:[String], success: (([MMUser]) -> Void)?, failure: ((error: NSError) -> Void)?) {
        
        let userService = MMUserService()
        userService.getUsersByUserNames(userNames, success: { (users) -> Void in
            success?(users)
        }) { (error) -> Void in
            failure?(error: error)
        }.executeInBackground(nil)
    }
    
    static public func usersWithUserIDs(userIDs:[String], success: (([MMUser]) -> Void)?, failure: ((error: NSError) -> Void)?) {
        
        let userService = MMUserService()
        userService.getUsersByUserIds(userIDs, success: { (users) -> Void in
            success?(users)
            }) { (error) -> Void in
                failure?(error: error)
            }.executeInBackground(nil)
    }
}
