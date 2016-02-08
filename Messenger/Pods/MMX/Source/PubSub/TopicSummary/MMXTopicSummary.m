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


#import "MMXTopicSummary_Private.h"
#import "MMXTopic_Private.h"
#import "MMXUtils.h"

@implementation MMXTopicSummary

+ (instancetype)topicSummaryFromDict:(NSDictionary *)summaryDict {
	MMXTopicSummary * summary = [[MMXTopicSummary alloc] init];
	MMXTopic * topic = [[MMXTopic alloc] init];
	NSDictionary * topicDict = summaryDict[@"topicNode"];
	topic.topicName = topicDict[@"topicName"];
	if (topicDict[@"userId"] && [topicDict[@"userId"] isKindOfClass:[NSNull class]]) {
		topic.nameSpace = topicDict[@"userId"];
	}
	summary.topic = topic;
	summary.numItemsPublished = [summaryDict[@"count"] intValue];
	summary.lastTimePublishedTo = [MMXUtils dateFromiso8601Format:summaryDict[@"lastPubTime"]];
	return summary;
}

@end
