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

