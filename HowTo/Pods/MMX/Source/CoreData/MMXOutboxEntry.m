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

#import "MMXOutboxEntry.h"
#import "MMXInternalMessageAdaptor.h"
#import "MMXMessageOptions.h"
#import "MMXKeyedArchiver.h"

@interface MMXOutboxEntry ()

@end

@implementation MMXOutboxEntry

- (instancetype)outboxEntryWithType:(MMXOutboxEntryMessageType)outboxEntryMessageType
                            message:(MMXInternalMessageAdaptor *)message
                            options:(MMXMessageOptions *)options
                           username:(NSString *)username {

    self.messageTypeValue = outboxEntryMessageType;

    self.creationTime = [NSDate date];
    self.messageID = message.messageID;
    self.username = username;
    self.message = [MMXKeyedArchiver archivedDataWithRootObject:message];
    self.messageOptions = [MMXKeyedArchiver archivedDataWithRootObject:options];

    return self;
}

@end
