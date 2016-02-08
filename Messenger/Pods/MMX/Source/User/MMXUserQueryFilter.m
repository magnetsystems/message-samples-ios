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

#import "MMXUserQueryFilter_Private.h"
#import "MMXQueryFilter_Private.h"

@implementation MMXUserQueryFilter

- (NSArray *)asArrayOfDictionaries {
	NSMutableArray * array = @[].mutableCopy;
	if (self.displayName && ![self.displayName isEqualToString:@""]) {
		[array addObject:@{@"match":[self predicateOperatorTypeAsString],
						   @"value":self.displayName,
						   @"propertyName":@"displayName"}];
	}
	if (self.email && ![self.email isEqualToString:@""]) {
		[array addObject:@{@"match":[self predicateOperatorTypeAsString],
						   @"value":self.email,
						   @"propertyName":@"email"}];
	}
	if (self.phoneNumber && ![self.phoneNumber isEqualToString:@""]) {
		[array addObject:@{@"match":[self predicateOperatorTypeAsString],
						   @"value":self.phoneNumber,
						   @"propertyName":@"phoneNumber"}];
	}
	return array.copy;
}

@end
