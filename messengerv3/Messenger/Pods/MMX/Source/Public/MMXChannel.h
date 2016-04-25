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
#import "MMXPublishPermissionsEnum.h"
#import "MMXMatchType.h"
#import "MMXChannelDetailResponse.h"

@import MagnetMaxCore;
@class MMUser;
@class MMXMessage;
@class MMXInvite;

NS_ASSUME_NONNULL_BEGIN
@interface MMXChannel : MMModel

/**
 * The unique identifer for the channel.
 */
@property (nonatomic, readonly) NSString *channelID;

/**
 *  Is the topic public?
 */
@property (nonatomic, assign) BOOL isPublic;

/**
 *  The unique name of the channel.
 */
@property (nonatomic, copy, readonly) NSString *name;

/**
 *  An optional summary of the channel.
 */
@property (nonatomic, copy, nullable) NSString *summary;

/**
 *  The required permissions needed to publish to this channel.
 */
@property (nonatomic, readonly) MMXPublishPermissions publishPermissions;

/**
 *  BOOL letting you know if the current user can publish to the channel.
 */
@property (nonatomic, readonly) BOOL canPublish;

/**
 *  The userID for the owner/creator of the channel.
 */
@property (nonatomic, readonly) NSString *ownerUserID;

/**
 *  The date the channel was created.
 */
@property (nonatomic, readonly) NSDate * creationDate;

/**
 *  The total number of messages that have been posted to the channel.
 */
@property (nonatomic, readonly) int numberOfMessages;

/**
 *  The timestamp of the most recent message published to the channel.
 */
@property (nonatomic, readonly) NSDate *lastTimeActive;

/**
 *  BOOL letting you know if the current user is subscribed to the channel.
 */
@property (nonatomic, readonly) BOOL isSubscribed;

/**
 * Is the channel muted?
 */
@property (nonatomic, readonly) BOOL isMuted;

/**
 * If the channel is muted (isMuted = YES), until what date is the channel muted?
 */
@property (nonatomic, readonly) NSDate *mutedUntil;

/**
 *  Method used to get existing channels.
 *
 *  @param limit	The max number of items you want returned.
 *  @param offset	The offset into the results list. Used for pagination.
 *  @param success  Block with the number of channels that match the query and a NSArray of MMXChannels that match the criteria.
 *  @param failure  Block with an NSError with details about the call failure.
 */
+ (void)allPublicChannelsWithLimit:(int)limit
                            offset:(int)offset
                           success:(nullable void (^)(int totalCount, NSArray <MMXChannel *>*channels))success
                           failure:(nullable void (^)(NSError *error))failure;

/**
 *  Method used to get private channels created by the current user.
 *
 *  @param limit	The max number of items you want returned.
 *  @param offset	The offset into the results list. Used for pagination.
 *  @param success  Block with the number of channels that match the query and a NSArray of MMXChannels that match the criteria.
 *  @param failure  Block with an NSError with details about the call failure.
 */
+ (void)allPrivateChannelsWithLimit:(int)limit
                             offset:(int)offset
                            success:(nullable void (^)(int totalCount, NSArray <MMXChannel *>*channels))success
                            failure:(nullable void (^)(NSError *error))failure;

/**
 *  Get a channel object by name
 *
 *  @param channelName	The exact name of the channel you are searching for.
 *  @param isPublic		Set to YES if it is a public channel. Will only return private channels created by the logged in user.
 *  @param success		Block with the channel with the name specified if it exists.
 *  @param failure		Block with an NSError with details about the call failure.
 */
+ (void)channelForName:(NSString *)channelName
              isPublic:(BOOL)isPublic
               success:(nullable void (^)(MMXChannel *channel))success
               failure:(nullable void (^)(NSError *error))failure;

/**
 *  Method used to discover existing channels by name
 *
 *  @param name     The begining of the channel name you are searching for.
 *  @param limit	The max number of items you want returned.
 *  @param offset	The offset into the results list. Used for pagination.
 *  @param success  Block with the number of channels that match the query and a NSArray of MMXChannels that match the criteria.
 *  @param failure  Block with an NSError with details about the call failure.

 *  @deprecated This method has been deprecated. Use -channelsStartingWith:isPublic:limit:offset:success:failure: instead.
 */
