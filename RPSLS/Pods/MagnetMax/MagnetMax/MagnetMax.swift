/**
 * Copyright (c) 2012-2015 Magnet Systems, Inc. All rights reserved.
 */

import Foundation
import MagnetMobileServer
import MMX


@objc public class MagnetMax: NSObject {
    
    /// The service adapter with the current configuration.
    static var serviceAdapter: MMServiceAdapter?
    
    /**
        Configure MagnetMax with specified configuration.
     
        - Parameters:
            - configuration: The configuration to be used.
    */
    static public func configure(configuration: MMServiceAdapterConfiguration) {
        registerObservers()
        serviceAdapter = MMServiceAdapter(configuration: configuration)
        MMCoreConfiguration.currentConfiguration = configuration
        MMCoreConfiguration.serviceAdapter = serviceAdapter
        
        // Register Modules
        //        initModule(MMX.sharedInstance())
    }
    
    /// Registers observers for various NSNotifications.
    static private func registerObservers() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "configurationReceived:", name: MMServiceAdapterDidReceiveConfigurationNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "appTokenReceived:", name: MMServiceAdapterDidReceiveCATTokenNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "userTokenReceived:", name: MMServiceAdapterDidReceiveHATTokenNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "userTokenInvalidated:", name: MMServiceAdapterDidInvalidateHATTokenNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "userTokenInvalidated:", name: MMServiceAdapterDidReceiveAuthenticationChallengeNotification, object: nil)
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
        let userInfo = notification.userInfo as! [String: String]
        userID = userInfo["userID"]
        deviceID = userInfo["deviceID"]
        for module in modules {
            if userID != nil && deviceID != nil {
                module.didInvalidateUserToken?()
            }
        }
    }
    
    /**
        Initialize a module.
     
        - Parameters:
            - module: The module to be initialized.
            - success: A block object to be executed when the initialization finishes successfully. This block has no return value and takes no arguments.
            - failure: A block object to be executed when the initialization finishes with an error. This block has no return value and takes one argument: the error object.
    */
    static public func initModule(module: MMModule, success: (() -> Void), failure: ((error: NSError) -> Void)) {
        dispatch_sync(moduleQueue) {
            self.success = success
            self.failure = failure
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
    /// A block object to be executed when the initialization finishes with an error. This block has no return value and takes one argument: the error object.
    static private var failure: ((error: NSError) -> Void)!
    
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
            
            success = nil
            failure = nil
        }
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}
