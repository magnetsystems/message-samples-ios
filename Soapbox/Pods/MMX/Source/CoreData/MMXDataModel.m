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

#import "XMPPIQ.h"
#import "MMXDataModel.h"
#import "MDMPersistenceController.h"
#import "MMXKeyedUnarchiver.h"
#import "MMXInternalMessageAdaptor.h"
#import "MMXMessageOptions.h"
#import "MMXAssert.h"
#import "MMXOutboxEntry.h"
#import "MMXPubSubMessage.h"
#import "MMXPubSubMessage_Private.h"

@interface MMXDataModel ()

@property(nonatomic, strong) MDMPersistenceController *persistenceController;

- (NSPredicate *)predicateForUser:(NSString *)username;

- (NSPredicate *)predicateForMessage:(NSString *)messageID;

- (NSFetchRequest *)fetchRequestForAllOutboxEntries;

- (MMXOutboxEntry *)fetchOutboxEntryByMessageId:(NSString *)messageID;

- (NSString *)documentsDirectory;

- (void)setupCoreData;

- (void)saveOperationWithType:(NSString *)saveType;

@end

@implementation MMXDataModel

#pragma mark - Public API

+ (instancetype)sharedDataModel {
    static MMXDataModel *_sharedDataModel = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedDataModel = [[MMXDataModel alloc] init];
    });

    return _sharedDataModel;
}

- (MMXOutboxEntry *)addOutboxEntryWithMessage:(MMXInternalMessageAdaptor *)message
                                 options:(MMXMessageOptions *)options
                                username:(NSString *)username {

    MMXParameterAssert(message);
    MMXParameterAssert(username);

    MMXOutboxEntry *outboxEntry = [MMXOutboxEntry insertInManagedObjectContext:self.persistenceController.managedObjectContext];
    outboxEntry = [outboxEntry outboxEntryWithType:MMXOutboxEntryMessageTypeDefault message:message options:options username:username];

    [self saveOperationWithType:@"Insert"];

    return outboxEntry;
}

- (MMXOutboxEntry *)addOutboxEntryWithPubSubMessage:(MMXPubSubMessage *)message username:(NSString *)username {

    MMXParameterAssert(message);
    MMXParameterAssert(username);

    MMXOutboxEntry *outboxEntry = [MMXOutboxEntry insertInManagedObjectContext:self.persistenceController.managedObjectContext];
    outboxEntry = [outboxEntry outboxEntryWithType:MMXOutboxEntryMessageTypePubSub message:[message asMMXMessage] options:nil username:username];

    [self saveOperationWithType:@"Insert"];

    return outboxEntry;
}


- (NSArray *)outboxEntriesForUser:(NSString *)username
           outboxEntryMessageType:(MMXOutboxEntryMessageType)outboxEntryMessageType {

    MMXParameterAssert(username);

    NSFetchRequest *fetchRequest= [self fetchRequestForAllOutboxEntries];

    [fetchRequest setPredicate:[self predicateForUser:username]];
    [fetchRequest setPredicate:[self predicateForType:outboxEntryMessageType]];

    NSArray *fetchedObjects = [self.persistenceController executeFetchRequest:fetchRequest error:^(NSError *error) {
        // TODO: Handle error!
    }];
    return fetchedObjects;
}

- (BOOL)deleteOutboxEntryForMessage:(NSString *)messageID {

    MMXParameterAssert(messageID);

    __block BOOL _success = NO;
    MMXOutboxEntry *outboxEntryToDelete = [self fetchOutboxEntryByMessageId:messageID];
    [self.persistenceController deleteObject:outboxEntryToDelete saveContextAndWait:YES completion:^(NSError *error) {
        _success = (error == nil);
    }];

    return _success;
}

- (MMXInternalMessageAdaptor *)extractMessageFromOutboxEntry:(MMXOutboxEntry *)outboxEntry {
    return [MMXKeyedUnarchiver unarchiveObjectWithData:outboxEntry.message];
}

- (MMXMessageOptions *)extractMessageOptionsFromOutboxEntry:(MMXOutboxEntry *)outboxEntry {
    return [MMXKeyedUnarchiver unarchiveObjectWithData:outboxEntry.messageOptions];
}


