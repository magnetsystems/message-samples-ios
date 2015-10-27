/**
 * Copyright (c) 2012-2015 Magnet Systems, Inc. All rights reserved.
 */

import Foundation

@objc public protocol MMServiceAdapterConfiguration : class {
    var baseURL: NSURL { get }
    var clientID: String { get }
    var clientSecret: String { get }
    optional var scope: String { get }
    optional var addtionalConfiguration: [String: String] { get }
}
