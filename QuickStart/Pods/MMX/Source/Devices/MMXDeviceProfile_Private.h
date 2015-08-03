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

#import "MMXDeviceProfile.h"

@interface MMXDeviceProfile ()
@property  (nonatomic, readwrite, strong) MMXEndpoint *endpoint;
@property  (nonatomic, readwrite) NSString *displayName;
@property  (nonatomic, readwrite) NSString *osType;
@property  (nonatomic, readwrite) NSString *modelInfo;
@property  (nonatomic, readwrite) NSString *osVersion;
@property  (nonatomic, readwrite) NSString *pushType;
@property  (nonatomic, readwrite) NSString *pushToken;
@property  (nonatomic, readwrite) NSString *apiKey;
@property  (nonatomic, readwrite) NSString *phoneNumber;
@property  (nonatomic, readwrite) NSString *carrierInfo;

@property  (nonatomic, readwrite) NSDictionary *extras;

/**
 *  Tags are stings used to identify groups of devices.
 *	Tags can be added using MMXDeviceMAnager APIs
 */
@property  (nonatomic, readwrite) NSArray *tags;

+ (instancetype)deviceFromResponseDictionary:(NSDictionary *)deviceDict username:(NSString *)username;
- (NSDictionary *)dictionaryRepresentation;

@end

