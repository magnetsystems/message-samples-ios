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
import UIKit
import CoreData

public class MMReliableCall: MMManagedObject {
    @NSManaged public private(set) var callID: String
    @NSManaged public private(set) var clazz: String?
    @NSManaged public private(set) var method: String?
    @NSManaged public private(set) var request: AnyObject?
    @NSManaged public var response: AnyObject?
    
    public static func insertIntoContext(moc: NSManagedObjectContext,
        callID: String,
        clazz: String,
        method: String,
        request: NSURLRequest,
        response: NSURLResponse?) -> MMReliableCall
    {
        let reliableCall: MMReliableCall = moc.insertObject()
        reliableCall.callID = callID
        reliableCall.clazz = clazz
        reliableCall.method = method
        reliableCall.request = request
        reliableCall.response = response
        
        return reliableCall
    }
}

extension MMReliableCall: MMManagedObjectType {
    public static var entityName: String {
        return "ReliableCall"
    }
    
    public static var defaultSortDescriptors: [NSSortDescriptor] {
        return [NSSortDescriptor(key: "callID", ascending: true)]
    }
}
