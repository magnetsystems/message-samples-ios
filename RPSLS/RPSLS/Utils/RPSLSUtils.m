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

#import "RPSLSUtils.h"
#import "RPSLSConstants.h"
#import "RPSLSUser.h"
#import "RPSLSUserStats.h"

@implementation RPSLSUtils

+ (NSString *)timestamp {
    return [NSString stringWithFormat:@"%llu",(long long)[[NSDate date] timeIntervalSince1970] * 1000];
}

+ (MMXChannel *)availablePlayersChannel {
    MMXChannel *channel = [MMXChannel channelWithName:kPostStatus_TopicName summary:nil];
    channel.isPublic = YES;
    return channel;
}

+ (MMXMessage *)availablilityMessage:(BOOL)available {
    // content:@"Letting other players know if I'm available"
    NSDictionary *messageContent = @{kMessageKey_Username : [RPSLSUser me].username,
            kMessageKey_UserAvailablity : available ? @"true" : @"false",
            kMessageKey_Timestamp : [RPSLSUtils timestamp],
            kMessageKey_Type : kMessageTypeValue_Availability,
            kMessageKey_Wins : [@([RPSLSUser me].stats.wins) stringValue],
            kMessageKey_Losses : [@([RPSLSUser me].stats.losses) stringValue],
            kMessageKey_Ties : [@([RPSLSUser me].stats.ties) stringValue]
    };
    return [MMXMessage messageToChannel:[self availablePlayersChannel]
                         messageContent:messageContent
    ];
}

+ (BOOL)isTrue:(id)value {
    if ([value isKindOfClass:[NSString class]]) {
        if ([value isEqualToString:@"true"]) {
            return YES;
        }
    } else if ([value isKindOfClass:[NSNumber class]]) {
        if ([value boolValue]) {
            return YES;
        }
    }
    
    return NO;
}
@end
