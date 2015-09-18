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

#import "MMXPubSubManager_Private.h"
#import "MMXConfiguration.h"
#import "MMXClient_Private.h"
#import "MMXTopic_Private.h"
#import "MMXUserProfile_Private.h"
#import "MMXConstants.h"
#import "MMXIQResponse.h"
#import "MMXSubscriptionResponse_Private.h"
#import "MMXSubscriptionListResponse.h"
#import "MMXTopicListResponse.h"
#import "MMXTopicSummaryRequestResponse.h"
#import "MMXTopicSubscription_Private.h"
#import "MMXInternalMessageAdaptor_Private.h"
#import "MMXQuery_Private.h"
#import "MMXEndpoint_Private.h"
#import "MMXTopicQueryResponse_Private.h"
#import "MMXPubSubFetchRequest_Private.h"
#import "DDXML.h"
#import "MMXUtils.h"
#import "MMXMessageUtils.h"
#import "MMXDataModel.h"
#import "MMXLogger.h"
#import "MMXAssert.h"
#import "MMXTopicSubscribersResponse.h"

#import "XMPP.h"
#import "XMPPIQ+MMX.h"
#import "XMPPJID+MMX.h"
#import "MMXPubSubMessage.h"
#import "MMXPubSubMessage_Private.h"

@import CoreLocation;

@implementation MMXPubSubManager

- (instancetype)initWithDelegate:(id<MMXPubSubManagerDelegate>)delegate {
    if ((self = [super init])) {
        _delegate = delegate;
		_callbackQueue = dispatch_get_main_queue();
    }
    return self;
}

- (instancetype)init {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:@"-init is not a valid initializer for the class MMXPubSubManager. Use the property from MMXClient."
                                 userInfo:nil];
    return nil;
}

#pragma mark - Create Topic

- (XMPPIQ *)topicCreationIQ:(MMXTopic *)topic error:(NSError**)error {
    NSDictionary *topicDict = [topic dictionaryRepresentation];
	
	NSError * parsingError;
	NSXMLElement *mmxElement = [MMXUtils mmxElementFromValidJSONObject:topicDict xmlns:MXnsPubSub commandStringValue:MXcommandCreateTopic error:&parsingError];
    if (parsingError) {
		*error = parsingError;
        return nil;
    } else {
        XMPPIQ *topicIQ = [[XMPPIQ alloc] initWithType:@"set" child:mmxElement];
        [topicIQ addAttributeWithName:@"from" stringValue: [[self.delegate currentJID] full]];
        [topicIQ addAttributeWithName:@"id" stringValue:[self.delegate generateMessageID]];
        return topicIQ;
    }
}

- (void)createTopic:(MMXTopic *)topic
            success:(void (^)(BOOL))success
            failure:(void (^)(NSError *))failure {
    
	[[MMXLogger sharedLogger] verbose:@"MMXPubSubManager createTopic. MMXTopic = %@", topic];
    if (![self hasActiveConnection]) {
        if (failure) {
			dispatch_async(self.callbackQueue, ^{
				failure([self connectionStatusError]);
			});
        }
        return;
    }
	NSError * validError;
	if (![topic isValid:&validError]) {
		if (failure) {
			dispatch_async(self.callbackQueue, ^{
				failure(validError);
			});
		}
		return;
	}
    NSError * parsingError;
    XMPPIQ *topicIQ = [self topicCreationIQ:topic error:&parsingError];
    if (!parsingError) {
        [self.delegate sendIQ:topicIQ completion:^ (id obj, id <XMPPTrackingInfo> info) {
            XMPPIQ * iq = (XMPPIQ *)obj;
            if ([iq isErrorIQ]) {
                if (failure) {
					dispatch_async(self.callbackQueue, ^{
						failure([iq errorWithTitle:@"Channel Creation Failure."]);
					});
                }
            } else {
                MMXIQResponse *response = [MMXIQResponse responseFromIQ:iq];
                NSString* iqId = [iq elementID];
                [self.delegate stopTrackingIQWithID:iqId];
                if (response.code == 200) {
					if (success) {
						if (topic.inUserNameSpace) {
							topic.nameSpace = [[self.delegate currentJID] usernameWithoutAppID];
						}
						dispatch_async(self.callbackQueue, ^{
							success(YES);
						});
					}
                } else {
                    if (failure) {
						dispatch_async(self.callbackQueue, ^{
							failure([response errorFromResponse:@"Channel Creation Failure"]);
						});
                    }
                }
            }
        }];
    } else {
        if (failure) {
			dispatch_async(self.callbackQueue, ^{
				failure(parsingError);
			});
        }
    }
    
}

#pragma mark - Delete Topic

- (XMPPIQ *)topicDeletionIQ:(MMXTopic *)topic error:(NSError**)error {
    NSDictionary *topicDict = [topic dictionaryRepresentationForDeletion];
	
	NSError * parsingError;
	NSXMLElement *mmxElement = [MMXUtils mmxElementFromValidJSONObject:topicDict xmlns:MXnsPubSub commandStringValue:MXcommandDeleteTopic error:&parsingError];
    //FIXME: Need to fix this error handling
    if (parsingError) {
		*error = parsingError;
        return nil;
    } else {
        XMPPIQ *topicIQ = [[XMPPIQ alloc] initWithType:@"set" child:mmxElement];
        [topicIQ addAttributeWithName:@"from" stringValue: [[self.delegate currentJID] full]];
        [topicIQ addAttributeWithName:@"id" stringValue:[self.delegate generateMessageID]];
        return topicIQ;
    }
}

- (void)deleteTopic:(MMXTopic *)topic
            success:(void (^)(BOOL))success
            failure:(void (^)(NSError *))failure {
    
	[[MMXLogger sharedLogger] verbose:@"MMXPubSubManager deleteTopic. MMXTopic = %@", topic];
    if (![self hasActiveConnection]) {
        if (failure) {
			dispatch_async(self.callbackQueue, ^{
				failure([self connectionStatusError]);
			});
        }
        return;
    }
    
    NSError * parsingError;
    XMPPIQ *topicIQ = [self topicDeletionIQ:topic error:&parsingError];
    if (!parsingError) {
        [self.delegate sendIQ:topicIQ completion:^ (id obj, id <XMPPTrackingInfo> info) {
            XMPPIQ * iq = (XMPPIQ *)obj;
            if ([iq isErrorIQ]) {
                if (failure) {
					dispatch_async(self.callbackQueue, ^{
						failure([iq errorWithTitle:@"Channel Delete Failure."]);
					});
                }
            } else {
                MMXIQResponse *response = [MMXIQResponse responseFromIQ:iq];
                NSString* iqId = [iq elementID];
                [self.delegate stopTrackingIQWithID:iqId];
                if (response.code == 200) {
                    if (success) {
						dispatch_async(self.callbackQueue, ^{
							success(YES);
						});
                    }
                } else {
                    if (failure) {
						dispatch_async(self.callbackQueue, ^{
							failure([response errorFromResponse:@"Channel Delete Failure"]);
						});
                    }
                }
            }
        }];
    } else {
        if (failure) {
			dispatch_async(self.callbackQueue, ^{
				failure(parsingError);
			});
        }
    }
}

#pragma mark - Subscribe to Topic

