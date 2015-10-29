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

#import "MMXInternalAddress.h"
#import "MMXConstants.h"
#import "NSString+XEP_0106.h"

@implementation MMXInternalAddress

- (NSDictionary *)asDictionary {
	NSMutableDictionary *dict = [NSMutableDictionary dictionary];
	if (self.username == nil) {
		return nil;
	}
	[dict setObject:[self.username.copy jidUnescapedString] forKey:kAddressUsernameKey];
	if (self.deviceID) {
		[dict setObject:self.deviceID.copy forKey:kAddressDeviceIDKey];
	}
	if (self.displayName) {
		[dict setObject:self.displayName.copy forKey:kAddressDisplayNameKey];
	}
	return dict.copy;
}
@end
