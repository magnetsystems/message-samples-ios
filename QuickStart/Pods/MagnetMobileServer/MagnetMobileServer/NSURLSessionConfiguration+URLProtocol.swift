/**
 * Copyright (c) 2012-2015 Magnet Systems, Inc. All rights reserved.
 */

import Foundation

extension NSURLSessionConfiguration {
    
    public func registerURLProtocolClass(protocolClass: AnyObject) {
        var protocolClasses = [AnyObject]()
        protocolClasses.append(protocolClass)
        self.protocolClasses = protocolClasses as? [AnyClass]
    }
}
