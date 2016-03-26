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
@import MagnetMaxCore;

NS_ASSUME_NONNULL_BEGIN
@interface MMUser (Privacy)

/**
 *  Block a user
 *
 *  @param usersToBlock - A set of users to block.
 *  @param success - A block object to be executed when the block user call finishes successfully. This block has no return value and takes no arguments.
 *  @param failure - A block object to be executed when the block user call finishes with an error. This block has no return value and takes one argument: the error object.
 *
 */
+ (void)blockUsers:(NSSet <MMUser *>*)usersToBlock
           success:(nullable void (^)())success
           failure:(nullable void (^)(NSError *error))failure;

/**
 *  Unblock a user
 *
 *  @param usersToUnblock - A set of users to unblock.
 *  @param success - A block object to be executed when the unblock user call finishes successfully. This block has no return value and takes no arguments.
 *  @param failure - A block object to be executed when the unblock user call finishes with an error. This block has no return value and takes one argument: the error object.
 *
 */
+ (void)unblockUsers:(NSSet <MMUser *>*)usersToUnblock
             success:(nullable void (^)())success
             failure:(nullable void (^)(NSError *error))failure;

/**
 *  Get all blocked users
 *
 *  @param success - A block object to be executed when the unblock user call finishes successfully. This block has no return value and takes one argument: An array of users that are blocked.
 *  @param failure - A block object to be executed when the unblock user call finishes with an error. This block has no return value and takes one argument: the error object.
 *
 */
+ (void)blockedUsersWithSuccess:(nullable void (^)(NSArray <MMUser *>*users))success
                        failure:(nullable void (^)(NSError *error))failure;

@end
NS_ASSUME_NONNULL_END
