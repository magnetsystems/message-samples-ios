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

@objc public protocol MMUserDelegate {
    
    static func overrideCompletion(completion:((error: NSError?) -> Void), error:NSError?, context:String)
    
}

public enum SessionStatus {
    case NotLoggedIn
    case LoggedIn
    case CanResume
}

public extension MMUser {
    
    /// The currently logged-in user or nil.
    static private var currentlyLoggedInUser: MMUser? {
        didSet {
            if let user = currentlyLoggedInUser where user.rememberMe {
                saveCurrentUser()
            } else {
                deleteSavedUser()
            }
        }
    }
    
    private struct HATTokenRefreshStatus : OptionSetType {
        let rawValue: Int
        
        static let None         = HATTokenRefreshStatus(rawValue: 0)
        static let HasRefreshed  = HATTokenRefreshStatus(rawValue: 1 << 0)
        static let WaitingForRefresh = HATTokenRefreshStatus(rawValue: 1 << 1)
    }
    
    static private var resumeSessionCompletionBlocks : [((error : NSError?) -> Void)] = [];
    static private let SAVED_OBJECT_KEY = "com.magnet.user.current"
    static private var tokenRefreshStatus : HATTokenRefreshStatus = .None
    
    @nonobjc static public var delegate : MMUserDelegate.Type?
    
    private func avatarID() -> String {
        return self.userID
    }
    
    
    
    /**
     The unique avatar URL for the user.
     */
    public func avatarURL() -> NSURL? {
        var url : NSURL? = nil
        if extras["hasAvatar"] == "true" {
            if let accessToken = MMCoreConfiguration.serviceAdapter.HATToken {
                url = MMAttachmentService.attachmentURL(avatarID(), userId: self.userID, parameters: ["access_token" : accessToken])
            }
        }
        
        return url
    }
    
