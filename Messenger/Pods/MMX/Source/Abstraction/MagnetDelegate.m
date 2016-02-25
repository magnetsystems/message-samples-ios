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

#import "MagnetDelegate.h"
#import "MMXNotificationConstants.h"
#import "MMXMessageTypes.h"
#import "MMXChannel_Private.h"
#import "MMXConfiguration.h"
#import "MMXClient_Private.h"
#import "MMXAddressable.h"
#import "MMXInternalMessageAdaptor.h"
#import "MMXInboundMessage_Private.h"
#import "MMXPubSubMessage.h"
#import "MMXClient_Private.h"
#import "MMXUserID_Private.h"
#import "MMXEndpoint.h"
#import "MMXUserProfile.h"
#import "MMXTopic_Private.h"
#import "MMXOutboundMessage_Private.h"
#import "MMXMessage_Private.h"
#import "MMXConstants.h"
#import <MMX/MMX-Swift.h>

@import MagnetMaxCore;

typedef void(^MessageSuccessBlock)(NSSet *);
typedef void(^MessageFailureBlock)(NSError *);

NSString  * const MMXMessageSuccessBlockKey = @"MMXMessageSuccessBlockKey";
NSString  * const MMXMessageFailureBlockKey = @"MMXMessageFailureBlockKey";

@interface MagnetDelegate () <MMXClientDelegate>

@property (nonatomic, copy) void (^maxInitSuccessBlock)(void);

@property (nonatomic, copy) void (^maxInitFailureBlock)(NSError *);

@property (nonatomic, copy) void (^connectSuccessBlock)(void);

@property (nonatomic, copy) void (^connectFailureBlock)(NSError *);

@property (nonatomic, copy) void (^logInSuccessBlock)(MMUser *);

@property (nonatomic, copy) void (^logInFailureBlock)(NSError *);

@property (nonatomic, copy) void (^logOutSuccessBlock)(void);

@property (nonatomic, copy) void (^logOutFailureBlock)(NSError *);

@property (nonatomic, strong) NSMutableDictionary *messageBlockQueue;

@property(nonatomic, strong) NSOperationQueue *internalQueue;

@end

@implementation MagnetDelegate

+ (instancetype)sharedDelegate {
    
    static MagnetDelegate *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[MagnetDelegate alloc] init];
        _sharedClient.messageBlockQueue = [NSMutableDictionary dictionary];
        [MMXClient sharedClient].delegate = _sharedClient;
    });
    return _sharedClient;
}

- (void)startMMXClientWithConfiguration:(NSString *)name {
    if ([MMXClient sharedClient].connectionStatus != MMXConnectionStatusAuthenticated &&
        [MMXClient sharedClient].connectionStatus != MMXConnectionStatusConnected) {
        [MMXClient sharedClient].shouldSuspendIncomingMessages = YES;
        MMXConfiguration * config = [MMXConfiguration configurationWithName:name];
        [MMXClient sharedClient].configuration = config;
        [MMXClient sharedClient].delegate = self;
    }
}

- (NSString *)sendMessage:(MMXMessage *)message
                  success:(void (^)(NSSet *invalidUsers))success
                  failure:(void (^)(NSError *error))failure {
    
    MMXOutboundMessage *msg = [MMXOutboundMessage messageTo:[message.recipients allObjects] withContent:nil metaData:message.messageContent];
    msg.messageID = message.messageID;
    
    if (success || failure) {
        NSMutableDictionary *blockDict = [NSMutableDictionary dictionary];
        if (success) {
            [blockDict setObject:success forKey:MMXMessageSuccessBlockKey];
        }
        if (failure) {
            [blockDict setObject:failure forKey:MMXMessageFailureBlockKey];
        }
        [self.messageBlockQueue setObject:blockDict forKey:msg.messageID];
    }
    
    NSString *messageID = [[MMXClient sharedClient] sendMessage:msg];
    
    return messageID;
}

- (NSString *)sendPushMessage:(MMXPushMessage *)message
                      success:(void (^)(NSSet * invalidDevices))success
                      failure:(void (^)(NSError *error))failure {
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:message.messageContent
                                                       options:kNilOptions
                                                         error:&error];
    NSString *json = [[NSString alloc] initWithData:jsonData
                                           encoding:NSUTF8StringEncoding];
    MMXOutboundMessage *msg = [MMXOutboundMessage messageTo:[message.recipients allObjects] withContent:json metaData:nil];
    
    NSString *messageID = [[MMXClient sharedClient] sendPushMessage:msg
                                                            success:^(NSSet *invalidDevices) {
                                                                invalidDevices = invalidDevices ? invalidDevices : [NSSet new];
                                                                success(invalidDevices);
                                                            } failure:failure];
    return messageID;
}


