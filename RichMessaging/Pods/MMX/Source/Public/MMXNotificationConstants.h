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

/**
 *  Constants for Notifications from Magnet Message
 */
@interface MMXNotificationConstants : NSObject

/**
	Notification when receiving a message.
 */
extern NSString * const MMXDidReceiveMessageNotification;

/**
	Key for MMXMessage object within the userInfo dictionary of the MMXDidReceiveMessageNotification notification.
 */
extern NSString * const MMXMessageKey;

/**
	Notification when receiving a message delivery confirmation.
 */
extern NSString * const MMXDidReceiveDeliveryConfirmationNotification;

/**
	Key for MMUser object within the userInfo dictionary of the MMXDidReceiveDeliveryConfirmationNotification notification to whom the message was delivered.
 */
extern NSString * const MMXRecipientKey;

/**
	Key for messageID(NSString) within the userInfo dictionary of the MMXDidReceiveDeliveryConfirmationNotification notification for message that was delivered.
 */
extern NSString * const MMXMessageIDKey;

/**
	Notification when receiving a MMXInvite.
 */
extern NSString * const MMXDidReceiveChannelInviteNotification;

/**
	Key for MMXInvite object within the userInfo dictionary of the MMXDidReceiveChannelInviteNotification notification.
 */
extern NSString * const MMXInviteKey;

/**
	Notification when receiving a MMXInviteResponse.
 */
extern NSString * const MMXDidReceiveChannelInviteResponseNotification;

/**
	Key for MMXInviteResponse object within the userInfo dictionary of the MMXDidReceiveChannelInviteResponseNotification notification.
 */
extern NSString * const MMXInviteResponseKey;

/**
	Notification when receiving an error for a sent message.
 */
extern NSString * const MMXMessageSendErrorNotification;

/**
	Key for NSError object within the userInfo dictionary of the MMXMessageSendErrorNotification notification.
 */
extern NSString * const MMXMessageSendErrorNSErrorKey;

/**
	Key for messageID(NSString) within the userInfo dictionary of the MMXMessageSendErrorNotification notification for the message that was sent.
 */
extern NSString * const MMXMessageSendErrorMessageIDKey;

/**
	Key for MMUser object within the userInfo dictionary of the MMXDidReceiveDeliveryConfirmationNotification notification to whom the message was sent to.
 */
extern NSString * const MMXMessageSendErrorRecipientsKey;

@end
