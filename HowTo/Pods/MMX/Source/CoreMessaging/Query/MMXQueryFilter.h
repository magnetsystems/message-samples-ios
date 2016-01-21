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

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, MMXPredicateOperatorType){
	/**
	 *  Will only return a result it is an exact match for the value provided.
	 *	Case sensitive.
	 */
	MMXEqualToPredicateOperatorType = 0,

	/**
	 *  Will only return a result it starts with the value provided.
	 *	Case insensitive.
	 */
	MMXBeginsWithPredicateOperatorType,
	
	/**
	 *  Will only return a result it ends with the value provided.
	 *	Case insensitive.
	 */
	MMXEndsWithPredicateOperatorType
};

/**
 *	MMXQueryFilter is the base class for a query filter. It should not be used directly.
 *	MMXQueryFiltershould be used via one of the MMXQueryFilter subclasses(MMXTopicQueryFilter,MMXUserQueryFilter).
 */
@interface MMXQueryFilter : NSObject

/**
 *  The type of matching you wish to do with the value. See MMXPredicateOperatorType.
 */
@property (nonatomic, assign)	MMXPredicateOperatorType predicateOperatorType;

@end
