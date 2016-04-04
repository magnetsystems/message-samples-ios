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

#import "MMXPrivacyManager.h"
#import "XMPPPrivacy.h"
#import "MMXClient_Private.h"
#import "MMUser+Addressable.h"
#import "MMXConfiguration.h"
#import "NSXMLElement+XMPP.h"
@import MagnetMaxCore;

@interface MMXPrivacyListOperation : MMAsynchronousOperation

+ (instancetype)operationWithPrivacyManager:(MMXPrivacyManager *)privacyManager;

@end

@interface MMXPrivacyListOperation ()

@property (nonatomic, strong) MMXPrivacyManager *privacyManager;

@property (nonatomic, assign) BOOL wasUnsuccessful;

@end

@implementation MMXPrivacyListOperation

+ (instancetype)operationWithPrivacyManager:(MMXPrivacyManager *)privacyManager {
    MMXPrivacyListOperation *operation = [[self alloc] init];
    operation.privacyManager = privacyManager;
    
    return operation;
}

- (void)execute {
    NSString *listName = [self.privacyManager defaultListName];
    [self.privacyManager.xmppPrivacy retrieveListWithName:listName];
}

@end

/**
 *  Values representing the type of the MMXPrivacyOperation.
 */
typedef NS_ENUM(NSInteger, MMXPrivacyOperationType){
    /**
     *  Block the given users.
     */
    MMXPrivacyOperationTypeBlock,
    /**
     *  Unblock the given users.
     */
    MMXPrivacyOperationTypeUnblock
};

@interface MMXPrivacyOperation : MMAsynchronousOperation

+ (instancetype)operationWithPrivacyManager:(MMXPrivacyManager *)privacyManager
                                       type:(MMXPrivacyOperationType)type
                                      users:(NSSet <MMUser *>*)users;

@end

@interface MMXPrivacyOperation ()

@property (nonatomic, strong) MMXPrivacyManager *privacyManager;

@property (nonatomic, assign) MMXPrivacyOperationType type;

@property (nonatomic, copy) NSSet <MMUser *>* users;

@property (nonatomic, assign) BOOL wasUnsuccessful;

@property (nonatomic, assign) NSUInteger postUpdateCount;

@end

@implementation MMXPrivacyOperation

+ (instancetype)operationWithPrivacyManager:(MMXPrivacyManager *)privacyManager
                                       type:(MMXPrivacyOperationType)type
                                      users:(NSSet <MMUser *>*)users {
    MMXPrivacyOperation *operation = [[self alloc] init];
    operation.privacyManager = privacyManager;
    operation.type = type;
    operation.users = users;
    
    return operation;
}

- (void)execute {
    self.privacyManager.currentlyExecutingOperation = self;
    
    NSString *listName = [self.privacyManager defaultListName];
    // TODO: Remove me!
    MMXClient *mmxClient = [MMXClient sharedClient];
    
    NSMutableArray *privacyItems = [NSMutableArray arrayWithCapacity:self.users.count];
    NSString *action = @"";
    switch (self.type) {
        case MMXPrivacyOperationTypeBlock:
            action = @"deny";
            break;
            
        case MMXPrivacyOperationTypeUnblock:
            action = @"allow";
            break;
    }
    for (MMUser *user in self.users) {
        MMXInternalAddress *address = user.address;
        NSString *userToBlockJid = [NSString stringWithFormat:@"%@%%%@@%@", address.username, mmxClient.appID, mmxClient.configuration.domain];
        NSXMLElement *privacyItem = [XMPPPrivacy privacyItemWithType:@"jid" value:userToBlockJid action:action order:1];
        [privacyItems addObject:privacyItem];
    }
    
    NSMutableArray *defaultList = [NSMutableArray arrayWithArray:self.privacyManager.defaultList];
    [defaultList makeObjectsPerformSelector:@selector(detach)];
    NSArray *existingItems = [[defaultList valueForKey:@"attributesAsDictionary"] valueForKey:@"value"];
    for (NSXMLElement *privacyItem in privacyItems) {
        switch (self.type) {
            case MMXPrivacyOperationTypeBlock: {
                NSUInteger privacyItemIndex = [existingItems indexOfObject:[privacyItem attributesAsDictionary][@"value"]];
                if (privacyItemIndex == NSNotFound) {
                    [defaultList addObject:privacyItem];
                } else {
                    //                    NSLog(@"already exists");
                }
                break;
            }
                
            case MMXPrivacyOperationTypeUnblock: {
                NSUInteger privacyItemIndex = [existingItems indexOfObject:[privacyItem attributesAsDictionary][@"value"]];
                if (privacyItemIndex != NSNotFound) {
                    [defaultList removeObjectAtIndex:privacyItemIndex];
                }
                break;
            }
        }
    }
    
    // TODO: If NSXMLElement's isEqual: were working as expected, we can simplify our logic using sets
    
    //    NSMutableSet *privacyItemsSet = [NSMutableSet setWithArray:self.privacyManager.defaultList];
    //    switch (self.type) {
    //        case MMXPrivacyOperationTypeBlock: {
    //            [privacyItemsSet unionSet:[NSSet setWithArray:privacyItems]];
    //            break;
    //        }
    //
    //        case MMXPrivacyOperationTypeUnblock: {
    //            [privacyItemsSet minusSet:[NSSet setWithArray:privacyItems]];
    //            break;
    //        }
    //    }
    self.postUpdateCount = defaultList.count;
    [self.privacyManager.xmppPrivacy setListWithName:listName items:defaultList];
}