- (XMPPIQ *)topicSubscribeIQ:(NSDictionary *)dict error:(NSError**)error {
    
	NSError * parsingError;
	NSXMLElement *mmxElement = [MMXUtils mmxElementFromValidJSONObject:dict xmlns:MXnsPubSub commandStringValue:MXcommandSubscribe error:&parsingError];
    if (parsingError) {
		*error = parsingError;
        return nil;
    } else {
        XMPPIQ *topicIQ = [[XMPPIQ alloc] initWithType:@"set" child:mmxElement];
        [topicIQ addAttributeWithName:@"from" stringValue: [[self.delegate currentJID] full]];
        [topicIQ addAttributeWithName:@"id" stringValue:[self.delegate generateMessageID]];
        return topicIQ;
    }
}

- (void)subscribeToTopic:(MMXTopic *)topic
                  device:(MMXEndpoint *)endpoint
                 success:(void (^)(MMXTopicSubscription * subscription))success
                 failure:(void (^)(NSError *))failure {
    
	[[MMXLogger sharedLogger] verbose:@"MMXPubSubManager subscribeToTopic. MMXTopic = %@", topic];
    if (![self hasActiveConnection]) {
        if (failure) {
			dispatch_async(self.callbackQueue, ^{
				failure([self connectionStatusError]);
			});
        }
        return;
    }
    
    NSError * parsingError;
	NSDictionary * topicDictionary = @{@"userId":topic.inUserNameSpace ? topic.nameSpace : [NSNull null],
										@"topicName":topic.topicName,
										@"devID":endpoint.deviceID ? endpoint.deviceID : [NSNull null],
									   @"errorOnDup":@NO
                                       };
    XMPPIQ *topicIQ = [self topicSubscribeIQ:topicDictionary error:&parsingError];
    if (!parsingError) {
        [self.delegate sendIQ:topicIQ completion:^ (id obj, id <XMPPTrackingInfo> info) {
            XMPPIQ * iq = (XMPPIQ *)obj;
            if ([iq isErrorIQ]) {
                if (failure) {
					dispatch_async(self.callbackQueue, ^{
						failure([iq errorWithTitle:@"Channel Subscribe Failure."]);
					});
                }
            } else {
                MMXSubscriptionResponse *response = [[MMXSubscriptionResponse alloc] initWithIQ:iq];
                NSString* iqId = [iq elementID];
                [self.delegate stopTrackingIQWithID:iqId];
                if (response.subscriptionID && ![response.subscriptionID isEqualToString:@""]) {
                    if (success) {
						MMXTopicSubscription * sub = [[MMXTopicSubscription alloc] init];
						sub.topic = topic;
						sub.subscriptionID = response.subscriptionID;
						sub.isSubscribed = YES;
						dispatch_async(self.callbackQueue, ^{
							success(sub);
						});
                    }
                } else {
                    if (failure) {
						dispatch_async(self.callbackQueue, ^{
							failure([response errorFromResponse:@"Channel Subscribe Failure"]);
						});
                    }
                }
            }
        }];
    } else {
        if (failure) {
			dispatch_async(self.callbackQueue, ^{
				failure(parsingError);
			});
        }
    }
}

- (void)subscribeToUserTopic:(MMXTopic *)topic
					username:(NSString *)username
					  device:(MMXEndpoint *)endpoint
					 success:(void (^)(MMXTopicSubscription * subscription))success
					 failure:(void (^)(NSError *))failure {
    
	[[MMXLogger sharedLogger] verbose:@"MMXPubSubManager subscribeToUserTopic. MMXTopic = %@\nUsername = %@", topic, username];
    if (![self hasActiveConnection]) {
        if (failure) {
			dispatch_async(self.callbackQueue, ^{
				failure([self connectionStatusError]);
			});
        }
        return;
    }
    
    NSError * parsingError;
    NSDictionary * topicDictionary = @{@"userId":username,
                                       @"topicName":topic.topicName,
                                       @"devID":endpoint.deviceID ? endpoint.deviceID : [NSNull null],
                                       @"errorOnDup":@NO
                                       };
    XMPPIQ *topicIQ = [self topicSubscribeIQ:topicDictionary error:&parsingError];
    if (!parsingError) {
        [self.delegate sendIQ:topicIQ completion:^ (id obj, id <XMPPTrackingInfo> info) {
            XMPPIQ * iq = (XMPPIQ *)obj;
            if ([iq isErrorIQ]) {
                if (failure) {
					dispatch_async(self.callbackQueue, ^{
						failure([iq errorWithTitle:@"Channel Subscribe Failure."]);
					});
                }
            } else {
                MMXSubscriptionResponse *response = [[MMXSubscriptionResponse alloc] initWithIQ:iq];
                NSString* iqId = [iq elementID];
                [self.delegate stopTrackingIQWithID:iqId];
                if (response.subscriptionID && ![response.subscriptionID isEqualToString:@""]) {
                    if (success) {
						MMXTopicSubscription * sub = [[MMXTopicSubscription alloc] init];
						sub.topic = topic;
						sub.subscriptionID = response.subscriptionID;
						sub.isSubscribed = YES;
						dispatch_async(self.callbackQueue, ^{
							success(sub);
						});
                    }
                } else {
                    if (failure) {
						dispatch_async(self.callbackQueue, ^{
							failure([response errorFromResponse:@"Channel Subscribe Failure"]);
						});
                    }
                }
            }
        }];
    } else {
        if (failure) {
			dispatch_async(self.callbackQueue, ^{
				failure(parsingError);
			});
        }
    }
    
}

#pragma mark - List Subscriptions

- (XMPPIQ *)listSubscriptionsIQ {
    NSXMLElement *mmxElement = [[NSXMLElement alloc] initWithName:@"pubsub" xmlns:@"http://jabber.org/protocol/pubsub"];
    [mmxElement addChild:[[NSXMLElement alloc] initWithName:@"subscriptions"]];

	XMPPIQ *topicIQ = [[XMPPIQ alloc] initWithType:@"get" child:mmxElement];
	[topicIQ addAttributeWithName:@"from" stringValue: [[self.delegate currentJID] full]];
	[topicIQ addAttributeWithName:@"to" stringValue:[NSString stringWithFormat:@"pubsub.%@",[[self.delegate currentJID] domain]]];
	[topicIQ addAttributeWithName:@"id" stringValue:[self.delegate generateMessageID]];
	return topicIQ;
}

- (void)listSubscriptionsWithSuccess:(void (^)(NSArray *))success
                             failure:(void (^)(NSError *))failure {
    
    if (![self hasActiveConnection]) {
        if (failure) {
			dispatch_async(self.callbackQueue, ^{
				failure([self connectionStatusError]);
			});
        }
        return;
    }
    
    XMPPIQ *topicIQ = [self listSubscriptionsIQ];
	[self.delegate sendIQ:topicIQ completion:^ (id obj, id <XMPPTrackingInfo> info) {
		XMPPIQ * iq = (XMPPIQ *)obj;
		if ([iq isErrorIQ]) {
			if (failure) {
				dispatch_async(self.callbackQueue, ^{
					failure([iq errorWithTitle:@"Channel List Request Failure."]);
				});
			}
		} else {
			MMXSubscriptionListResponse *response = [MMXSubscriptionListResponse initWithIQ:iq];
			NSString* iqId = [iq elementID];
			[self.delegate stopTrackingIQWithID:iqId];
			if (success) {
				dispatch_async(self.callbackQueue, ^{
					success(response.subscriptionArray);
				});
			}
		}
	}];
}

