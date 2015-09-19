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
#import "MMXAddressable.h"
#import <Mantle/Mantle.h>

/**
 *  The MMXOutboundMessage represents an outbound message.
 *	It contains the data provided you provide, a unique ID and the necessary information to address the message.
 */
@interface MMXOutboundMessage : MTLModel

/**
 *  NSArray of MMXAddressable objects to whom you want to send the message.
 */
@property (nonatomic, copy, readonly) NSArray *recipients;

/**
 *  Unique UUID for the message to allow tracking.
 */
@property (nonatomic, copy, readonly) NSString *messageID;

/**
 *  NSDictionary used to pass additional information that would be useful for displaying or consuming the message. 
 *	Meta Data dictionary must be JSON serializable.
 */
@property (nonatomic, copy, readonly) NSDictionary *metaData;

/**
 *  The content of the message in NSString form.
 */
@property (nonatomic, copy, readonly) NSString *messageContent;

/**
 *  Send message to other users
 *
 *  @param recipients	- The MMXUserIDs and/or MMXEndpoints the message was targeted for.
 *  @param content		- The content of the message in NSString format.
 *  @param metaData		- A dictionary of additional information that could be used when displaying the message. Meta Data dictionary must be JSON serializable.
 *
 *  @return A MMXOutboundMessage object for use with the sendMessage:withOptions: method of the MMXClient
 */
+ (instancetype)messageTo:(NSArray *)recipients
              withContent:(NSString *)content
                 metaData:(NSDictionary *)metaData;

@end