@end

@interface MMXPrivacyManager () <XMPPPrivacyDelegate>

- (void)setPrivacyWithType:(MMXPrivacyOperationType)type
                     users:(NSSet <MMUser *>*)usersToBlock
                   success:(nullable void (^)())success
                   failure:(nullable void (^)(NSError *error))failure;

- (void)executeBlockedUsersWithSuccess:(nullable void (^)(NSArray <MMUser *>*users))success
                               failure:(nullable void (^)(NSError *error))failure;

@end

@implementation MMXPrivacyManager

#pragma mark - XMPPPrivacyDelegate

- (void)xmppPrivacy:(XMPPPrivacy *)sender didReceiveListNames:(NSArray *)listNames {
//    NSLog(@"listNames = %@", listNames);
    for (NSString *listName in listNames) {
        [sender retrieveListWithName:listName];
    }
    // TODO: Check why listNames.count == 0
    self.retrievePrivacyListOperation = [MMXPrivacyListOperation operationWithPrivacyManager:self];
    [self.operationQueue addOperation:self.retrievePrivacyListOperation];
}

- (void)xmppPrivacy:(XMPPPrivacy *)sender didNotReceiveListNamesDueToError:(id)error {
    //    NSLog(@"error = %@", error);
}

- (void)xmppPrivacy:(XMPPPrivacy *)sender didReceiveListWithName:(NSString *)name items:(NSArray *)items {
    if ([name isEqualToString:[self defaultListName]]) {
        self.defaultList = items;
        if (self.retrievePrivacyListOperation.isExecuting) {
            [self.retrievePrivacyListOperation finish];
        }
        if (self.currentlyExecutingOperation.isExecuting) {
            [self.currentlyExecutingOperation finish];
        }
    }
}

- (void)xmppPrivacy:(XMPPPrivacy *)sender didNotReceiveListWithName:(NSString *)name error:(id)error {
//    NSLog(@"error = %@", error);
    if ([name isEqualToString:[self defaultListName]]) {
        self.retrievePrivacyListOperation.wasUnsuccessful = YES;
        [self.retrievePrivacyListOperation finish];
    }
}

- (void)xmppPrivacy:(XMPPPrivacy *)sender didSetListWithName:(NSString *)name {
//    NSLog(@"name = %@", name);
    if ([name isEqualToString:[self defaultListName]]) {
        if (self.currentlyExecutingOperation.isExecuting) {
            switch (self.currentlyExecutingOperation.type) {
                case MMXPrivacyOperationTypeBlock:
                    [sender setDefaultListName:[self defaultListName]];
                    break;
                    
                case MMXPrivacyOperationTypeUnblock:
                    // We dont get the updated list since the list is considered as deleted
                    if (self.currentlyExecutingOperation.postUpdateCount == 0) {
                        self.defaultList = @[];
                        [self.currentlyExecutingOperation finish];
                    }
                    break;
            }
        }
    }
}

