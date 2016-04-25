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

@objc public class MMXPollOption: MMModel {
    
    //Public Variables
    
    public var count: NSNumber? = 0
    
    public var extras : [String:String] = [:]
    
    public internal(set) var optionID: String = ""
    
    public internal(set) var pollID: String = ""
    
    public private(set) var text: String = ""
    
    //MARK: init
    
    public override init!() {
        super.init()
    }
    
    public init(text: String, count: NSNumber?) {
        self.text = text
        self.count = count
        super.init()
    }
    
    required public init(dictionary dictionaryValue: [NSObject : AnyObject]!) throws {
        try super.init(dictionary: dictionaryValue)
    }
    
    required public init!(coder: NSCoder!) {
        super.init(coder: coder)
    }
    
    public override class func attributeMappings() -> [NSObject : AnyObject]! {
        return (super.attributeMappings() ?? [:]) + ["pollID" as NSString: "pollId"] + ["optionID" as NSString: "optionId"]
    }
}

// MARK: MMXPollOption Equality

extension MMXPollOption {
    
    override public func isEqual(object: AnyObject?) -> Bool {
        if let rhs = object as? MMXPollOption {
            return pollID == rhs.pollID && optionID == rhs.optionID
        }
        
        return false
        
    }
    
    override public var hash: Int {
        return pollID.hashValue ^ optionID.hashValue
    }
}
