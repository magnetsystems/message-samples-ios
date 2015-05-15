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

#import "MMXGeoLocationMessage_Private.h"
#import "MMXMessage_Private.h"
#import "MMXUserID_Private.h"
#import "MMXTopic_Private.h"

@import CoreLocation;

@implementation MMXGeoLocationMessage

+ (instancetype)initWithMessage:(MMXMessage *)message {
    MMXGeoLocationMessage *msg = [[MMXGeoLocationMessage alloc] init];
    msg.mmxMessage = message;
    return msg;
}

- (MMXUserID *)userID {
	NSString * username = self.mmxMessage.topic.nameSpace;
    return [MMXUserID userIDWithUsername:username];
}

- (CLLocation *)location {
    return self.mmxMessage.location;
}

- (NSDate *)timestamp {
    return self.mmxMessage.timestamp;
}

@end
