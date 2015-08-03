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

typedef NS_ENUM(NSInteger, MMXCompoundPredicateType){
	MMXAndPredicateType = 0,
	MMXOrPredicateType
};

/**
 *  MMXQuery is the foundation class for querying objects. After creating a MMXQuery object you can add specific filters to narrow the query.
 *	There are a number of convenience methods for quickly creating commonly used queries and filters.
 */
@interface MMXQuery : NSObject

/**
 *  One or more NSString tags. Objects that contain ANY of the tags will be returned.
 */
@property (nonatomic, copy) NSArray * tags;

/**
 *  One or more MMXUserQueryFilter or MMXTopicQueryFilter objects.
 *	Used to furhter refine search results after the tag filter is applied.
 */
@property (nonatomic, copy) NSArray * queryFilters;

/**
 *  The operator you want applied to all query filters. Either OR or AND.
 *	Defaults to AND.
 */
@property (nonatomic, assign) MMXCompoundPredicateType compoundPredicateType;

/**
 *  The max number of results you want returned. Defaults to 20.
 */
@property (nonatomic, assign) int limit;

/**
 *  Creates a MMXQuery with a MMXUserQueryFilter where displayName = value passed for displayName
 *	The MMXUserQueryFilter predicateOperatorType is set to MMXBeginsWithPredicateOperatorType
 *
 *  @param displayName - Partial user displayName you want to query for.
 *  @param tags        - One or more NSString tags. Objects that contain ANY of the tags will be returned.
 *  @param limit       - The max number of results you want returned.
 *
 *  @return MMXQuery object
 */
+ (instancetype)queryForUserDisplayNameStartsWith:(NSString *)displayName
											 tags:(NSArray *)tags
											limit:(int)limit;

/**
 *  Creates a MMXQuery with a MMXUserQueryFilter where email = value passed for email
 *	The MMXUserQueryFilter predicateOperatorType is set to MMXBeginsWithPredicateOperatorType
 *
 *  @param email  - Partial user email you want to query for.
 *  @param tags   - One or more NSString tags. Objects that contain ANY of the tags will be returned.
 *  @param limit  - The max number of results you want returned.
 *
 *  @return MMXQuery object
 */
+ (instancetype)queryForEmailStartsWith:(NSString *)email
								   tags:(NSArray *)tags
								  limit:(int)limit;

/**
 *  Creates a MMXQuery with a MMXTopicQueryFilter where topicName = value passed for topicName
 *	The MMXUserQueryFilter predicateOperatorType is set to MMXBeginsWithPredicateOperatorType
 *
 *  @param topicName	- Partial topic name you want to query for.
 *  @param tags			- One or more NSString tags. Objects that contain ANY of the tags will be returned.
 *  @param limit		- The max number of results you want returned.
 *
 *  @return MMXQuery object
 */
+ (instancetype)queryForTopicNameStartsWith:(NSString *)topicName
									   tags:(NSArray *)tags
									  limit:(int)limit;

/**
 *  Creates a MMXQuery with a MMXTopicQueryFilter where topicDescription = value passed for topicDescription
 *	The MMXUserQueryFilter predicateOperatorType is set to MMXBeginsWithPredicateOperatorType
 *
 *  @param topicDescription - Partial topic topicDescription you want to query for.
 *  @param tags				- One or more NSString tags. Objects that contain ANY of the tags will be returned.
 *  @param limit			- The max number of results you want returned.
 *
 *  @return MMXQuery object
 */
+ (instancetype)queryForTopicDescriptionStartsWith:(NSString *)topicDescription
											  tags:(NSArray *)tags
											 limit:(int)limit;

@end
