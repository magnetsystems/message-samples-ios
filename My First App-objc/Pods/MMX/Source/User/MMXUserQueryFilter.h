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

#import "MMXQueryFilter.h"

@interface MMXUserQueryFilter : MMXQueryFilter

/**
 *  The user displayName or partial displayName you want to search for.
 *  The valid character set is alphanumeric plus period, dash and underscore. .-_
 */
@property (nonatomic, copy) NSString * displayName;

/**
 *  The user email or partial email you want to search for.
 */
@property (nonatomic, copy) NSString * email;

/**
 *  The user phone number or partial phone number you want to search for.
 */
@property (nonatomic, copy) NSString * phoneNumber;

@end
