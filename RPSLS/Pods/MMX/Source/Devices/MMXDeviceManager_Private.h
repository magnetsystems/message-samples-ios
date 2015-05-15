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

#import "MMXDeviceManager.h"
#import "MMXClient_Private.h"

@class XMPPStream;
@class XMPPIDTracker;
@class XMPPJID;
@class XMPPIQ;
@class MMXConfiguration;
@class MMXUserID;

@protocol MMXDeviceManagerDelegate <NSObject>

@property (nonatomic, strong) MMXConfiguration *configuration;

- (NSString *)deviceToken;

- (void)disconnect;

- (void)sendIQ:(XMPPIQ*)iq completion:(IQCompletionBlock)completion;

- (void)stopTrackingIQWithID:(NSString*)trackingID;

- (XMPPJID *)currentJID;

- (NSString*)generateMessageID;


@end

@interface MMXDeviceManager ()

@property (nonatomic, weak) id<MMXDeviceManagerDelegate> delegate;

- (instancetype)initWithDelegate:(id<MMXDeviceManagerDelegate>)delegate;

/**
 *  Method for getting the list of devices for a user.
 *
 *  @param user    - MMXUserID object for the user you want devices for.
 *  @param success - An NSArray of MMXDeviceProfile objects.
 *  @param failure - Block with an NSError with details about the call failure.
 */
- (void)devicesForUser:(MMXUserID *)user
			   success:(void (^)(NSArray * devices))success
			   failure:(void (^)(NSError * error))failure;

- (void)registerCurrentDeviceWithSuccess:(void (^)(BOOL success))success
                                 failure:(void (^)(NSError * error))failure;

- (void)deactivateCurrentDeviceSuccess:(void (^)(BOOL success))success
							   failure:(void (^)(NSError * error))failure;

+ (NSString*)deviceUUID;

+ (NSURLCredential *)anonymousCredentials;

@end
