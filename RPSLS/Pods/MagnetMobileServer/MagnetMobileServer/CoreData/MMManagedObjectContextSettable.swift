/**
 * Copyright (c) 2012-2015 Magnet Systems, Inc. All rights reserved.
 */

import Foundation
import CoreData

protocol MMManagedObjectContextSettable: class {
    var managedObjectContext: NSManagedObjectContext! { get set }
}

