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
@class MMXUserID;

@interface MMXTopic : NSObject <NSCoding>

typedef NS_ENUM(NSInteger, MMXPublishPermissionsLevel){
    MMXPublishPermissionsLevelOwner = 0,
    MMXPublishPermissionsLevelSubscribers,
    MMXPublishPermissionsLevelAnyone
};

/**
 *  Name or identifier for the topic.
 *  The valid character set is alphanumeric plus period, dash and underscore. .-_
 */
@property (nonatomic, copy)   NSString * topicName;

/**
 *  Discription of the topic and what should be published to the topic.
 */
@property (nonatomic, copy)   NSString * topicDescription;

/**
 *  The MMXUserID of the creator of the topic.
 *	This infomation is only available when obtaining the MMXTopic object from an API request.
 *	The creator will not be known if using one of the initializers.
 *	If the creator information is not available the property will be nil.
 */
@property (nonatomic, copy)   MMXUserID * topicCreator;

/**
 *  Used to set limit on the number of published items to be persisted for the topic.
 *	Set as -1 for unlimited. Default value is -1.
 */
@property (nonatomic, assign) int maxItemsToBePersisted;

/**
 *  The permissions level required to publish to a topic. See MMXPublishPermissionsLevel for options.
 */
@property (nonatomic, assign) MMXPublishPermissionsLevel publishPermissionsLevel;

/**
 *  Create a new topic.
 *
 *  @param name - The name of the new topic.
 *
 *  @return A new MMXTopic object
 */
+ (instancetype)topicWithName:(NSString *)name;

/**
 *  Create a new topic.
 *
 *  @param name		- The name of the new topic.
 *  @param maxItems	- Set for the max number of posts that should be persisted. Use -1 for infinite.
 *  @param level	- Permissions level for who should be able to post; Owner/Creator, Subscribers, Anyone.
 *
 *  @return A new MMXTopic object
 */
+ (instancetype)topicWithName:(NSString *)name
			maxItemsToPersist:(int)maxItems
			 permissionsLevel:(MMXPublishPermissionsLevel)level;

@end