#pragma mark - Fetch Items

- (void)fetchItems:(MMXPubSubFetchRequest *)query
           success:(void (^)(NSArray * messages))success
           failure:(void (^)(NSError * error))failure {

	[[MMXLogger sharedLogger] verbose:@"MMXPubSubManager fetchItems. MMXPubSubFetchRequest = %@", query];
    if (![self hasActiveConnection]) {
        if (failure) {
			dispatch_async(self.callbackQueue, ^{
				failure([self connectionStatusError]);
			});
        }
        return;
    }
    NSError * error;
    NSXMLElement *mmxElement = [MMXUtils mmxElementFromValidJSONObject:[query dictionaryRepresentation] xmlns:MXnsPubSub commandStringValue:MXcommandFetch error:&error];
    if (!error) {
        XMPPIQ *fetchItemsIQ = [[XMPPIQ alloc] initWithType:@"get" child:mmxElement];
        [fetchItemsIQ addAttributeWithName:@"from" stringValue: [[self.delegate currentJID] full]];
        [fetchItemsIQ addAttributeWithName:@"id" stringValue:[self.delegate generateMessageID]];
        [self.delegate sendIQ:fetchItemsIQ completion:^ (id obj, id <XMPPTrackingInfo> info) {
            XMPPIQ * iq = (XMPPIQ *)obj;
            if ([iq isErrorIQ]) {
                if (failure) {
					dispatch_async(self.callbackQueue, ^{
						failure([iq errorWithTitle:@"Fetch Items for Topic Failure."]);
					});
                }
            } else {
                NSError * parsingError;
                NSArray * messageArray = [MMXInternalMessageAdaptor pubsubMessagesFromFetchResponseIQ:iq topic:query.topic error:&parsingError];
				if (parsingError) {
					if (failure) {
						dispatch_async(self.callbackQueue, ^{
							failure(parsingError);
						});
					}
				} else {
					if (success) {
						dispatch_async(self.callbackQueue, ^{
							success(messageArray);
						});
					}
				}
                NSString* iqId = [iq elementID];
                [self.delegate stopTrackingIQWithID:iqId];
            }
        }];
    } else {
        if (failure) {
			dispatch_async(self.callbackQueue, ^{
				failure(error);
			});
        }
    }
}

#pragma mark - Unsubscribe from Topic

- (XMPPIQ *)topicUnsubscribeIQ:(MMXTopic *)topic
				subscriptionID:(NSString *)subscriptionID
						 error:(NSError**)error {
	
    NSDictionary * topicDictionary = @{@"userId":topic.inUserNameSpace ? topic.nameSpace : [NSNull null],
                                       @"topicName":topic.topicName,
                                       @"subscriptionId":subscriptionID ? subscriptionID : [NSNull null]
                                       };
	
	NSError * parsingError;
	NSXMLElement *mmxElement = [MMXUtils mmxElementFromValidJSONObject:topicDictionary xmlns:MXnsPubSub commandStringValue:MXcommandUnsubscribe error:&parsingError];
    //FIXME: Need to fix this error handling
    if (parsingError) {
		*error = parsingError;
        return nil;
    } else {
        XMPPIQ *topicIQ = [[XMPPIQ alloc] initWithType:@"set" child:mmxElement];
        [topicIQ addAttributeWithName:@"from" stringValue: [[self.delegate currentJID] full]];
        [topicIQ addAttributeWithName:@"id" stringValue:[self.delegate generateMessageID]];
        return topicIQ;
    }
}

- (void)unsubscribeFromTopic:(MMXTopic *)topic
			  subscriptionID:(NSString *)subscriptionID
					 success:(void (^)(BOOL))success
					 failure:(void (^)(NSError *))failure {

	[[MMXLogger sharedLogger] verbose:@"MMXPubSubManager unsubscribeFromTopic. MMXTopic = %@", topic];
    if (![self hasActiveConnection]) {
        if (failure) {
			dispatch_async(self.callbackQueue, ^{
				failure([self connectionStatusError]);
			});
        }
        return;
    }

    NSError * parsingError;
    XMPPIQ *topicIQ = [self topicUnsubscribeIQ:topic subscriptionID:nil error:&parsingError];
    if (!parsingError) {
        [self.delegate sendIQ:topicIQ completion:^ (id obj, id <XMPPTrackingInfo> info) {
            XMPPIQ * iq = (XMPPIQ *)obj;
            if ([iq isErrorIQ]) {
                if (failure) {
					dispatch_async(self.callbackQueue, ^{
						failure([iq errorWithTitle:@"Channel Unsubscribe Failure."]);
					});
                }
            } else {
                MMXIQResponse *response = [MMXIQResponse responseFromIQ:iq];
                NSString* iqId = [iq elementID];
                [self.delegate stopTrackingIQWithID:iqId];
                if (response.code == 200) {
                    if (success) {
						dispatch_async(self.callbackQueue, ^{
							success(YES);
						});
                    }
                } else {
                    if (failure) {
						dispatch_async(self.callbackQueue, ^{
							failure([response errorFromResponse:@"Channel Unsubscribe Failure"]);
						});
                    }
                }
            }
        }];
    } else {
        if (failure) {
			dispatch_async(self.callbackQueue, ^{
				failure(parsingError);
			});
        }
    }
}

#pragma mark - Unsubscribe Device from all Topics

- (XMPPIQ *)unsubscribeDeviceIQ:(NSString *)deviceID
						  error:(NSError**)error {
    NSDictionary * topicDictionary = @{@"devId":deviceID};
    
	NSError * parsingError;
	NSXMLElement *mmxElement = [MMXUtils mmxElementFromValidJSONObject:topicDictionary xmlns:MXnsPubSub commandStringValue:MXcommandUnsubscribeForDevice error:&parsingError];
    if (parsingError) {
		*error = parsingError;
        return nil;
    } else {
        XMPPIQ *topicIQ = [[XMPPIQ alloc] initWithType:@"set" child:mmxElement];
        [topicIQ addAttributeWithName:@"from" stringValue: [[self.delegate currentJID] full]];
        [topicIQ addAttributeWithName:@"id" stringValue:[self.delegate generateMessageID]];
        return topicIQ;
    }
}

