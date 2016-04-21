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

func + <K, V> (left: Dictionary<K, V>, right: Dictionary<K, V>) -> Dictionary<K, V>  {
    var l = left
    for (k, v) in right { l.updateValue(v, forKey: k) }
    return l
}

@objc public class MMXPollAnswer: MMModel, MMXPayload {
    
    //MARK: Public Variables
    
    public static var contentType: String { return "object/MMXPollAnswer"}
    //Poll Attributes
    public var pollID: String = ""
    public var name: String = ""
    public var question : String = ""
    //Poll Options
    public var previousSelection: [MMXPollOption]?
    public var currentSelection = [MMXPollOption]()
    
    public override init!() {
        super.init()
    }
    
    public init(_ poll: MMXPoll, selectedOptions:[MMXPollOption], previousSelection:[MMXPollOption]?) {
        self.pollID = poll.pollID!
        self.name = poll.name
        self.question = poll.question
        self.currentSelection = selectedOptions
        self.previousSelection = previousSelection
        
        super.init()
    }
    
    required public init(dictionary dictionaryValue: [NSObject : AnyObject]!) throws {
        try super.init(dictionary: dictionaryValue)
    }
    
    required public init!(coder: NSCoder!) {
        super.init(coder: coder)
    }
    
    //MARK: Overrides
    
    public override class func attributeMappings() -> [NSObject : AnyObject]! {
        return (super.attributeMappings() ?? [:]) + ["pollID" as NSString: "pollId"]
    }
    
    public override class func listAttributeTypes() -> [NSObject : AnyObject]! {
        return (super.listAttributeTypes() ?? [:]) + ["currentSelection" as NSString: MMXPollOption.self, "previousSelection" as NSString: MMXPollOption.self]
    }
    
}
