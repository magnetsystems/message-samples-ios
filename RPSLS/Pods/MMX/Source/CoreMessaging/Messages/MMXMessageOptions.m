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

#import "MMXMessageOptions_Private.h"

@implementation MMXMessageOptions

#pragma mark - NSCoding

- (id)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        self.shouldRequestDeliveryReceipt = [coder decodeBoolForKey:@"self.shouldRequestDeliveryReceipt"];
    }

    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeBool:self.shouldRequestDeliveryReceipt forKey:@"self.shouldRequestDeliveryReceipt"];
}

//Not currently used. Server needs to add ability to not require an ack
//- (void)setOptimizeForPerformanceFromMessageType:(NSString *)messageType {
//    self.optimizeForPerformance = [messageType isEqualToString:@"normal"];
//}

@end