+ (void)channelsStartingWith:(NSString *)name
                       limit:(int)limit
                      offset:(int)offset
                     success:(nullable void (^)(int totalCount, NSArray <MMXChannel *>*channels))success
                     failure:(nullable void (^)(NSError *error))failure DEPRECATED_ATTRIBUTE;

/**
 *  Method used to discover existing channels by name
 *
 *  @param name     The begining of the channel name you are searching for.
 *  @param isPublic	Set to YES if it is a public channel. Will only return private channels created by the logged in user.
 *  @param limit	The max number of items you want returned.
 *  @param offset	The offset into the results list. Used for pagination.
 *  @param success  Block with the number of channels that match the query and a NSArray of MMXChannels that match the criteria.
 *  @param failure  Block with an NSError with details about the call failure.
 */
+ (void)channelsStartingWith:(NSString *)name
                    isPublic:(BOOL)isPublic
                       limit:(int)limit
                      offset:(int)offset
                     success:(nullable void (^)(int totalCount, NSArray <MMXChannel *>*channels))success
                     failure:(nullable void (^)(NSError *error))failure;

/**
 *  Method used to discover existing channels that have any of the tags provided
 *
 *  @param tags		A set of unique tags
 *  @param limit	The max number of items you want returned.
 *  @param offset	The offset into the results list. Used for pagination.
 *  @param success  Block with the number of channels that match the query and a NSArray of MMXChannels that match the criteria.
 *  @param failure  Block with a NSError with details about the call failure.
 */
+ (void)findByTags:(NSSet <NSString *>*)tags
             limit:(int)limit
            offset:(int)offset
           success:(nullable void (^)(int totalCount, NSArray <MMXChannel *>*channels))success
           failure:(nullable void (^)(NSError *error))failure;

/**
 *  Get tags for this channel
 *
 *  @param success - Block with a NSSet of tags(NSStrings)
 *  @param failure - Block with a NSError with details about the call failure.
 */
- (void)tagsWithSuccess:(nullable void (^)(NSSet <NSString *>*tags))success
                failure:(nullable void (^)(NSError * error))failure;

/**
 *  Set tags for a specific channel. This will overwrite ALL existing tags for the chanel.
 *	This can be used to delete tags by passing in the sub-set of existing tags that you want to keep.
 *
 *  @param tags    - NSSet of tags(NSStrings).
 *  @param success - Block called if operation is successful.
 *  @param failure - Block with a NSError with details about the call failure.
 */
- (void)setTags:(NSSet <NSString *>*)tags
        success:(nullable void (^)(void))success
        failure:(nullable void (^)(NSError *error))failure;

/**
 *  Method to create a new channel.
 *
 *  @param name					The name you want for the new channel must be unique. Cannot have spaces. The valid character set is alphanumeric plus period, dash and underscore. .-_
 *  @param summary				The summary you want for the channel. (Used to give other users a better idea about the purpose of the channel).
 *  @param isPublic				Set to YES if you want the channel to be discoverable by other users.
 *  @param publishPermissions	Permissions level required to be able to post; Owner/Creator only, Subscribers, Anyone. Owner can always publish.
 *  @param success				Block called if operation is successful.
 *  @param failure				Block with an NSError with details about the call failure.
 */
+ (void)createWithName:(NSString *)name
               summary:(nullable NSString *)summary
              isPublic:(BOOL)isPublic
    publishPermissions:(MMXPublishPermissions)publishPermissions
               success:(nullable void (^)(MMXChannel *channel))success
               failure:(nullable void (^)(NSError *error))failure;

/**
 *  Method to create a new channel.
 *
 *  @param name					The name you want for the new channel must be unique. Cannot have spaces. The valid character set is alphanumeric plus period, dash and underscore. .-_
 *  @param summary				The summary you want for the channel. (Used to give other users a better idea about the purpose of the channel).
 *  @param isPublic				Set to YES if you want the channel to be discoverable by other users.
 *  @param publishPermissions	Permissions level required to be able to post; Owner/Creator only, Subscribers, Anyone. Owner can always publish.
 *  @param subscribers          The set of users to auto-subscribe.
 *  @param success				Block called if operation is successful.
 *  @param failure				Block with an NSError with details about the call failure.
 */
+ (void)createWithName:(NSString *)name
               summary:(nullable NSString *)summary
              isPublic:(BOOL)isPublic
    publishPermissions:(MMXPublishPermissions)publishPermissions
           subscribers:(nullable NSSet <MMUser *>*)subscribers
               success:(nullable void (^)(MMXChannel *channel))success
               failure:(nullable void (^)(NSError *error))failure;

