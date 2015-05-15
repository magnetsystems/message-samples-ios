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

#import "MMXTopic.h"

@interface MMXTopic ()

@property (nonatomic, assign)   BOOL isCollection;
@property (nonatomic, readonly)	BOOL inUserNameSpace;

@property (nonatomic, readonly) NSString * identifier;
@property (nonatomic, copy)		NSString * nameSpace;

- (BOOL)isValid:(NSError **)error;

+ (instancetype)topicFromQueryResult:(NSDictionary *)topicDict;
+ (instancetype)topicFromNode:(NSString *)node;
+ (instancetype)geoLocationTopicForUsername:(NSString *)username;

- (NSDictionary *)dictionaryRepresentation;
- (NSDictionary *)dictionaryRepresentationForDeletion;
- (NSDictionary *)dictionaryForTopicSummary;

@end
