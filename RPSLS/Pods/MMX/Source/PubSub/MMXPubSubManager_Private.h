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

#import "MMXPubSubManager.h"
#import "MMXClient_Private.h"

@class XMPPIQ;
@class MMXUserProfile;

@protocol MMXPubSubManagerDelegate <NSObject>

@property (nonatomic, strong) MMXConfiguration *configuration;
@property (nonatomic, assign) MMXConnectionStatus connectionStatus;

- (void)sendIQ:(XMPPIQ *)iq completion:(IQCompletionBlock)completion;

- (void)stopTrackingIQWithID:(NSString*)trackingID;

- (XMPPJID *)currentJID;

- (NSString *)generateMessageID;

@end


typedef NS_ENUM(NSInteger, MMXTopicType){
	MMXTopicTypeUser = 0,
	MMXTopicTypeGlobal,
	MMXTopicTypeAll
};

@interface MMXPubSubManager ()

@property (nonatomic, weak) id<MMXPubSubManagerDelegate> delegate;

- (instancetype)initWithDelegate:(id<MMXPubSubManagerDelegate>)delegate;

- (void)retractItemsFromTopic:(MMXTopic *)topic
                      itemIDs:(NSArray *)itemIDs
                      success:(void (^)(BOOL success))success
                      failure:(void (^)(NSError * error))failure;

- (void)subscribersForTopic:(MMXTopic *)topic
					  limit:(int)limit
					success:(void (^)(int totalCount,NSArray * subscriptions))success
					failure:(void (^)(NSError * error))failure;

- (void)queryTopicsWithDictionary:(NSDictionary *)queryDict
						  success:(void (^)(int, NSArray * topics))success
						  failure:(void (^)(NSError *))failure;

@end