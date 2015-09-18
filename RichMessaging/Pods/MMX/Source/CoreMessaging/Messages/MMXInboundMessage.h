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
#import <Mantle/Mantle.h>
@class MMXUserID;
@class MMXEndpoint;

/**
 *  The MMXInboundMessage represents an incoming message. 
 *	It contains the data provided by the sender, a timestamp for when it was sent, a unique ID and the necessary information to reply to the sender.
 */
@interface MMXInboundMessage : MTLModel

/**
 *  Unique UUID for the message to allow tracking.
 */
@property(nonatomic, copy, readonly) NSString *messageID;

/**
 *  NSDictionary used to pass additional information that would be useful for displaying or consuming the message.
 */
@property(nonatomic, copy, readonly) NSDictionary *metaData;

/**
 *  The content of the message in NSString form.
 */
@property(nonatomic, copy, readonly) NSString *messageContent;

/**
 *  The MMXUserID for the user that sent the message.
 */
@property(nonatomic, copy, readonly) MMXUserID *senderUserID;

/**
 *  The specific MMXEndpoint the message was sent from.
 *	If the endpoint is unknown this property will be nil.
 */
@property(nonatomic, copy, readonly) MMXEndpoint *senderEndpoint;

/**
 *  The list of the other users the message was sent to.
 */
@property(nonatomic, copy, readonly) NSArray *otherRecipients;

/**
 *  The timestamp for when the message was originally sent.
 */
@property(nonatomic, strong, readonly) NSDate *timestamp;

@end