/**
 *  Method to create a new channel.
 *
 *  @param name					The name you want for the new channel must be unique. Cannot have spaces. The valid character set is alphanumeric plus period, dash and underscore. .-_
 *  @param summary				The summary you want for the channel. (Used to give other users a better idea about the purpose of the channel).
 *  @param isPublic				Set to YES if you want the channel to be discoverable by other users.
 *  @param publishPermissions	Permissions level required to be able to post; Owner/Creator only, Subscribers, Anyone. Owner can always publish.
 *  @param subscribers          The set of users to auto-subscribe.
 *  @param pushConfigName       Optional push config name.
 *  @param success				Block called if operation is successful.
 *  @param failure				Block with an NSError with details about the call failure.
 */
+ (void)createWithName:(NSString *)name
               summary:(nullable NSString *)summary
              isPublic:(BOOL)isPublic
    publishPermissions:(MMXPublishPermissions)publishPermissions
           subscribers:(nullable NSSet <MMUser *>*)subscribers
        pushConfigName:(nullable NSString *)pushConfigName
               success:(nullable void (^)(MMXChannel *channel))success
               failure:(nullable void (^)(NSError *error))failure;

/**
 *  Method to delete an existing new channel.
 *	Current user must be the owner of the channel to delete it.
 *
 *  @param success - Block called if operation is successful.
 *  @param failure - Block with an NSError with details about the call failure.
 */
- (void)deleteWithSuccess:(nullable void (^)(void))success
                  failure:(nullable void (^)(NSError *error))failure;

/**
 *  Method to subscribe to an existing channel.
 *
 *  @param success - Block called if operation is successful.
 *  @param failure - Block with an NSError with details about the call failure.
 */
- (void)subscribeWithSuccess:(nullable void (^)(void))success
                     failure:(nullable void (^)(NSError *error))failure;

/**
 *  Method to unsubscribe to an existing channel.
 *
 *  @param success - Block called if operation is successful.
 *  @param failure - Block with an NSError with details about the call failure.
 */
- (void)unSubscribeWithSuccess:(nullable void (^)(void))success
                       failure:(nullable void (^)(NSError *error))failure;


/**
 *  Get all channels the current user is subscribed to
 *
 *  @param success Block with a NSArray of channels
 *  @param failure - Block with an NSError with details about the call failure.
 */
+ (void)subscribedChannelsWithSuccess:(nullable void (^)(NSArray <MMXChannel *>*channels))success
                              failure:(nullable void (^)(NSError *error))failure;

/**
 *  Get the subscribers for a channel
 *	Must be subscribed to the channel to use this API
 *
 *  @param limit	The max number of items you want returned.
 *  @param offset	The offset into the results list. Used for pagination.
 *  @param success	Block with the total count of subscribers and a NSSet of the subscribers(MMUser objects)
 *  @param failure	Block with an NSError with details about the call failure.
 */
- (void)subscribersWithLimit:(int)limit
                      offset:(int)offset
                     success:(nullable void (^)(int totalCount, NSArray <MMUser *>*subscribers))success
                     failure:(nullable void (^)(NSError *error))failure;

/**
 *  Method to publish to a channel.
 *
 *  @param messageContent The content you want to publish
 *  @param success		  Block with the published message
 *  @param failure		  Block with an NSError with details about the call failure.
 */
- (void)publish:(NSDictionary <NSString *,NSString *>*)messageContent
        success:(nullable void (^)(MMXMessage *message))success
        failure:(nullable void (^)(NSError *error))failure;

/**
 *  Method to publish to a channel.
 *
 *  @param message  The message you want to publish
 *  @param success  Block with the published message
 *  @param failure  Block with an NSError with details about the call failure.
 */
- (void)publishMessage:(MMXMessage *)message
               success:(nullable void (^)())success
               failure:(nullable void (^)(NSError *error))failure;

/**
 *  Get messages previous posted to this channel.
 *
 *  @param startDate    The earliest date you would like messages from.
 *  @param endDate      The latest date you would like messages until. Defaults to now.
 *  @param limit		The max number of items you want returned.
 *  @param offset		The offset into the results list. Used for pagination.
 *  @param ascending	The sort order(by date) for the messages returned.
 *  @param success		The total available messages and a NSArray of MMXMessages
 *  @param failure		Block with an NSError with details about the call failure.
 */
