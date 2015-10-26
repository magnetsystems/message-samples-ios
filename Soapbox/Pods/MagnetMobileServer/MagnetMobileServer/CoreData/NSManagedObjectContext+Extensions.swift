/**
 * Copyright (c) 2012-2015 Magnet Systems, Inc. All rights reserved.
 */

import Foundation
import CoreData

extension NSManagedObjectContext {
    
    func insertObject<A: MMManagedObject where A: MMManagedObjectType>() -> A {
        guard let obj = NSEntityDescription.insertNewObjectForEntityForName(
            A.entityName, inManagedObjectContext: self) as? A
            else { fatalError("Wrong object type") }
        return obj
    }
    
    func saveOrRollback() -> Bool {
        do {
            try save()
            return true
        } catch {
            rollback()
            return false
        }
    }
    
    public func performChanges(block: () -> ()) {
        performBlock {
            block()
            self.saveOrRollback()
        }
    }
}