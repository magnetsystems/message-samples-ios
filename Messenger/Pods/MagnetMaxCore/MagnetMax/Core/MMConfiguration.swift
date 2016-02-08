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

@objc public protocol MMConfiguration : class {
    /// The baseURL for the configuration.
    var baseURL: NSURL { get }
    
    /// The clientID for the configuration.
    var clientID: String { get }
    
    /// The clientSecret for the configuration.
    var clientSecret: String { get }
    
    /// The scope for the configuration.
    optional var scope: String { get }
    
    /// The additional key-value pairs associated with the configuration.
    optional var addtionalConfiguration: [String: String] { get }
}
