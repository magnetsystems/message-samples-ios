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

#import "MMXEndpoint_Private.h"
#import "MMXUserID_Private.h"
#import "NSString+XEP_0106.h"
#import "MMXInternalAddress.h"

@implementation MMXEndpoint

+	(instancetype)endpointWithUsername:(NSString *)username deviceID:(NSString *)deviceID {
	MMXEndpoint *endpoint = [[MMXEndpoint alloc] init];
	endpoint.userID = [MMXUserID userIDWithUsername:username];
	endpoint.deviceID = deviceID;
	return endpoint;
}

- (MMXInternalAddress *)address {
	MMXInternalAddress *address = [MMXInternalAddress new];
	address.username = [self.userID.username jidEscapedString];
	address.displayName = self.userID.displayName;
	address.deviceID = self.deviceID;
	return address;
}

@end
