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

#import "MMXMessage_Private.h"
#import "MagnetDelegate.h"
#import "MMXInternal_Private.h"
#import "MMXMessageUtils.h"
#import "MMXClient_Private.h"
#import "MMXChannel_Private.h"
#import "MMXPubSubMessage_Private.h"
#import "MMXInternalMessageAdaptor_Private.h"
#import "MMXUserID_Private.h"
#import "MMXMessageOptions.h"
#import "MMXTopic_Private.h"
#import "MMXInternalAddress.h"
#import "MMXConstants.h"
#import "MMUser+Addressable.h"
#import  "MMXNotificationConstants.h"
#import <MMX/MMX-Swift.h>

@import MagnetMaxCore;

@implementation MMXMessage

static int kATTACHMENTCONTEXT;

+ (instancetype)messageToRecipients:(NSSet <MMUser *>*)recipients
                     messageContent:(NSDictionary <NSString *,NSString *>*)messageContent {
    MMXMessage *msg = [MMXMessage new];
    msg.recipients = recipients;
    msg.messageContent = messageContent;
    return msg;
};

+ (instancetype)messageToChannel:(MMXChannel *)channel
                  messageContent:(NSDictionary <NSString *,NSString *>*)messageContent {
    MMXMessage *msg = [MMXMessage new];
    msg.channel = channel;
    msg.messageContent = messageContent;
    return msg;
}

+ (instancetype)messageFromPubSubMessage:(MMXPubSubMessage *)pubSubMessage
                                  sender:(MMUser *)sender {
    MMXMessage *msg = [MMXMessage new];
    msg.channel = [MMXChannel channelWithName:pubSubMessage.topic.topicName summary:pubSubMessage.topic.topicDescription isPublic:pubSubMessage.topic.inUserNameSpace publishPermissions:pubSubMessage.topic.publishPermissions];
    if (pubSubMessage.topic.inUserNameSpace) {
        msg.channel.isPublic = NO;
        msg.channel.ownerUserID = pubSubMessage.topic.nameSpace;
    } else {
        msg.channel.isPublic = YES;
    }
    msg.senderDeviceID = pubSubMessage.senderDeviceID;
    msg.sender = sender;
    
    // Handle attachments
    NSMutableDictionary *metaData = pubSubMessage.metaData.mutableCopy;
    NSArray *receivedAttachments;
    NSString *attachmentsJSONString = pubSubMessage.metaData[@"_attachments"];
    if (attachmentsJSONString) {
        NSData *attachmentsJSON = [attachmentsJSONString dataUsingEncoding:NSUTF8StringEncoding];
        NSError *serializationError;
        id attachments = [NSJSONSerialization JSONObjectWithData:attachmentsJSON options:0 error:&serializationError];
        if (!serializationError) {
            receivedAttachments = attachments;
        }
        [metaData removeObjectForKey:@"_attachments"];
    }
    
    MMModel<MMXPayload>*payload;
    if (pubSubMessage.messageContent) {
        NSData *data = [pubSubMessage.messageContent dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *payloadContent = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
        Class contentClass = [MMXPayloadRegister classForContentType:payloadContent[@"mType"]];
        if (payloadContent && contentClass) {
            payload = [MTLJSONAdapter modelOfClass:contentClass fromJSONDictionary:payloadContent error:nil];
        }
    }
    
    pubSubMessage.metaData = metaData;
    
    if (receivedAttachments.count > 0) {
        NSMutableArray *attachments = [NSMutableArray arrayWithCapacity:receivedAttachments.count];
        for (NSDictionary *attachmentDictionary in receivedAttachments) {
            [attachments addObject:[MMAttachment fromDictionary:attachmentDictionary]];
        }
        msg.attachments = attachments;
    }
    
    msg.messageID = pubSubMessage.messageID;
    msg.messageContent = pubSubMessage.metaData;
    msg.timestamp = pubSubMessage.timestamp;
    msg.messageType = MMXMessageTypeChannel;
    msg.payload = payload;
    return msg;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
                        change:(NSDictionary *)change context:(void *)context
{
    if (context == &kATTACHMENTCONTEXT) {
        if ([keyPath isEqualToString:@"uploadProgress"]) {
            [[self attachmentProgress] removeObserver:self forKeyPath:@"uploadProgress" context:&kATTACHMENTCONTEXT];
            [[self attachmentProgress].uploadProgress addObserver:self forKeyPath:@"fractionCompleted" options:NSKeyValueObservingOptionNew context:&kATTACHMENTCONTEXT];
            self.attachmentUploadProgress = 0;
            [[NSNotificationCenter defaultCenter] postNotificationName:MMXAttachmentUploadDidChangeValueNotification object:self];
        } else {
            self.attachmentUploadProgress = [self attachmentProgress].uploadProgress;
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:MMXAttachmentUploadDidChangeValueNotification object:self];
            });
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object
                               change:change context:context];
    }
}

