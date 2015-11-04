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

#import "MMX.h"
#import "MagnetDelegate.h"
#import "MMXClient_Private.h"

@implementation MMX

+ (id <MMModule> __nonnull)sharedInstance {
	
	static MMX *_sharedInstance = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		_sharedInstance = [[MMX alloc] init];
	});
	return _sharedInstance;
}

+ (void)teardown {
	if ([MMXClient sharedClient].connectionStatus == MMXConnectionStatusAuthenticated ||
		[MMXClient sharedClient].connectionStatus == MMXConnectionStatusConnected) {
		[[MMXClient sharedClient] disconnect];
	}
}

+ (void)start {
	[MMXClient sharedClient].shouldSuspendIncomingMessages = NO;
}

+ (void)stop {
	[MMXClient sharedClient].shouldSuspendIncomingMessages = YES;
}

#pragma mark - MMModule Protocol methods

- (NSString *)name {
    return @"MMX";
}

- (void)shouldInitializeWithConfiguration:(NSDictionary * __nonnull)configuration success:(void (^ __nonnull)(void))success failure:(void (^ __nonnull)(NSError * __nonnull))failure {
    
    return [[MagnetDelegate sharedDelegate] shouldInitializeWithConfiguration:configuration success:success failure:failure];
}

- (void)didReceiveAppToken:(NSString * __nonnull)appToken appID:(NSString * __nonnull)appID deviceID:(NSString * __nonnull)deviceID {
    
    return [[MagnetDelegate sharedDelegate] didReceiveAppToken:appToken appID:appID deviceID:deviceID];
}

- (void)didReceiveUserToken:(NSString * __nonnull)userToken userID:(NSString * __nonnull)userID deviceID:(NSString * __nonnull)deviceID {
    
    return [[MagnetDelegate sharedDelegate] didReceiveUserToken:userToken userID:userID deviceID:deviceID];
}

- (void)didInvalidateUserToken {
	[[MagnetDelegate sharedDelegate] didInvalidateUserToken];
}

@end
