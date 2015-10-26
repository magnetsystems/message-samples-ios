/**
 * Copyright (c) 2012-2015 Magnet Systems, Inc. All rights reserved.
 */

import Foundation

public extension MMDevice {
    
    static public func updateCurentDeviceToken(data: NSData, success: (() -> Void)?, failure: ((error: NSError) -> Void)?) {
        let currentDevice = MMCoreConfiguration.serviceAdapter.currentDevice
        currentDevice.deviceToken = NSString(data: data, encoding: NSUTF8StringEncoding) as! String
        MMCoreConfiguration.serviceAdapter.registerCurrentDeviceWithSuccess({ _ -> Void in
            success?()
        }) { error -> Void in
            failure?(error: error)
        }
    }
    
    static public func currentDevice() -> MMDevice {
        return MMCoreConfiguration.serviceAdapter.currentDevice
    }
}

