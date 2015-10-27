/**
 * Copyright (c) 2012-2015 Magnet Systems, Inc. All rights reserved.
 */

import Foundation
import MagnetMobileServer
import MMX


@objc public class MagnetMax: NSObject {
    
    static var serviceAdapter: MMServiceAdapter?
    
    static public func configure(configuration: MMServiceAdapterConfiguration) {
        registerObservers()
        serviceAdapter = MMServiceAdapter(configuration: configuration)
        MMCoreConfiguration.currentConfiguration = configuration
        MMCoreConfiguration.serviceAdapter = serviceAdapter
        
        // Register Modules
        //        initModule(MMX.sharedInstance())
    }
    
    static private func registerObservers() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "configurationReceived:", name: MMServiceAdapterDidReceiveConfigurationNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "appTokenReceived:", name: MMServiceAdapterDidReceiveCATTokenNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "userTokenReceived:", name: MMServiceAdapterDidReceiveHATTokenNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "userTokenInvalidated:", name: MMServiceAdapterDidInvalidateHATTokenNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "userTokenInvalidated:", name: MMServiceAdapterDidReceiveAuthenticationChallengeNotification, object: nil)
    }
    
    @objc static private func configurationReceived(notification: NSNotification) {
        configuration = notification.userInfo
        for module in modules {
            if configuration != nil {
                module.shouldInitializeWithConfiguration(configuration!, success: success, failure: failure)
            }
        }
    }
    
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
    
    static public func initModule(module: MMModule, success: (() -> Void), failure: ((error: NSError) -> Void)) {
        dispatch_sync(moduleQueue) {
            self.success = success
            self.failure = failure
            modules.append(module)
        }
    }
    
    static private func deinitModule(module: MMModule) {
        modules = modules.filter {$0 !== module}
        module.shouldDeInitialize?()
    }
    
    static private var moduleQueue: dispatch_queue_t = {
        return dispatch_queue_create("com.magnet.iOS.moduleQueue", nil)
        }()
    
    static private var configuration: [NSObject: AnyObject]?
    static private var appID: String?
    static private var deviceID: String?
    static private var appToken: String?
    static private var userID: String?
    static private var userToken: String?
    static private var success: (() -> Void)!
    static private var failure: ((error: NSError) -> Void)!
    
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