- (void)unsubscribeDevice:(MMXEndpoint *)endpoint
                  success:(void (^)(BOOL))success
                  failure:(void (^)(NSError *))failure {

	[[MMXLogger sharedLogger] verbose:@"MMXPubSubManager unsubscribeDevice. deviceID = %@", endpoint.deviceID];
    if (![self hasActiveConnection]) {
        if (failure) {
			dispatch_async(self.callbackQueue, ^{
				failure([self connectionStatusError]);
			});
        }
        return;
    }

    if (!endpoint.deviceID || [endpoint.deviceID isEqualToString:@""]) {
        NSDictionary *userInfo = @{
                                   NSLocalizedDescriptionKey: NSLocalizedString(@"deviceID cannot be nil or empty string.", nil),
                                   NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"deviceID cannot be nil or empty string.", nil),
                                   };
        NSError *error = [NSError errorWithDomain:MMXErrorDomain
                                             code:400
                                         userInfo:userInfo];
        if (failure) {
			dispatch_async(self.callbackQueue, ^{
				failure(error);
			});
        }
		return;
    }
    NSError * parsingError;
    XMPPIQ *topicIQ = [self unsubscribeDeviceIQ:endpoint.deviceID error:&parsingError];
    if (!parsingError) {
        [self.delegate sendIQ:topicIQ completion:^ (id obj, id <XMPPTrackingInfo> info) {
            XMPPIQ * iq = (XMPPIQ *)obj;
            if ([iq isErrorIQ]) {
                if (failure) {
					dispatch_async(self.callbackQueue, ^{
						failure([iq errorWithTitle:@"Channel Unsubscribe Failure."]);
					});
                }
            } else {
                MMXIQResponse *response = [MMXIQResponse responseFromIQ:iq];
                NSString* iqId = [iq elementID];
                [self.delegate stopTrackingIQWithID:iqId];
                if (response.code == 200) {
                    if (success) {
						dispatch_async(self.callbackQueue, ^{
							success(YES);
						});
                    }
                } else {
                    if (failure) {
						dispatch_async(self.callbackQueue, ^{
							failure([response errorFromResponse:@"Device Unsubscribe Failure"]);
						});
                    }
                }
            }
        }];
    } else {
        if (failure) {
			dispatch_async(self.callbackQueue, ^{
				failure(parsingError);
			});
        }
    }
}

#pragma mark - Subscribers

- (XMPPIQ *)subscribersForTopicIQ:(MMXTopic *)topic
							limit:(int)limit
							error:(NSError**)error {
	NSDictionary * topicDictionary = @{@"userId":topic.inUserNameSpace ? topic.nameSpace : [NSNull null],
									   @"topicName":topic.topicName,
									   @"limit":@(limit)};
	
	NSError * parsingError;
	NSXMLElement *mmxElement = [MMXUtils mmxElementFromValidJSONObject:topicDictionary xmlns:MXnsPubSub commandStringValue:MXcommandGetSubscribers error:&parsingError];
	if (parsingError) {
		*error = parsingError;
		return nil;
	} else {
		XMPPIQ *topicIQ = [[XMPPIQ alloc] initWithType:@"get" child:mmxElement];
		[topicIQ addAttributeWithName:@"from" stringValue: [[self.delegate currentJID] full]];
		[topicIQ addAttributeWithName:@"id" stringValue:[self.delegate generateMessageID]];
		return topicIQ;
	}
}

- (void)subscribersForTopic:(MMXTopic *)topic
					  limit:(int)limit
					success:(void (^)(int,NSArray *))success
					failure:(void (^)(NSError *))failure {
	[[MMXLogger sharedLogger] verbose:@"MMXPubSubManager subscribersForTopic. Topic = %@", topic.topicName];
	if (![self hasActiveConnection]) {
		if (failure) {
			dispatch_async(self.callbackQueue, ^{
				failure([self connectionStatusError]);
			});
		}
		return;
	}
	NSError * parsingError;
	XMPPIQ *topicIQ = [self subscribersForTopicIQ:topic limit:limit error:&parsingError];
	if (!parsingError) {
		[self.delegate sendIQ:topicIQ completion:^ (id obj, id <XMPPTrackingInfo> info) {
			XMPPIQ * iq = (XMPPIQ *)obj;
			if ([iq isErrorIQ]) {
				if (failure) {
					dispatch_async(self.callbackQueue, ^{
						failure([iq errorWithTitle:@"Subscribers Failure."]);
					});
				}
			} else {
				MMXTopicSubscribersResponse *response = [[MMXTopicSubscribersResponse alloc] initWithIQ:iq];
				NSString* iqId = [iq elementID];
				[self.delegate stopTrackingIQWithID:iqId];
				if (response) {
					if (success) {
						dispatch_async(self.callbackQueue, ^{
							success(response.totalCount,response.subscribers);
						});
					}
				} else {
					if (failure) {
						dispatch_async(self.callbackQueue, ^{
							failure([MMXClient errorWithTitle:@"Subscribers Error" message:@"An unknown error occured" code:500]);
						});
					}
				}
			}
		}];
	} else {
		if (failure) {
			dispatch_async(self.callbackQueue, ^{
				failure(parsingError);
			});
		}
	}

}


#pragma mark - Retract Published Items from Topic

- (XMPPIQ *)topicRetractItemsIQ:(NSDictionary *)dict all:(BOOL)all error:(NSError**)error {
    NSString * command = MXcommandRetract;
    if (all) {
        command = MXcommandRetractAll;
    }
	NSError * parsingError;
	NSXMLElement *mmxElement = [MMXUtils mmxElementFromValidJSONObject:dict xmlns:MXnsPubSub commandStringValue:command error:&parsingError];
    if (parsingError) {
		*error = parsingError;
        return nil;
    } else {
        XMPPIQ *topicIQ = [[XMPPIQ alloc] initWithType:@"set" child:mmxElement];
        [topicIQ addAttributeWithName:@"from" stringValue: [[self.delegate currentJID] full]];
        [topicIQ addAttributeWithName:@"id" stringValue:[self.delegate generateMessageID]];
        return topicIQ;
    }
}

- (void)retractItemsFromTopic:(MMXTopic *)topic
                      itemIDs:(NSArray *)itemIDs
                      success:(void (^)(BOOL success))success
                      failure:(void (^)(NSError * error))failure {

    if (![self hasActiveConnection]) {
        if (failure) {
			dispatch_async(self.callbackQueue, ^{
				failure([self connectionStatusError]);
			});
        }
        return;
    }
    
    NSError * parsingError;
    NSMutableDictionary * topicDictionary = @{@"topicName":topic.topicName,
                                              @"userID":(topic.topicCreator && topic.topicCreator.username) ? topic.topicCreator.username : [NSNull null]
                                              }.mutableCopy;
    BOOL all = YES;
    if (itemIDs && itemIDs.count) {
        [topicDictionary setObject:itemIDs forKey:@"itemIds"];
        all = NO;
    }
    XMPPIQ *topicIQ = [self topicRetractItemsIQ:topicDictionary all:all error:&parsingError];
    if (!parsingError) {
        [self.delegate sendIQ:topicIQ completion:^ (id obj, id <XMPPTrackingInfo> info) {
            XMPPIQ * iq = (XMPPIQ *)obj;
            if ([iq isErrorIQ]) {
                if (failure) {
					dispatch_async(self.callbackQueue, ^{
						failure([iq errorWithTitle:@"Retract Items Failure."]);
					});
                }
            } else {
                MMXIQResponse *response = [MMXIQResponse responseFromIQ:iq];
                NSString* iqId = [iq elementID];
                [self.delegate stopTrackingIQWithID:iqId];
                if (response.code == 200) {
                    if (success) {
						dispatch_async(self.callbackQueue, ^{
							success(YES);
						});
                    }
                } else {
                    if (failure) {
						dispatch_async(self.callbackQueue, ^{
							failure([response errorFromResponse:@"Retract Items Failure"]);
						});
                    }
                }
            }
        }];
    } else {
        if (failure) {
			dispatch_async(self.callbackQueue, ^{
				failure(parsingError);
			});
        }
    }
}

#pragma mark - List Topics

