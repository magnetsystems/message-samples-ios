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
#import <Mantle/Mantle.h>
@class MMXUser;
@class MMXMessage;
@class MMXInvite;

@interface MMXChannel : MTLModel

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
@property (nonatomic, copy) NSString *summary;

/**
 *  The owner/creator of the channel.
 */
@property (nonatomic, readonly) NSString *ownerUsername;

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
 *  Create a new channel object
 *
 *  @param name    The name you want the channel to have
 *  @param summary A summary or description of the channel
 *
 *  @return A new MMXChannel object
 */
+ (instancetype)channelWithName:(NSString *)name
						summary:(NSString *)summary;

/**
 *  Method used to discover existing channels by name
 *
 *  @param name     The exact name of the channel you are searching for.
 *  @param limit	The max number of items you want returned.
 *  @param success  Block with the number of channels that match the query and a NSSet of MMXChannels that match the criteria.
 *  @param failure  Block with an NSError with details about the call failure.
 */
+ (void)channelsStartingWith:(NSString *)name
					   limit:(int)limit
					 success:(void (^)(int totalCount, NSArray *channels))success
					 failure:(void (^)(NSError *error))failure;

/**
 *  Method used to discover existing channels that have any of the tags provided
 *
 *  @param tags		A set of unique tags
 *  @param success  Block with the number of channels that match the query and a NSArray of MMXChannels that match the criteria.
 *  @param failure  Block with a NSError with details about the call failure.
 */
+ (void)findByTags:(NSSet *)tags
		   success:(void (^)(int totalCount, NSArray *channels))success
		   failure:(void (^)(NSError *error))failure;

/**
 *  Get tags for this channel
 *
 *  @param success - Block with a NSSet of tags(NSStrings)
 *  @param failure - Block with a NSError with details about the call failure.
 */
- (void)tagsWithSuccess:(void (^)(NSSet * tags))success
				failure:(void (^)(NSError * error))failure;

/**
 *  Set tags for a specific channel. This will overwrite ALL existing tags for the chanel.
 *	This can be used to delete tags by passing in the sub-set of existing tags that you want to keep.
 *
 *  @param tags    - NSSet of tags(NSStrings).
 *  @param success - Block called if operation is successful.
 *  @param failure - Block with a NSError with details about the call failure.
 */
- (void)setTags:(NSSet *)tags
		success:(void (^)(void))success
		failure:(void (^)(NSError *error))failure;

/**
 *  Method to create a new channel.
 *
 *  @param success - Block called if operation is successful.
 *  @param failure - Block with an NSError with details about the call failure.
 */
- (void)createWithSuccess:(void (^)(void))success
				  failure:(void (^)(NSError * error))failure;

/**
 *  Method to delete an existing new channel.
 * Current user must be the owner of the channel to delete it.
 *
 *  @param success - Block called if operation is successful.
 *  @param failure - Block with an NSError with details about the call failure.
 */
- (void)deleteWithSuccess:(void (^)(void))success
				  failure:(void (^)(NSError * error))failure;

/**
 *  Method to subscribe to an existing channel.
 *
 *  @param success - Block called if operation is successful.
 *  @param failure - Block with an NSError with details about the call failure.
 */
- (void)subscribeWithSuccess:(void (^)(void))success
					 failure:(void (^)(NSError * error))failure;

/**
 *  Method to unsubscribe to an existing channel.
 *
 *  @param success - Block called if operation is successful.
 *  @param failure - Block with an NSError with details about the call failure.
 */
- (void)unSubscribeWithSuccess:(void (^)(void))success
					   failure:(void (^)(NSError * error))failure;


/**
 *  Get all channels the current user is subscribed to
 *
 *  @param success Block with a NSArray of channels
 *  @param failure - Block with an NSError with details about the call failure.
 */
+ (void)subscribedChannelsWithSuccess:(void (^)(NSArray *channels))success
							  failure:(void (^)(NSError *error))failure;

/**
 *  Get the subscribers for a channel
 *	Must be subscribed to the channel to use this API
 *
 *  @param success Block with the total count of subscribers and a NSSet of the subscribers(MMXUser objects)
 *  @param failure Block with an NSError with details about the call failure.
 */
- (void)subscribersWithSuccess:(void (^)(int totalCount, NSArray *subscribers))success
					   failure:(void (^)(NSError *error))failure;

/**
 *  Method to publish to a channel.
 *
 *  @param messageContent The content you want to publish
 *  @param success		  Block with the published message
 *  @param failure		  Block with an NSError with details about the call failure.
 */
- (void)publish:(NSDictionary *)messageContent
		success:(void (^)(MMXMessage *message))success
		failure:(void (^)(NSError *error))failure;

/**
 *  Fetch previous items posted to this channel.
 *
 *  @param startDate     The earliest date you would like messages from.
 *  @param endDate       The latest date you would like messages until. Defaults to now.
 *  @param limit		 The max number of items you want returned.
 *  @param ascending	 The sort order(by date) for the messages returned.
 *  @param success		 The total available messages and a NSArray of MMXMessages
 *  @param failure		 Block with an NSError with details about the call failure.
 */
- (void)fetchMessagesBetweenStartDate:(NSDate *)startDate
							  endDate:(NSDate *)endDate
								limit:(int)limit
							ascending:(BOOL)ascending
							  success:(void (^)(int totalCount, NSArray *messages))success
							  failure:(void (^)(NSError *error))failure;

/**
 *  Invite a user to the channel
 *
 *  @param user			The MMXUser object for the user you want to invite
 *  @param comments		An optional message telling the user why you want them to join the channel
 *  @param success		Block with the MMXInvite object that was sent.
 *  @param failure		Block with an NSError with details about the call failure.
 *
 *  @return The messageID for the invite sent
 */
- (NSString *)inviteUser:(MMXUser *)user
				comments:(NSString *)comments
				 success:(void (^)(MMXInvite *invite))success
				 failure:(void (^)(NSError *error))failure;

@end
