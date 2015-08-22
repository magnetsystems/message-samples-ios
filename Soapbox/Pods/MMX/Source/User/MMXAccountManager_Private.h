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

#import "MMXAccountManager.h"
#import "MMXClient_Private.h"

@class XMPPStream;
@class XMPPIDTracker;
@class XMPPJID;
@class XMPPIQ;
@class MMXConfiguration;
@class MMXDeviceManager;
@class MMXUser;

@protocol MMXAccountManagerDelegate <NSObject>

@property (nonatomic, strong) MMXConfiguration *configuration;
@property (nonatomic, assign) MMXConnectionStatus connectionStatus;
@property (nonatomic, readonly) MMXDeviceManager * deviceManager;

- (void)authenticate;

- (NSURLCredential *)anonymousCredentials;

- (void)sendIQ:(XMPPIQ *)iq completion:(IQCompletionBlock)completion;

- (void)stopTrackingIQWithID:(NSString *)trackingID;

- (XMPPJID *)currentJID;

- (NSString *)generateMessageID;

+ (BOOL)validateCharacterSet:(NSString *)string;

+ (NSError *)errorWithTitle:(NSString *)title message:(NSString *)message code:(int)code;

@end

@interface MMXAccountManager () <NSURLSessionDelegate>

@property (nonatomic, weak) id<MMXAccountManagerDelegate> delegate;

- (instancetype)initWithDelegate:(id<MMXAccountManagerDelegate>)delegate;

- (void)registerUser:(MMXUserProfile*)user
			password:(NSString *)password
			 success:(void (^)(BOOL success))success
			 failure:(void (^)(NSError * error))failure;

- (void)registerAnonymousWithSuccess:(void (^)(BOOL success))success
							 failure:(void (^)(NSError * error))failure;

- (void)userForUserName:(NSString *)username
				success:(void (^)(MMXUser *))success
				failure:(void (^)(NSError * error))failure;

@end
