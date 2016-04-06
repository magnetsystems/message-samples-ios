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

#import "MMXChannel_Private.h"
#import "MMXConstants.h"
#import "MMXMessage_Private.h"
#import "MMXTopic_Private.h"
#import "MMXTopicSummary.h"
#import "MMXTopicSubscription.h"
#import "MMXUserID.h"
#import "MMXClient_Private.h"
#import "MMXPubSubManager_Private.h"
#import "MMXPubSubFetchRequest.h"
#import "MagnetDelegate.h"
#import "MMXInvite_Private.h"
#import "MMXInternalMessageAdaptor.h"
#import "MMXPubSubMessage_Private.h"
#import "MMXPubSubService.h"
#import "MMXMessage.h"
#import "MMXQueryChannel.h"
#import "MMXQueryChannelResponse.h"
#import "MMXRemoveSubscribersResponse.h"
#import "MMXAddSubscribersResponse.h"
#import "MMXChannelSummaryRequest.h"
#import "MMXSubscribeResponse.h"
#import "MMXChannelLookupKey.h"
#import "MMXWhitelistManager.h"

@import MagnetMaxCore;

@interface MMXPublishPermissionsContainer : NSObject <MMEnumAttributeContainer>

@end

@implementation MMXPublishPermissionsContainer

+ (NSDictionary *)mappings {
    return @{
             @"anyone" : @(MMXPublishPermissionsAnyone),
             @"owner" : @(MMXPublishPermissionsOwnerOnly),
             @"subscribers" : @(MMXPublishPermissionsSubscribers),
             };
}

@end

@implementation MMXChannel

+ (instancetype)channelWithName:(NSString *)name
                        summary:(NSString *)summary
                       isPublic:(BOOL)isPublic
             publishPermissions:(MMXPublishPermissions)publishPermissions {
    MMXChannel *channel = [MMXChannel new];
    channel.name = name;
    channel.summary = summary;
    channel.isPublic = isPublic;
    channel.publishPermissions = publishPermissions;
    return channel;
}

+ (void)allPublicChannelsWithLimit:(int)limit
                            offset:(int)offset
                           success:(void (^)(int totalCount, NSArray <MMXChannel *>*channels))success
                           failure:(void (^)(NSError *))failure {
    if ([MMXClient sharedClient].connectionStatus != MMXConnectionStatusAuthenticated) {
        if (failure) {
            failure([MagnetDelegate notLoggedInError]);
        }
        return;
    }
    
    NSDictionary *queryDict = @{@"operator" : @"AND",
                                @"limit" : @(limit),
                                @"offset" : @(offset),
                                @"type": @"global",
                                @"tags" : [NSNull null],
                                @"topicName": @{
                                        @"match": @"PREFIX",
                                        @"value": @""}};
    [MMXChannel findChannelsWithDictionary:queryDict success:success failure:failure];
}

+ (void)allPrivateChannelsWithLimit:(int)limit
                             offset:(int)offset
                            success:(void (^)(int totalCount, NSArray <MMXChannel *>*channels))success
                            failure:(void (^)(NSError *))failure {
    if ([MMXClient sharedClient].connectionStatus != MMXConnectionStatusAuthenticated) {
        if (failure) {
            failure([MagnetDelegate notLoggedInError]);
        }
        return;
    }
    
    NSDictionary *queryDict = @{@"operator" : @"AND",
                                @"limit" : @(limit),
                                @"offset" : @(offset),
                                @"type":@"personal",
                                @"tags" : [NSNull null],
                                @"topicName": @{
                                        @"match": @"PREFIX",
                                        @"value": @""}};
    [MMXChannel findChannelsWithDictionary:queryDict success:success failure:failure];
}


+ (void)channelForName:(NSString *)channelName
              isPublic:(BOOL)isPublic
               success:(void (^)(MMXChannel *))success
               failure:(void (^)(NSError *))failure {
    if ([MMXClient sharedClient].connectionStatus != MMXConnectionStatusAuthenticated) {
        if (failure) {
            failure([MagnetDelegate notLoggedInError]);
        }
        return;
    }
    if (channelName == nil || [channelName isEqualToString:@""]) {
        if (failure) {
            failure([MMXClient errorWithTitle:@"Invalid Search Parameter"
                                      message:@"You must pass at least one valid character to this method."
                                         code:500]);
        }
        return;
    }
    
    NSDictionary *queryDict = @{@"operator" : @"AND",
                                @"limit" : @(-1),
                                @"tags" : [NSNull null],
                                @"type":isPublic ? @"global" : @"personal",
                                @"topicName": @{
                                        @"match": @"EXACT",
                                        @"value": channelName}};
    [MMXChannel findChannelsWithDictionary:queryDict success:^(int count, NSArray *channelArray) {
        if (count == 1 && channelArray.count) {
            if (success) {
                MMXChannel *channel = channelArray.firstObject;
                success(channel);
            }
        } else if (failure) {
            if (failure) {
                failure([MMXClient errorWithTitle:@"Not Found"
                                          message:@"The requested channel was not found."
                                             code:404]);
            }
        }
    } failure:failure];
}

