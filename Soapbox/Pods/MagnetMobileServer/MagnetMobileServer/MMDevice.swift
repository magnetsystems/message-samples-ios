/**
 * Copyright (c) 2012-2015 Magnet Systems, Inc. All rights reserved.
 */

import Foundation

public extension MMDevice {
    
    /**
        Update the deviceToken for the currently registered device.
     
        - Parameters:
            - data: The APNs token data.
            - success: A block object to be executed when the logout finishes successfully. This block has no return value and takes no arguments.
            - failure: A block object to be executed when the logout finishes with an error. This block has no return value and takes one argument: the error object.
    */
    static public func updateCurentDeviceToken(data: NSData, success: (() -> Void)?, failure: ((error: NSError) -> Void)?) {
        let currentDevice = MMCoreConfiguration.serviceAdapter.currentDevice
        currentDevice.deviceToken = NSString(data: data, encoding: NSUTF8StringEncoding) as! String
        MMCoreConfiguration.serviceAdapter.registerCurrentDeviceWithSuccess({ _ -> Void in
            success?()
        }) { error -> Void in
            failure?(error: error)
        }
    }
    
    /**
        Get the currently registered device.
     
        - Returns: The currently registered device.
    */
    static public func currentDevice() -> MMDevice {
        return MMCoreConfiguration.serviceAdapter.currentDevice
    }
}