- (NSString *)sendWithSuccess:(void (^)(NSSet <NSString *>*invalidUsers))success
                      failure:(void (^)(NSError *))failure {
    if (![MMXMessageUtils isValidMetaData:self.messageContent]) {
        NSError * error = [MMXClient errorWithTitle:@"Not Valid" message:@"All values must be strings." code:401];
        if (failure) {
            failure(error);
        }
        return nil;
    }
    if ([MMUser currentUser] == nil) {
        NSError * error = [MMXClient errorWithTitle:@"Not Logged In" message:@"You must be logged in to send a message." code:401];
        if (failure) {
            failure(error);
        }
        return nil;
    }
    if (self.channel) {
        NSString *messageID = [[MMXClient sharedClient] generateMessageID];
        NSString *payload;
        if (self.payload) {
            NSError *error;
            NSMutableDictionary *payloadDictionary = [MTLJSONAdapter JSONDictionaryFromModel:self.payload error:&error].mutableCopy;
            payloadDictionary[@"mType"] = self.contentType;
            if (error) {
                NSError * error = [MMXClient errorWithTitle:@"Not Valid" message:@"Failed to parse MMModel." code:401];
                if (failure) {
                    failure(error);
                }
                return nil;
            }
            
            error = nil;
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:payloadDictionary options:0 error:&error];
            
            if (error) {
                NSError * error = [MMXClient errorWithTitle:@"Not Valid" message:@"Failed to parse JSON." code:401];
                if (failure) {
                    failure(error);
                }
                return nil;
            }
            
            payload = [[NSString alloc] initWithBytes:[jsonData bytes] length:[jsonData length] encoding:NSUTF8StringEncoding];
            NSMutableDictionary *dict = self.messageContent.mutableCopy;
            self.messageContent = dict.copy;
        }
        
        MMXPubSubMessage *msg = [MMXPubSubMessage pubSubMessageToTopic:[self.channel asTopic] content:payload metaData:self.messageContent];
        msg.messageID = messageID;
        self.messageID = messageID;
        if ([MMXClient sharedClient].connectionStatus != MMXConnectionStatusAuthenticated) {
            if (failure) {
                failure([MMXMessage notNotLoggedInAndNoUserError]);
            }
            return nil;
        }
        // Handle attachments
        if (self.mutableAttachments.count > 0) {
            NSDictionary *metaData = @{
                                       @"channel_name": self.channel.name,
                                       @"channel_is_public": self.channel.isPublic ? @"true" : @"false",
                                       @"message_id": messageID,
                                       };
            
            self.attachmentProgress = [[MMAttachmentProgress alloc] init];
            [[self attachmentProgress] addObserver:self forKeyPath:@"uploadProgress" options:NSKeyValueObservingOptionNew context:&kATTACHMENTCONTEXT];
            
            [MMAttachmentService upload:self.mutableAttachments metaData:metaData  progress:self.attachmentProgress success:^{
                @try {
                    [[self attachmentProgress].uploadProgress removeObserver:self forKeyPath:@"fractionCompleted" context:&kATTACHMENTCONTEXT];
                }
                @catch (NSException *exception) {}
                NSMutableDictionary *messageContent = self.messageContent.mutableCopy;
                NSMutableArray *attachmentsToSend = [NSMutableArray arrayWithCapacity:self.mutableAttachments.count];
                for (MMAttachment *attachment in self.mutableAttachments) {
                    [attachmentsToSend addObject:[attachment toJSONString]];
                }
                messageContent[@"_attachments"] = [NSString stringWithFormat:@"%@%@%@", @"[", [attachmentsToSend componentsJoinedByString:@","], @"]"];
                self.messageContent = messageContent;
                msg.metaData = self.messageContent;
                
                [[MMXClient sharedClient].pubsubManager publishPubSubMessage:msg success:^(BOOL successful, NSString *messageID) {
                    self.sender = [MMUser currentUser];
                    self.timestamp = [NSDate date];
                    if (success) {
                        success([NSSet set]);
                    }
                } failure:^(NSError *error) {
                    if (failure) {
                        failure(error);
                    }
                }];
                
            } failure:^(NSError * _Nonnull error) {
                @try {
                    [[self attachmentProgress].uploadProgress removeObserver:self forKeyPath:@"fractionCompleted" context:&kATTACHMENTCONTEXT];
                }
                @catch (NSException *exception) {}
                if (failure) {
                    failure(error);
                }
            }];
        } else {
            [[MMXClient sharedClient].pubsubManager publishPubSubMessage:msg success:^(BOOL successful, NSString *messageID) {
                self.sender = [MMUser currentUser];
                self.timestamp = [NSDate date];
                if (success) {
                    success([NSSet set]);
                }
            } failure:^(NSError *error) {
                if (failure) {
                    failure(error);
                }
            }];
        }
        return messageID;
    } else {
        NSString *messageID = [[MMXClient sharedClient] generateMessageID];
        self.messageID = messageID;
        if ([MMXClient sharedClient].connectionStatus != MMXConnectionStatusAuthenticated) {
            if (failure) {
                failure([MMXMessage notNotLoggedInAndNoUserError]);
            }
            return nil;
        }
        NSError *error;
        [MMXMessage validateMessageRecipients:self.recipients content:self.messageContent error:&error];
        if (error) {
            if (failure) {
                failure(error);
            }
        } else {
            
            // Handle attachments
            if (self.mutableAttachments.count > 0) {
                NSDictionary *metaData = @{
                                           @"recipients": [[[self.recipients valueForKey:@"userID"] allObjects] componentsJoinedByString:@","],
                                           @"message_id": messageID,
                                           };
                
                self.attachmentProgress = [[MMAttachmentProgress alloc] init];
                [[self attachmentProgress] addObserver:self forKeyPath:@"uploadProgress" options:NSKeyValueObservingOptionNew context:&kATTACHMENTCONTEXT];
                
                [MMAttachmentService upload:self.mutableAttachments metaData:metaData progress:self.attachmentProgress success:^{
                    @try {
                        [[self attachmentProgress].uploadProgress removeObserver:self forKeyPath:@"fractionCompleted" context:&kATTACHMENTCONTEXT];
                    }
                    @catch (NSException *exception) {}
                    NSMutableDictionary *messageContent = self.messageContent.mutableCopy;
                    NSMutableArray *attachmentsToSend = [NSMutableArray arrayWithCapacity:self.mutableAttachments.count];
                    for (MMAttachment *attachment in self.mutableAttachments) {
                        [attachmentsToSend addObject:[attachment toJSONString]];
                    }
                    messageContent[@"_attachments"] = [NSString stringWithFormat:@"%@%@%@", @"[", [attachmentsToSend componentsJoinedByString:@","], @"]"];
                    self.messageContent = messageContent;
                    
                    [[MagnetDelegate sharedDelegate] sendMessage:self success:^(NSSet *invalidUsers) {
                        self.sender = [MMUser currentUser];
                        self.timestamp = [NSDate date];
                        if (self.recipients.count == invalidUsers.count) {
                            if (failure) {
                                NSError *error = [MMXClient errorWithTitle:@"Invalid User(s)" message:@"The user(s) you are trying to send a message to does not exist or does not have a valid device associated with them." code:500];
                                failure(error);
                            }
                        } else {
                            if (success) {
                                success(invalidUsers);
                            }
                        }
                    } failure:^(NSError *error) {
                        if (failure) {
                            failure(error);
                        }
                    }];
                } failure:^(NSError * _Nonnull error) {
                    @try {
                        [[self attachmentProgress].uploadProgress removeObserver:self forKeyPath:@"fractionCompleted" context:&kATTACHMENTCONTEXT];
                    }
                    @catch (NSException *exception) {}
                    if (failure) {
                        failure(error);
                    }
                }];
            } else {
                [[MagnetDelegate sharedDelegate] sendMessage:self success:^(NSSet *invalidUsers) {
                    self.sender = [MMUser currentUser];
                    self.timestamp = [NSDate date];
                    if (self.recipients.count == invalidUsers.count) {
                        if (failure) {
                            NSError *error = [MMXClient errorWithTitle:@"Invalid User(s)" message:@"The user(s) you are trying to send a message to does not exist or does not have a valid device associated with them." code:500];
                            failure(error);
                        }
                    } else {
                        if (success) {
                            success(invalidUsers);
                        }
                    }
                } failure:^(NSError *error) {
                    if (failure) {
                        failure(error);
                    }
                }];
            }
        }
        return messageID;
    }
}