- (NSString *)sendInternalMessageFormat:(MMXInternalMessageAdaptor *)message
                                success:(void (^)(NSSet *))success
                                failure:(void (^)(NSError *error))failure {
    
    NSString *messageID = [[MMXClient sharedClient] sendMMXMessage:message withOptions:nil shouldValidate:NO];
    if (messageID) {
        if (success || failure) {
            NSMutableDictionary *blockDict = [NSMutableDictionary dictionary];
            if (success) {
                [blockDict setObject:success forKey:MMXMessageSuccessBlockKey];
            }
            if (failure) {
                [blockDict setObject:failure forKey:MMXMessageFailureBlockKey];
            }
            [self.messageBlockQueue setObject:blockDict forKey:messageID];
        }
    }
    return messageID;
}

#pragma mark - MMXClientDelegate Callbacks

- (void)client:(MMXClient *)client didReceiveConnectionStatusChange:(MMXConnectionStatus)connectionStatus error:(NSError *)error {
    switch (connectionStatus) {
        case MMXConnectionStatusAuthenticated: {
            if (self.maxInitSuccessBlock) {
                self.maxInitSuccessBlock();
                self.maxInitSuccessBlock = nil;
                self.maxInitFailureBlock = nil;
            }
        }
            break;
        case MMXConnectionStatusAuthenticationFailure: {
            if (self.maxInitFailureBlock) {
                self.maxInitFailureBlock(error);
            }
            self.maxInitSuccessBlock = nil;
            self.maxInitFailureBlock = nil;
        }
            break;
        case MMXConnectionStatusNotConnected: {
        }
            break;
        case MMXConnectionStatusConnecting: {
        }
            break;
        case MMXConnectionStatusConnected: {
            if (self.connectSuccessBlock) {
                self.connectSuccessBlock();
            }
            self.connectSuccessBlock = nil;
            self.connectFailureBlock = nil;
        }
            break;
        case MMXConnectionStatusDisconnected: {
            if (self.logOutSuccessBlock) {
                self.logOutSuccessBlock();
            }
            if (self.maxInitFailureBlock) {
                self.maxInitFailureBlock(error);
            }
            self.maxInitSuccessBlock = nil;
            self.maxInitFailureBlock = nil;
            
            if (self.connectFailureBlock) {
                self.connectFailureBlock(error);
            }
            self.connectSuccessBlock = nil;
            self.connectFailureBlock = nil;
            self.logOutSuccessBlock = nil;
            self.logOutFailureBlock = nil;
            if (error) {
                //				[[NSNotificationCenter defaultCenter] postNotificationName:MMXDidDisconnectNotification object:nil userInfo:@{MMXDisconnectErrorKey:error}];
            }
        }
            break;
        case MMXConnectionStatusFailed: {
            if (self.maxInitFailureBlock) {
                self.maxInitFailureBlock(error);
            }
            self.maxInitSuccessBlock = nil;
            self.maxInitFailureBlock = nil;
            
            if (self.connectFailureBlock) {
                self.connectFailureBlock(error);
            }
            if (self.logInFailureBlock) {
                self.logInFailureBlock(error);
            }
            self.connectSuccessBlock = nil;
            self.connectFailureBlock = nil;
            self.logInSuccessBlock = nil;
            self.logInFailureBlock = nil;
            
        }
            break;
        case MMXConnectionStatusReconnecting: {
        }
            break;
    }
}

// TODO: Delete me! This method is not used anymore. Double check.
- (void)client:(MMXClient *)client didReceivePubSubMessage:(MMXPubSubMessage *)message {
    MMXMessage *msg = [MMXMessage new];
    msg.messageType = MMXMessageTypeChannel;
    MMXChannel *channel = [MMXChannel channelWithName:message.topic.topicName summary:nil isPublic:YES publishPermissions:message.topic.publishPermissions];
    if (message.topic.inUserNameSpace) {
        channel.isPublic = NO;
        channel.ownerUserID = message.topic.nameSpace;
    } else {
        channel.isPublic = YES;
    }
    msg.channel = channel;
    msg.messageContent = message.metaData;
    msg.timestamp = message.timestamp;
    msg.messageID = message.messageID;
    [MMUser usersWithUserIDs:@[message.senderUserID.username] success:^(NSArray *users) {
        msg.sender = users.firstObject;
        [[NSNotificationCenter defaultCenter] postNotificationName:MMXDidReceiveMessageNotification
                                                            object:nil
                                                          userInfo:@{MMXMessageKey:msg}];
    } failure:^(NSError *error) {
        [[MMLogger sharedLogger] error:@"Failed to get users for Delivery Confirmation\n%@",error];
    }];
}

