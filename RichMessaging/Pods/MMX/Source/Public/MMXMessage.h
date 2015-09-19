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
#import "MMXMessageTypes.h"
#import <Mantle/Mantle.h>
@class MMXUser;
@class MMXChannel;

@interface MMXMessage : MTLModel

/**
 *  Type of message. See MMXMessageTypes
 */
@property (nonatomic, assign, readonly) MMXMessageType messageType;

/**
 *  Unique UUID for the message to allow tracking.
 */
@property(nonatomic, readonly) NSString *messageID;

/**
 *  The timestamp for when the message was originally sent.
 */
@property(nonatomic, readonly) NSDate *timestamp;

/**
 *  The MMXUserID for the user that sent the message.
 */
@property(nonatomic, readonly) MMXUser *sender;

/**
 *  The channel the message was published to. See MMXChannel.h for more details.
 */
@property (nonatomic, readonly) MMXChannel *channel;

/**
 *  The list of users the message was sent to.
 */
@property(nonatomic, readonly) NSSet *recipients;

/**
 *  The content you want to send.
 *	NSDictionary can only contain objects that are JSON serializable.
 */
@property(nonatomic, readonly) NSDictionary *messageContent;

/**
 *  Initializer for creating a new MMXMessage object
 *
 *  @param recipients     Set of unique recipients to send the message to
 *  @param messageContent NSDictionary of content to send. Must contain only objects that are JSON serializable.
 *
 *  @return New MMXMessage
 */
+ (instancetype)messageToRecipients:(NSSet *)recipients
					 messageContent:(NSDictionary *)messageContent;

/**
 *  Initializer for creating a new MMXMessage object
 *
 *  @param recipients     Set of unique recipients to send the message to
 *  @param messageContent NSDictionary of content to send. Must contain only objects that are JSON serializable.
 *
 *  @return New MMXMessage
 */
+ (instancetype)messageToChannel:(MMXChannel *)channel
				  messageContent:(NSDictionary *)messageContent;

/**
 *  Method to send the message
 *
 *  @param success - Block with the message ID for the sent message.
 *  @param failure - Block with an NSError with details about the call failure.
 *
 *  @return The messageID for the message sent
 */
- (NSString *)sendWithSuccess:(void (^)(void))success
					  failure:(void (^)(NSError *error))failure;

/**
 *  Method to send a message in reply to the received message
 *
 *  @param content NSDictionary of content to send. Must contain only objects that are JSON serializable.
 *  @param success - Block with the message ID for the sent message.
 *  @param failure - Block with an NSError with details about the call failure.
 *
 *  @return The messageID for the message sent
 */
- (NSString *)replyWithContent:(NSDictionary *)content
				 success:(void (^)(void))success
				 failure:(void (^)(NSError * error))failure;

/**
 *  Method to send a message to all recipients of the received message including the sender
 *
 *  @param content NSDictionary of content to send. Must contain only objects that are JSON serializable.
 *  @param success - Block with the message ID for the sent message.
 *  @param failure - Block with an NSError with details about the call failure.
 *
 *  @return The messageID for the message sent
 */
- (NSString *)replyAllWithContent:(NSDictionary *)content
						  success:(void (^)(void))success
						  failure:(void (^)(NSError * error))failure;

/**
 *  Send a delivery confimation message to the sender of the message.
 */
- (void)sendDeliveryConfirmation;

@end