+ (void)channelsStartingWith:(NSString *)name
                       limit:(int)limit
                      offset:(int)offset
                     success:(void (^)(int, NSArray <MMXChannel *>*))success
                     failure:(void (^)(NSError *))failure {
    [self channelsStartingWith:name isPublic:YES limit:limit offset:offset success:success failure:failure];
    
}

+ (void)channelsStartingWith:(NSString *)name
                    isPublic:(BOOL)isPublic
                       limit:(int)limit
                      offset:(int)offset
                     success:(nullable void (^)(int totalCount, NSArray <MMXChannel *>*channels))success
                     failure:(nullable void (^)(NSError *error))failure {
    
    if ([MMXClient sharedClient].connectionStatus != MMXConnectionStatusAuthenticated) {
        if (failure) {
            failure([MagnetDelegate notLoggedInError]);
        }
        return;
    }
    if (name == nil || [name isEqualToString:@""]) {
        if (failure) {
            failure([MMXClient errorWithTitle:@"Invalid Search Parameter"
                                      message:@"You must pass at least one valid character to this method."
                                         code:500]);
        }
        return;
    }
    
    NSDictionary *queryDict = @{@"operator" : @"AND",
                                @"limit" : @(limit),
                                @"offset" : @(offset),
                                @"tags" : [NSNull null],
                                @"type":isPublic ? @"global" : @"personal",
                                @"topicName": @{
                                        @"match": @"PREFIX",
                                        @"value": name}};
    [MMXChannel findChannelsWithDictionary:queryDict success:success failure:failure];
}

+ (void)findByTags:(NSSet <NSString *>*)tags
             limit:(int)limit
            offset:(int)offset
           success:(void (^)(int, NSArray <MMXChannel *>*))success
           failure:(void (^)(NSError *))failure {
    
    if ([MMXClient sharedClient].connectionStatus != MMXConnectionStatusAuthenticated) {
        if (failure) {
            failure([MagnetDelegate notLoggedInError]);
        }
        return;
    }
    
    if (tags.count < 1) {
        if (failure) {
            NSError * error = [MMXClient errorWithTitle:@"Tags Empty" message:@"You must specify at least one tag." code:400];
            failure(error);
        }
        return;
    }
    
    for (id tag in tags) {
        if (![tag isKindOfClass:[NSString class]]) {
            if (failure) {
                NSError * error = [MMXClient errorWithTitle:@"Invalid Tags" message:@"Tags can only be strings." code:400];
                failure(error);
            }
            return;
        }
    }
    
    NSDictionary *queryDict = @{@"operator" : @"AND",
                                @"limit" : @(limit),
                                @"offset" : @(offset),
                                @"tags": @{@"match": @"EXACT",
                                           @"values": [tags allObjects]}};
    
    [MMXChannel findChannelsWithDictionary:queryDict success:success failure:failure];
}

+ (void)findChannelsWithDictionary:(NSDictionary *)queryDict
                           success:(void (^)(int count, NSArray *channels))success
                           failure:(void (^)(NSError *))failure {
    
    [[MMXClient sharedClient].pubsubManager queryTopicsWithDictionary:queryDict success:^(int totalCount, NSArray *topics) {
        [[MMXClient sharedClient].pubsubManager summaryOfTopics:topics since:nil until:nil success:^(NSArray *summaries) {
            [[MMXClient sharedClient].pubsubManager listSubscriptionsWithSuccess:^(NSArray *subscriptions) {
                NSArray *channelArray = [MMXChannel channelsFromTopics:topics summaries:summaries subscriptions:subscriptions];
                if (success) {
                    success(totalCount, channelArray);
                }
            } failure:^(NSError *error) {
                if (failure) {
                    failure(error);
                }
            }];
        } failure:^(NSError *error) {
            if (failure) {
                failure(error);
            }
        }];
    } failure:^(NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}

- (NSString *)iconID {
    NSMutableString *iconID = self.name.mutableCopy;
    if (!self.isPublic) {
        [iconID appendFormat:@"_%@",self.ownerUserID];
    }
    return iconID;
}

- (NSURL *)iconURL {
    NSString *accessToken = MMCoreConfiguration.serviceAdapter.HATToken;
    if (accessToken) {
        return [MMAttachmentService attachmentURL:[self iconID]
                                           userId:self.ownerUserID
                                       parameters:@{@"access_token" : accessToken}];
    }
    
    return nil;
}

- (void)setIconWithURL:(nullable NSURL *)url
               success:(nullable void (^)(NSURL *iconUrl))success
               failure:(nullable void (^)(NSError *error))failure {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSData *data = [NSData dataWithContentsOfURL:url];
        
        [self setIconWithData:data success:success failure:failure];
    });
}

