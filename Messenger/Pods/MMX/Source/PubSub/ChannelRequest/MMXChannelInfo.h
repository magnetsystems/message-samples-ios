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
#import "MMXPublisherType.h"

@import MagnetMaxCore;

@interface MMXChannelInfo : MMModel

@property (nonatomic, assign) int maxItems;

@property (nonatomic, copy) NSString *creator;

@property (nonatomic, copy) NSString *escUserId;

@property (nonatomic, assign) MMXPublisherType  publishPermission;

@property (nonatomic, copy) NSString *channelInfoDescription;

@property (nonatomic, assign) BOOL subscriptionEnabled;

@property (nonatomic, assign) BOOL collection;

@property (nonatomic, assign) NSDate *creationDate;

@property (nonatomic, copy) NSString *userId;

@property (nonatomic, assign) int maxPayloadSize;

@property (nonatomic, assign) BOOL userChannel;

@property (nonatomic, copy) NSString *name;

@property (nonatomic, assign) NSDate *modifiedDate;

@property (nonatomic, assign) BOOL persistent;

@property (nonatomic, assign) BOOL isMuted;

@property (nonatomic, readwrite) NSDate *mutedUntil;

@end
