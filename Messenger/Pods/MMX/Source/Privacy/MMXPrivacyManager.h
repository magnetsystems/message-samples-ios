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

#import <Foundation/Foundation.h>

@class XMPPPrivacy;
@class MMXPrivacyOperation;
@class MMXPrivacyListOperation;
@class MMUser;

NS_ASSUME_NONNULL_BEGIN
@interface MMXPrivacyManager : NSObject

- (void)blockUsers:(NSSet <MMUser *>*)usersToBlock
           success:(nullable void (^)())success
           failure:(nullable void (^)(NSError *error))failure;

- (void)unblockUsers:(NSSet <MMUser *>*)usersToBlock
             success:(nullable void (^)())success
             failure:(nullable void (^)(NSError *error))failure;

- (void)blockedUsersWithSuccess:(nullable void (^)(NSArray <MMUser *>*users))success
                        failure:(nullable void (^)(NSError *error))failure;

@property (nonatomic, strong) XMPPPrivacy *xmppPrivacy;

@property (nonatomic, strong) NSArray *defaultList;

@property (nonatomic, strong) NSOperationQueue *operationQueue;

@property (nonatomic, strong) MMXPrivacyListOperation *retrievePrivacyListOperation;

@property (nonatomic, strong) MMXPrivacyOperation *currentlyExecutingOperation;

- (NSString *)defaultListName;

@end
NS_ASSUME_NONNULL_END