- (void)setIconWithData:(nullable NSData *)data
                success:(nullable void (^)(NSURL *iconUrl))success
                failure:(nullable void (^)(NSError *error))failure {
    if (data.length <= 0) {
        NSError *error = [MMXClient errorWithTitle:@"Data Empty" message:@"NSData cannot be nil" code:500];
        failure(error);
        
        return;
    }
    
    MMAttachment *attachment = [[MMAttachment alloc] initWithData:data mimeType:@"image/png"];
    NSDictionary *metadata = @{@"file_id" : [self iconID]};
    [MMAttachmentService upload:@[attachment] metaData:metadata success:^{
        if (success) {
            success(self.iconURL);
        }
    } failure:failure];
}

- (void)tagsWithSuccess:(void (^)(NSSet <NSString *>*))success
                failure:(void (^)(NSError *))failure {
    if ([MMXClient sharedClient].connectionStatus != MMXConnectionStatusAuthenticated) {
        if (failure) {
            failure([MagnetDelegate notLoggedInError]);
        }
        return;
    }
    [[MMXClient sharedClient].pubsubManager tagsForTopic:[self asTopic] success:^(NSDate *lastTimeModified, NSArray *tags) {
        if (success) {
            success([NSSet setWithArray:tags]);
        }
    } failure:^(NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}

- (void)setTags:(NSSet <NSString *>*)tags
        success:(void (^)(void))success
        failure:(void (^)(NSError *))failure {
    
    if ([MMXClient sharedClient].connectionStatus != MMXConnectionStatusAuthenticated) {
        if (failure) {
            failure([MagnetDelegate notLoggedInError]);
        }
        
        return;
    }
    [[MMXClient sharedClient].pubsubManager setTags:[tags allObjects]
                                              topic:[self asTopic]
                                            success:^(BOOL successful) {
                                                if (success) {
                                                    success();
                                                }
                                            } failure:^(NSError *error) {
                                                if (failure) {
                                                    failure(error);
                                                }
                                            }];
}

+ (void)createWithName:(NSString *)name
               summary:(NSString *)summary
              isPublic:(BOOL)isPublic
    publishPermissions:(MMXPublishPermissions)publishPermissions
               success:(void (^)(MMXChannel *channel))success
               failure:(void (^)(NSError *))failure {
    
    if ([MMXClient sharedClient].connectionStatus != MMXConnectionStatusAuthenticated) {
        if (failure) {
            failure([MagnetDelegate notLoggedInError]);
        }
        
        return;
    }
    MMXChannel *channel = [MMXChannel channelWithName:name summary:summary isPublic:isPublic publishPermissions:publishPermissions];
    channel.ownerUserID = [MMUser currentUser].userID;
    MMXTopic *topic = [channel asTopic];
    [[MMXClient sharedClient].pubsubManager createTopic:topic success:^(BOOL successful) {
        [MMXChannel channelForName:channel.name isPublic:isPublic success:^(MMXChannel *channel) {
            if (success) {
                success(channel);
            }
        } failure:^(NSError *error) {
            if (failure) {
                failure(error);
            }
        }];
    } failure:^(NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}

+ (void)createWithName:(NSString *)name
               summary:(nullable NSString *)summary
              isPublic:(BOOL)isPublic
    publishPermissions:(MMXPublishPermissions)publishPermissions
           subscribers:(NSSet <MMUser *>*)subscribers
               success:(nullable void (^)(MMXChannel *channel))success
               failure:(nullable void (^)(NSError *error))failure {
    
    MMXChannel *channel = [MMXChannel channelWithName:name summary:summary isPublic:isPublic publishPermissions:publishPermissions];
    channel.ownerUserID = [MMUser currentUser].userID;
    channel.subscribers = [[subscribers valueForKey:@"userID"] allObjects];
    MMXPubSubService *pubSubService = [[MMXPubSubService alloc] init];
    MMCall *call = [pubSubService createChannel:channel success:^(MMXChannelResponse *response) {
        NSMutableArray *subscribers = [channel.subscribers mutableCopy];
        [subscribers addObject:[MMUser currentUser].userID];
        channel.subscribers = subscribers;
        channel.isSubscribed = YES;
        if (success) {
            success(channel);
        }
    } failure:^(NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
    [call executeInBackground:nil];
}

- (void)deleteWithSuccess:(void (^)(void))success
                  failure:(void (^)(NSError *))failure {
    
    if ([MMXClient sharedClient].connectionStatus != MMXConnectionStatusAuthenticated) {
        if (failure) {
            failure([MagnetDelegate notLoggedInError]);
        }
        
        return;
    }
    [[MMXClient sharedClient].pubsubManager deleteTopic:[self asTopic] success:^(BOOL successful) {
        if (success) {
            success();
        }
    } failure:^(NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}

- (void)subscribeWithSuccess:(void (^)(void))success
                     failure:(void (^)(NSError *))failure {
    
    if ([MMXClient sharedClient].connectionStatus != MMXConnectionStatusAuthenticated) {
        if (failure) {
            failure([MagnetDelegate notLoggedInError]);
        }
        
        return;
    }
    [[MMXClient sharedClient].pubsubManager subscribeToTopic:[self asTopic] device:nil success:^(MMXTopicSubscription *subscription) {
        self.isSubscribed = YES;
        if (success) {
            success();
        }
    } failure:^(NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}

- (void)unSubscribeWithSuccess:(void (^)(void))success
                       failure:(void (^)(NSError *))failure {
    
    if ([MMXClient sharedClient].connectionStatus != MMXConnectionStatusAuthenticated) {
        if (failure) {
            failure([MagnetDelegate notLoggedInError]);
        }
        
        return;
    }
    [[MMXClient sharedClient].pubsubManager unsubscribeFromTopic:[self asTopic] subscriptionID:nil success:^(BOOL successful) {
        self.isSubscribed = NO;
        if (success) {
            success();
        }
    } failure:^(NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}

+ (void)subscribedChannelsWithSuccess:(void (^)(NSArray <MMXChannel *>*))success
                              failure:(void (^)(NSError *))failure {
    if ([MMXClient sharedClient].connectionStatus != MMXConnectionStatusAuthenticated) {
        if (failure) {
            failure([MagnetDelegate notLoggedInError]);
        }
        return;
    }
    [[MMXClient sharedClient].pubsubManager listSubscriptionsWithSuccess:^(NSArray *subscriptions) {
        [[MMXClient sharedClient].pubsubManager topicsFromTopicSubscriptions:subscriptions success:^(NSArray * topics) {
            [[MMXClient sharedClient].pubsubManager summaryOfTopics:topics since:nil until:nil success:^(NSArray *summaries) {
                NSArray *channelArray = [MMXChannel channelsFromTopics:topics summaries:summaries subscriptions:subscriptions];
                if (success) {
                    success(channelArray);
                }
            } failure:^(NSError *error) {
                if (failure) {
                    failure(error);
                }
            }];
        } failure:^(NSError *error) {
            if (failure) {
                failure(error);
            }
        }];
    } failure:^(NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}

- (void)subscribersWithLimit:(int)limit
                      offset:(int)offset
                     success:(void (^)(int totalCount, NSArray <MMUser *>*subscribers))success
                     failure:(void (^)(NSError *error))failure {
    if ([MMXClient sharedClient].connectionStatus != MMXConnectionStatusAuthenticated) {
        if (failure) {
            failure([MagnetDelegate notLoggedInError]);
        }
        return;
    }
    [[MMXClient sharedClient].pubsubManager subscribersForTopic:[self asTopic] limit:limit offset:offset success:^(int totalCount, NSArray *subscribers) {
        if (success) {
            success(totalCount, subscribers);
        }
    } failure:^(NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}

- (void)publish:(NSDictionary <NSString *,NSString *>*)messageContent
        success:(void (^)(MMXMessage *))success
        failure:(void (^)(NSError *))failure {
    
    NSString *messageID = [[MMXClient sharedClient] generateMessageID];
    MMXPubSubMessage *msg = [MMXPubSubMessage pubSubMessageToTopic:[self asTopic] content:nil metaData:messageContent];
    msg.timestamp = [NSDate date];
    msg.messageID = messageID;
    if ([MMXClient sharedClient].connectionStatus != MMXConnectionStatusAuthenticated) {
        if (failure) {
            failure([MMXChannel notNotLoggedInAndNoUserError]);
        }
        return;
    }
    [[MMXClient sharedClient].pubsubManager publishPubSubMessage:msg success:^(BOOL successful, NSString *messageID) {
        if (success) {
            MMXMessage *message = [MMXMessage messageToChannel:self.copy messageContent:messageContent];
            message.sender = [MMUser currentUser];
            message.timestamp = msg.timestamp;
            message.messageID = messageID;
            message.channel = self.copy;
            success(message);
        }
    } failure:^(NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}

- (void)publishMessage:(MMXMessage *)message
               success:(nullable void (^)())success
               failure:(nullable void (^)(NSError *error))failure {
    
    // Ignore the recipients
    message.recipients = [NSSet set];
    message.channel = self;
    [message sendWithSuccess:^(NSSet<NSString *> * _Nonnull __unused invalidUsers) {
        if (success) {
            success();
        }
    } failure:^(NSError * _Nonnull error) {
        if (failure) {
            failure(error);
        }
    }];
}

- (void)messagesBetweenStartDate:(NSDate *)startDate
                         endDate:(NSDate *)endDate
                           limit:(int)limit
                          offset:(int)offset
                       ascending:(BOOL)ascending
                         success:(void (^)(int, NSArray <MMXMessage *>*))success
                         failure:(void (^)(NSError *))failure {
    if ([MMXClient sharedClient].connectionStatus != MMXConnectionStatusAuthenticated) {
        if (failure) {
            failure([MagnetDelegate notLoggedInError]);
        }
        
        return;
    }
    MMXPubSubFetchRequest * fetch = [[MMXPubSubFetchRequest alloc] init];
    MMXTopic *topic = [MMXTopic topicWithName:self.name];
    if (!self.isPublic) {
        topic.nameSpace = self.ownerUserID;
    }
    fetch.topic = topic;
    fetch.since = startDate;
    fetch.until = endDate;
    fetch.maxItems = limit;
    fetch.offset = offset;
    fetch.ascending = ascending;
    [[MMXClient sharedClient].pubsubManager fetchItems:fetch success:^(NSArray *messages) {
        if (messages && messages.count) {
            NSMutableArray *channelMessageArray = [[NSMutableArray alloc] initWithCapacity:messages.count];
            NSArray *usernames = [[messages valueForKey:@"senderUserID"] valueForKey:@"username"];
            if (usernames && usernames.count) {
                [MMUser usersWithUserIDs:usernames success:^(NSArray *users) {
                    for (MMXPubSubMessage *pubMsg in messages) {
                        NSPredicate *usernamePredicate = [NSPredicate predicateWithFormat:@"userID == %@",pubMsg.senderUserID.username];
                        MMUser *sender = [users filteredArrayUsingPredicate:usernamePredicate].firstObject;
                        MMXMessage *channelMessage = [MMXMessage messageFromPubSubMessage:pubMsg sender:sender];
                        [channelMessageArray addObject:channelMessage];
                    }
                    [[MMXClient sharedClient].pubsubManager summaryOfTopics:@[topic] since:startDate until:endDate success:^(NSArray *summaries) {
                        int count = 0;
                        if (summaries.count) {
                            MMXTopicSummary *sum = summaries[0];
                            count =  sum.numItemsPublished;
                        }
                        if (success) {
                            success(count, channelMessageArray);
                        }
                    } failure:^(NSError *error) {
                        if (failure) {
                            failure(error);
                        }
                    }];
                } failure:^(NSError * error) {
                    [[MMLogger sharedLogger] error:@"Failed to get users for MMXMessages from Channels\n%@",error];
                }];
                return;
            }
        } else {
            if (success) {
                success(0, @[]);
            }
        }
    } failure:^(NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}

- (void)inviteUser:(MMUser *)user
          comments:(NSString *)comments
           success:(void (^)(MMXInvite *))success
           failure:(void (^)(NSError *))failure {
    if ([MMXClient sharedClient].connectionStatus != MMXConnectionStatusAuthenticated) {
        if (failure) {
            failure([MagnetDelegate notLoggedInError]);
        }
        return;
    }
    if (nil == self.ownerUserID || [self.ownerUserID isEqualToString:@""]) {
        if (failure) {
            NSError * error = [MMXClient errorWithTitle:@"Invalid Channel Invite" message:@"It looks like you are trying to send an invite from an invalid channel. Please user the channelForName:isPublic:success:failure API to get the valid channel object." code:500];
            failure(error);
        }
        return;
    }
    
    void (^invitationBlock)() = ^{
        MMXInternalMessageAdaptor *msg = [MMXInternalMessageAdaptor inviteMessageToUser:user forChannel:self.copy comments:comments];
        NSString *messageID = [[MagnetDelegate sharedDelegate] sendInternalMessageFormat:msg success:^(NSSet *invalidUsers){
            if (invalidUsers.count == 1) {
                if (failure) {
                    NSError *error = [MMXClient errorWithTitle:@"Invalid User" message:@"The user you are trying to send a message to does not exist or does not have a valid device associated with them." code:500];
                    failure(error);
                }
            } else {
                if (success) {
                    MMXInvite *invite = [MMXInvite new];
                    invite.comments = comments;
                    invite.channel = self.copy;
                    invite.sender = [MMUser currentUser];
                    invite.timestamp = [NSDate date];
                    success(invite);
                }
            }
        } failure:^(NSError *error) {
            if (failure) {
                failure(error);
            }
        }];
    };
    
    if (!self.isPublic) {
        [[MMXWhitelistManager sharedManager] addUsersToWhitelist:@[user] channel:self.copy completion:^(NSError *error) {
            if (error != nil) {
                if (failure) {
                    failure(error);
                }
                return;
            }
            invitationBlock();
        }];
    } else {
        invitationBlock();
    }
    return;
}

#pragma mark - Channel Owner Methods

// Owner only!
- (void)addSubscribers:(NSArray <MMUser *> *)subscribers
               success:(nullable void (^)(NSSet <NSString *>*invalidUsers))success
               failure:(nullable void (^)(NSError *error))failure {
    if (subscribers.count == 0) {
        NSError *error = [MMXClient errorWithTitle:@"No Subscribers" message:@"No Subscribers" code:403];
        if (failure) {
            failure(error);
        }
        
        return;
    }
    
    NSMutableArray *invalidUsers = [NSMutableArray new];
    NSMutableArray *currentUsers = [NSMutableArray new];
    if (self.subscribers) {
        [currentUsers addObjectsFromArray:self.subscribers];
    }
    
    MMXPubSubService *pubSubService = [[MMXPubSubService alloc] init];
    MMXChannel *channel = [[MMXChannel alloc] initWithDictionary:self.dictionaryValue error:nil];
    
    channel.subscribers = [subscribers valueForKey:@"userID"];
    
    MMCall *call = [pubSubService addSubscribersToChannel:channel.name body:channel success:^(MMXAddSubscribersResponse *response) {
        
        for (MMUser *user in subscribers) {
            MMXSubscribeResponse *userResponse  = response.subscribeResponse[user.userID];
            NSInteger code = NSIntegerMax;
            
            if (userResponse) {
                code = userResponse.code;
            }
            
            if (code == 0) {
                [currentUsers addObject:user.userID];
            } else {
                [invalidUsers addObject:user.userID];
            }
        }
        self.subscribers = currentUsers;
        
        if (success) {
            success([NSSet setWithArray:invalidUsers]);
        }
    } failure: failure];
    
    [call executeInBackground:nil];
}

// Owner only!
- (void)removeSubscribers:(NSArray <MMUser *> *)subscribers
                  success:(nullable void (^)(NSSet <NSString *>*invalidUsers))success
                  failure:(nullable void (^)(NSError *error))failure {
    if (subscribers.count == 0) {
        NSError *error = [MMXClient errorWithTitle:@"No Subscribers" message:@"No Subscribers" code:403];
        if (failure) {
            failure(error);
        }
        
        return;
    }
    
    NSMutableArray *invalidUsers = [NSMutableArray new];
    NSMutableArray *currentUsers = [NSMutableArray new];
    if (self.subscribers) {
        [currentUsers addObjectsFromArray:self.subscribers];
    }
    
    MMXPubSubService *pubSubService = [[MMXPubSubService alloc] init];
    MMXChannel *channel = [[MMXChannel alloc] initWithDictionary:self.dictionaryValue error:nil];
    
    channel.subscribers = [subscribers valueForKey:@"userID"];
    
    MMCall *call = [pubSubService removeSubscribersFromChannel:channel.name body:channel success:^(MMXRemoveSubscribersResponse *response) {
        
        for (MMUser *user in subscribers) {
            MMXSubscribeResponse *userResponse  = response.subscribeResponse[user.userID];
            NSInteger code = NSIntegerMax;
            
            if (userResponse) {
                code = userResponse.code;
            }
            
            if (code == 0) {
                [currentUsers removeObject:user.userID];
            } else {
                [invalidUsers addObject:user.userID];
            }
        }
        self.subscribers = currentUsers;
        
        if (success) {
            success([NSSet setWithArray:invalidUsers]);
        }
    } failure: failure];
    
    [call executeInBackground:nil];
}

+ (void)findChannelsBySubscribers:(NSArray <MMUser *> *)subscribers
                        matchType:(MMXMatchType)matchType
                          success:(nullable void (^)(NSArray <MMXChannel *>*channels))success
                          failure:(nullable void (^)(NSError *error))failure {
    if (subscribers.count == 0) {
        NSError *error = [MMXClient errorWithTitle:@"No Subscribers" message:@"No Subscribers" code:403];
        if (failure) {
            failure(error);
        }
        
        return;
    }
    
    MMXQueryChannel *queryChannel = [[MMXQueryChannel alloc] init];
    queryChannel.subscribers = [subscribers valueForKey:@"userID"];
    queryChannel.matchFilter = matchType;
    MMXPubSubService *pubSubService = [[MMXPubSubService alloc] init];
    MMCall *call = [pubSubService queryChannels:queryChannel success:^(MMXQueryChannelResponse *response) {
        if (success) {
            success(response.toMMXChannels);
        }
    } failure:failure];
    
    [call executeInBackground:nil];
}

+ (void)channelDetails:(NSArray<MMXChannel *>*)channels
      numberOfMessages:(NSInteger)numberOfMessages
    numberOfSubcribers:(NSInteger)numberOfSubcribers
               success:(nullable void (^)(NSArray <MMXChannelDetailResponse *>*detailsForChannels))success
               failure:(nullable void (^)(NSError *error))failure {
    if (channels.count == 0) {
        NSError *error = [MMXClient errorWithTitle:@"No channels" message:@"No channels" code:403];
        if (failure) {
            failure(error);
        }
        
        return;
    }
    
    MMXChannelSummaryRequest *channelSummary = [[MMXChannelSummaryRequest alloc] init];
    channelSummary.numOfMessages = numberOfMessages;
    channelSummary.numOfSubcribers = numberOfSubcribers;
    NSMutableArray *channelRequestObjects = [NSMutableArray new];
    NSMutableDictionary *channelMap = [NSMutableDictionary new];
    
    for (MMXChannel *channel in channels) {
        [channelMap setObject:channel forKey:channel.channelID];
        MMXChannelLookupKey *channelRequestObject = [[MMXChannelLookupKey alloc] init];
        channelRequestObject.ownerUserID = channel.ownerUserID;
        channelRequestObject.privateChannel = channel.privateChannel;
        channelRequestObject.channelName = channel.name;
        [channelRequestObjects addObject:channelRequestObject];
    }
    channelSummary.channelIds = channelRequestObjects;
    
    MMXPubSubService *pubSubService = [[MMXPubSubService alloc] init];
    MMCall *call = [pubSubService getSummary:channelSummary
                                     success:^(NSArray<MMXChannelDetailResponse *>*response) {
                                         for (MMXChannelDetailResponse *details in response) {
                                             NSString *channelName = details.channelName;
                                             // TODO: Use details.isPublic instead when it's implemented on the server
                                             BOOL isPublic = (details.userID == nil);
                                             if (!isPublic) {
                                                 channelName = [NSString stringWithFormat:@"%@#%@", details.userID, details.channelName];
                                             }
                                             details.channel = [channelMap objectForKey:channelName];
                                         }
                                         if (success) {
                                             success(response);
                                         }
                                     } failure:failure];
    
    [call executeInBackground:nil];
}

#pragma mark - Errors
+ (NSError *)notNotLoggedInAndNoUserError {
    NSError * error = [MMXClient errorWithTitle:@"Forbidden" message:@"You are not logged in and there is no current user." code:403];
    return error;
}

#pragma mark - Conversion Helpers

+ (NSArray *)topicsFromSubscriptions:(NSArray *)subscriptions {
    NSMutableArray *topics = [NSMutableArray arrayWithCapacity:subscriptions.count];
    for (MMXTopicSubscription *sub in subscriptions) {
        [topics addObject:sub.topic];
    }
    return topics.copy;
}

+ (NSArray *)channelsFromTopics:(NSArray *)topics summaries:(NSArray *)summaries subscriptions:(NSArray *)subscriptions {
    NSMutableDictionary *channelDict = [NSMutableDictionary dictionaryWithCapacity:topics.count];
    for (MMXTopic *topic in topics) {
        MMXChannel *channel = [MMXChannel channelWithName:topic.topicName summary:topic.topicDescription isPublic:!topic.inUserNameSpace publishPermissions:topic.publishPermissions];
        channel.ownerUserID = topic.topicCreator.username;
        channel.isPublic = !topic.inUserNameSpace;
        channel.creationDate = topic.creationDate;
        [channelDict setObject:channel forKey:[MMXChannel channelKeyFromTopic:topic]];
    }
    for (MMXTopicSummary *sum in summaries) {
        MMXChannel *channel = channelDict[[MMXChannel channelKeyFromTopic:sum.topic]];
        if (channel) {
            channel.numberOfMessages = sum.numItemsPublished;
            channel.lastTimeActive = sum.lastTimePublishedTo;
        }
    }
    for (MMXTopicSubscription *sub in subscriptions) {
        MMXChannel *channel = channelDict[[MMXChannel channelKeyFromTopic:sub.topic]];
        if (channel) {
            channel.isSubscribed = sub.isSubscribed;
        }
    }
    NSMutableArray *channelArray = [NSMutableArray arrayWithCapacity:topics.count];
    for (MMXTopic *topic in topics) {
        MMXChannel *chan = [channelDict objectForKey:[MMXChannel channelKeyFromTopic:topic]];
        if (chan) {
            [channelArray addObject:chan];
        }
        
    }
    return channelArray.copy;
}

+ (NSString *)channelKeyFromTopic:(MMXTopic *)topic {
    NSString *topicKey = [[NSString stringWithFormat:@"%@%@", topic.topicName, topic.nameSpace] lowercaseString];
    return topicKey;
}

- (MMXTopic *)asTopic {
    MMXTopic *newTopic = [MMXTopic topicWithName:self.name];
    newTopic.topicDescription = self.summary;
    newTopic.publishPermissions = self.publishPermissions;
    if (!self.isPublic) {
        if (self.ownerUserID) {
            newTopic.nameSpace = self.ownerUserID;
        } else {
            return nil;
        }
    }
    return newTopic;
}

#pragma mark - Override Getters

- (NSString *)channelID {
    NSString *channelName = self.name;
    if (!self.isPublic) {
        channelName = [NSString stringWithFormat:@"%@#%@", self.ownerUserID, channelName];
    }
    
    return channelName;
}

- (NSDate *)lastTimeActive {
    return _lastTimeActive ?: self.creationDate;
}

- (BOOL)canPublish {
    switch (self.publishPermissions) {
        case MMXPublishPermissionsAnyone:
            return YES;
        case MMXPublishPermissionsSubscribers:
            return [self isOwner] || self.isSubscribed;
        case MMXPublishPermissionsOwnerOnly:
            return [self isOwner];
        default:
            break;
    }
}

- (BOOL)isOwner {
    return [[MMUser currentUser].userID.lowercaseString isEqualToString:self.ownerUserID.lowercaseString];
}

#pragma mark - Equality

- (BOOL)isEqual:(id)other {
    if (other == self)
        return YES;
    if (!other || ![[other class] isEqual:[self class]])
        return NO;
    
    return [self isEqualToChannel:other];
}

- (BOOL)isEqualToChannel:(MMXChannel *)channel{
    if (self == channel)
        return YES;
    if (channel == nil)
        return NO;
    if (![self.name.lowercaseString isEqualToString:channel.name.lowercaseString])
        return NO;
    if (self.isPublic != channel.isPublic)
        return NO;
    if (!self.isPublic && !channel.isPublic && ![self.ownerUserID.lowercaseString isEqualToString:channel.ownerUserID.lowercaseString])
        return NO;
    return YES;
}

- (NSUInteger)hash {
    NSUInteger hash = [self.name hash];
    if (!self.isPublic) {
        hash = hash * 31u + [self.ownerUserID hash];
    }
    return hash;
}

#pragma mark - MMModel methods

- (BOOL)privateChannel {
    return !self.isPublic;
}

+ (NSDictionary *)attributeMappings {
    NSDictionary *dictionary = @{
                                 @"name": @"channelName",
                                 @"privateChannel": @"privateChannel",
                                 @"summary": @"description",
                                 @"publishPermissions": @"publishPermission",
                                 @"subscribers": @"subscribers",
                                 };
    //    NSMutableDictionary *attributeMappings = [[super attributeMappings] mutableCopy];
    //    [attributeMappings addEntriesFromDictionary:dictionary];
    
    //    return attributeMappings;
    return dictionary;
}

+ (NSDictionary *)listAttributeTypes {
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithDictionary:@{
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
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithDictionary:@{ @"publishPermissions" : MMXPublishPermissionsContainer.class}];
    [dictionary addEntriesFromDictionary:[super enumAttributeTypes]];
    return dictionary;
}

+ (NSArray *)charAttributes {
    NSMutableArray *array = [NSMutableArray arrayWithArray:@[
                                                             ]];
    [array addObjectsFromArray:[super charAttributes]];
    return array;
}

@end