- (NSString *)replyWithContent:(NSDictionary <NSString *,NSString *>*)content
                       success:(void (^)(NSSet <NSString *>*invalidUsers))success
                       failure:(void (^)(NSError *))failure {
    NSSet *recipients = [NSSet setWithObject:self.sender];
    NSError *error;
    [MMXMessage validateMessageRecipients:recipients content:self.messageContent error:&error];
    if (error) {
        if (failure) {
            failure(error);
        }
        return nil;
    }
    
    MMXMessage *msg = [MMXMessage messageToRecipients:recipients messageContent:content];
    NSString * messageID = [msg sendWithSuccess:^(NSSet *invalidUsers) {
        if (success) {
            success(invalidUsers);
        }
    } failure:^(NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
    return messageID;
}

- (NSString *)replyAllWithContent:(NSDictionary <NSString *,NSString *>*)content
                          success:(void (^)(NSSet <NSString *>*invalidUsers))success
                          failure:(void (^)(NSError *))failure {
    NSMutableSet *newSet = [NSMutableSet setWithSet:self.recipients];
    [newSet addObject:self.sender];
    MMUser *currentUser = [MMUser currentUser];
    if (currentUser) {
        [newSet removeObject:currentUser];
    }
    NSError *error;
    [MMXMessage validateMessageRecipients:newSet content:self.messageContent error:&error];
    if (error) {
        if (failure) {
            failure(error);
        }
        return nil;
    }
    MMXMessage *msg = [MMXMessage messageToRecipients:newSet messageContent:content];
    NSString * messageID = [msg sendWithSuccess:^(NSSet *invalidUsers) {
        if (success) {
            success(invalidUsers);
        }
    } failure:^(NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
    return messageID;
}

- (void)addAttachment:(MMAttachment *)attachment {
    NSAssert((attachment.fileURL != nil || attachment.data != nil || attachment.inputStream != nil || attachment.content != nil), @"fileURL, data, inputStream & content cannot be nil");
    [self.mutableAttachments addObject:attachment];
}

- (void)addAttachments:(NSArray<MMAttachment *> *)attachments {
    for (MMAttachment *attachment in attachments) {
        [self addAttachment:attachment];
    }
}

#pragma mark - Errors

+ (NSError *)notNotLoggedInAndNoUserError {
    NSError * error = [MMXClient errorWithTitle:@"Forbidden" message:@"You are not logged in and there is no current user." code:403];
    return error;
}


#pragma mark - Helpers
- (NSArray *)replyAllArray {
    NSMutableArray *recipients = [NSMutableArray arrayWithCapacity:self.recipients.count + 1];
    [recipients addObject:self.sender];
    [recipients addObjectsFromArray:[self.recipients allObjects]];
    return recipients.copy;
}

- (void)sendDeliveryConfirmation {
    [[MMXClient sharedClient] sendDeliveryConfirmationForAddress:self.sender.address messageID:self.messageID toDeviceID:self.senderDeviceID];
}

+ (BOOL)validateMessageRecipients:(NSSet *)recipients content:(NSDictionary *)content error:(NSError **)error {
    if (recipients == nil || recipients.count < 1) {
        *error = [MMXClient errorWithTitle:@"Recipients not set" message:@"Recipients cannot be nil" code:401];
        return NO;
    } else {
        for (MMUser *user in recipients) {
            if (user.userID == nil || [user.userID isEqualToString:@""]) {
                *error = [MMXClient errorWithTitle:@"Invalid Recipients" message:@"One or more recipients are not valid because their userID is nil" code:401];
                return NO;
            }
        }
        
    }
    
    if (![MMXMessageUtils isValidMetaData:content]) {
        *error = [MMXClient errorWithTitle:@"Not Valid" message:@"All values must be strings." code:401];
        return NO;
    }
    if ([MMXMessageUtils sizeOfMessageContent:nil metaData:content] > kMaxMessageSize) {
        *error = [MMXClient errorWithTitle:@"Message too large" message:@"Message content exceeds the max size of 200KB" code:401];
        return NO;
    }
    return YES;
}

#pragma mark - Equality

- (BOOL)isEqual:(MMXMessage *)object {
    return [self.messageID isEqualToString:object.messageID];
}

- (NSUInteger)hash {
    return [self.messageID hash];
}


#pragma mark - Overriden getters

- (NSString *)contentType {
    return [self.payload.class contentType];
}

- (NSMutableArray *)mutableAttachments {
    if (!_mutableAttachments) {
        _mutableAttachments = [NSMutableArray array];
    }
    return _mutableAttachments;
}

@end
