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

/**
 *  MMXPubSubFetchRequest is used to specify parameters when trying to fetch previously posted messages from PubSub.
 */
@interface MMXPubSubFetchRequest : NSObject

/**
 *  The MMXTopic object for the topic from which you want to fetch previously posted items.
 *	Required
 */
@property (nonatomic, strong)   MMXTopic * topic;

/**
 *  The earliest date you would like messages from.
 *	Optional.
 */
@property (nonatomic, strong)   NSDate * since;

/**
 *  The latest date you would like messages from. 
 *	Defaults to now.
 *	Optional.
 */
@property (nonatomic, strong)   NSDate * until;

/**
 *  This is the sort order you want the results in.
 *	Defaults to NO. aka Descending order.
 *	Optional.
 */
@property (nonatomic, assign)   BOOL ascending;

/**
 *  This is the max number of items you want returned.
 *	Defaults the system set max.
 *	Optional.
 */
@property (nonatomic, assign)   int maxItems;

/**
 *  Convenience initializer for a MMXPubSubFetchRequest
 *
 *  @param topic - The MMXTopic object for the topic from which you want to fetch previously posted items.
 *
 *  @return MMXPubSubFetchRequest with everything other than the MMXTopic using default values;
 */
+ (instancetype)requestWithTopic:(MMXTopic *)topic;

@end

