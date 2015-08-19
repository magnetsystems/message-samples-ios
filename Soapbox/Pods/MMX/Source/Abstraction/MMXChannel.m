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

#import "MMXChannel.h"
#import "MMXMessage_Private.h"
#import "MMX_Private.h"
#import "MMXTopic_Private.h"
#import "MMXUser.h"
#import "MMXClient_Private.h"
#import "MagnetDelegate.h"

@interface MMXChannel ()

@property (nonatomic, readwrite) NSString *name;
@property (nonatomic, readwrite) NSString *ownerUsername;
@property (nonatomic, readwrite) int numberOfMessages;
@property (nonatomic, readwrite) NSDate *lastTimeActive;
@property (nonatomic, readwrite) NSSet *tags;
@property (nonatomic, readwrite) BOOL isSubscribed;

@end

@implementation MMXChannel

+ (instancetype)channelWithName:(NSString *)name
						summary:(NSString *)summary {
	MMXChannel *channel = [MMXChannel new];
	channel.name = name;
	channel.summary = summary;
	return channel;
}

+ (void)channelsStartingWith:(NSString *)name
					   limit:(int)limit
					 success:(void (^)(int, NSSet *))success
					 failure:(void (^)(NSError *))failure {
	if ([MMXClient sharedClient].connectionStatus != MMXConnectionStatusAuthenticated) {
		if (failure) {
			failure([MagnetDelegate notNotLoggedInError]);
		}
		return;
	}
	MMXTopicQueryFilter *tFilter = [[MMXTopicQueryFilter alloc] init];
	tFilter.topicName = name;
	tFilter.predicateOperatorType = MMXEqualToPredicateOperatorType;
	
	MMXQuery * query =  [[MMXQuery alloc] init];
	query.queryFilters = @[tFilter];
	query.compoundPredicateType = MMXAndPredicateType;
	query.limit = limit;
	[MMXChannel findChannelsWithQuery:query success:success failure:failure];
}

+ (void)findByTags:(NSSet *)tags
		   success:(void (^)(int, NSSet *))success
		   failure:(void (^)(NSError *))failure {

	if ([MMXClient sharedClient].connectionStatus != MMXConnectionStatusAuthenticated) {
		if (failure) {
			failure([MagnetDelegate notNotLoggedInError]);
		}
		return;
	}
	MMXQuery * query =  [[MMXQuery alloc] init];
	query.tags = [tags allObjects];;
	[MMXChannel findChannelsWithQuery:query success:success failure:failure];
}

