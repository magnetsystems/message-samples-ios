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

#import "MMXMessage+RPSLS.h"
#import "RPSLSConstants.h"


@implementation MMXMessage (RPSLS)

- (BOOL)isTimelyMessage {
    if (self.messageContent != nil && self.messageContent[kMessageKey_Timestamp] != nil) {
        NSString * stamp = self.messageContent[kMessageKey_Timestamp];
        long long stampValue = [stamp longLongValue];
        NSTimeInterval secondsSinceSent = [[NSDate date] timeIntervalSince1970] - (stampValue / 1000);
        if (secondsSinceSent <= 60) {
            return YES;
        }
    }
    return NO;
}

@end