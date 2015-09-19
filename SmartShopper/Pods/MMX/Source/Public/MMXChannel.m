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
#import "MMXMessage_Private.h"
#import "MMX_Private.h"
#import "MMXTopic_Private.h"
#import "MMXUser.h"
#import "MMXClient_Private.h"
#import "MMXPubSubManager_Private.h"
#import "MagnetDelegate.h"
#import "MMXInvite_Private.h"
#import "MMXInternalMessageAdaptor.h"
#import "MMXDataModel.h"
#import "MMXPubSubMessage_Private.h"

@implementation MMXChannel

+ (instancetype)channelWithName:(NSString *)name
						summary:(NSString *)summary {
	MMXChannel *channel = [MMXChannel new];
	channel.name = name;
	channel.summary = summary;
	return channel;
}

+ (instancetype)channelWithName:(NSString *)name
						summary:(NSString *)summary
					   isPublic:(BOOL)isPublic {
	MMXChannel *channel = [MMXChannel new];
	channel.name = name;
	channel.summary = summary;
	channel.isPublic = isPublic;
	return channel;
}

+ (void)allPublicChannelsWithLimit:(int)limit
							offset:(int)offset
						   success:(void (^)(int totalCount, NSArray *channels))success
						   failure:(void (^)(NSError *))failure {
	if ([MMXClient sharedClient].connectionStatus != MMXConnectionStatusAuthenticated) {
		if (failure) {
			failure([MagnetDelegate notNotLoggedInError]);
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
							success:(void (^)(int totalCount, NSArray *channels))success
							failure:(void (^)(NSError *))failure {
	if ([MMXClient sharedClient].connectionStatus != MMXConnectionStatusAuthenticated) {
		if (failure) {
			failure([MagnetDelegate notNotLoggedInError]);
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
			failure([MagnetDelegate notNotLoggedInError]);
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
				failure([MMXClient errorWithTitle:@"Unknown Error"
										  message:@"An unknown error occurred."
											 code:500]);
			}
		}
	} failure:failure];
}

+ (void)channelsStartingWith:(NSString *)name
					   limit:(int)limit
					 success:(void (^)(int, NSArray *))success
					 failure:(void (^)(NSError *))failure {
	if ([MMXClient sharedClient].connectionStatus != MMXConnectionStatusAuthenticated) {
		if (failure) {
			failure([MagnetDelegate notNotLoggedInError]);
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
								@"tags" : [NSNull null],
								@"topicName": @{
									@"match": @"PREFIX",
									@"value": name}};
	[MMXChannel findChannelsWithDictionary:queryDict success:success failure:failure];
}

+ (void)channelsStartingWith:(NSString *)name
					   limit:(int)limit
					  offset:(int)offset
					 success:(void (^)(int, NSArray *))success
					 failure:(void (^)(NSError *))failure {
	if ([MMXClient sharedClient].connectionStatus != MMXConnectionStatusAuthenticated) {
		if (failure) {
			failure([MagnetDelegate notNotLoggedInError]);
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
								@"topicName": @{
										@"match": @"PREFIX",
										@"value": name}};
	[MMXChannel findChannelsWithDictionary:queryDict success:success failure:failure];
	
}

+ (void)findByTags:(NSSet *)tags
		   success:(void (^)(int, NSArray *))success
		   failure:(void (^)(NSError *))failure {
	
	if ([MMXClient sharedClient].connectionStatus != MMXConnectionStatusAuthenticated) {
		if (failure) {
			failure([MagnetDelegate notNotLoggedInError]);
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
								@"limit" : @(-1),
								@"tags": @{@"match": @"EXACT",
										   @"values": [tags allObjects]}};
	
	[MMXChannel findChannelsWithDictionary:queryDict success:success failure:failure];
}

+ (void)findByTags:(NSSet *)tags
			 limit:(int)limit
			offset:(int)offset
		   success:(void (^)(int, NSArray *))success
		   failure:(void (^)(NSError *))failure {
	
	if ([MMXClient sharedClient].connectionStatus != MMXConnectionStatusAuthenticated) {
		if (failure) {
			failure([MagnetDelegate notNotLoggedInError]);
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
		MMXUser *creator = [MMXUser currentUser];
		if (creator) {
			self.ownerUsername = creator.username;
		}
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
			   success:(void (^)(MMXChannel *channel))success
			   failure:(void (^)(NSError *))failure {
	
	if ([MMXClient sharedClient].connectionStatus != MMXConnectionStatusAuthenticated) {
		if (failure) {
			failure([MagnetDelegate notNotLoggedInError]);
		}
		
		return;
	}
	MMXChannel *channel = [MMXChannel channelWithName:name summary:summary isPublic:isPublic];
	[[MMXClient sharedClient].pubsubManager createTopic:[channel asTopic] success:^(BOOL successful) {
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

+ (void)subscribedChannelsWithSuccess:(void (^)(NSArray *))success
							  failure:(void (^)(NSError *))failure {
	if ([MMXClient sharedClient].connectionStatus != MMXConnectionStatusAuthenticated) {
		if (failure) {
			failure([MagnetDelegate notNotLoggedInError]);
		}
		return;
	}
	[[MMXClient sharedClient].pubsubManager listSubscriptionsWithSuccess:^(NSArray *subscriptions) {
		NSArray *topics = [MMXChannel topicsFromSubscriptions:subscriptions];
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
}

- (void)subscribersWithSuccess:(void (^)(int totalCount, NSArray *subscribers))success
					   failure:(void (^)(NSError *error))failure {

	[self subscribersWithLimit:-1 offset:0 success:success failure:failure];
}

- (void)subscribersWithLimit:(int)limit
					  offset:(int)offset
					 success:(void (^)(int totalCount, NSArray *subscribers))success
					 failure:(void (^)(NSError *error))failure {
	if ([MMXClient sharedClient].connectionStatus != MMXConnectionStatusAuthenticated) {
		if (failure) {
			failure([MagnetDelegate notNotLoggedInError]);
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

- (void)publish:(NSDictionary *)messageContent
		success:(void (^)(MMXMessage *))success
		failure:(void (^)(NSError *))failure {

	NSString *messageID = [[MMXClient sharedClient] generateMessageID];
	MMXPubSubMessage *msg = [MMXPubSubMessage pubSubMessageToTopic:[self asTopic] content:nil metaData:messageContent];
	msg.messageID = messageID;
	if ([MMXClient sharedClient].connectionStatus != MMXConnectionStatusAuthenticated) {
		if ([MMXUser currentUser]) {
			[self saveForOfflineAsPubSub:msg];
			return;
		} else {
			if (failure) {
				failure([MMXChannel notNotLoggedInAndNoUserError]);
			}
			return;
		}
	}
	[[MMXClient sharedClient].pubsubManager publishPubSubMessage:msg success:^(BOOL successful, NSString *messageID) {
		if (success) {
			MMXMessage *message = [MMXMessage messageToChannel:self.copy messageContent:messageContent];
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
							  success:(void (^)(int totalCount, NSArray *messages))success
							  failure:(void (^)(NSError *))failure {
	
	[self messagesBetweenStartDate:startDate
						   endDate:endDate
							 limit:limit
							offset:0
						 ascending:ascending
						   success:success
						   failure:failure];
}

- (void)messagesBetweenStartDate:(NSDate *)startDate
						 endDate:(NSDate *)endDate
						   limit:(int)limit
						  offset:(int)offset
					   ascending:(BOOL)ascending
						 success:(void (^)(int, NSArray *))success
						 failure:(void (^)(NSError *))failure {
	if ([MMXClient sharedClient].connectionStatus != MMXConnectionStatusAuthenticated) {
		if (failure) {
			failure([MagnetDelegate notNotLoggedInError]);
		}
		
		return;
	}
	MMXPubSubFetchRequest * fetch = [[MMXPubSubFetchRequest alloc] init];
	MMXTopic *topic = [MMXTopic topicWithName:self.name];
	if (!self.isPublic) {
		topic.nameSpace = self.ownerUsername;
	}
	fetch.topic = topic;
	fetch.since = startDate;
	fetch.until = endDate;
	fetch.maxItems = limit;
	fetch.offset = offset;
	fetch.ascending = ascending;
	[[MMXClient sharedClient].pubsubManager fetchItems:fetch success:^(NSArray *messages) {
		NSMutableArray *msgArray = [[NSMutableArray alloc] initWithCapacity:messages.count];
		for (MMXPubSubMessage *message in messages) {
			MMXMessage *msg = [MMXMessage messageFromPubSubMessage:message];
			[msgArray addObject:msg];
		}
		[[MMXClient sharedClient].pubsubManager summaryOfTopics:@[topic] since:startDate until:endDate success:^(NSArray *summaries) {
			int count = 0;
			if (summaries.count) {
				MMXTopicSummary *sum = summaries[0];
				count =  sum.numItemsPublished;
			}
			if (success) {
				success(count, msgArray);
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

- (NSString *)inviteUser:(MMXUser *)user
				comments:(NSString *)comments
				 success:(void (^)(MMXInvite *))success
				 failure:(void (^)(NSError *))failure {
	if ([MMXClient sharedClient].connectionStatus != MMXConnectionStatusAuthenticated) {
		if (failure) {
			failure([MagnetDelegate notNotLoggedInError]);
		}
		return nil;
	}
	if (nil == self.ownerUsername || [self.ownerUsername isEqualToString:@""]) {
		if (failure) {
			NSError * error = [MMXClient errorWithTitle:@"Invalid Channel Invite" message:@"It looks like you are trying to send an invite from an invalid channel. Please user the channelForName:isPublic:success:failure API to get the valid channel object." code:500];
			failure(error);
		}
		return nil;
	}
	MMXInternalMessageAdaptor *msg = [MMXInternalMessageAdaptor inviteMessageToUser:user forChannel:self.copy comments:comments];
	NSString *messageID = [[MagnetDelegate sharedDelegate] sendInternalMessageFormat:msg success:^{
		if (success) {
			MMXInvite *invite = [MMXInvite new];
			invite.comments = comments;
			invite.channel = self.copy;
			invite.sender = [MMXUser currentUser];
			invite.timestamp = [NSDate date];
			success(invite);
		}
	} failure:^(NSError *error) {
		if (failure) {
			failure(error);
		}
	}];
	return messageID;
}

#pragma mark - Offline

- (void)saveForOfflineAsPubSub:(MMXPubSubMessage *)message {
	[[MMXDataModel sharedDataModel] addOutboxEntryWithPubSubMessage:message username:[MMXUser currentUser].username];
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
		MMXChannel *channel = [MMXChannel channelWithName:topic.topicName summary:topic.topicDescription isPublic:!topic.inUserNameSpace];
		channel.ownerUsername = topic.topicCreator.username;
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
	if (!self.isPublic && !channel.isPublic && ![self.ownerUsername isEqualToString:channel.ownerUsername])
		return NO;
	return YES;
}

- (NSUInteger)hash {
	NSUInteger hash = [self.name hash];
	if (!self.isPublic) {
		hash = hash * 31u + [self.ownerUsername hash];
	}
	return hash;
}


@end
