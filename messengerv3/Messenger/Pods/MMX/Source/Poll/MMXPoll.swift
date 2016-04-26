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

@objc public class MMXPoll: NSObject {
    
    public let pollID: String
    
    public let question: String
    
    public let options: [MMXPollOption]
    
    public let hideResultsFromOthers: Bool
    
    public let endDate: NSDate?
    
    public let myVote: MMXPollOption?
    
    public static func create(question: String, options: [String], hideResultsFromOthers: Bool, endDate: NSDate?, success: ((MMXPoll) -> Void)?, failure: ((error: NSError) -> Void)?) {
        
    }
    
    init(pollID: String, question: String, options: [String], hideResultsFromOthers: Bool, endDate: NSDate?, myVote: MMXPollOption?) {
        
        self.pollID = pollID
        self.question = question
        self.options = []
        self.hideResultsFromOthers = hideResultsFromOthers
        self.endDate = endDate
        self.myVote = myVote
    }
    
    static public func pollWithID(pollID: String, success: ((MMXPoll) -> Void)?, failure: ((error: NSError) -> Void)?) {
        //
    }
    
    public func choose(option: MMXPollOption, success: (Void -> Void)?, failure: ((error: NSError) -> Void)?) {
        
        // 1. Use PollService to choose Poll option (REST)
        
        // 2. If 1. succeeds embed chosen option information in the messageContent (similar to attachments)
        
        // 3. Send message created in 2.
    }
}

// MARK: MMXPoll Equality

extension MMXPoll {
    
    override public func isEqual(object: AnyObject?) -> Bool {
        if let rhs = object as? MMXPoll {
            return pollID == rhs.pollID
        }
        
        return false
        
    }
    
    override public var hash: Int {
        return pollID.hashValue
    }
}
