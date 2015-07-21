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

#import "MMXQuery_Private.h"
#import "MMXQueryFilter_Private.h"
#import "MMXUserQueryFilter_Private.h"
#import "MMXTopicQueryFilter_Private.h"
#import "XMPPIQ.h"
#import "MMXUtils.h"
#import "MMXConstants.h"

@implementation MMXQuery

+ (instancetype)queryForUserDisplayNameStartsWith:(NSString *)displayName tags:(NSArray *)tags limit:(int)limit {
	MMXQuery * query = [MMXQuery queryWithTags:tags compoundPredicateType:MMXAndPredicateType limit:limit];
	MMXUserQueryFilter * userFilter = [[MMXUserQueryFilter alloc] init];
	userFilter.displayName = displayName;
	userFilter.predicateOperatorType = MMXBeginsWithPredicateOperatorType;
	query.queryFilters = @[userFilter];
	return query;
}

+ (instancetype)queryForEmailStartsWith:(NSString *)email tags:(NSArray *)tags limit:(int)limit {
	MMXQuery * query = [MMXQuery queryWithTags:tags compoundPredicateType:MMXAndPredicateType limit:limit];
	MMXUserQueryFilter * userFilter = [[MMXUserQueryFilter alloc] init];
	userFilter.email = email;
	userFilter.predicateOperatorType = MMXBeginsWithPredicateOperatorType;
	query.queryFilters = @[userFilter];
	return query;
}

+ (instancetype)queryForTopicNameStartsWith:(NSString *)topicName tags:(NSArray *)tags limit:(int)limit {
	MMXQuery * query = [MMXQuery queryWithTags:tags compoundPredicateType:MMXAndPredicateType limit:limit];
	MMXTopicQueryFilter * topicFilter = [[MMXTopicQueryFilter alloc] init];
	topicFilter.topicName = topicName;
	topicFilter.predicateOperatorType = MMXBeginsWithPredicateOperatorType;
	query.queryFilters = @[topicFilter];
	return query;
}

+ (instancetype)queryForTopicDescriptionStartsWith:(NSString *)topicDescription tags:(NSArray *)tags limit:(int)limit {
	MMXQuery * query = [MMXQuery queryWithTags:tags compoundPredicateType:MMXAndPredicateType limit:limit];
	MMXTopicQueryFilter * topicFilter = [[MMXTopicQueryFilter alloc] init];
	topicFilter.topicDescription = topicDescription;
	topicFilter.predicateOperatorType = MMXBeginsWithPredicateOperatorType;
	query.queryFilters = @[topicFilter];
	return query;
}

+ (instancetype)queryWithTags:(NSArray *)tags compoundPredicateType:(MMXCompoundPredicateType)compoundPredicateType limit:(int)limit {
	MMXQuery * query = [[MMXQuery alloc] init];
	query.tags = tags;
	query.compoundPredicateType = compoundPredicateType;
	query.limit = limit;
	return query;
}

- (NSDictionary *)dictionaryRepresentation {
	NSMutableDictionary * queryDict = [self baseDictionary];
	for (NSDictionary * propertyDict in [self filteredPropertyArray]) {
		NSString *keyName = [self keyNameForProperty:propertyDict[@"propertyName"]];
		[queryDict setObject:@{@"match":propertyDict[@"match"],
							   @"value":propertyDict[@"value"]} forKey:keyName];
	}
	return queryDict.copy;
}

- (NSMutableDictionary *)baseDictionary {
	return @{
			 @"operator": [self operatorAsString],
			 @"limit":self.limit ? @(self.limit) : @20,
			 @"tags":(self.tags && self.tags.count) ? @{@"match": @"EXACT",
														@"values":self.tags} : [NSNull null]
			 }.mutableCopy;
}

- (NSString *)operatorAsString {
	switch (self.compoundPredicateType) {
		case MMXAndPredicateType:
			return @"AND";
			break;
		case MMXOrPredicateType:
			return @"OR";
			break;
		default:
			return @"AND";
			break;
	}
}

- (NSArray *)filteredPropertyArray {
	NSMutableArray * array = @[].mutableCopy;
	for (NSString * propertyName in [[self propertyMap] allKeys]) {
		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"propertyName = %@", propertyName];
		NSArray * tempArray = [[self filtersAsDictionaryList] filteredArrayUsingPredicate:predicate];
		if (tempArray && tempArray.count) {
			[array addObject:tempArray.lastObject];
		}
	}
	return array.copy;
}

- (NSArray *)filtersAsDictionaryList {
	NSMutableArray * dictionaryList = @[].mutableCopy;
	for (MMXQueryFilter * filter in self.queryFilters) {
		[dictionaryList addObjectsFromArray:[filter asArrayOfDictionaries]];
	}
	return dictionaryList.copy;
}

- (NSDictionary *)propertyMap {
	return @{@"displayName":@"displayName",
			 @"email":@"email",
			 @"phoneNumber":@"phone",
			 @"topicDescription":@"description"};
}

- (NSString *)keyNameForProperty:(NSString *)propertyName {
	return [self propertyMap][propertyName];
}

@end
