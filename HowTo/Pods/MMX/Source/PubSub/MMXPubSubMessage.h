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
@class MMXUserID;

@interface MMXPubSubMessage : NSObject

/**
 *  Unique UUID for the message to allow tracking.
 */
@property (nonatomic, copy, readonly)	NSString *messageID;

/**
 *  The MMXUserID for the user that posted the message.
 */
@property (nonatomic, copy, readonly)	MMXUserID *senderUserID;

/**
 *  NSDictionary used to pass additional information that would be useful for displaying or consuming the message.
 *	Meta Data dictionary must be JSON serializable.
 */
@property (nonatomic, copy, readonly)	NSDictionary *metaData;

/**
 *  The content of the message in NSString form.
 */
@property (nonatomic, copy, readonly)	NSString *messageContent;

/**
 *  The timestamp for when the message was originally sent.
 */
@property (nonatomic, strong, readonly) NSDate *timestamp;

/**
 *  The topic the message was published to. See MMXTopic.h for more details.
 */
@property (nonatomic, strong, readonly) MMXTopic * topic;

/**
 *  Create a PubSub message to post
 *
 *  @param topic    - The MMXTopic object of the topic you want to post to.
 *  @param content  - The contents of the message in the form of a NSString.
 *  @param metaData - A dictionary of additional information that could be used when displaying the message. Meta Data dictionary must be JSON serializable.
 *
 *  @return A MMXPubSubMessage object for use with the publishPubSubMessage:success:failure: method of the MMXPubSubManager
 */
+ (instancetype)pubSubMessageToTopic:(MMXTopic *)topic
                             content:(NSString *)content
                            metaData:(NSDictionary *)metaData;

@end
