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

@class MMXTopic;

@interface MMXTopicSubscription : NSObject

/**
 *  The MMXTopic object for the topic subscribed to.
 */
@property (nonatomic, readonly) MMXTopic *topic;

/**
 *  The subscription ID. This can be used to unsubscribe.
 */
@property (nonatomic, readonly) NSString *subscriptionID;

/**
 *  Set to YES if the user is currently subscribed.
 */
@property (nonatomic, readonly) BOOL isSubscribed;

@end
