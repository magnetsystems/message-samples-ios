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

#import "MagnetConstants.h"

@implementation MagnetConstants

NSString * const MMXDidReceiveMessageNotification = @"com.magnet.mmx.message.receive";
NSString * const MagnetMessageKey = @"com.magnet.message.key";
NSString * const MMXDidReceiveDeliveryConfirmationNotification = @"com.magnet.mmx.delivery.confirmation.receive";
NSString * const MagnetRecipientKey = @"com.magnet.recipient.key";
NSString * const MagnetMessageIDKey = @"com.magnet.message_id.key";
NSString * const MMXDidReceiveChannelInvitationNotification = @"com.magnet.mmx.invite.receive";
NSString * const MagnetInviteKey = @"com.magnet.invite.key";
NSString * const MMXDidReceiveChannelInvitationResponseNotification = @"com.magnet.mmx.invite.response.receive";
NSString * const MagnetInviteResponseKey = @"com.magnet.invite.response.key";

@end
