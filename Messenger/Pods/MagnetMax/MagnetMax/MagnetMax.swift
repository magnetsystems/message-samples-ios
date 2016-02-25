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
import MagnetMaxCore
import MMX


@objc public class MagnetMax: NSObject, MMUserDelegate {
    
    /// The default baseURL.
    static private let defaultBaseURL = "https://sandbox.magnet.com/mobile/api"
    
    /// The service adapter with the current configuration.
    static var serviceAdapter: MMServiceAdapter?
    
    /**
        Configure MagnetMax with a clientID and clientSecret.
     
        - Parameters:
            - clientID: The clientID to be used.
            - clientSecret: The clientSecret to be used.
     */
    static public func configureWithClientID(clientID: String, clientSecret: String) {
        configureWithBaseURL(defaultBaseURL, clientID: clientID, clientSecret: clientSecret)
    }
    
    /**
        Configure MagnetMax with a baseURL, clientID and clientSecret.
     
        - Parameters:
            - baseURL: The baseURL to be used.
            - clientID: The clientID to be used.
            - clientSecret: The clientSecret to be used.
     */
    static public func configureWithBaseURL(baseURL: String, clientID: String, clientSecret: String) {
        let dictionary = ["BaseURL": baseURL, "ClientID": clientID, "ClientSecret": clientSecret]
        let configuration = MMPropertyListConfiguration(dictionary: dictionary)
        MagnetMax.configure(configuration)
    }
    
    /**
        Configure MagnetMax with specified configuration.
     
        - Parameters:
            - configuration: The configuration to be used.
    */
    static public func configure(configuration: MMConfiguration) {
        registerObservers()
        MMCoreConfiguration.currentConfiguration = configuration
        let client = MMClient()
        client.timeoutInterval = 15
        serviceAdapter = MMServiceAdapter(configuration: configuration, client:client)
        MMCoreConfiguration.serviceAdapter = serviceAdapter
        MMUser.delegate = self
        
        // Register Modules
        //        initModule(MMX.sharedInstance())
    }
    
    static public func overrideCompletion(completion: ((error: NSError?) -> Void), error: NSError?, context: String) {
        guard let e = error else {
            initializeModule(MMX.sharedInstance(), success: {
                completion(error:nil)
                }) { (error) -> Void in
                    completion(error:error)
            }
            return
        }
        completion(error: e)
    }
    
