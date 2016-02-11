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

#import "MMXNotificationConstants.h"

@implementation MMXNotificationConstants

NSString * const MMXUserDidLogOutNotification = @"com.magnet.networking.hattoken.invalidate";
NSString * const MMXUserDidLogInNotification = @"com.magnet.networking.hattoken.receive";
NSString * const MMXDidReceiveMessageNotification = @"com.magnet.mmx.message.receive";
NSString * const MMXMessageKey = @"com.magnet.message.key";
NSString * const MMXDidReceiveDeliveryConfirmationNotification = @"com.magnet.mmx.delivery.confirmation.receive";
NSString * const MMXRecipientKey = @"com.magnet.recipient.key";
NSString * const MMXMessageIDKey = @"com.magnet.message_id.key";
NSString * const MMXDidReceiveChannelInviteNotification = @"com.magnet.mmx.invite.receive";
NSString * const MMXAttachmentUploadDidChangeValueNotification = @"com.magnet.attachment.upload.value.did.change";
NSString * const MMXInviteKey = @"com.magnet.invite.key";
NSString * const MMXDidReceiveChannelInviteResponseNotification = @"com.magnet.mmx.invite.response.receive";
NSString * const MMXInviteResponseKey = @"com.magnet.invite.response.key";
NSString * const MMXMessageSendErrorNotification = @"com.magnet.message.send.error.receive";
NSString * const MMXMessageSendErrorNSErrorKey = @"com.magnet.message.send.error.key";
NSString * const MMXMessageSendErrorMessageIDKey = @"com.magnet.message.send.message.id.key";
NSString * const MMXMessageSendErrorRecipientsKey = @"com.magnet.message.send.recipients.key";

@end
