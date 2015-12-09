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
@import MagnetMaxCore;
@class MMUser;
@class MMXChannel;

NS_ASSUME_NONNULL_BEGIN
@interface MMXMessage : MMModel

/**
 *  Type of message. See MMXMessageTypes
 */
@property (nonatomic, assign, readonly) MMXMessageType messageType;

/**
 *  Unique UUID for the message to allow tracking.
 */
@property(nonatomic, readonly, nullable) NSString *messageID;

/**
 *  The timestamp for when the message was originally sent.
 */
@property(nonatomic, readonly, nullable) NSDate *timestamp;

/**
 *  The MMUser for the user that sent the message.
 */
@property(nonatomic, readonly, nullable) MMUser *sender;

/**
 *  The channel the message was published to. See MMXChannel.h for more details.
 */
@property (nonatomic, readonly, nullable) MMXChannel *channel;

/**
 *  The list of users the message was sent to.
 */
@property(nonatomic, readonly, nullable) NSSet <MMUser *>*recipients;

/**
 *  The content you want to send.
 *	NSDictionary can only contain objects that are JSON serializable.
 */
@property(nonatomic, readonly) NSDictionary <NSString *, NSString *> *messageContent;

/**
 *  The list of attachments associated with the message.
 */
@property(nonatomic, readonly, nullable) NSArray <MMAttachment *> *attachments;

/**
 *  Initializer for creating a new MMXMessage object
 *
 *  @param recipients     Set of unique recipients to send the message to
 *  @param messageContent NSDictionary of content to send. Must contain only objects that are JSON serializable.
 *
 *  @return New MMXMessage
 */
+ (instancetype)messageToRecipients:(NSSet <MMUser *>*)recipients
					 messageContent:(NSDictionary <NSString *,NSString *>*)messageContent;

/**
 *  Initializer for creating a new MMXMessage object
 *
 *  @param recipients     Set of unique recipients to send the message to
 *  @param messageContent NSDictionary of content to send. Must contain only objects that are JSON serializable.
 *
 *  @return New MMXMessage
 */
+ (instancetype)messageToChannel:(MMXChannel *)channel
				  messageContent:(NSDictionary <NSString *,NSString *>*)messageContent;

/**
 *  Method to send the message
 *
 *  @param success - Block with the NSSet of usernames for any users that were not valid.
 *  @param failure - Block with an NSError with details about the call failure.
 *
 *  @return The messageID for the message sent
 */
- (nullable NSString *)sendWithSuccess:(nullable void (^)(NSSet <NSString *>*invalidUsers))success
                               failure:(nullable void (^)(NSError *error))failure;

/**
 *  Method to send a message in reply to the received message
 *
 *  @param content NSDictionary of content to send. Must contain only objects that are JSON serializable.
 *  @param success - Block with the message ID for the sent message.
 *  @param failure - Block with an NSError with details about the call failure.
 *
 *  @return The messageID for the message sent
 */
- (nullable NSString *)replyWithContent:(NSDictionary <NSString *,NSString *>*)content
                                success:(nullable void (^)(NSSet <NSString *>*invalidUsers))success
                                failure:(nullable void (^)(NSError *error))failure;

/**
 *  Method to send a message to all recipients of the received message including the sender
 *
 *  @param content NSDictionary of content to send. Must contain only objects that are JSON serializable.
 *  @param success - Block with the message ID for the sent message.
 *  @param failure - Block with an NSError with details about the call failure.
 *
 *  @return The messageID for the message sent
 */
- (nullable NSString *)replyAllWithContent:(NSDictionary <NSString *,NSString *>*)content
                                   success:(nullable void (^)(NSSet <NSString *>*invalidUsers))success
                                   failure:(nullable void (^)(NSError *error))failure;

/**
 *  Send a delivery confimation message to the sender of the message.
 */
- (void)sendDeliveryConfirmation;

/**
 *  Add an attachment.
 *
 *  @param attachment The attachment to add to the message.
 */
- (void)addAttachment:(MMAttachment *)attachment;

/**
 *  Add attachments.
 *
 *  @param attachments The attachments to add to the message.
 */
- (void)addAttachments:(NSArray <MMAttachment *> *)attachments;

NS_ASSUME_NONNULL_END
@end