+ (void)findChannelsWithQuery:(MMXQuery *)query
					  success:(void (^)(int, NSSet *))success
					  failure:(void (^)(NSError *))failure {
	
	[[MMXClient sharedClient].pubsubManager queryTopics:query success:^(int totalCount, NSArray *topics) {
		[[MMXClient sharedClient].pubsubManager summaryOfTopics:topics since:nil until:nil success:^(NSArray *summaries) {
			[[MMXClient sharedClient].pubsubManager listSubscriptionsWithSuccess:^(NSArray *subscriptions) {
				NSSet *channelSet = [MMXChannel channelsFromTopics:topics summaries:summaries subscriptions:subscriptions];
				if (success) {
					success(totalCount, channelSet);
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

- (void)tagsWithSuccess:(void (^)(NSSet *))success
				failure:(void (^)(NSError *))failure {
	if ([MMXClient sharedClient].connectionStatus != MMXConnectionStatusAuthenticated) {
		if (failure) {
			failure([MagnetDelegate notNotLoggedInError]);
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

- (void)setTags:(NSSet *)tags
		success:(void (^)(void))success
		failure:(void (^)(NSError *))failure {

	if ([MMXClient sharedClient].connectionStatus != MMXConnectionStatusAuthenticated) {
		if (failure) {
			failure([MagnetDelegate notNotLoggedInError]);
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

- (void)createWithSuccess:(void (^)(void))success
				  failure:(void (^)(NSError *))failure {

	if ([MMXClient sharedClient].connectionStatus != MMXConnectionStatusAuthenticated) {
		if (failure) {
			failure([MagnetDelegate notNotLoggedInError]);
		}
		
		return;
	}
	[[MMXClient sharedClient].pubsubManager createTopic:[self asTopic] success:^(BOOL successful) {
		if (success) {
			success();
		}
	} failure:^(NSError *error) {
		if (failure) {
			failure(error);
		}
	}];
}

- (void)deleteWithSuccess:(void (^)(void))success
				 failure:(void (^)(NSError *))failure {

	if ([MMXClient sharedClient].connectionStatus != MMXConnectionStatusAuthenticated) {
		if (failure) {
			failure([MagnetDelegate notNotLoggedInError]);
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
			failure([MagnetDelegate notNotLoggedInError]);
		}
		
		return;
	}
	[[MMXClient sharedClient].pubsubManager subscribeToTopic:[self asTopic] device:nil success:^(MMXTopicSubscription *subscription) {
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
			failure([MagnetDelegate notNotLoggedInError]);
		}
		
		return;
	}
	[[MMXClient sharedClient].pubsubManager unsubscribeFromTopic:[self asTopic] subscriptionID:nil success:^(BOOL successful) {
		if (success) {
			success();
		}
	} failure:^(NSError *error) {
		if (failure) {
			failure(error);
		}
	}];
}

- (void)subscribersWithSuccess:(void (^)(NSSet *))success
					   failure:(void (^)(NSError *))failure {
	if ([MMXClient sharedClient].connectionStatus != MMXConnectionStatusAuthenticated) {
		if (failure) {
			failure([MagnetDelegate notNotLoggedInError]);
		}
		return;
	}
	
}

- (void)publish:(MMXMessage *)message
		success:(void (^)(MMXMessage *))success
		failure:(void (^)(NSError *))failure {

	if ([MMXClient sharedClient].connectionStatus != MMXConnectionStatusAuthenticated) {
		if (failure) {
			failure([MagnetDelegate notNotLoggedInError]);
		}
		
		return;
	}
	MMXPubSubMessage *msg = [MMXPubSubMessage pubSubMessageToTopic:[self asTopic] content:nil metaData:message.messageContent];
	[[MMXClient sharedClient].pubsubManager publishPubSubMessage:msg success:^(BOOL successful, NSString *messageID) {
		if (success) {
			//FIXME: not sure that this is the best way to handle this
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

- (void)fetchMessagesBetweenStartDate:(NSDate *)startDate
							  endDate:(NSDate *)endDate
								limit:(int)limit
							ascending:(BOOL)ascending
							  success:(void (^)(NSSet *))success
							  failure:(void (^)(NSError *))failure {
	if ([MMXClient sharedClient].connectionStatus != MMXConnectionStatusAuthenticated) {
		if (failure) {
			failure([MagnetDelegate notNotLoggedInError]);
		}
		
		return;
	}
	MMXPubSubFetchRequest * fetch = [[MMXPubSubFetchRequest alloc] init];
	fetch.topic = [MMXTopic topicWithName:self.name];
	fetch.since = startDate;
	fetch.until = endDate;
	fetch.maxItems = limit;
	fetch.ascending = ascending;
	[[MMXClient sharedClient].pubsubManager fetchItems:fetch success:^(NSArray *messages) {
		NSMutableArray *msgArray = [[NSMutableArray alloc] initWithCapacity:messages.count];
		for (MMXPubSubMessage *message in messages) {
			MMXMessage *msg = [MMXMessage messageFromPubSubMessage:message];
			[msgArray addObject:msg];
		}
		if (success) {
			success([NSSet setWithArray:msgArray.copy]);
		}
	} failure:^(NSError *error) {
		NSLog(@"Fail error = %@",error);
		if (failure) {
			failure(error);
		}
	}];

}

- (void)inviteUser:(MMXUser *)user
		   message:(NSString *)message
		   success:(void (^)(MMXInvite *))success
		   failure:(void (^)(NSError *))failure {
	if ([MMXClient sharedClient].connectionStatus != MMXConnectionStatusAuthenticated) {
		if (failure) {
			failure([MagnetDelegate notNotLoggedInError]);
		}
		return;
	}
	
}

#pragma mark - Conversion Helpers

+ (NSSet *)channelsFromTopics:(NSArray *)topics summaries:(NSArray *)summaries subscriptions:(NSArray *)subscriptions {
	NSMutableDictionary *channelDict = [NSMutableDictionary dictionaryWithCapacity:topics.count];
	for (MMXTopic *topic in topics) {
		MMXChannel *channel = [MMXChannel channelWithName:topic.topicName summary:topic.topicDescription];
		channel.ownerUsername = topic.topicCreator.username;
		channel.isPublic = !topic.inUserNameSpace;
		[channelDict setObject:channel forKey:channel.name];
	}
	for (MMXTopicSummary *sum in summaries) {
		MMXChannel *channel = channelDict[sum.topic.topicName];
		if (channel) {
			channel.numberOfMessages = sum.numItemsPublished;
			channel.lastTimeActive = sum.lastTimePublishedTo;
		}
	}
	for (MMXTopicSubscription *sub in subscriptions) {
		MMXChannel *channel = channelDict[sub.topic.topicName];
		if (channel) {
			channel.isSubscribed = sub.isSubscribed;
		}
	}
	return [NSSet setWithArray:[channelDict allValues]];
}

- (MMXTopic *)asTopic {
	MMXTopic *newTopic = [MMXTopic topicWithName:self.name];
	if (!self.isPublic) {
		MMXUser *currentUser = [MMXUser currentUser];
		if (currentUser) {
			newTopic.nameSpace = currentUser.username;
		} else {
			return nil;
		}
	}
	return newTopic;
}

#pragma mark - NSCoding

- (id)initWithCoder:(NSCoder *)coder {
	self = [super init];
	if (self) {
		_name = [coder decodeObjectForKey:@"_name"];
		_summary = [coder decodeObjectForKey:@"_summary"];
		_ownerUsername = [coder decodeObjectForKey:@"_ownerUsername"];
		_numberOfMessages = [[coder decodeObjectForKey:@"_numberOfMessages"] intValue];
		_lastTimeActive = [coder decodeObjectForKey:@"_lastTimeActive"];
		_tags = [coder decodeObjectForKey:@"_tags"];
		_isSubscribed = [[coder decodeObjectForKey:@"_isSubscribed"] boolValue];
	}
	
	return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
	[coder encodeObject:self.name forKey:@"_name"];
	[coder encodeObject:self.summary forKey:@"_summary"];
	[coder encodeObject:self.ownerUsername forKey:@"_ownerUsername"];
	[coder encodeObject:@(self.numberOfMessages) forKey:@"_numberOfMessages"];
	[coder encodeObject:self.lastTimeActive forKey:@"_lastTimeActive"];
	[coder encodeObject:self.tags forKey:@"_tags"];
	[coder encodeObject:@(self.isSubscribed) forKey:@"_isSubscribed"];
}

- (id)copyWithZone:(NSZone *)zone {
	MMXChannel *copy = [[[self class] allocWithZone:zone] init];
	
	if (copy != nil) {
		copy.name = self.name;
		copy.summary = self.summary;
		copy.ownerUsername = self.ownerUsername;
		copy.numberOfMessages = self.numberOfMessages;
		copy.lastTimeActive = self.lastTimeActive;
		copy.tags = self.tags;
		copy.isSubscribed = self.isSubscribed;
	}
	
	return copy;
}



@end
