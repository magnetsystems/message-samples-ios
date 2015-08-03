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

#import "MMXTopicSummaryRequestResponse.h"
#import "MMXTopic_Private.h"
#import "MMXTopicSummary_Private.h"
#import "DDXML.h"
#import "MMXConstants.h"
#import "XMPP.h"

@implementation MMXTopicSummaryRequestResponse

- (instancetype)initWithIQ:(XMPPIQ *)iq {
    if ((self = [super init])) {
        NSXMLElement* mmxElement =  [iq elementForName:MXmmxElement xmlns:MXnsPubSub];
        if (mmxElement) {
            NSString* jsonContent =  [[mmxElement childAtIndex:0] XMLString];
            NSError* error;
            NSData* jsonData = [jsonContent dataUsingEncoding:NSUTF8StringEncoding];
            id parsedJson = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
            
            if (!error) {
                if ([parsedJson isKindOfClass:[NSArray class]]) {
                    NSMutableArray * topicArray = @[].mutableCopy;
                    for (NSDictionary * dict in (NSArray *)parsedJson) {
                        if (dict && dict[@"topicNode"]) {
                            MMXTopicSummary * topic = [MMXTopicSummary topicSummaryFromDict:dict];
                            if (topic) {
                                [topicArray addObject:topic];
                            }
                        }
                    }
                    if (topicArray.count) {
                        _topics = topicArray.copy;
                    } else {
                        _topics = @[];
                    }
                } else if ([parsedJson isKindOfClass:[NSDictionary class]]){
                    NSDictionary * dict = parsedJson;
                    if (dict[@"code"]) {
                        _code = [dict[@"code"] intValue];
                        _message = dict[@"message"];
                        _error = [self errorFromResponse:@"Error fetching topic list"];
                    }
                } else {
                    _code = 500;
                    _message = @"An unknown error occured";
                    _error = [self errorFromResponse:@"Error fetching topic list"];
                }
            } else {
                _code = 0;
                _error = error;
            }
        }
    }
    return self;
}

- (NSError *)unknownError {
    
    NSDictionary *userInfo = @{
                               NSLocalizedDescriptionKey: NSLocalizedString(@"An unknown error occured", nil),
                               NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"An unknown error occured", nil),
                               };
    NSError *error = [NSError errorWithDomain:MMXErrorDomain
                                         code:500
                                     userInfo:userInfo];
    return error;
    
}

- (NSString *)description {
    NSString *description = [NSString stringWithFormat:@"topics::%@\ncode::%i\nmessage::%@\n",
                             self.topics, self.code, self.message
                             ];
    return description;
}

- (NSError *)errorFromResponse:(NSString *)description {
    NSDictionary *userInfo = @{
                               NSLocalizedDescriptionKey: NSLocalizedString(description, nil),
                               NSLocalizedFailureReasonErrorKey: NSLocalizedString(self.message, nil),
                               };
    NSError *error = [NSError errorWithDomain:MMXErrorDomain
                                         code:self.code
                                     userInfo:userInfo];
    return error;
}

@end