- (XMPPIQ *)topicListIQ:(NSDictionary *)dict error:(NSError**)error {
	
	NSError * parsingError;
	NSXMLElement *mmxElement = [MMXUtils mmxElementFromValidJSONObject:dict xmlns:MXnsPubSub commandStringValue:MXcommandListTopics error:&parsingError];
	if (parsingError) {
		*error = parsingError;
		return nil;
    } else {
        XMPPIQ *topicIQ = [[XMPPIQ alloc] initWithType:@"get" child:mmxElement];
        [topicIQ addAttributeWithName:@"from" stringValue: [[self.delegate currentJID] full]];
        [topicIQ addAttributeWithName:@"id" stringValue:[self.delegate generateMessageID]];
        return topicIQ;
    }
}

- (NSString *)topicTypeAsString:(MMXTopicType)type {
    switch (type) {
        case MMXTopicTypeUser:
            return @"personal";
            break;
        case MMXTopicTypeGlobal:
            return @"global";
            break;
        case MMXTopicTypeAll:
            return @"both";
            break;
        default:
            return @"global";
            break;
    }
}

- (void)listTopics:(int)limit
		   success:(void (^)(int,NSArray * topics))success
		   failure:(void (^)(NSError * error))failure {
	MMXQuery * query = [[MMXQuery alloc] init];
	query.limit = limit;
	[self queryTopics:query success:success failure:failure];
}


- (void)listTopics:(int)limit
              type:(MMXTopicType)type
           success:(void (^)(NSArray * topics))success
           failure:(void (^)(NSError * error))failure {

    if (![self hasActiveConnection]) {
        if (failure) {
			dispatch_async(self.callbackQueue, ^{
				failure([self connectionStatusError]);
			});
        }
        return;
    }
    
    NSError * parsingError;
    NSDictionary * topicDictionary = @{@"limit":@(limit),
                                       @"recursive":@YES,
                                       @"topicName":[NSNull null],
                                       @"type":[self topicTypeAsString:type]
                                       };
    XMPPIQ *topicIQ = [self topicListIQ:topicDictionary error:&parsingError];
    if (!parsingError) {
        [self.delegate sendIQ:topicIQ completion:^ (id obj, id <XMPPTrackingInfo> info) {
            XMPPIQ * iq = (XMPPIQ *)obj;
            if ([iq isErrorIQ]) {
                if (failure) {
					dispatch_async(self.callbackQueue, ^{
						failure([iq errorWithTitle:@"Channel List Failure."]);
					});
                }
            } else {
                MMXTopicListResponse *response = [[MMXTopicListResponse alloc] initWithIQ:iq];
                NSString* iqId = [iq elementID];
                [self.delegate stopTrackingIQWithID:iqId];
                if (!response.error) {
                    if (success) {
						dispatch_async(self.callbackQueue, ^{
							success(response.topics);
						});
                    }
                } else {
                    if (failure) {
						dispatch_async(self.callbackQueue, ^{
							failure(response.error);
						});
                    }
                }
            }
        }];
    } else {
        if (failure) {
			dispatch_async(self.callbackQueue, ^{
				failure(parsingError);
			});
        }
    }
}

#pragma mark - Summary of Topics

- (XMPPIQ *)topicSummariesIQ:(NSDictionary *)dict
					   error:(NSError**)error {
	
	NSError * parsingError;
	NSXMLElement *mmxElement = [MMXUtils mmxElementFromValidJSONObject:dict xmlns:MXnsPubSub commandStringValue:MXcommandGetSummary error:&parsingError];
    if (parsingError) {
		*error = parsingError;
        return nil;
    } else {
        XMPPIQ *topicIQ = [[XMPPIQ alloc] initWithType:@"get" child:mmxElement];
        [topicIQ addAttributeWithName:@"from" stringValue: [[self.delegate currentJID] full]];
        [topicIQ addAttributeWithName:@"id" stringValue:[self.delegate generateMessageID]];
        return topicIQ;
    }
}

- (void)summaryOfTopics:(NSArray *)topics
				  since:(NSDate *)since
				  until:(NSDate *)until
                success:(void (^)(NSArray *))success
                failure:(void (^)(NSError *))failure {
    
	[[MMXLogger sharedLogger] verbose:@"MMXPubSubManager summaryOfTopics. topics = %@", topics];
    if (![self hasActiveConnection]) {
        if (failure) {
			dispatch_async(self.callbackQueue, ^{
				failure([self connectionStatusError]);
			});
        }
        return;
    }
    NSError * parsingError;
    NSMutableArray * topicArray = @[].mutableCopy;
    for (MMXTopic * topic in topics) {
        [topicArray addObject:[topic dictionaryForTopicSummary]];
    }
    NSDictionary * topicDictionary = @{@"topicNodes":topicArray,
									   @"since": since ? [MMXUtils stringIniso8601Format:since] : [NSNull null],
									   @"until": until ? [MMXUtils stringIniso8601Format:until] : [NSNull null]
                                       };
    XMPPIQ *topicIQ = [self topicSummariesIQ:topicDictionary error:&parsingError];
    if (!parsingError) {
        [self.delegate sendIQ:topicIQ completion:^ (id obj, id <XMPPTrackingInfo> info) {
            XMPPIQ * iq = (XMPPIQ *)obj;
            if ([iq isErrorIQ]) {
                if (failure) {
					dispatch_async(self.callbackQueue, ^{
						failure([iq errorWithTitle:@"Channel Summary Failure."]);
					});
                }
            } else {
                MMXTopicSummaryRequestResponse *response = [[MMXTopicSummaryRequestResponse alloc] initWithIQ:iq];
                if (!response.error) {
                    if (success) {
						dispatch_async(self.callbackQueue, ^{
							success(response.topics);
						});
                    }
                } else {
                    if (failure) {
						dispatch_async(self.callbackQueue, ^{
							failure(response.error);
						});
                    }
                }
            }
			NSString* iqId = [iq elementID];
			[self.delegate stopTrackingIQWithID:iqId];
        }];
    } else {
        if (failure) {
			dispatch_async(self.callbackQueue, ^{
				failure(parsingError);
			});
        }
    }
 
}

#pragma mark - Publish to Topic

