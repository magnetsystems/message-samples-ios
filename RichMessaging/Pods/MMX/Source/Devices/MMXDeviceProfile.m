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

#import "MMXDeviceProfile_Private.h"
#import "MMXUtils.h"
#import "MMXEndpoint_Private.h"
#import "NSString+XEP_0106.h"

@implementation MMXDeviceProfile

+ (instancetype)deviceFromResponseDictionary:(NSDictionary *)deviceDict username:(NSString *)username{
    MMXDeviceProfile * device = [[MMXDeviceProfile alloc] init];
	NSString * deviceID = mmxNullSafeConversion(deviceDict[@"devId"]);
    device.endpoint = [MMXEndpoint endpointWithUsername:[username jidUnescapedString] deviceID:deviceID];
    device.modelInfo = mmxNullSafeConversion(deviceDict[@"modelInfo"]);
    device.displayName = mmxNullSafeConversion(deviceDict[@"displayName"]);
    device.osType = mmxNullSafeConversion(deviceDict[@"osType"]);
    device.osVersion = mmxNullSafeConversion(deviceDict[@"osVersion"]);
    device.pushType = mmxNullSafeConversion(deviceDict[@"pushType"]);
    device.pushToken = mmxNullSafeConversion(deviceDict[@"pushToken"]);
    device.phoneNumber = mmxNullSafeConversion(deviceDict[@"phoneNumber"]);
    device.carrierInfo = mmxNullSafeConversion(deviceDict[@"carrierInfo"]);
    device.tags = mmxNullSafeConversion(deviceDict[@"tags"]);
    device.extras = mmxNullSafeConversion(deviceDict[@"extras"]);
    
    return device;
}

- (NSDictionary *)dictionaryRepresentation {
  return @{@"apiKey": self.apiKey,
           @"devId": self.endpoint.deviceID,
           @"displayName": self.displayName,
           @"modelInfo": @"",
           @"osType": self.osType,
           @"osVersion": self.osVersion,
           @"pushType": self.pushType ? self.pushType : [NSNull null],
           @"pushToken": self.pushToken ? self.pushToken : [NSNull null],
           @"phoneNumber": self.phoneNumber ? self.phoneNumber : [NSNull null],
           @"carrierInfo": self.carrierInfo ? self.carrierInfo : [NSNull null],
           @"tags": self.tags ? self.tags : @[],
           @"extras": self.extras ? self.extras : @{}};
}

@end
