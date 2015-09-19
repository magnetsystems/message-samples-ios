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
#import "MMX_Private.h"

@implementation MMX

+ (void)setupWithConfiguration:(NSString *)name {
	[[MagnetDelegate sharedDelegate] startMMXClientWithConfiguration:name];
}

+ (void)teardown {
	if ([MMXClient sharedClient].connectionStatus == MMXConnectionStatusAuthenticated ||
		[MMXClient sharedClient].connectionStatus == MMXConnectionStatusConnected) {
		[[MMXClient sharedClient] disconnect];
	}
}

+ (void)enableIncomingMessages {
	[MMXClient sharedClient].shouldSuspendIncomingMessages = NO;
}

+ (void)disableIncomingMessages {
	[MMXClient sharedClient].shouldSuspendIncomingMessages = YES;
}

+ (void)start {
	[MMXClient sharedClient].shouldSuspendIncomingMessages = NO;
}

+ (void)stop {
	[MMXClient sharedClient].shouldSuspendIncomingMessages = YES;
}

+ (void)setRemoteNotificationDeviceToken:(NSData *)deviceToken {
	[[MMXClient sharedClient] updateRemoteNotificationDeviceToken:deviceToken];
}

@end
