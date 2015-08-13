//
//  MMXTopic2.m
//  QuickStart
//
//  Created by Jason Ferguson on 8/5/15.
//  Copyright (c) 2015 Magnet Systems, Inc. All rights reserved.
//

#import "MMXChannel.h"
#import "MMXMessage_Private.h"
#import "MMX.h"

@interface MMXChannel ()

@property (nonatomic, readwrite) NSString *name;
@property (nonatomic, readwrite) MMXUser *owner;
@property (nonatomic, readwrite) int numberOfMessages;
@property (nonatomic, readwrite) NSDate *lastTimeActive;
@property (nonatomic, readwrite) NSSet *tags;
@property (nonatomic, readwrite) BOOL isSubscribed;

@end

@implementation MMXChannel

+ (instancetype)channelWithName:(NSString *)name summary:(NSString *)summary {
	MMXChannel *channel = [MMXChannel new];
	channel.name = name;
	channel.summary = summary;
	return channel;
}

+ (void)findByName:(NSString *)name
			success:(void (^)(int, NSArray *))success
			failure:(void (^)(NSError *))failure {
	//FIXME: Handle case that user is not logged in
	MMXTopicQueryFilter *tFilter = [[MMXTopicQueryFilter alloc] init];
	tFilter.topicName = name;
	tFilter.predicateOperatorType = MMXEqualToPredicateOperatorType;
	
	MMXQuery * query =  [[MMXQuery alloc] init];
	query.queryFilters = @[tFilter];
	query.compoundPredicateType = MMXAndPredicateType;
	[[MMXClient sharedClient].pubsubManager queryTopics:query success:^(int totalCount, NSArray *topics) {
		if (success) {
			//FIXME: convert topics to channels
			success(totalCount, topics);
		}
	} failure:^(NSError *error) {
		if (failure) {
			failure(error);
		}
	}];
}

+ (void)findByTags:(NSSet *)tags
			success:(void (^)(int, NSArray *))success
			failure:(void (^)(NSError *))failure {
	//FIXME: Handle case that user is not logged in
	MMXQuery * query =  [[MMXQuery alloc] init];
	query.tags = [tags allObjects];;
	[[MMXClient sharedClient].pubsubManager queryTopics:query success:^(int totalCount, NSArray *topics) {
		if (success) {
			//FIXME: convert topics to channels
			success(totalCount, topics);
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
	//FIXME: Handle case that user is not logged in
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
	//FIXME: Handle case that user is not logged in
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
	//FIXME: Handle case that user is not logged in
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
	//FIXME: Handle case that user is not logged in
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
	//FIXME: Handle case that user is not logged in
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

- (void)publish:(MMXMessage *)message
		success:(void (^)(MMXMessage *))success
		failure:(void (^)(NSError *))failure {
	//FIXME: Handle case that user is not logged in
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

- (void)fetchMessagesFrom:(NSDate *)from
					   to:(NSDate *)to
			maxToReturned:(int)maxToReturned
				  success:(void (^)(NSArray *))success
				  failure:(void (^)(NSError *))failure {
	MMXPubSubFetchRequest * fetch = [[MMXPubSubFetchRequest alloc] init];
	fetch.topic = [MMXTopic topicWithName:self.name];
	fetch.since = from;
	fetch.until = to;
	fetch.maxItems = maxToReturned;
	fetch.ascending = YES;
	[[MMXClient sharedClient].pubsubManager fetchItems:fetch success:^(NSArray *messages) {
		NSMutableArray *msgArray = [[NSMutableArray alloc] initWithCapacity:messages.count];
		for (MMXPubSubMessage *message in messages) {
			MMXMessage *msg = [MMXMessage messageToChannel:self.copy messageContent:message.metaData];
			[msgArray addObject:msg];
		}
		if (success) {
			success(msgArray.copy);
		}
	} failure:^(NSError *error) {
		NSLog(@"Fail error = %@",error);
		if (failure) {
			failure(error);
		}
	}];

}

#pragma mark - Conversion Helpers
- (MMXTopic *)asTopic {
	return [MMXTopic topicWithName:self.name];
}

#pragma mark - NSCoding

- (id)initWithCoder:(NSCoder *)coder {
	self = [super init];
	if (self) {
		_name = [coder decodeObjectForKey:@"_name"];
		_summary = [coder decodeObjectForKey:@"_summary"];
		_owner = [coder decodeObjectForKey:@"_owner"];
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
	[coder encodeObject:self.owner forKey:@"_owner"];
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
		copy.owner = self.owner;
		copy.numberOfMessages = self.numberOfMessages;
		copy.lastTimeActive = self.lastTimeActive;
		copy.tags = self.tags;
		copy.isSubscribed = self.isSubscribed;
	}
	
	return copy;
}



@end
