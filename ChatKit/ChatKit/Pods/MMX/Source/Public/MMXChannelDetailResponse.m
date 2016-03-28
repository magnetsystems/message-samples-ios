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

#import "MMXChannelDetailResponse.h"
#import "MMXChannel.h"
#import "MMXMessage.h"
#import "MMXPubSubItemChannel.h"

@implementation MMXChannelDetailResponse

+ (NSDictionary *)attributeMappings {
    NSDictionary *dictionary = @{
                                 @"userID": @"userId",
                                 };
    NSMutableDictionary *attributeMappings = [[super attributeMappings] mutableCopy];
    [attributeMappings addEntriesFromDictionary:dictionary];
    
    return attributeMappings;
}

+ (NSDictionary *)listAttributeTypes {
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithDictionary:@{
                                                                                      @"messages" : MMXPubSubItemChannel.class,
                                                                                      @"subscribers" : MMUserProfile.class,
                                                                                      }];
    [dictionary addEntriesFromDictionary:[super listAttributeTypes]];
    return dictionary;
}

+ (NSDictionary *)mapAttributeTypes {
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithDictionary:@{
                                                                                      }];
    [dictionary addEntriesFromDictionary:[super mapAttributeTypes]];
    return dictionary;
}

+ (NSDictionary *)enumAttributeTypes {
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithDictionary:@{
                                                                                      }];
    [dictionary addEntriesFromDictionary:[super enumAttributeTypes]];
    return dictionary;
}

+ (NSArray *)charAttributes {
    NSMutableArray *array = [NSMutableArray arrayWithArray:@[
                                                             ]];
    [array addObjectsFromArray:[super charAttributes]];
    return array;
}

- (void)setMessages:(NSArray *)messages {
    NSArray <MMXPubSubItemChannel *> *messsagesArray = messages;
    NSMutableArray *mmxMessages = [NSMutableArray new];
    for (id message in messsagesArray) {
        if ([message isKindOfClass:[MMXPubSubItemChannel class]]) {
            [mmxMessages addObject:[message toMMXMessage]];
        } else if ([message isKindOfClass:[MMXMessage class]]) {
            [mmxMessages addObject:message];
        }
    }
    
    _messages = mmxMessages;
}

@end