- (void)publishPubSubMessage:(MMXPubSubMessage *)message
                     success:(void (^)(BOOL, NSString * messageID))success
                     failure:(void (^)(NSError *))failure {

	MMXAssert(!(message.messageContent == nil && message.metaData == nil),@"MMXPubSubManager publishPubSubMessage: messageContent && metaData cannot both be nil");

	[[MMXLogger sharedLogger] verbose:@"MMXPubSubManager publishPubSubMessage. MMXPubSubMessage = %@", message];
	if (![MMXMessageUtils isValidMetaData:message.metaData]) {
		if (failure) {
			dispatch_async(self.callbackQueue, ^{
				failure([MMXClient errorWithTitle:@"Not Valid" message:@"All values must be strings." code:401]);
			});
		}
		
		return;
	}
	
	if ([MMXMessageUtils sizeOfMessageContent:message.messageContent metaData:message.metaData] > kMaxMessageSize) {
		if (failure) {
			dispatch_async(self.callbackQueue, ^{
				failure([MMXClient errorWithTitle:@"Message too large" message:@"Message content and metaData exceed the max size of 200KB" code:401]);
			});
		}
		return;
	}

	if (message.messageID == nil) {
		message.messageID = [self.delegate generateMessageID];
	}
	
	if (![self hasActiveConnection]) {
        if (failure) {
            NSString * errorMessage = @"Your message was queued and will be sent the next time you log in.";
            if (![self hasNecessaryConfigurationAndCredentialToSend]) {
                errorMessage = @"You have not provided enough infomation in your configuration or credentials to be able to send a message";
			} else {
				if (message.timestamp == nil) {
					message.timestamp = [NSDate date];
				}
				[[MMXDataModel sharedDataModel] addOutboxEntryWithPubSubMessage:message username:self.delegate.configuration.credential.user];
			}
			dispatch_async(self.callbackQueue, ^{
				failure([MMXClient errorWithTitle:@"Not currently connected." message:errorMessage code:503]);
			});
        }
        return;
    }
	NSString *itemID = [self.delegate generateMessageID];
    XMPPIQ *publishIQ = [message pubsubIQForAppID:self.delegate.configuration.appID
									   currentJID:[self.delegate currentJID]
										   itemID:itemID];
    [self.delegate sendIQ:publishIQ completion:^ (id obj, id <XMPPTrackingInfo> info) {
        XMPPIQ * iq = (XMPPIQ *)obj;
        if (iq) {
            if ([iq isErrorIQ]) {
                if (failure) {
					dispatch_async(self.callbackQueue, ^{
						failure([iq errorWithTitle:@"Publish to Channel Failure."]);
					});
                }
            } else {
                if (success) {
					dispatch_async(self.callbackQueue, ^{
						success(YES, itemID);
					});
                }
            }
			NSString* iqId = [iq elementID];
			[self.delegate stopTrackingIQWithID:iqId];
        } else {
            //FIXME: There is no documentation for an error response
            NSDictionary *userInfo = @{
                    NSLocalizedDescriptionKey: NSLocalizedString(@"An unknown error occured.", nil),
                    NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Something went wrong with your attempt to publish.", nil),
            };
            if (failure) {
				dispatch_async(self.callbackQueue, ^{
					failure([NSError errorWithDomain:MMXErrorDomain
												code:0
											userInfo:userInfo]);
				});
            }
        }
    }];
}

#pragma mark - Query Topics

- (void)queryTopics:(MMXQuery *)topicQuery
            success:(void (^)(int, NSArray * topics))success
            failure:(void (^)(NSError *))failure {
	[[MMXLogger sharedLogger] verbose:@"MMXPubSubManager queryTopics. MMXQuery = %@", topicQuery];
	if (topicQuery == nil) {
		topicQuery = [[MMXQuery alloc] init];
	}
	
	NSDictionary *queryDict = [topicQuery dictionaryRepresentation];
	[self queryTopicsWithDictionary:queryDict success:success failure:failure];
}

- (void)queryTopicsWithDictionary:(NSDictionary *)queryDict
			success:(void (^)(int, NSArray * topics))success
			failure:(void (^)(NSError *))failure {
	NSError *error;
	NSXMLElement *mmxElement = [MMXUtils mmxElementFromValidJSONObject:queryDict xmlns:MXnsPubSub commandStringValue:@"searchTopic" error:&error];
	
	XMPPIQ *queryIQ = [[XMPPIQ alloc] initWithType:@"get" child:mmxElement];
	[queryIQ addAttributeWithName:@"id" stringValue:[[NSUUID UUID] UUIDString]];
    [self.delegate sendIQ:queryIQ completion:^ (id obj, id <XMPPTrackingInfo> info) {
		if (obj) {
			XMPPIQ * returnIQ = (XMPPIQ *)obj;
			if ([returnIQ isErrorIQ]) {
				dispatch_async(self.callbackQueue, ^{
					failure([returnIQ errorWithTitle:@"Channel Query Error"]);
				});
			} else {
				MMXTopicQueryResponse *response = [MMXTopicQueryResponse responseFromIQ:returnIQ];
				if (success) {
					dispatch_async(self.callbackQueue, ^{
						success(response.totalCount, response.topics);
					});
				}
			}
			NSString* iqId = [returnIQ elementID];
			[self.delegate stopTrackingIQWithID:iqId];
		} else {
			if (failure) {
				failure([MMXClient errorWithTitle:@"Channel Query Error" message:@"An unknown error occured" code:500]);
			}
		}
    }];
}

#pragma mark - Fetch Items with IDs

- (XMPPIQ *)fetchItemsFromTopicIQ:(NSDictionary *)dict error:(NSError**)error {
	NSError * parsingError;
	NSXMLElement *mmxElement = [MMXUtils mmxElementFromValidJSONObject:dict xmlns:MXnsPubSub commandStringValue:@"getItems" error:&parsingError];
	if (parsingError) {
		*error = parsingError;
		return nil;
	} else {
		XMPPIQ *topicIQ = [[XMPPIQ alloc] initWithType:@"get" child:mmxElement];
		[topicIQ addAttributeWithName:@"from" stringValue: [[self.delegate currentJID] full]];
		[topicIQ addAttributeWithName:@"id" stringValue:[self.delegate generateMessageID]];
		return topicIQ;
	}
}


- (void)fetchItemsFromTopic:(MMXTopic *)topic
			  forMessageIDs:(NSArray *)messageIDs
					success:(void (^)(NSArray * messages))success
					failure:(void (^)(NSError * error))failure {
	if (![self hasActiveConnection]) {
		if (failure) {
			dispatch_async(self.callbackQueue, ^{
				failure([self connectionStatusError]);
			});
		}
		return;
	}
	
	NSError * parsingError;
	NSMutableDictionary * topicDictionary = @{@"topicName":topic.topicName,
											  @"userID":(topic.topicCreator && topic.topicCreator.username) ? topic.topicCreator.username : [NSNull null]
											  }.mutableCopy;
	BOOL all = YES;
	if (messageIDs && messageIDs.count) {
		[topicDictionary setObject:messageIDs forKey:@"itemIds"];
		all = NO;
	}
	XMPPIQ *topicIQ = [self fetchItemsFromTopicIQ:topicDictionary error:&parsingError];
	if (!parsingError) {
		[self.delegate sendIQ:topicIQ completion:^ (id obj, id <XMPPTrackingInfo> info) {
			XMPPIQ * iq = (XMPPIQ *)obj;
			if ([iq isErrorIQ]) {
				if (failure) {
					dispatch_async(self.callbackQueue, ^{
						failure([iq errorWithTitle:@"Fetch Items Failure."]);
					});
				}
			} else {
				NSError * parsingError;
				NSArray * messageArray = [MMXInternalMessageAdaptor pubsubMessagesFromFetchResponseIQ:iq topic:topic error:&parsingError];
				if (parsingError) {
					if (failure) {
						dispatch_async(self.callbackQueue, ^{
							failure(parsingError);
						});
					}
				} else {
					if (success) {
						dispatch_async(self.callbackQueue, ^{
							success(messageArray);
						});
					}
				}
				NSString* iqId = [iq elementID];
				[self.delegate stopTrackingIQWithID:iqId];
			}
		}];
	} else {
		if (failure) {
			dispatch_async(self.callbackQueue, ^{
				failure(parsingError);
			});
		}
	}

}


#pragma mark - Request Latest Posts

- (XMPPIQ *)topicRequestLatestIQ:(NSDictionary *)dict error:(NSError**)error {
	
	NSError * parsingError;
	NSXMLElement *mmxElement = [MMXUtils mmxElementFromValidJSONObject:dict xmlns:MXnsPubSub commandStringValue:MXcommandGetLatest error:&parsingError];
    if (parsingError) {
		*error = parsingError;
        return nil;
    } else {
        XMPPIQ *topicIQ = [[XMPPIQ alloc] initWithType:@"get" child:mmxElement];
        [topicIQ addAttributeWithName:@"from" stringValue: [[self.delegate currentJID] full]];
        [topicIQ addAttributeWithName:@"id" stringValue:[self.delegate generateMessageID]];
        return topicIQ;
    }
}