    /// Registers observers for various NSNotifications.
    static private func registerObservers() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "configurationReceived:", name: MMServiceAdapterDidReceiveConfigurationNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "appTokenReceived:", name: MMServiceAdapterDidReceiveCATTokenNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "userTokenReceived:", name: MMServiceAdapterDidReceiveHATTokenNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "userTokenInvalidated:", name: MMServiceAdapterDidInvalidateHATTokenNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "userTokenExpired:", name: MMServiceAdapterDidReceiveAuthenticationChallengeNotification, object: nil)
    }
    
    /**
        Acts as the configuration receiver.
     
        - Parameters:
            - notification: The notification that was received.
    */
    @objc static private func configurationReceived(notification: NSNotification) {
        configuration = notification.userInfo
        for module in modules {
            if configuration != nil {
                module.shouldInitializeWithConfiguration(configuration!, success: success, failure: failure)
            }
        }
    }
    
    /**
        Acts as the appToken receiver.
     
        - Parameters:
            - notification: The notification that was received.
    */
    @objc static private func appTokenReceived(notification: NSNotification) {
        let userInfo = notification.userInfo as! [String: String]
        appID = userInfo["appID"]
        deviceID = userInfo["deviceID"]
        appToken = userInfo["token"]
        for module in modules {
            if appID != nil && deviceID != nil && appToken != nil {
                module.didReceiveAppToken?(appToken!, appID: appID!, deviceID: deviceID!)
            }
        }
    }
    
    /**
        Acts as the userToken receiver.
     
        - Parameters:
            - notification: The notification that was received.
    */
    @objc static private func userTokenReceived(notification: NSNotification) {
        let userInfo = notification.userInfo as! [String: String]
        userID = userInfo["userID"]
        deviceID = userInfo["deviceID"]
        userToken = userInfo["token"]
        for module in modules {
            if userID != nil && deviceID != nil && userToken != nil {
                module.didReceiveUserToken?(userToken!, userID: userID!, deviceID: deviceID!)
            }
        }
    }
    
    /**
        Acts as the userToken invalidated event receiver.
     
        - Parameters:
            - notification: The notification that was received.
    */
    @objc static private func userTokenInvalidated(notification: NSNotification) {
        
        if let userInfo = notification.userInfo as? [String: String] {
            userID = userInfo["userID"]
            deviceID = userInfo["deviceID"]
            for module in modules {
                if userID != nil && deviceID != nil {
                    module.didInvalidateUserToken?()
                }
            }
        } else {
            for module in modules {
                module.didInvalidateUserToken?()
            }
        }
        
    }
    
    /**
        Acts as the userToken expired event receiver.
     
        - Parameters:
            - notification: The notification that was received.
     */
    @objc static private func userTokenExpired(notification: NSNotification) {
        NSNotificationCenter.defaultCenter().postNotificationName(MMUserDidReceiveAuthenticationChallengeNotification, object: nil, userInfo: notification.userInfo)
        userTokenInvalidated(notification)
    }
    
    /**
        Initialize a module.
     
        - Parameters:
            - module: The module to be initialized.
            - success: A block object to be executed when the initialization finishes successfully. This block has no return value and takes no arguments.
            - failure: A block object to be executed when the initialization finishes with an error. This block has no return value and takes one argument: the error object.
    */
    static public func initModule(module: MMModule, success: (() -> Void), failure: ((error: NSError) -> Void)) {
        success()
    }
    
    static private func initializeModule(module: MMModule, success: (() -> Void), failure: ((error: NSError) -> Void)) {
        dispatch_sync(moduleQueue) {
            self.success = {
                success()
                self.success = self.successNull
                self.failure = self.failureNull
            }
            self.failure = { error in
                failure(error: error)
                self.success = self.successNull
                self.failure = self.failureNull
            }
            
            for var i : NSInteger = 0; i < modules.count; i++ {
                if modules[i].name == module.name || module === modules[i] {
                    modules[i].shouldDeInitialize?()
                }
            }
            
            modules = modules.filter {$0.name != module.name && module !== $0}
            modules.append(module)
        }
    }
    
    /**
        Deinitialize a module.
     
        - Parameters:
            - module: The module to be deinitialized.
    */
    static private func deinitModule(module: MMModule) {
        modules = modules.filter {$0 !== module}
        module.shouldDeInitialize?()
    }
    
    /// A queue to synchronize module initialization.
    static private var moduleQueue: dispatch_queue_t = {
        return dispatch_queue_create("com.magnet.iOS.moduleQueue", nil)
        }()
    
    /// The current configuration.
    static private var configuration: [NSObject: AnyObject]?
    /// The current AppID.
    static private var appID: String?
    /// The current deviceID.
    static private var deviceID: String?
    /// The current appToken.
    static private var appToken: String?
    /// The userID of the currently logged-in user.
    static private var userID: String?
    /// The token of the currently logged-in user.
    static private var userToken: String?
    /// A block object to be executed when the initialization finishes successfully. This block has no return value and takes no arguments.
    static private var success: (() -> Void)!
    static private let successNull: (() -> Void) = {}
    /// A block object to be executed when the initialization finishes with an error. This block has no return value and takes one argument: the error object.
    static private var failure: ((error: NSError) -> Void)!
    static private let failureNull: ((error: NSError) -> Void) = {error in}
    
    /// The currently registered modules.
    static var modules: [MMModule] = [] {
        didSet {
            let module = modules.last
            
            if configuration != nil {
                module?.shouldInitializeWithConfiguration(configuration!, success: success, failure: failure)
            }
            if appID != nil && deviceID != nil && appToken != nil {
                module?.didReceiveAppToken?(appToken!, appID: appID!, deviceID: deviceID!)
            }
            if userID != nil && deviceID != nil && userToken != nil {
                module?.didReceiveUserToken?(userToken!, userID: userID!, deviceID: deviceID!)
            }
            // FIXME: Don't nil out the configuration for now
//            success = nil
//            failure = nil
        }
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}