- (void)client:(MMXClient *)client didReceiveServerAckForMessageID:(NSString *)messageID invalidUsers:(NSSet *)invalidUsers{
    NSDictionary *messageBlockDict = [self.messageBlockQueue objectForKey:messageID];
    if (messageBlockDict) {
        MessageSuccessBlock success = messageBlockDict[MMXMessageSuccessBlockKey];
        if (success) {
            success(invalidUsers);
        }
        [self.messageBlockQueue removeObjectForKey:messageID];
    }
}

- (void)client:(MMXClient *)client didFailToSendMessage:(NSString *)messageID recipients:(NSArray *)recipients error:(NSError *)error {
    if (recipients && recipients.count) {
        NSArray *usernames = [recipients valueForKey:@"username"];
        [MMUser usersWithUserIDs:usernames success:^(NSArray *users) {
            [[NSNotificationCenter defaultCenter] postNotificationName:MMXMessageSendErrorNotification
                                                                object:nil
                                                              userInfo:@{MMXMessageSendErrorNSErrorKey:error,
                                                                         MMXMessageSendErrorMessageIDKey:messageID,
                                                                         MMXMessageSendErrorRecipientsKey:users}];
            
        } failure:^(NSError * error) {
            [[MMLogger sharedLogger] error:@"Failed to get users for Delivery Confirmation\n%@",error];
        }];
    }
}

- (void)client:(MMXClient *)client didDeliverMessage:(NSString *)messageID recipient:(id<MMXAddressable>)recipient {
    MMXInternalAddress *address = recipient.address;
    if (address) {
        //Converting to MMXUserID will handle any exscaping needed
        MMXUserID *userID = [MMXUserID userIDFromAddress:address];
        [MMUser usersWithUserIDs:@[userID.username] success:^(NSArray *users) {
            [[NSNotificationCenter defaultCenter] postNotificationName:MMXDidReceiveDeliveryConfirmationNotification
                                                                object:nil
                                                              userInfo:@{MMXRecipientKey:users.firstObject,
                                                                         MMXMessageIDKey:messageID}];
            
        } failure:^(NSError * error) {
            [[MMLogger sharedLogger] error:@"Failed to get users for Delivery Confirmation\n%@",error];
        }];
    }
}

+ (NSError *)notLoggedInError {
    NSError * error = [MMXClient errorWithTitle:@"Forbidden" message:@"You must log in to use this API." code:403];
    return error;
}

#pragma mark - Overriden getters

- (NSOperationQueue *)internalQueue {
    
    if (!_internalQueue) {
        _internalQueue = [[NSOperationQueue alloc] init];
        _internalQueue.maxConcurrentOperationCount = 1;
    }
    
    return _internalQueue;
}

#pragma mark - MMModule methods

+ (id <MMModule> __nonnull)sharedInstance {
    return [self sharedDelegate];
}

- (NSString *)name {
    // NOT USED
    return @"MagnetDelegate";
}

- (void)shouldInitializeWithConfiguration:(NSDictionary * __nonnull)configuration success:(void (^ __nonnull)(void))success failure:(void (^ __nonnull)(NSError * __nonnull))failure {
    if (nil == [MMUser currentUser]) {
        if (failure) {
            NSError * error = [MMXClient errorWithTitle:@"Not Authorized" message:@"You must be logged in to initialize MMX." code:401];
            failure(error);
        }
    } else {
        self.maxInitSuccessBlock = success;
        self.maxInitFailureBlock = failure;
        [[MMXClient sharedClient] updateConfiguration:configuration];
    }
}

- (void)didReceiveAppToken:(NSString * __nonnull)appToken appID:(NSString * __nonnull)appID deviceID:(NSString * __nonnull)deviceID {
    
    [[MMXClient sharedClient] updateDeviceID:deviceID appToken:appToken];
}

- (void)didReceiveUserToken:(NSString * __nonnull)userToken userID:(NSString * __nonnull)userID deviceID:(NSString * __nonnull)deviceID {
    
    [[MMXClient sharedClient] updateUsername:userID deviceID:deviceID userToken:userToken];
    if (![[MMXClient sharedClient] connect]) {
        if (self.maxInitFailureBlock) {
            NSError * error = [MMXClient errorWithTitle:@"Missing Information" message:@"MMX did not have enough information to connect to the server." code:500];
            self.maxInitFailureBlock(error);
        }
        self.maxInitSuccessBlock = nil;
        self.maxInitFailureBlock = nil;
    }
}

- (void)didInvalidateUserToken {
    [[MMXClient sharedClient] closeConnectionAndInvalidateUserData];
}

@end
