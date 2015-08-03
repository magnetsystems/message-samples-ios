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

#import "MMXPubSubFetchRequest_Private.h"
#import "MMXTopic_Private.h"
#import "MMXClient_Private.h"
#import "MMXUtils.h"

@implementation MMXPubSubFetchRequest

+ (instancetype)requestWithTopic:(MMXTopic *)topic {
	MMXPubSubFetchRequest * request = [[MMXPubSubFetchRequest alloc] init];
	request.topic = topic;
	return request;
}

- (NSDictionary *)dictionaryRepresentation {
    return @{@"userId": [NSNull null],
             @"topicName":self.topic.topicName,
             @"options":[self options]
                 };
}

- (NSDictionary *)options {
    return @{@"subscriptionId": self.subscriptionID ?: [NSNull null],
             @"since": self.since ? [MMXUtils stringIniso8601Format:self.since] : [NSNull null],
             @"until": self.until ? [MMXUtils stringIniso8601Format:self.until] : [NSNull null],
             @"ascending": @(self.ascending),
             @"maxItems": self.maxItems ? @(self.maxItems) : @(-1)};
}

@end
