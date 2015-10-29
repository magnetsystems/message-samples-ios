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
#import "MMPasswordResetMethod.h"


@interface MMPasswordResetRequest : MMModel


@property (nonatomic, assign) MMPasswordResetMethod passwordResetMethod;

@property (nonatomic, copy) NSString *theNewPassword;

@property (nonatomic, copy) NSString *otpCode;

@property (nonatomic, copy) NSDictionary *challengeResponses;

@property (nonatomic, copy) NSString *userName;

@property (nonatomic, copy) NSString *oldPassword;

@property (nonatomic, copy) NSString *client_description;

@end
