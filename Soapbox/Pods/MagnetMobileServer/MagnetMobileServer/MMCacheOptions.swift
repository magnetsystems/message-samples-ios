/**
 * Copyright (c) 2012-2015 Magnet Systems, Inc. All rights reserved.
 */

import Foundation

@objc public class MMCacheOptions: NSObject {
    
    public let maxCacheAge: NSTimeInterval
    public let alwaysUseCacheIfOffline: Bool
    
    public init(maxCacheAge: NSTimeInterval, alwaysUseCacheIfOffline: Bool) {
        self.maxCacheAge = maxCacheAge
        self.alwaysUseCacheIfOffline = alwaysUseCacheIfOffline
    }
}