#pragma mark - Overriden Getters

- (MDMPersistenceController *)persistenceController {
    if (!_persistenceController) {
        [self setupCoreData];
    }
    return _persistenceController;
}

#pragma mark - Private implementation

- (NSPredicate *)predicateForUser:(NSString *)username {

    MMXParameterAssert(username);

    return [NSPredicate predicateWithFormat:@"(%K == %@)", MMXOutboxEntryAttributes.username, username];
}

- (NSPredicate *)predicateForType:(MMXOutboxEntryMessageType)outboxEntryMessageType {

    return [NSPredicate predicateWithFormat:@"(%K == %@)", MMXOutboxEntryAttributes.messageType, @(outboxEntryMessageType)];
}

- (NSPredicate *)predicateForMessage:(NSString *)messageID {

    MMXParameterAssert(messageID);

    return [NSPredicate predicateWithFormat:@"(%K == %@)", MMXOutboxEntryAttributes.messageID, messageID];
}

- (NSFetchRequest *)fetchRequestForAllOutboxEntries {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [MMXOutboxEntry entityInManagedObjectContext:self.persistenceController.managedObjectContext];
    [fetchRequest setEntity:entity];
    [fetchRequest setSortDescriptors:@[[[NSSortDescriptor alloc] initWithKey:MMXOutboxEntryAttributes.creationTime ascending:YES]]];
    return fetchRequest;
}

- (MMXOutboxEntry *)fetchOutboxEntryByMessageId:(NSString *)messageID {

    MMXParameterAssert(messageID);

    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [MMXOutboxEntry entityInManagedObjectContext:self.persistenceController.managedObjectContext];
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:[self predicateForMessage:messageID]];
    [fetchRequest setFetchLimit:1];

    NSArray *fetchedObjects = [self.persistenceController executeFetchRequest:fetchRequest error:^(NSError *error) {
        // TODO: Handle error!
    }];
    return [fetchedObjects firstObject];
}

- (NSString *)documentsDirectory {
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
}

- (void)setupCoreData {
    
	NSString *mainBundlePath = [[NSBundle bundleForClass:[self class]] resourcePath];
	NSString *frameworkBundlePath = [mainBundlePath stringByAppendingPathComponent:@"MMX.bundle"];
	NSBundle *frameworkBundle = [NSBundle bundleWithPath:frameworkBundlePath];
	if (frameworkBundle == nil) {
		frameworkBundle = [NSBundle bundleForClass:[self class]];
	}
	NSURL *modelUrl = [frameworkBundle URLForResource:@"MMX" withExtension:@"momd"];
	NSString *storePath = [[self documentsDirectory] stringByAppendingPathComponent:@"MMX.sqlite"];
	NSURL *storeUrl = [NSURL fileURLWithPath:storePath];

//    [[NSFileManager defaultManager] attributesOfFileSystemForPath:<#(NSString *)path#> error:<#(NSError **)error#>]

//    NSDictionary *fileAttributes = @{NSFileProtectionKey : NSFileProtectionComplete};
//    NSError *protectionError;
//    if (![[NSFileManager defaultManager] setAttributes:fileAttributes ofItemAtPath:storePath error:&protectionError]) {
//        protectionError;
//    }

    [[MMXLogger sharedLogger] verbose:@"Setting up store at %@", storeUrl];

    self.persistenceController = [[MDMPersistenceController alloc] initWithStoreURL:storeUrl modelURL:modelUrl];
}

- (void)saveOperationWithType:(NSString *)saveType {
    NSError *error;
    BOOL didSave = [self.persistenceController.managedObjectContext save:&error];
    if (!didSave) {
        [self.persistenceController.managedObjectContext rollback];
        NSAssert(NO, ([NSString stringWithFormat:@"%@ should not fail", saveType]));
    }
    [self.persistenceController saveContextAndWait:YES completion:^(NSError *error) {
        NSAssert(error == nil, ([NSString stringWithFormat:@"%@ to disk should not fail", saveType]));
    }];
}

@end
