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

public class MMPropertyListConfiguration: NSObject, MMConfiguration {

    /// The baseURL for the configuration.
    public var baseURL: NSURL
    
    /// The clientID for the configuration.
    public var clientID: String = ""
    
    /// The clientSecret for the configuration.
    public var clientSecret: String = ""
    
    /**
        Initializes a new configuration with the provided dictionary.
     
        - Parameters:
            - dictionary: A dictionary withe BaseURL, ClientID and ClientSecret keys.
     
        - Returns: A configuration object.
     */
    public init(dictionary: NSDictionary?) {
        self.baseURL = NSURL(string: (dictionary?["BaseURL"] as! String))!
        self.clientID = dictionary?["ClientID"] as! String
        self.clientSecret = dictionary?["ClientSecret"] as! String
    }
    
    /**
        Initializes a new configuration with the provided URL.
    
        - Parameters:
            - url: A URL for the plist file.
    
        - Returns: A configuration object.
    */
    public convenience init?(contentsOfURL url: NSURL) {
        let dictionary = NSDictionary(contentsOfURL: url)
        self.init(dictionary: dictionary)
    }
    
    /**
        Initializes a new configuration with the provided file path.
    
        - Parameters:
            - path: A file path for the plist file.
    
        - Returns: A configuration object.
    */
    public convenience init?(contentsOfFile path: String) {
        let dictionary = NSDictionary(contentsOfFile: path)
        self.init(dictionary: dictionary)
    }
}