- (void)messagesBetweenStartDate:(nullable NSDate *)startDate
                         endDate:(nullable NSDate *)endDate
                           limit:(int)limit
                          offset:(int)offset
                       ascending:(BOOL)ascending
                         success:(nullable void (^)(int totalCount, NSArray <MMXMessage *>*messages))success
                         failure:(nullable void (^)(NSError *error))failure;

/**
 *  Invite a user to the channel
 *
 *  @param user			The MMUser object for the user you want to invite
 *  @param comments		An optional message telling the user why you want them to join the channel
 *  @param success		Block with the MMXInvite object that was sent.
 *  @param failure		Block with an NSError with details about the call failure.
 *
 *  @return void
 */
- (void)inviteUser:(MMUser *)user
                comments:(nullable NSString *)comments
                 success:(nullable void (^)(MMXInvite *invite))success
                 failure:(nullable void (^)(NSError *error))failure;

/**
 *  Method to add subscribers to a channel. (Owner Only)
 *
 *  @param subscribers    The users you want to subscribe
 *  @param success		  Block with the invalid users
 *  @param failure		  Block with an NSError with details about the call failure.
 */
- (void)addSubscribers:(NSArray <MMUser *> *)subscribers
               success:(nullable void (^)(NSSet <NSString *>*invalidUsers))success
               failure:(nullable void (^)(NSError *error))failure;

/**
 *  Method to remove subscribers from a channel. (Owner Only)
 *
 *  @param subscribers    The users you want remove
 *  @param success		  Block with the invalid users
 *  @param failure		  Block with an NSError with details about the call failure.
 */
- (void)removeSubscribers:(NSArray <MMUser *> *)subscribers
                  success:(nullable void (^)(NSSet <NSString *>*invalidUsers))success
                  failure:(nullable void (^)(NSError *error))failure;
/**
 *  Method to find common subscribers for a channel.
 *
 *  @param subscribers    The users you want remove
 *  @param success		  Block with the channels
 *  @param failure		  Block with an NSError with details about the call failure.
 */
+ (void)findChannelsBySubscribers:(NSArray <MMUser *> *)subscribers
                        matchType:(MMXMatchType)matchType
                          success:(nullable void (^)(NSArray <MMXChannel *>*channels))success
                          failure:(nullable void (^)(NSError *error))failure;

/**
 *  Method to find summaries for channels.
 *
 *  @param subscribers    The users you want remove
 *  @param success		  Block with the channels
 *  @param failure		  Block with an NSError with details about the call failure.
 */
+ (void)channelDetails:(NSArray<MMXChannel *>*)channels
      numberOfMessages:(NSInteger)numberOfMessages
    numberOfSubcribers:(NSInteger)numberOfSubcribers
               success:(nullable void (^)(NSArray <MMXChannelDetailResponse *>*detailsForChannels))success
               failure:(nullable void (^)(NSError *error))failure;

- (NSURL *)iconURL;

- (void)setIconWithURL:(nullable NSURL *)url
        success:(nullable void (^)(NSURL *iconUrl))success
        failure:(nullable void (^)(NSError *error))failure;

- (void)setIconWithData:(nullable NSData *)data
            success:(nullable void (^)(NSURL *iconUrl))success
            failure:(nullable void (^)(NSError *error))failure;

/**
 *  Disable push notifications for the channel
 *
 *  @param date           An optional date to mute notifications until
 *  @param success		  A block object to be executed when the mute API call finishes successfully. This block has no return value and takes no arguments.
 *  @param failure		  A block object to be executed when the mute API finishes with an error. This block has no return value and takes one argument: the error object.
 */
- (void)muteUntil:(nullable NSDate *)date
          success:(nullable void (^)())success
          failure:(nullable void (^)(NSError *error))failure;

/**
 *  Re-enable push notifications for the channel
 *
 *  @param success		  A block object to be executed when the unMute API call finishes successfully. This block has no return value and takes no arguments.
 *  @param failure		  A block object to be executed when the unMute API finishes with an error. This block has no return value and takes one argument: the error object.
 */
- (void)unMuteWithSuccess:(nullable void (^)())success
                  failure:(nullable void (^)(NSError *error))failure;

NS_ASSUME_NONNULL_END
@end
