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
 
#import <Foundation/Foundation.h>

@class MMXInternalMessageAdaptor;
@class MMXMessageOptions;
@class MMXOutboxEntry;
@class XMPPIQ;
@class MMXPubSubMessage;

typedef NS_ENUM(NSUInteger, MMXOutboxEntryMessageType){
    MMXOutboxEntryMessageTypeDefault = 0, // Good old XMPP message
    MMXOutboxEntryMessageTypePubSub
};

@interface MMXDataModel : NSObject

+ (instancetype)sharedDataModel;

/**
 Returns the newly created outbox entry.

 @param message The message to be inserted.

 @param options The options for the message.

 @param username The username of the sender.

*/
- (MMXOutboxEntry *)addOutboxEntryWithMessage:(MMXInternalMessageAdaptor *)message
                                 options:(MMXMessageOptions *)options
                                username:(NSString *)username;

- (MMXOutboxEntry *)addOutboxEntryWithPubSubMessage:(MMXPubSubMessage *)message
                                           username:(NSString *)username;

/**
 Returns a list of outbox entries for the user.

 @param username The username of the sender.
 @param outboxEntryMessageType The type of the message.

*/
- (NSArray *)outboxEntriesForUser:(NSString *)username
           outboxEntryMessageType:(MMXOutboxEntryMessageType)outboxEntryMessageType;

/**
 Delete an outbox entry by messageID.

 @param messageID The messageID of the message to delete.

 @return YES if the entry was successfully deleted.

*/
- (BOOL)deleteOutboxEntryForMessage:(NSString *)messageID;

/**
 Extract message from an outbox entry.

 @param outboxEntry The outbox entry to extract the message from.

 @return The extracted message.

*/
- (MMXInternalMessageAdaptor *)extractMessageFromOutboxEntry:(MMXOutboxEntry *)outboxEntry;

/**
 Extract message options from an outbox entry.

 @param outboxEntry The outbox entry to extract the message from.

 @return The extracted message options.

*/
- (MMXMessageOptions *)extractMessageOptionsFromOutboxEntry:(MMXOutboxEntry *)outboxEntry;

@end