- (void)requestLatestPosts:(int)maxItems
					 since:(NSDate *)since
				   success:(void (^)(BOOL))success
				   failure:(void (^)(NSError *))failure {
    if (![self hasActiveConnection]) {
        if (failure) {
			dispatch_async(self.callbackQueue, ^{
				failure([self connectionStatusError]);
			});
        }
        return;
    }
    NSError * parsingError;
	NSDictionary * requestDictionary = @{@"since":[MMXUtils stringIniso8601Format:since],
                                       @"maxItems":@(maxItems),
                                       };
    XMPPIQ *topicIQ = [self topicRequestLatestIQ:requestDictionary error:&parsingError];
    if (!parsingError) {
        [self.delegate sendIQ:topicIQ completion:^ (id obj, id <XMPPTrackingInfo> info) {
            XMPPIQ * iq = (XMPPIQ *)obj;
            if ([iq isErrorIQ]) {
                if (failure) {
					dispatch_async(self.callbackQueue, ^{
						failure([iq errorWithTitle:@"Request Latest Posts Failure."]);
					});
                }
            } else {
                MMXIQResponse *response = [MMXIQResponse responseFromIQ:iq];
                if (response.code == 200) {
                    if (success) {
						dispatch_async(self.callbackQueue, ^{
							success(YES);
						});
                    }
                } else {
                    if (failure) {
						dispatch_async(self.callbackQueue, ^{
							failure([response errorFromResponse:@"Request Latest Posts Failure"]);
						});
                    }
                }
            }
			NSString* iqId = [iq elementID];
			[self.delegate stopTrackingIQWithID:iqId];
        }];
    } else {
        if (failure) {
			dispatch_async(self.callbackQueue, ^{
				failure(parsingError);
			});
        }
    }
}

#pragma mark - Publish GeoLocation

- (void)updateGeoLocation:(CLLocation *)location
                   success:(void (^)(BOOL))success
                   failure:(void (^)(NSError *))failure {
	[[MMXLogger sharedLogger] verbose:@"MMXPubSubManager publishGeoLocation. CLLocation = %@", location];
    if (![self hasActiveConnection]) {
        if (failure) {
			dispatch_async(self.callbackQueue, ^{
				failure([self connectionStatusError]);
			});
        }
        return;
    }
    NSXMLElement *mmxElement = [[NSXMLElement alloc] initWithName:MXmmxElement xmlns:MXnsDataPayload];
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        [[MMXLogger sharedLogger] verbose:@"Finding address"];
        if (error) {
            [[MMXLogger sharedLogger] error:@"Error %@", error.description];
        } else {
            CLPlacemark *placemark = [placemarks lastObject];
            NSXMLElement *payload = [self payloadFromlocation:location placemark:placemark];
            [mmxElement addChild:payload];
            NSXMLElement *meta = [MMXUtils metaDataToXML:@{ @"Content-Type": @"application/json" }];
            [mmxElement addChild:meta];
            NSXMLElement *itemElement = [[NSXMLElement alloc] initWithName:@"item"];
            NSString *messageID = [self.delegate generateMessageID];
            [itemElement addAttributeWithName:@"id" stringValue:messageID];
            [itemElement addChild:mmxElement];
            NSXMLElement *publishElement = [[NSXMLElement alloc] initWithName:@"publish"];
            [publishElement addAttributeWithName:@"node" stringValue:[NSString stringWithFormat:@"/%@/%@/com.magnet.geoloc", self.delegate.configuration.appID, [[self.delegate currentJID] usernameWithoutAppID]]];
            [publishElement addChild:itemElement];
            NSXMLElement *pubsubElement = [[NSXMLElement alloc] initWithName:@"pubsub" xmlns:@"http://jabber.org/protocol/pubsub"];
            [pubsubElement addChild:publishElement];
            
            XMPPIQ *postIQ = [[XMPPIQ alloc] initWithType:@"set" child:pubsubElement];
            [postIQ addAttributeWithName:@"from" stringValue: [[self.delegate currentJID] full]];
            [postIQ addAttributeWithName:@"id" stringValue:[self.delegate generateMessageID]];
            
            [postIQ addAttributeWithName:@"to" stringValue:[NSString stringWithFormat:@"pubsub.%@",[[self.delegate currentJID] domain]]];
            [self.delegate sendIQ:postIQ completion:^ (id obj, id <XMPPTrackingInfo> info) {
                XMPPIQ * iq = (XMPPIQ *)obj;
                if ([iq isErrorIQ]) {
                    if (failure) {
						dispatch_async(self.callbackQueue, ^{
							failure([iq errorWithTitle:@"GeoLocation Post Failure."]);
						});
                    }
                } else {
					if (success) {
						dispatch_async(self.callbackQueue, ^{
							success(YES);
						});
					}
                }
				NSString* iqId = [iq elementID];
				[self.delegate stopTrackingIQWithID:iqId];
            }];
			
        }
    }];
}

- (NSXMLElement *)payloadFromlocation:(CLLocation *)location placemark:(CLPlacemark *)placemark {
    NSDictionary * dict = @{@"accuracy": @(location.horizontalAccuracy),
                            @"lat": @(location.coordinate.latitude),
                            @"lng": @(location.coordinate.longitude),
                            @"altaccuracy": @(location.verticalAccuracy),
                            @"alt": @(location.horizontalAccuracy),
                            @"locality": placemark.locality,
                            @"subloc": placemark.subLocality,
                            @"subadmin": placemark.subAdministrativeArea,
                            @"adminarea": placemark.administrativeArea,
                            @"postal": placemark.postalCode,
                            @"country": placemark.country};
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    NSString *json = [[NSString alloc] initWithData:jsonData
                                           encoding:NSUTF8StringEncoding];
    return [MMXUtils contentToXML:json type:@"geoloc"];
}

#pragma mark - Topic Tags

