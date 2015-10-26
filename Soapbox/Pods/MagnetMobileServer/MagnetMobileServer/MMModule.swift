/**
 * Copyright (c) 2012-2015 Magnet Systems, Inc. All rights reserved.
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
