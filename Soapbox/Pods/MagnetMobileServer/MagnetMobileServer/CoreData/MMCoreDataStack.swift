/**
 * Copyright (c) 2012-2015 Magnet Systems, Inc. All rights reserved.
 */

import Foundation
import CoreData

public class MMCoreDataStack: NSObject {

    static let modelName = "MagnetMobileServer"
    
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