- (void)xmppPrivacy:(XMPPPrivacy *)sender didNotSetListWithName:(NSString *)name error:(id)error {
//    NSLog(@"error = %@", error);
    if ([name isEqualToString:[self defaultListName]]) {
        self.currentlyExecutingOperation.wasUnsuccessful = YES;
        [self.currentlyExecutingOperation finish];
    }
}

#pragma mark - Public API

- (void)blockUsers:(NSSet <MMUser *>*)usersToBlock
           success:(nullable void (^)())success
           failure:(nullable void (^)(NSError *error))failure {
    
    [self setPrivacyWithType:MMXPrivacyOperationTypeBlock users:usersToBlock success:success failure:failure];
}

- (void)unblockUsers:(NSSet <MMUser *>*)usersToBlock
             success:(nullable void (^)())success
             failure:(nullable void (^)(NSError *error))failure {
    
    [self setPrivacyWithType:MMXPrivacyOperationTypeUnblock users:usersToBlock success:success failure:failure];
}

- (void)blockedUsersWithSuccess:(nullable void (^)(NSArray <MMUser *>*users))success
                        failure:(nullable void (^)(NSError *error))failure {
    if (!self.retrievePrivacyListOperation.isFinished) {
        __weak __typeof__(self) weakSelf = self;
        self.retrievePrivacyListOperation.completionBlock = ^{
            [weakSelf executeBlockedUsersWithSuccess:success failure:failure];
        };
    } else {
        [self executeBlockedUsersWithSuccess:success failure:failure];
    }
}

#pragma mark - Private implementation

- (NSString *)defaultListName {
    return @"default";
}

- (void)setPrivacyWithType:(MMXPrivacyOperationType)type
                     users:(NSSet <MMUser *>*)usersToBlock
                   success:(nullable void (^)())success
                   failure:(nullable void (^)(NSError *error))failure {
    MMXPrivacyOperation *blockOperation = [MMXPrivacyOperation operationWithPrivacyManager:self
                                                                                      type:type
                                                                                     users:usersToBlock];
    __weak __typeof__(blockOperation) weakBlockOperation = blockOperation;
    blockOperation.completionBlock = ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            if (weakBlockOperation.wasUnsuccessful) {
                if (failure) {
                    // TODO: Error shouldnt be nil
                    failure(nil);
                }
            } else {
                if (success) {
                    success();
                }
            }
        });
    };
    if (self.retrievePrivacyListOperation) {
        [blockOperation addDependency:self.retrievePrivacyListOperation];
    }
    if (self.currentlyExecutingOperation) {
        [blockOperation addDependency:self.currentlyExecutingOperation];
    }
    [self.operationQueue addOperation:blockOperation];
}

- (void)executeBlockedUsersWithSuccess:(nullable void (^)(NSArray <MMUser *>*users))success
                               failure:(nullable void (^)(NSError *error))failure {
    if (self.defaultList.count > 0) {
        NSPredicate *denyPredicate = [NSPredicate predicateWithFormat:@"action == 'deny'"];
        NSArray *blockedJids = [[[self.defaultList valueForKey:@"attributesAsDictionary"] filteredArrayUsingPredicate:denyPredicate] valueForKey:@"value"];
        NSMutableArray *blockedUserIDs = [NSMutableArray arrayWithCapacity:blockedJids.count];
        // TODO: Remove me!
        MMXClient *mmxClient = [MMXClient sharedClient];
        for (NSString *blockedJid in blockedJids) {
            NSString *appIDAndDomain = [NSString stringWithFormat:@"%%%@@%@", mmxClient.appID, mmxClient.configuration.domain];
            NSString *blockedUserID = [blockedJid stringByReplacingOccurrencesOfString:appIDAndDomain withString:@""];
            [blockedUserIDs addObject:blockedUserID];
        }
        [MMUser usersWithUserIDs:blockedUserIDs success:success failure:failure];
    } else {
        if (success) {
            success(@[]);
        }
    }
}

#pragma mark - Overriden getters

- (NSOperationQueue *)operationQueue {
    if (!_operationQueue) {
        _operationQueue = [[NSOperationQueue alloc] init];
        _operationQueue.maxConcurrentOperationCount = 1;
    }
    return _operationQueue;
}

@end
