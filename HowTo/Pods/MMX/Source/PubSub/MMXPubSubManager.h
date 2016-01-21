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

@class MMXTopic;
@class MMXTopicSubscription;
@class MMXPubSubMessage;
@class MMXQuery;
@class MMXEndpoint;
@class MMXPubSubFetchRequest;
@class CLLocation;

/**
 *  MMXPubSubManager is the primary class interacting with MMXTopic and MMXPubSubMessage.
 *	It has many methods for getting topics, messages, subscription, etc.
 *	It also contains methods for discovering/querying for topics.
 */
@interface MMXPubSubManager : NSObject

#pragma mark - Topics

/**
 *  The callback dispatch queue. Value is initially set to the main queue.
 */
@property (nonatomic, assign) dispatch_queue_t callbackQueue;

/**
 *  Method to create a new topic.
 *
 *  @param topic   - MMXTopic object for the topic you want to create .
 *  @param success - Block with BOOL. Value should be YES.
 *  @param failure - Block with an NSError with details about the call failure.
 */
- (void)createTopic:(MMXTopic *)topic
            success:(void (^)(BOOL success))success
            failure:(void (^)(NSError * error))failure;

/**
 *  Method to delete an existing topic where the current user is the owner.
 *
 *  @param topic   - MMXTopic object for the topic you want to delete.
 *  @param success - Block with BOOL. Value should be YES.
 *  @param failure - Block with an NSError with details about the call failure.
 */
- (void)deleteTopic:(MMXTopic *)topic
            success:(void (^)(BOOL success))success
            failure:(void (^)(NSError * error))failure;

#pragma mark - Find Topics

/**
 *  Query for topics
 *
 *  @param topicQuery - MMXQuery object with the properties set that you wish to query on.
 *  @param success    - Block with an int for the total number of topics that fit your criteria(not the number returned) and a NSArray of MMXTopics.
 *  @param failure    - Block with an NSError with details about the call failure.
 */
- (void)queryTopics:(MMXQuery *)topicQuery
			success:(void (^)(int totalCount, NSArray * topics))success
			failure:(void (^)(NSError * error))failure;

/**
 *  List all topics of a particular type.
 *
 *  @param limit   - The max number of topics you want returned.
 *  @param success - Block with an int for the total number of topics that fit your criteria(not the number returned) and a NSArray of MMXTopics.
 *  @param failure - Block with an NSError with details about the call failure.
 */
- (void)listTopics:(int)limit
           success:(void (^)(int totalCount, NSArray * topics))success
           failure:(void (^)(NSError * error))failure;

/**
 *  Get a summary for a list of topics
 *
 *  @param topics  - A NSArray of MMXTopics objects for the topics you want a summary of.
 *  @param since   - The earliest date you want to receive information about.
 *  @param until   - The latest date you want to receive information about.
 *  @param success - Block with a NSArray of MMXTopicSummary objects.
 *  @param failure - Block with an NSError with details about the call failure.
 */
- (void)summaryOfTopics:(NSArray *)topics
				  since:(NSDate *)since
				  until:(NSDate *)until
                success:(void (^)(NSArray * summaries))success
                failure:(void (^)(NSError * error))failure;

#pragma mark - Get Posts

/**
 *  Fetch previous items posted to a topic.
 *
 *  @param request	- See MMXPubSubFetchRequest.h for more information.
 *  @param success	- Block with a NSArray of MMXPubSubMessages
 *  @param failure	- Block with an NSError with details about the call failure.
 */
- (void)fetchItems:(MMXPubSubFetchRequest *)request
           success:(void (^)(NSArray * messages))success
           failure:(void (^)(NSError * error))failure;

/**
 *  Fetch published items from a topic with specific message IDs.
 *
 *  @param topic		- MMXTopic object for the topic you want to subscribe to.
 *  @param messageIDs	- An Array of message IDs of the posts you are intereted in fetching.
 *  @param success		- Block with a NSArray of MMXPubSubMessages
 *  @param failure		- Block with an NSError with details about the call failure.
 */
- (void)fetchItemsFromTopic:(MMXTopic *)topic
			  forMessageIDs:(NSArray *)messageIDs
					success:(void (^)(NSArray * messages))success
					failure:(void (^)(NSError * error))failure;

/**
 *  Method to request the most recent post for all topics the user is subscribed to.
 *
 *  @param maxItems - Max number of items you want to receive. The messages are delivered via the client:didReceivePubSubMessage: delegate callback.
 *  @param since    - The earliest date you want to receive messages from.
 *  @param success  - Block with BOOL. Value should be YES.
 *  @param failure  - Block with an NSError with details about the call failure.
 */
- (void)requestLatestPosts:(int)maxItems
                     since:(NSDate *)since
                   success:(void (^)(BOOL success))success
                   failure:(void (^)(NSError * error))failure;

#pragma mark - Publishing

/**
 *  Method to publish a message to a PubSub topic.
 *
 *  @param message - MMXPubSubMessage object that you want to post.
 *  @param success - Block with BOOL and a NSString with the message ID for the message you posted. The BOOL value should be YES.
 *  @param failure - Block with an NSError with details about the call failure.
 */
