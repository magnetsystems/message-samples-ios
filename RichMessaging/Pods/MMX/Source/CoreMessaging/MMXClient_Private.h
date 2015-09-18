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

#import "MMXClient.h"

@class XMPPStream;
@class XMPPIDTracker;
@class XMPPIQ;
@class XMPPJID;
@class MMXUserProfile;
@class MMXInternalMessageAdaptor;

@protocol XMPPTrackingInfo;

typedef void (^IQCompletionBlock)(id obj, id <XMPPTrackingInfo> info);

extern int const kTempVersionMajor;
extern int const kTempVersionMinor;

@interface MMXClient ()

@property (nonatomic, strong) XMPPStream *xmppStream;
@property (nonatomic, strong) XMPPIDTracker *iqTracker;
@property (nonatomic, strong) dispatch_queue_t mmxQueue;
@property (nonatomic, readwrite) BOOL anonymousConnection;
@property (nonatomic, readwrite) NSString *deviceToken;
@property (nonatomic, assign) MMXConnectionStatus connectionStatus;

@property (nonatomic, strong) MMXUserProfile *currentProfile;

- (XMPPJID *)currentJID;
- (NSString *)generateMessageID;
- (void)sendIQ:(XMPPIQ *)iq completion:(IQCompletionBlock)completion;
- (void)stopTrackingIQWithID:(NSString*)trackingID;
+ (BOOL)validateCharacterSet:(NSString *)string;
+ (NSError *)errorWithTitle:(NSString *)title message:(NSString *)message code:(int)code;
- (NSString *)sendMMXMessage:(MMXInternalMessageAdaptor *)outboundMessage
				 withOptions:(MMXMessageOptions *)options
			  shouldValidate:(BOOL)validate;

- (NSString *)sendDeliveryConfirmationForAddress:(MMXInternalAddress *)address
									   messageID:(NSString *)messageID
									  toDeviceID:(NSString *)deviceID;

@end