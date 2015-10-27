/**
 * Copyright (c) 2012-2015 Magnet Systems, Inc. All rights reserved.
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