- (void)publishPubSubMessage:(MMXPubSubMessage *)message
                     success:(void (^)(BOOL success, NSString * messageID))success
                     failure:(void (^)(NSError * error))failure;

#pragma mark - Topic Subscriptions

/**
 *  Method to subscribe to an existing topic.
 *
 *  @param topic    - MMXTopic object for the topic you want to subscribe to.
 *  @param endpoint - The MMXEndpoint for the specific device you want to subscribe with. Set as nil if you want to subscribe on all the user's devices.
 *  @param success  - Block with a MMXTopicSubscription. The ID can be used later to unsubscribe.
 *  @param failure  - Block with an NSError with details about the call failure.
 */
- (void)subscribeToTopic:(MMXTopic *)topic
                  device:(MMXEndpoint *)endpoint
                 success:(void (^)(MMXTopicSubscription * subscription))success
                 failure:(void (^)(NSError * error))failure;

/**
 *  Get a list of subscriptions for the current user.
 *
 *  @param success  - Block with a NSArray of the MMXTopicSubscriptions. See MMXTopicSubscription.h The IDs can be used to unsubscribe.
 *  @param failure  - Block with an NSError with details about the call failure.
 */
- (void)listSubscriptionsWithSuccess:(void (^)(NSArray * subscriptions))success
                             failure:(void (^)(NSError * error))failure;

/**
 *  Unsubscribe from a topic.
 *
 *  @param topic            - MMXTopic object for the topic you want to unsubscribe from.
 *  @param subscriptionID   - Set as nil if you want to cancel all subscriptions to the topic or specify the subscription ID.
 *  @param success          - Block with BOOL. Value should be YES.
 *  @param failure          - Block with an NSError with details about the call failure.
 */
- (void)unsubscribeFromTopic:(MMXTopic *)topic
              subscriptionID:(NSString *)subscriptionID
                     success:(void (^)(BOOL success))success
                     failure:(void (^)(NSError * error))failure;

/**
 *  Unsubscribe a device from all PubSub Topics.
 *
 *  @param endpoint - MMXEndpoint object of the device you want to unsubscribe.
 *  @param success  - Block with BOOL. Value should be YES.
 *  @param failure  - Block with an NSError with details about the call failure.
 */
- (void)unsubscribeDevice:(MMXEndpoint *)endpoint
                  success:(void (^)(BOOL success))success
                  failure:(void (^)(NSError * error))failure;


#pragma mark - Topic Tags

/**
 *  Get tags for a topic
 *
 *  @param topic   - MMXTopic object for the topic you want the tags for. Cannot be nil.
 *  @param success - Block with an array of tags(NSStrings) and the date of the last time the tags were modified.
 *  @param failure - Block with an NSError with details about the call failure.
 */
- (void)tagsForTopic:(MMXTopic *)topic
             success:(void (^)(NSDate * lastTimeModified, NSArray * tags))success
             failure:(void (^)(NSError * error))failure;

/**
 *  Add tags on a topic.
 *
 *  @param tags    - NSArray of tags(NSStrings).
 *  @param topic   - MMXTopic object for the topic you want to add the tags to. Cannot be nil.
 *  @param success - Block with BOOL. Value should be YES.
 *  @param failure - Block with an NSError with details about the call failure.
 */
- (void)addTags:(NSArray *)tags
		  topic:(MMXTopic *)topic
		success:(void (^)(BOOL success))success
		failure:(void (^)(NSError * error))failure;

/**
 *  Set tags for a specific topic. This will overwrite ALL existing tags for the topic.
 *	This can be used to delete tags by passing in the sub-set of existing tags that you want to keep.
 *
 *  @param tags    - NSArray of tags(NSStrings).
 *  @param topic   - MMXTopic object for the topic you want to set the tags for. Cannot be nil.
 *  @param success - Block with BOOL. Value should be YES.
 *  @param failure - Block with an NSError with details about the call failure.
 */
- (void)setTags:(NSArray *)tags
		  topic:(MMXTopic *)topic
		success:(void (^)(BOOL success))success
		failure:(void (^)(NSError * error))failure;

/**
 *  Remove tags from a specific topic.
 *
 *  @param tags    - NSArray of tags(NSStrings).
 *  @param topic   - MMXTopic object for the topic you want to remove the tags from. Cannot be nil.
 *  @param success - Block with BOOL. Value should be YES.
 *  @param failure - Block with an NSError with details about the call failure.
 */
- (void)removeTags:(NSArray *)tags
			 topic:(MMXTopic *)topic
		   success:(void (^)(BOOL success))success
		   failure:(void (^)(NSError * error))failure;

#pragma mark - Update GeoLocation

/**
 *  Method to publish the current GeoLocation of the user.
 *
 *  @param location - CLLocation object for the current location.
 *  @param success  - Block with BOOL and a NSString with the message ID for the message you posted. The BOOL value should be YES.
 *  @param failure  - Block with an NSError with details about the call failure.
 */
- (void)updateGeoLocation:(CLLocation *)location
				  success:(void (^)(BOOL success))success
				  failure:(void (^)(NSError * error))failure;


@end
