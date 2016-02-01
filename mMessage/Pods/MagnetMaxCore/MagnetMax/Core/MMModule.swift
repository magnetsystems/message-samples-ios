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

@objc public protocol MMModule : class {
    static var sharedInstance: MMModule { get }
    var name: String { get }
    
    func shouldInitializeWithConfiguration(configuration: [NSObject: AnyObject], success: (Void -> Void), failure: ((error: NSError) -> Void))
    
    optional func shouldDeInitialize()
    
    optional func didReceiveAppToken(appToken: String, appID: String, deviceID: String)
    
    optional func didReceiveUserToken(userToken: String, userID: String, deviceID: String)
    
    optional func didInvalidateUserToken()
}
