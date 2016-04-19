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
    
    public static var contentType: String { return "MMXPollAnswer"}
    public var result = [MMXPollOption]()
    
    //MARK: Overrides
    
    public override class func listAttributeTypes() -> [NSObject : AnyObject]! {
        return super.listAttributeTypes() ?? [:] + ["result" as NSString : MMXPollOption.self]
    }
    
}
