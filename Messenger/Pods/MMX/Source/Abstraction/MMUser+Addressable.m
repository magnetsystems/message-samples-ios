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

#import "MMUser+Addressable.h"
#import "NSString+XEP_0106.h"
#import "MMXInternalAddress.h"

#import "MMXClient_Private.h"
#import "XMPPPrivacy.h"
#import "MMXConfiguration.h"

@implementation MMUser (Addressable)

- (MMXInternalAddress *)address {
	MMXInternalAddress *address = [MMXInternalAddress new];
	address.username = [self.userID jidEscapedString];
	return address;
}

+ (void)blockUsers:(NSSet <MMUser *>*)usersToBlock
           success:(nullable void (^)())success
           failure:(nullable void (^)(NSError *error))failure {
    
    [[MMXClient sharedClient].privacyManager blockUsers:usersToBlock success:success failure:failure];
}

+ (void)unblockUsers:(NSSet <MMUser *>*)usersToUnblock
             success:(nullable void (^)())success
             failure:(nullable void (^)(NSError *error))failure {
    [[MMXClient sharedClient].privacyManager unblockUsers:usersToUnblock success:success failure:failure];
}

+ (void)blockedUsersWithSuccess:(nullable void (^)(NSArray <MMUser *>*users))success
                        failure:(nullable void (^)(NSError *error))failure {
    [[MMXClient sharedClient].privacyManager blockedUsersWithSuccess:success failure:failure];
}

@end
