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
@class RPSLSUserStats;
@class MMXPubSubMessage;
@class MMXInboundMessage;

@interface RPSLSUser : NSObject

@property (nonatomic, strong) RPSLSUserStats * stats;
@property (nonatomic, strong) NSDate * timestamp;
@property (nonatomic, copy) NSString * username;
@property (nonatomic, assign) BOOL isAvailable;

+ (instancetype)userWithUsername:(NSString *)username
						   stats:(RPSLSUserStats *)stats;

+ (RPSLSUser *)me;

+ (NSString *)myUsername;

+ (instancetype)availablePlayerFromPubSubMessage:(MMXPubSubMessage *)message;

+ (instancetype)playerFromInvite:(MMXInboundMessage *)message;

@end