- (NSDictionary *)parsedTagsResponseIQ:(XMPPIQ *)iq {
    NSMutableDictionary * responseDict = @{}.mutableCopy;
    NSXMLElement* mmxElement = [iq elementForName:MXmmxElement];
    if (mmxElement) {
        NSString* jsonContent =  [[mmxElement childAtIndex:0] XMLString];
        NSError* error;
        NSData* jsonData = [jsonContent dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
        if (!error && jsonDictionary[@"topicName"] && ![jsonDictionary[@"topicName"] isEqualToString:@""]) {
            [responseDict setObject:jsonDictionary[@"tags"] forKey:@"tags"];
            NSDate * lastTime = [MMXUtils dateFromiso8601Format:jsonDictionary[@"lastModTime"]];
            [responseDict setObject:lastTime forKey:@"lastModTime"];
            return jsonDictionary;
        }
    }
    return nil;
}

- (void)tagsForTopic:(MMXTopic *)topic
             success:(void (^)(NSDate * lastTimeModified, NSArray * tags))success
             failure:(void (^)(NSError * error))failure {
	[[MMXLogger sharedLogger] verbose:@"MMXPubSubManager tagsForTopic. MMXTopic = %@", topic];
	NSDictionary * dict = @{@"userId":topic.inUserNameSpace ? topic.nameSpace : [NSNull null],
                            @"topicName":topic.topicName};
    NSError * error;
    NSXMLElement *mmxElement = [MMXUtils mmxElementFromValidJSONObject:dict xmlns:MXnsPubSub commandStringValue:MXcommandGetTags error:&error];
    if (!error) {
        XMPPIQ *topicIQ = [[XMPPIQ alloc] initWithType:@"get" child:mmxElement];
        [topicIQ addAttributeWithName:@"from" stringValue: [[self.delegate currentJID] full]];
//        [topicIQ addAttributeWithName:@"to" stringValue:[NSString stringWithFormat:@"pubsub.%@",[[self.delegate currentJID] domain]]];
        [topicIQ addAttributeWithName:@"id" stringValue:[self.delegate generateMessageID]];
        [self.delegate sendIQ:topicIQ completion:^ (id obj, id <XMPPTrackingInfo> info) {
            XMPPIQ * iq = (XMPPIQ *)obj;
            if ([iq isErrorIQ]) {
                if (failure) {
					dispatch_async(self.callbackQueue, ^{
						failure([iq errorWithTitle:@"Channel Tags Request Failure."]);
					});
                }
            } else {
                if (success) {
					NSDictionary * dict = [self parsedTagsResponseIQ:iq];
					dispatch_async(self.callbackQueue, ^{
						success(dict[@"lastModTime"],dict[@"tags"]);
					});
                }
            }
			NSString* iqId = [iq elementID];
			[self.delegate stopTrackingIQWithID:iqId];
        }];
    } else {
        if (failure) {
            failure(error);
        }
    }
}

- (void)addTags:(NSArray *)tags
		  topic:(MMXTopic *)topic
		success:(void (^)(BOOL success))success
		failure:(void (^)(NSError * error))failure {
	[self updateTags:tags updateType:@"add" topic:topic success:success failure:failure];
}

- (void)setTags:(NSArray *)tags
		  topic:(MMXTopic *)topic
		success:(void (^)(BOOL success))success
		failure:(void (^)(NSError * error))failure {
	[self updateTags:tags updateType:@"set" topic:topic success:success failure:failure];
}

- (void)removeTags:(NSArray *)tags
			 topic:(MMXTopic *)topic
		   success:(void (^)(BOOL success))success
		   failure:(void (^)(NSError * error))failure {
	[self updateTags:tags updateType:@"remove" topic:topic success:success failure:failure];
}

- (void)updateTags:(NSArray *)tags
		updateType:(NSString *)updateType
			 topic:(MMXTopic *)topic
		   success:(void (^)(BOOL success))success
		failure:(void (^)(NSError * error))failure {
	if ([updateType isEqualToString:@"add"] && (tags == nil || tags.count < 1)) {
		if (failure) {
			dispatch_async(self.callbackQueue, ^{
				failure([MMXClient errorWithTitle:@"Invalid Tags" message:@"Tags cannot be empty." code:500]);
			});
		}
		return;
	}
	for (NSString * tag in tags) {
		if (![MMXUtils validateTag:tag]) {
			if (failure) {
				dispatch_async(self.callbackQueue, ^{
					failure([MMXClient errorWithTitle:@"Invalid Tags" message:@"Tag was too long or used invalid characters." code:500]);
				});
			}
			return;
		}
	}
	[[MMXLogger sharedLogger] verbose:@"MMXPubSubManager %@Tags:topic:. MMXTopic = %@\nTags=%@",updateType,topic,tags];
	NSDictionary * dict = @{@"userId":topic.inUserNameSpace ? topic.nameSpace : [NSNull null],
                            @"topicName":topic.topicName,
							@"tags":tags ? tags : @[]};
    NSError * error;
	NSString *commandString = [NSString stringWithFormat:@"%@Tags",updateType];
    NSXMLElement *mmxElement = [MMXUtils mmxElementFromValidJSONObject:dict xmlns:MXnsPubSub commandStringValue:commandString error:&error];
    if (!error) {
        XMPPIQ *topicIQ = [[XMPPIQ alloc] initWithType:@"set" child:mmxElement];
        [topicIQ addAttributeWithName:@"from" stringValue: [[self.delegate currentJID] full]];
        [topicIQ addAttributeWithName:@"id" stringValue:[self.delegate generateMessageID]];
        [self.delegate sendIQ:topicIQ completion:^ (id obj, id <XMPPTrackingInfo> info) {
            XMPPIQ * iq = (XMPPIQ *)obj;
            if ([iq isErrorIQ]) {
                if (failure) {
					dispatch_async(self.callbackQueue, ^{
						failure([iq errorWithTitle:[NSString stringWithFormat:@"%@ Channel Tags Failure.",[updateType capitalizedString]]]);
					});
                }
            } else {
                MMXIQResponse *response = [MMXIQResponse responseFromIQ:iq];
                NSString* iqId = [iq elementID];
                [self.delegate stopTrackingIQWithID:iqId];
                if (response.code == 200 || response.code == 201) {
                    if (success) {
						dispatch_async(self.callbackQueue, ^{
							success(YES);
						});
                    }
                } else {
                    if (failure) {
						dispatch_async(self.callbackQueue, ^{
							failure([response errorFromResponse:[NSString stringWithFormat:@"%@ Channel Tags Failure.",[updateType capitalizedString]]]);
						});
                    }
                }
            }
        }];
    } else {
        if (failure) {
			dispatch_async(self.callbackQueue, ^{
				failure(error);
			});
        }
    }
}


#pragma mark - Archive Message

- (void)archiveMessage:(MMXPubSubMessage *)message error:(NSError **)error {
    NSString * username = [self validFullUsernameForCurrentUser];
    if (username) {
        [[MMXDataModel sharedDataModel] addOutboxEntryWithPubSubMessage:message username:username];
    }
}

#pragma mark - Helper Methods


- (NSString *)validFullUsernameForCurrentUser {
    if ([self.delegate currentJID] && ![[[self.delegate currentJID] user] isEqualToString:@""]) {
        return [[self.delegate currentJID] user];
    } else if (self.delegate.configuration.credential.user && ![self.delegate.configuration.credential.user isEqualToString:@""]) {
        NSMutableString *username = [[NSMutableString alloc] init];
        [username appendString:self.delegate.configuration.credential.user];
        [username appendString:@"%"];
        [username appendString:self.delegate.configuration.appID];
        return username.copy;
    }
    return nil;
}

- (BOOL)hasNecessaryConfigurationAndCredentialToSend {
    if (!self.delegate.configuration || !self.delegate.configuration.appID || [self.delegate.configuration.appID isEqualToString:@""]) {
        return NO;
    }
    if (!self.delegate.configuration.credential.user || [self.delegate.configuration.credential.user isEqualToString:@""]) {
        return NO;
    }
    return YES;
}

- (BOOL)hasActiveConnection {
    if (self.delegate.connectionStatus != MMXConnectionStatusAuthenticated &&
        self.delegate.connectionStatus != MMXConnectionStatusConnected) {
        return NO;
    }
    return YES;
}

- (NSError *)connectionStatusError {
    return [MMXClient errorWithTitle:@"Not currently connected." message:@"The feature you are trying to use requires an active connection." code:503];
}

@end
