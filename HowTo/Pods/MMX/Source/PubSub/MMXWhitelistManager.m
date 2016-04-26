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

#import "MMXWhitelistManager.h"
#import "MMXClient.h"
#import "MMXWhitelistOperation.h"
#import "MMUser.h"
#import "MMXChannel.h"

@implementation MMXWhitelistManager

+ (MMXWhitelistManager *)sharedManager {
    static dispatch_once_t onceToken;
    static MMXWhitelistManager *instance;
    dispatch_once(&onceToken, ^{
        instance = [[MMXWhitelistManager alloc] init];
        instance.maxConcurrentOperationCount = 1;
    });
    return instance;
}

- (void)addUsersToWhitelist:(NSArray<MMUser *> *)users channel:(MMXChannel *)channel completion : (void (^) (NSError * __nullable error))completion {
    MMXWhitelistOperation *operation = [[MMXWhitelistOperation alloc] init:[MMXClient sharedClient] channel:channel users:users makeMember:YES completion:completion];
    [self addOperation:operation];
}

- (void)removeUsersFromWhitelist:(NSArray<MMUser *> *)users channel:(MMXChannel *)channel completion : (void (^) (NSError * __nullable error))completion {
    MMXWhitelistOperation *operation = [[MMXWhitelistOperation alloc] init:[MMXClient sharedClient] channel:channel users:users makeMember:NO completion:completion];
    [self addOperation:operation];
}

@end