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

import MagnetMaxCore

@objc public class MMXPollIdentifier: MMModel, MMXPayload {
    
    static public var contentType: String {
        return "MMXPollIdentifier"
    }
    
    public private(set) var pollID: String = ""
    
    //MARK: init
    
    public override init!() {
        super.init()
    }
    
    public init(_ pollID: String) {
        self.pollID = pollID
        super.init()
    }
    
    required public init(dictionary dictionaryValue: [NSObject : AnyObject]!) throws {
        try super.init(dictionary: dictionaryValue)
    }
    
    required public init!(coder: NSCoder!) {
        super.init(coder: coder)
    }
}

// MARK: MMXPollIdentifier Equality

extension MMXPollIdentifier {
    
    override public var hash: Int {
        return pollID.hashValue
    }
    
    override public func isEqual(object: AnyObject?) -> Bool {
        if let rhs = object as? MMXPollIdentifier {
            return pollID == rhs.pollID
        }
        
        return false
        
    }
}
