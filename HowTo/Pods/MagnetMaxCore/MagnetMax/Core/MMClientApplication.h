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

#import "MMModel.h"

#import "MMDeviceStatus.h"
#import "MMTimeUnit.h"

@interface MMClientApplication : MMModel


@property (nonatomic, copy) NSString *clientDescription;

@property (nonatomic, copy) NSString *internalId;

@property (nonatomic, assign) MMTimeUnit  expirationTimeUnit;

@property (nonatomic, copy) NSString *oauthSecret;

@property (nonatomic, assign) NSDate *createdTime;

@property (nonatomic, assign) MMDeviceStatus  clientStatus;

@property (nonatomic, assign) long long expiresIn;

@property (nonatomic, copy) NSString *clientName;

@property (nonatomic, copy) NSString *redirectUrl;

@property (nonatomic, copy) NSString *oauthClientId;

@end