    /**
     sets the avatar image for the user with file.
     */
    public func setAvatarWithURL(url : NSURL, success: ((url : NSURL?) -> Void)?, failure: ((error: NSError) -> Void)? ) -> Void {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {
            let data : NSData? = NSData.init(contentsOfURL: url)

            self.setAvatarWithData(data, success: success, failure: failure)
        })
    }
    
    /**
     sets the avatar image for the user with data.
     */
    public func setAvatarWithData(data : NSData?, success: ((url : NSURL?) -> Void)?, failure: ((error: NSError) -> Void)? ) -> Void {
        guard let imageData = data where imageData.length > 0 else {
            let userInfo = [
                NSLocalizedDescriptionKey: NSLocalizedString("Data Empty", comment : "Data Empty"),
                NSLocalizedFailureReasonErrorKey: NSLocalizedString("NSData cannot be nil", comment : "NSData cannot be nil"),
            ]
            
            let error = NSError.init(domain: "MMErrorDomain", code: 500, userInfo: userInfo)
            failure?(error: error)
            
            return
        }
        
        let attachment = MMAttachment.init(data: imageData, mimeType: "image/png")
        let metaData = ["file_id" : avatarID()]
        MMAttachmentService.upload([attachment], metaData: metaData, success: {
            let updateProfileRequest = MMUpdateProfileRequest(user: MMUser.currentUser())
            updateProfileRequest.password = nil
            updateProfileRequest.extras["hasAvatar"] = "true"
            MMUser.updateProfile(updateProfileRequest, success: { user in
                success?(url: self.avatarURL())
            }, failure:failure)
        }, failure:failure)
    }
    
    /**
        Registers a new user.
     
        - Parameters:
            - success: A block object to be executed when the registration finishes successfully. This block has no return value and takes one argument: the newly created user.
            - failure: A block object to be executed when the registration finishes with an error. This block has no return value and takes one argument: the error object.
    */
    public func register(success: ((user: MMUser) -> Void)?, failure: ((error: NSError) -> Void)?) {

        assert(!userName.isEmpty && !password.isEmpty, "userName or password cannot be empty")
        
        MMCoreConfiguration.serviceAdapter.registerUser(self, success: { user in
            success?(user: user)
        }) { error in
            failure?(error: error)
        }.executeInBackground(nil)
    }

    /**
     Logs in as a MMuser from saved Token.
     - success: A block object to be executed when the login finishes successfully. This block has no return value and takes no arguments.
     - failure: A block object to be executed when the login finishes with an error. This block has no return value and takes one argument: the error object.
     */
    static public func resumeSession(success: (() -> Void)?, failure: ((error: NSError) -> Void)?) {

            let completion : ((error : NSError?) -> Void) = { error in
                guard let e = error else {
                    success?()
                    
                    return
                }
                
                failure?(error: e)
            }
        
        if self.sessionStatus() == .NotLoggedIn {
            let error = NSError.init(domain:"com.magnet.mms.no.user", code: 400, userInfo: nil)
            completion(error: error)
            
            return
        } else if currentUser() != nil && tokenRefreshStatus == .None {
            completion(error: nil)
            
            return
        }
        
        resumeSessionCompletionBlocks.append(completion)
        
        tokenRefreshStatus = tokenRefreshStatus.union(.WaitingForRefresh)
        if tokenRefreshStatus.contains(.HasRefreshed) && resumeSessionCompletionBlocks.count == 1 {
            resumeSession()
        }
    }
    
    static private func resumeSession() {
        if let user = retrieveSavedUser() {
            updateCurrentUser(user, rememberMe: true)
            //update current user
            if let _ = self.delegate {
                handleCompletion({
                    tokenRefreshStatus = .None
                    for i in (0..<resumeSessionCompletionBlocks.count).reverse() {
                        let completion = resumeSessionCompletionBlocks[i]
                        completion(error: nil)
                    }
                    resumeSessionCompletionBlocks = []
                    
                    }, failure:{error in
                        tokenRefreshStatus = .None
                        for i in (0..<resumeSessionCompletionBlocks.count).reverse() {
                            let completion = resumeSessionCompletionBlocks[i]
                            completion(error: error)
                        }
                        resumeSessionCompletionBlocks = []
                        
                    }, error : nil, context: "com.magnet.login.succeeded")
            }
        }
    }
    
    /**
        Logs in as an user.
     
        - Parameters:
            - credential: A credential object containing the user's userName and password.
            - success: A block object to be executed when the login finishes successfully. This block has no return value and takes no arguments.
            - failure: A block object to be executed when the login finishes with an error. This block has no return value and takes one argument: the error object.
    */
    static public func login(credential: NSURLCredential, success: (() -> Void)?, failure: ((error: NSError) -> Void)?) {
        login(credential, rememberMe: false, success: success, failure: failure)
    }
    
    /**
        Logs in as an user.
     
        - Parameters:
            - credential: A credential object containing the user's userName and password.
            - rememberMe: A boolean indicating if the user should stay logged in across app restarts.
            - success: A block object to be executed when the login finishes successfully. This block has no return value and takes no arguments.
            - failure: A block object to be executed when the login finishes with an error. This block has no return value and takes one argument: the error object.
     */
    static public func login(credential: NSURLCredential, rememberMe: Bool, success: (() -> Void)?, failure: ((error: NSError) -> Void)?) {
        
        let loginClosure : () -> Void = { () in
        MMCoreConfiguration.serviceAdapter.loginWithUsername(credential.user, password: credential.password, rememberMe: rememberMe, success: { _ in
            // Get current user now
            MMCoreConfiguration.serviceAdapter.getCurrentUserWithSuccess({ user -> Void in
               //update current user
                updateCurrentUser(user, rememberMe: rememberMe)
                
                if let _ = self.delegate {
                    handleCompletion(success, failure: failure, error : nil, context: "com.magnet.login.succeeded")
                } else {
                    success?()
                }
                
                }, failure: { error in
                    if let _ = self.delegate {
                        handleCompletion(success, failure: failure, error : error, context: "com.magnet.login.failed")
                    } else {
                        failure?(error: error)
                    }
            }).executeInBackground(nil)
            
            }) { error in
                if let _ = self.delegate {
                    handleCompletion(success, failure: failure, error : error, context: "com.magnet.login.failed")
                } else {
                    failure?(error: error)
                }
            }.executeInBackground(nil)
        }
        
        //begin login
        if currentlyLoggedInUser != nil {
            MMUser.logout({ () in
                loginClosure()
                }) { error in
                    failure?(error : error);
            }
            
        } else {
            loginClosure()
        }
    }
    
    /**
     Refreshes A Saved User
     */
    @objc static private func refreshUser() {
        tokenRefreshStatus = tokenRefreshStatus.union(.HasRefreshed)
        if tokenRefreshStatus.contains(.WaitingForRefresh) {
            resumeSession()
        }
    }

    static private func updateCurrentUser(user : MMUser, rememberMe : Bool) {
        // Reset the state
        userTokenExpired(nil)
        user.rememberMe = rememberMe
        user.password = nil
        currentlyLoggedInUser = user
        let userInfo = ["userID": user.userID, "deviceID": MMServiceAdapter.deviceUUID(), "token": MMCoreConfiguration.serviceAdapter.HATToken]
        NSNotificationCenter.defaultCenter().postNotificationName(MMServiceAdapterDidReceiveHATTokenNotification, object: self, userInfo: userInfo)
        
        // Register for token expired notification
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "userTokenExpired:", name: MMServiceAdapterDidReceiveAuthenticationChallengeNotification, object: nil)
    }
    
    static private func handleCompletion(success: (() -> Void)?, failure: ((error: NSError) -> Void)?, error: NSError?, context : String) {
        delegate?.overrideCompletion({ (error) -> Void in
            if let error = error {
                failure?(error: error)
            } else {
                success?()
            }
            }, error: error, context: context)
    }
    
    
    /**
        Acts as the userToken expired event receiver.
     
        - Parameters:
            - notification: The notification that was received.
     */
    @objc static private func userTokenExpired(notification: NSNotification?) {
        currentlyLoggedInUser = nil
        // Unregister for token expired notification
        NSNotificationCenter.defaultCenter().removeObserver(self, name: MMServiceAdapterDidReceiveAuthenticationChallengeNotification, object: nil)
    }
    
    /**
        Logs out a currently logged-in user.
    */
    static public func logout() {
        logout(nil, failure: nil)
    }
    /**
        Logs out a currently logged-in user.
     
        - Parameters:
            - success: A block object to be executed when the logout finishes successfully. This block has no return value and takes no arguments.
            - failure: A block object to be executed when the logout finishes with an error. This block has no return value and takes one argument: the error object.
    */
    static public func logout(success: (() -> Void)?, failure: ((error: NSError) -> Void)?) {
        tokenRefreshStatus = .None
        
        if currentUser() == nil {
            success?()
            return
        }
        
        userTokenExpired(nil)
        
        MMCoreConfiguration.serviceAdapter.logoutWithSuccess({ _ in
            success?()
            }) { error in
                failure?(error: error)
            }.executeInBackground(nil)
    }

    /**
     Get the user logged in status
     
     - Returns: Whether a user is logged in or not or is a user can be retrieved from saved credential
     */
    static public func sessionStatus() -> SessionStatus {
        if self.currentUser() != nil {
            return .LoggedIn
        } else if self.retrieveSavedUser() != nil {
            return .CanResume
        } else {
            return .NotLoggedIn
        }
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
            - limit: The number of records to retrieve.
            - offset: The offset to start from.
            - sort: The sort criteria.
            - success: A block object to be executed when the call finishes successfully. This block has no return value and takes one argument: the list of users that match the specified criteria.
            - failure: A block object to be executed when the call finishes with an error. This block has no return value and takes one argument: the error object.
    */
    static public func searchUsers(query: String, limit take: Int, offset skip: Int, sort: String, success: (([MMUser]) -> Void)?, failure: ((error: NSError) -> Void)?) {
        
        let userService = MMUserService()
        userService.searchUsers(query, take: Int32(take), skip: Int32(skip), sort: sort, success: { users in
            success?(users)
        }) { error in
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
        userService.getUsersByUserNames(userNames, success: { users in
            success?(users)
        }) { error in
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
        userService.getUsersByUserIds(userIDs, success: { users in
            success?(users)
            }) { error in
                failure?(error: error)
            }.executeInBackground(nil)
    }
    
    /**
        Update the currently logged-in user's profile.
     
        - Parameters:
            - updateProfileRequest: A profile update request.
            - success: A block object to be executed when the update finishes successfully. This block has no return value and takes one argument: the updated user.
            - failure: A block object to be executed when the registration finishes with an error. This block has no return value and takes one argument: the error object.
     */
    static public func updateProfile(updateProfileRequest: MMUpdateProfileRequest, success: ((user: MMUser) -> Void)?, failure: ((error: NSError) -> Void)?) {
        guard let _ = currentUser() else {
            // FIXME: Use a different domain
            failure?(error: NSError(domain: "MMXErrorDomain", code: 401, userInfo: nil))
            return
        }
        let userService = MMUserService()
        userService.updateProfile(updateProfileRequest, success: { _ in
            // Get current user now
            MMCoreConfiguration.serviceAdapter.getCurrentUserWithSuccess({ user in
                currentlyLoggedInUser = user
                success?(user: user)
            }) { error in
                failure?(error: error)
            }.executeInBackground(nil)
        }) { error in
            failure?(error: error)
        }.executeInBackground(nil)
    }
    
    override public func isEqual(object: AnyObject?) -> Bool {
        if let rhs = object as? MMUser {
            return userID != nil && userID == rhs.userID
        }
        return false
    }
    
    override var hash: Int {
        return userID != nil ? userID.hashValue : ObjectIdentifier(self).hashValue
    }
    
    static private func deleteSavedUser() {
        NSUserDefaults.standardUserDefaults().removeObjectForKey(SAVED_OBJECT_KEY)
    }
    
    static public func savedUser() -> MMUser? {
        
    return retrieveSavedUser()
    }
    
    static private func retrieveSavedUser() -> MMUser? {
        guard let data = NSUserDefaults.standardUserDefaults().objectForKey(SAVED_OBJECT_KEY) as? NSData where MMCoreConfiguration.serviceAdapter.hasAuthToken() == true else {
            self.deleteSavedUser()
            return nil
        }
        return NSKeyedUnarchiver.unarchiveObjectWithData(data) as? MMUser
    }
    
    static private func saveCurrentUser() {
        guard let currentUser = currentlyLoggedInUser else {
            self.deleteSavedUser()
            return
        }
        let data = NSKeyedArchiver.archivedDataWithRootObject(currentUser)
        NSUserDefaults.standardUserDefaults().setObject(data, forKey: SAVED_OBJECT_KEY)
    }

    static public func registerForNotifications() {
        struct Pred {
            static var token: dispatch_once_t = 0
        }
        dispatch_once(&Pred.token, {
             NSNotificationCenter.defaultCenter().addObserver(self, selector: "refreshUser" , name: MMServiceAdapterDidRestoreHATTokenNotification, object: nil)
            })
    }
    
    
}
