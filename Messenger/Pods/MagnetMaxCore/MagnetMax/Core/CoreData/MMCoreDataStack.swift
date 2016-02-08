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
import CoreData

public class MMCoreDataStack: NSObject {

    static let modelName = "MagnetMax"
    
    // MARK: - Properties
    
    /**
        A shared instance of `NSManagedObjectContext`.
    */
    public static let sharedContext: NSManagedObjectContext = {
        let bundle = NSBundle(forClass: MMReliableCall.self)
        let coordinator = NSPersistentStoreCoordinator.coordinatorForModelWithName(
            MMCoreDataStack.modelName, inBundle: bundle)
        let context = NSManagedObjectContext.mainContextForCoordinator(coordinator)
        return context
    }()
    
}

extension NSPersistentStoreCoordinator {
    public static func coordinatorForModelWithName(name: String,
        inBundle bundle: NSBundle) -> NSPersistentStoreCoordinator
    {
        let model = NSManagedObjectModel.modelNamed(name, inBundle: bundle)
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
        let url = storeURLForName(name)
        try! coordinator.addPersistentStoreWithType(NSSQLiteStoreType,
            configuration: nil, URL: url, options: nil)
        return coordinator
    }
}

extension NSManagedObjectModel {
    public static func modelNamed(name: String, inBundle bundle: NSBundle)
        -> NSManagedObjectModel
    {
        guard let modelURL = bundle.URLForResource(name, withExtension: "momd")
            else {
                fatalError("Managed object model not found")
        }
        guard let model = NSManagedObjectModel(contentsOfURL: modelURL)
            else {
                fatalError("Could not load managed object model from \(modelURL)")
        }
        return model
    }
}

extension NSPersistentStoreCoordinator {
    private static func storeURLForName(name: String) -> NSURL {
        let fm = NSFileManager.defaultManager()
        let documentDirURL = try! fm.URLForDirectory(.DocumentDirectory,
            inDomain: .UserDomainMask, appropriateForURL: nil, create: true)
        let storeURL = documentDirURL
            .URLByAppendingPathComponent(name)
            .URLByAppendingPathExtension("sqlite")
        print("storeURL = \(storeURL)")
        
        return storeURL
    }
}

extension NSManagedObjectContext {
    public static func mainContextForCoordinator(
        coordinator: NSPersistentStoreCoordinator) -> NSManagedObjectContext
    {
        let context = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        context.persistentStoreCoordinator = coordinator
        return context
    }
}
