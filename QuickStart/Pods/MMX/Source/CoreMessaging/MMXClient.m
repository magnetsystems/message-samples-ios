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

#import "MMXClient_Private.h"

#import "MMXAssert.h"
#import "MMXConstants.h"
#import "MMXInternalAck.h"
#import "MMXInternalMessageAdaptor.h"
//DDXML.h needs to be imported before MMXMessage_Private.h
#import "DDXML.h"
#import "MMXInternalMessageAdaptor_Private.h"
#import "MMXInboundMessage_Private.h"
#import "MMXOutboundMessage_Private.h"
#import "MMXPubSubMessage_Private.h"
#import "MMXGeoLocationMessage_Private.h"
#import "MMXTopic_Private.h"
#import "MMXMessageOptions_Private.h"
#import "MMXMessageStateQueryResponse_Private.h"
#import "MMXPubSubManager_Private.h"
#import "MMXDataModel.h"
#import "MMXUserProfile_Private.h"
#import "MMXEndpoint.h"

#import "MMXOAuthPlatformAuthentication.h"
#import "MMXInvite_Private.h"
#import "MMXInviteResponse_Private.h"
#import "MMXNotificationConstants.h"

#import "MMXUtils.h"
#import "MMXMessageUtils.h"
#import "MMXMessage_Private.h"

#import "XMPP.h"
#import "XMPPJID+MMX.h"
#import "XMPPReconnect.h"
#import "XMPPIDTracker.h"
#import "MMXConfiguration.h"
#import "NSString+XEP_0106.h"

#import "MMUser+Addressable.h"

#import <AssertMacros.h>

@import CoreLocation;
@import MagnetMaxCore;
// Taken from https://github.com/AFNetworking/AFNetworking/blob/master/AFNetworking/AFSecurityPolicy.m
static BOOL MMXServerTrustIsValid(SecTrustRef serverTrust) {
    BOOL isValid = NO;
    SecTrustResultType result;
    __Require_noErr_Quiet(SecTrustEvaluate(serverTrust, &result), _out);

    isValid = (result == kSecTrustResultUnspecified || result == kSecTrustResultProceed);

    _out:
    return isValid;
}

//FIXME: At some point this should be set in a plist or something.
int const kTempVersionMajor = 1;
int const kTempVersionMinor = 0;
int const kPort = 5222;
int const kMaxReconnectionTries = 4;
int const kReconnectionTimerInterval = 4;

@interface MMXClient () <XMPPStreamDelegate, XMPPReconnectDelegate, MMXPubSubManagerDelegate>

@property (nonatomic, readwrite) MMXPubSubManager * pubsubManager;
@property (nonatomic, strong) XMPPReconnect * xmppReconnect;
@property (nonatomic, assign) NSUInteger messageNumber;
@property (nonatomic, assign) NSUInteger reconnectionTryCount;

- (NSString *)sanitizeDeviceToken:(NSData *)deviceToken;

@end

@implementation MMXClient

+ (instancetype)sharedClient {

    static MMXClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[MMXClient alloc] initWithConfiguration:nil delegate:nil];
    });

    return _sharedClient;
}

- (instancetype)init {
	if ((self = [super init])) {
		_delegate = nil;
		_mmxQueue = dispatch_queue_create("mmxQueue", NULL);
		_callbackQueue = dispatch_get_main_queue();
		_connectionStatus = MMXConnectionStatusNotConnected;
		_messageNumber = 0;
		_configuration = nil;
	}
	return self;
}


//FIXME: this method will need to go away as part of blowfish integration
- (instancetype)initWithConfiguration:(MMXConfiguration *)configuration delegate:(id <MMXClientDelegate>)delegate {
    if ((self = [super init])) {
        _delegate = delegate;
        _mmxQueue = dispatch_queue_create("mmxQueue", NULL);
		_callbackQueue = dispatch_get_main_queue();
        _connectionStatus = MMXConnectionStatusNotConnected;
		_messageNumber = 0;
		_reconnectionTryCount = 0;
		_configuration = configuration;
	}
    return self;
}


#pragma mark - MMModule methods

- (void)updateConfiguration:(NSDictionary *)configurationDict {
	if (configurationDict[@"mmx-host"]) {
		MMXConfiguration *config = [MMXConfiguration new];
		NSString *urlString = [NSString stringWithFormat:@"mmx://%@:%@",configurationDict[@"mmx-host"],configurationDict[@"mmx-port"]];
		config.baseURL = [NSURL URLWithString:urlString];
		config.shouldForceTLS = [configurationDict[@"tls-enabled"] boolValue];
		config.allowInvalidCertificates = [configurationDict[@"security-policy"] isEqualToString:@"NONE"] || [configurationDict[@"security-policy"] isEqualToString:@"RELAXED"];
		self.appID = configurationDict[@"mmx-appId"];
		self.configuration = config;
	} else {
		[[MMXLogger sharedLogger] error:@"Configuration ERROR (mmx-host == nil)"];
	}
}

- (void)updateDeviceID:(NSString *)deviceID
			  appToken:(NSString *)appToken {
	self.deviceID = deviceID;
	self.accessToken = appToken;
}

- (void)updateUsername:(NSString *)username deviceID:(NSString *)deviceID userToken:(NSString *)userToken {
	if (self.configuration == nil) {
		[[MMXLogger sharedLogger] error:@"MMXClient -updateUsername: Configuration ERROR (self.configuration == nil)"];
		return;
	} else if (self.configuration.baseURL == nil) {
		[[MMXLogger sharedLogger] error:@"MMXClient -updateUsername: Configuration ERROR (self.configuration.baseURL == nil)"];
		return;
	} else if (username == nil) {
		[[MMXLogger sharedLogger] error:@"MMXClient -updateUsername: username ERROR (username == nil)"];
		return;
	} else if (deviceID == nil) {
		[[MMXLogger sharedLogger] error:@"MMXClient -updateUsername: deviceID ERROR (deviceID == nil)"];
		return;
	} else if (userToken == nil) {
		[[MMXLogger sharedLogger] error:@"MMXClient -updateUsername: userToken ERROR (userToken == nil)"];
		return;
	} else if (self.appID == nil) {
		[[MMXLogger sharedLogger] error:@"MMXClient -updateUsername: self.appID ERROR (self.appID == nil)"];
		return;
	}
	self.username = username;
	self.deviceID = deviceID;
	self.accessToken = userToken;
}

#pragma mark - Current User

- (MMXUserID *)currentUser {
	if ([MMXUtils objectIsValidString:self.username]) {
		return [MMXUserID userIDWithUsername:self.username];
	} else {
		return nil;
	}
}

#pragma mark - Connection Lifecycle

- (BOOL)openStream {
	[[MMXLogger sharedLogger] verbose:@"MMXClient openStream start"];
    [self disconnect];
    self.xmppStream = [[XMPPStream alloc] init];
    self.iqTracker = [[XMPPIDTracker alloc] initWithStream:self.xmppStream dispatchQueue:self.mmxQueue];

	if (self.xmppReconnect != nil) {
		[self.xmppReconnect removeDelegate:self delegateQueue:self.mmxQueue];
		[self.xmppReconnect deactivate];
	} else {
		self.xmppReconnect = [[XMPPReconnect alloc] init];
	}
	[self.xmppReconnect addDelegate:self delegateQueue:self.mmxQueue];
	[self.xmppReconnect activate:self.xmppStream];
	self.xmppReconnect.reconnectTimerInterval = kReconnectionTimerInterval;
	
	[self updateConnectionStatus:MMXConnectionStatusConnecting error:nil];

	NSMutableString *userWithAppId = [[NSMutableString alloc] initWithString:[self.username jidEscapedString]];
    [userWithAppId appendString:@"%"];
    [userWithAppId appendString:self.appID];
	
    NSString *host = self.configuration.baseURL.host;

    [self.xmppStream setMyJID:[XMPPJID jidWithUser:userWithAppId
											domain:@"mmx"
										  resource:self.deviceID]];

    [self.xmppStream setHostName:host];

	[self.xmppStream setHostPort:[self.configuration.baseURL.port integerValue]];
	
    if (self.configuration.shouldForceTLS) {
        self.xmppStream.startTLSPolicy = XMPPStreamStartTLSPolicyRequired;
    }
    
    [self.xmppStream addDelegate:self delegateQueue:self.mmxQueue];
	
    NSError* error;
    BOOL result = [self.xmppStream connectWithTimeout:XMPPStreamTimeoutNone error:&error];
    if (!result) {
        if (error) {
            [[MMXLogger sharedLogger] verbose:@"Failed to attempt connecting. Fail with error. Error = %@", error.localizedDescription];
        } else {
            
            [[MMXLogger sharedLogger] verbose:@"Failed to connect. No error given"];
        }
    } else {
        [[MMXLogger sharedLogger] verbose:@"Attempting to connect"];
    }
    return result;

}

#pragma mark - Connection Lifecycle


- (BOOL)connect {
	if (self.configuration == nil) {
		[[MMXLogger sharedLogger] error:@"MMXClient -connect: Configuration ERROR (self.configuration == nil)"];
		return NO;
	} else if (self.configuration.baseURL == nil) {
		[[MMXLogger sharedLogger] error:@"MMXClient -connect: Configuration ERROR (self.configuration.baseURL == nil)"];
		return NO;
	} else if (self.username == nil) {
		[[MMXLogger sharedLogger] error:@"MMXClient -connect: username ERROR (username == nil)"];
		return NO;
	} else if (self.deviceID == nil) {
		[[MMXLogger sharedLogger] error:@"MMXClient -connect: deviceID ERROR (deviceID == nil)"];
		return NO;
	} else if (self.accessToken == nil) {
		[[MMXLogger sharedLogger] error:@"MMXClient -connect: userToken ERROR (userToken == nil)"];
		return NO;
	} else if (self.appID == nil) {
		[[MMXLogger sharedLogger] error:@"MMXClient -connect: self.appID ERROR (self.appID == nil)"];
		return NO;
	} else {
		[self openStream];
		return YES;
	}
}

- (void)authenticate {
	[[MMXLogger sharedLogger] verbose:@"MMXClient authenticate start"];
    NSError* error;
	if ([self.xmppStream authenticateWithMMXOAuthAccessToken:self.accessToken error:&error]) {
        if (error) {
            [[MMXLogger sharedLogger] verbose:@"ERROR = %@",error];
        }
        [[MMXLogger sharedLogger] verbose:@"connection completed"];
    } else {
		if (error == nil) {
			error = [MMXClient errorWithTitle:@"Unknown Messaging Error" message:@"Unable to connect to the Messaging server" code:500];
		}
        [[MMXLogger sharedLogger] verbose:@"Authentication Attempt Error:%@", error.description];
		[self updateConnectionStatus:MMXConnectionStatusAuthenticationFailure error:error];
    }
}

- (void)disconnect {
    if (self.xmppStream && [self.xmppStream isConnected]) {
        [self.xmppStream disconnect];
    }
}

- (void)closeConnectionAndInvalidateUserData {
	[self disconnect];
	self.configuration = nil;
	self.username = nil;
	self.appID = nil;
	self.deviceID = nil;
	self.accessToken = nil;
	
}

#pragma mark - Credentials

- (XMPPJID *)currentJID {
    return self.xmppStream.myJID;
}

#pragma mark - Session and Message IDs

+ (NSString *)sessionIdentifier {
	static NSString *__sessionIdentifier = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		NSString * uuid = [MMXUtils generateUUID];
		__sessionIdentifier = [uuid stringByReplacingOccurrencesOfString:@"-" withString:@""];
	});
	return __sessionIdentifier;
}

- (NSString *)generateMessageID {
	self.messageNumber = self.messageNumber + 1;
	return [NSString stringWithFormat:@"%@-%ld",[MMXClient sessionIdentifier],(unsigned long)self.messageNumber];
}

#pragma mark - PubSub Manager

- (MMXPubSubManager *)pubsubManager {
    if (!_pubsubManager) {
        _pubsubManager = [[MMXPubSubManager alloc] initWithDelegate:self];
    }
    return _pubsubManager;
}


#pragma mark - GeoLocation methods

- (void)updateGeoLocation:(CLLocation *)location
				 success:(void (^)(BOOL successful))success
				 failure:(void (^)(NSError *))failure {
	if (![self hasActiveConnection]) {
		if (failure) {
			failure([MMXClient connectionStatusError]);
		}
		return;
	}
	MMXTopic * geoTopic = [MMXTopic geoLocationTopicForUsername:[[self currentJID] usernameWithoutAppID]];
	[self.pubsubManager createTopic:geoTopic success:^(BOOL successful) {
		[self.pubsubManager updateGeoLocation:location success:success failure:failure];
	} failure:^(NSError *error) {
		if (error.code == 409) {
			[self.pubsubManager updateGeoLocation:location success:success failure:failure];
		} else {
			if (failure) {
				failure(error);
			}
		}
	}];
}

#pragma mark - Messaging methods

- (NSString *)sendMessage:(MMXOutboundMessage *)message {
	return [self sendMessage:message withOptions:nil];
}

- (NSString *)sendMessage:(MMXOutboundMessage *)outboundMessage
			  withOptions:(MMXMessageOptions *)options {
	MMXInternalMessageAdaptor *message = [MMXInternalMessageAdaptor messageTo:outboundMessage.recipients
									withContent:outboundMessage.messageContent
									messageType:nil
									   metaData:outboundMessage.metaData];
	message.messageID = outboundMessage.messageID;
	return [self sendMMXMessage:message withOptions:options shouldValidate:YES];
}

- (NSString *)sendMMXMessage:(MMXInternalMessageAdaptor *)outboundMessage
				 withOptions:(MMXMessageOptions *)options
			  shouldValidate:(BOOL)validate {
	

	if (validate && ![self validateAndRespondToErrorsForOutboundMessage:outboundMessage]) {
		return nil;
	}

	if (outboundMessage.messageID == nil) {
		outboundMessage.messageID = [self generateMessageID];
	}

	NSString * mType = @"chat";
    NSXMLElement *mmxElement = [[NSXMLElement alloc] initWithName:MXmmxElement xmlns:MXnsDataPayload];
	[mmxElement addChild:[MMXInternalMessageAdaptor xmlFromRecipients:outboundMessage.recipients senderAddress:[MMUser currentUser].address]];
	[mmxElement addChild:[outboundMessage contentToXML]];

    if (outboundMessage.metaData) {
        [mmxElement addChild:[outboundMessage metaDataToXML]];
    }
	
	XMPPMessage *xmppMessage;
	NSString *fullUsername = [NSString stringWithFormat:@"mmx$multicast%%%@",self.appID];
	XMPPJID *toAddress = [XMPPJID jidWithUser:fullUsername domain:[[self currentJID] domain] resource:nil];
	xmppMessage = [[XMPPMessage alloc] initWithType:mType to:toAddress];
	[xmppMessage addAttributeWithName:@"from" stringValue: [[self currentJID] full]];
	
	//Always sending delivery receipt request because Android can't function without it
//	if (options && options.shouldRequestDeliveryReceipt) {
		NSXMLElement *deliveryReceiptElement = [[NSXMLElement alloc] initWithName:MXrequestElement xmlns:MXnsDeliveryReceipt];
		[xmppMessage addChild:deliveryReceiptElement];
//	}
	
	[xmppMessage addChild:mmxElement.copy];
	[xmppMessage addAttributeWithName:@"id" stringValue:outboundMessage.messageID];
	
	[[MMXLogger sharedLogger] verbose:@"About to send the message %@", outboundMessage.messageID];
	
	[self.xmppStream sendElement: xmppMessage];
	return outboundMessage.messageID;
}

- (BOOL)validateAndRespondToErrorsForOutboundMessage:(MMXInternalMessageAdaptor *)outboundMessage {
	MMXAssert(!(outboundMessage.messageContent == nil && outboundMessage.metaData == nil),@"MMXClient sendMessage: messageContent && metaData cannot both be nil");
	if (outboundMessage == nil) {
		if ([self.delegate respondsToSelector:@selector(client:didFailToSendMessage:recipients:error:)]) {
			NSError * error = [MMXClient errorWithTitle:@"Message cannot be nil" message:@"Message cannot be nil" code:401];
			[self.delegate client:self didFailToSendMessage:nil recipients:nil error:error];
		}
		return NO;
	}
	if (outboundMessage.recipients == nil || outboundMessage.recipients.count < 1) {
		if ([self.delegate respondsToSelector:@selector(client:didFailToSendMessage:recipients:error:)]) {
			NSError * error = [MMXClient errorWithTitle:@"Recipients not set" message:@"Recipients cannot be nil" code:401];
			[self.delegate client:self didFailToSendMessage:outboundMessage.messageID recipients:nil error:error];
		}
		return NO;
	}
	
	if (![MMXMessageUtils isValidMetaData:outboundMessage.metaData]) {
		if ([self.delegate respondsToSelector:@selector(client:didFailToSendMessage:recipients:error:)]) {
			NSError * error = [MMXClient errorWithTitle:@"Not Valid" message:@"All values must be strings." code:401];
			[self.delegate client:self didFailToSendMessage:outboundMessage.messageID recipients:outboundMessage.recipients error:error];
		}
		return NO;
	}
	if ([MMXMessageUtils sizeOfMessageContent:outboundMessage.messageContent metaData:outboundMessage.metaData] > kMaxMessageSize) {
		if ([self.delegate respondsToSelector:@selector(client:didFailToSendMessage:recipients:error:)]) {
			NSError * error = [MMXClient errorWithTitle:@"Message too large" message:@"Message content and metaData exceed the max size of 200KB" code:401];
			[self.delegate client:self didFailToSendMessage:outboundMessage.messageID recipients:outboundMessage.recipients error:error];
		}
		return NO;
	}
	return YES;
}

- (NSString *)sendDeliveryConfirmationForMessage:(MMXInboundMessage *)message {
	return [self sendDeliveryConfirmationForAddress:message.senderUserID.address messageID:message.messageID toDeviceID:message.senderEndpoint.deviceID];
}

- (NSString *)sendDeliveryConfirmationForAddress:(MMXInternalAddress *)address messageID:(NSString *)messageID toDeviceID:(NSString *)deviceID {
	NSString *sender = [NSString stringWithFormat:@"%@%%%@@%@", address.username, self.appID, self.configuration.domain];
	if (deviceID) {
		sender = [NSString stringWithFormat:@"%@/%@", sender, deviceID];
	}
    XMPPJID *respondToAddress = [XMPPJID jidWithString:sender];
    
    XMPPMessage *confirmationMessage = [[XMPPMessage alloc] initWithType:@"chat" to:respondToAddress];
	[confirmationMessage addAttributeWithName:@"from" stringValue: [[self currentJID] full]];
	[confirmationMessage addBody:@"."];

    NSXMLElement *receivedElement = [[NSXMLElement alloc] initWithName:MXreceivedElement xmlns:MXnsDeliveryReceipt];
    NSString *sourceMessageId = messageID;
    [receivedElement addAttributeWithName:@"id" stringValue:sourceMessageId];
    [confirmationMessage addChild:receivedElement];
    
    NSString *confirmationMessageID = [self generateMessageID];
    //id for this message
    [confirmationMessage addAttributeWithName:@"id" stringValue:confirmationMessageID];
    [[MMXLogger sharedLogger] verbose:@"About to send the delivery confirmation message %@", confirmationMessage];
    
    [self.xmppStream sendElement:confirmationMessage];
    
    return messageID;
}

- (void)sendSDKAckMessageId:(NSString*)messageID sourceFrom:(XMPPJID*)sfrom sourceTo:(XMPPJID*)sto {
    MMXInternalAck *ack = [[MMXInternalAck alloc] init];
    ack.from = [sfrom full];
    ack.to = [sto full];
    ack.msgID = messageID;
    NSDictionary *ackDictionary = [ack dictionaryRepresentation];
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:ackDictionary
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    NSString *json = [[NSString alloc] initWithData:jsonData
                                           encoding:NSUTF8StringEncoding];
    if (error) {
        [[MMXLogger sharedLogger] verbose:@"Error withJSON Serialization %@", error.localizedDescription];
    }
    NSXMLElement *mmxElement = [[NSXMLElement alloc] initWithName:MXmmxElement xmlns:MXnsMsgAck];
    [mmxElement addAttributeWithName:MXcommandString stringValue:MXcommandAck];
    [mmxElement setStringValue:json];
    [mmxElement addAttributeWithName:MXctype stringValue:MXctypeJSON];
    
    [[MMXLogger sharedLogger] verbose:@"message ack xml  %@", mmxElement];
    
    XMPPIQ *ackIQ = [[XMPPIQ alloc] initWithType:@"set" child:mmxElement];
    [ackIQ addAttributeWithName:@"from" stringValue: [[self currentJID] full]];
    [ackIQ addAttributeWithName:@"id" stringValue:[self generateMessageID]];
    
    [self sendIQ:ackIQ completion:^(id obj, id<XMPPTrackingInfo> info) {
        XMPPIQ * iq = (XMPPIQ *)obj;
        NSString* iqId = [iq elementID];
        [self stopTrackingIQWithID:iqId];
        [[MMXLogger sharedLogger] verbose:@"Process Internal Ack IQ Response %@", iq];
    }];
}

- (void)queryStateForMessages:(NSArray *)messageIDs
                      success:(void (^)(NSDictionary * response))success
                      failure:(void (^)(NSError * error))failure {

    NSError * jsonError;
	NSXMLElement *mmxElement = [MMXUtils mmxElementFromValidJSONObject:messageIDs xmlns:MXnsMsgState commandStringValue:MXcommandQuery error:&jsonError];

    if (jsonError) {
        if (failure) {
			dispatch_async(self.callbackQueue, ^{
				failure(jsonError);
			});
        }
        return;
    }
    
    XMPPIQ *queryIQ = [[XMPPIQ alloc] initWithType:@"get" child:mmxElement];
    [queryIQ addAttributeWithName:@"from" stringValue: [self.xmppStream.myJID full]];
    [queryIQ addAttributeWithName:@"id" stringValue:[self generateMessageID]];

    [self sendIQ:queryIQ completion:^ (id obj, id <XMPPTrackingInfo> info) {
        XMPPIQ * iq = (XMPPIQ *)obj;
        MMXMessageStateQueryResponse *queryResponse = [MMXMessageStateQueryResponse initWithIQ:iq];
        NSString* iqId = [iq elementID];
        [self stopTrackingIQWithID:iqId];
        if (queryResponse) {
            if (success) {
				dispatch_async(self.callbackQueue, ^{
					success(queryResponse.queryResult);
				});
            }
        } else {
            //FIXME: There is no documentation for an error response
            NSDictionary *userInfo = @{
                                       NSLocalizedDescriptionKey: NSLocalizedString(@"Message status query failure.", nil),
                                       NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Something went wrong", nil),
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

#pragma mark - IQs

- (void)sendIQ:(XMPPIQ*)iq completion:(IQCompletionBlock)completion {
    __weak __typeof__(self) weakSelf = self;
    dispatch_block_t block = ^{
        __typeof__(self) strongSelf = weakSelf;
         [strongSelf.xmppStream sendElement: iq];
        [strongSelf.iqTracker addElement:iq block:completion timeout:15];
    };
    dispatch_async(self.mmxQueue, block);
}

- (void)stopTrackingIQWithID:(NSString*)trackingID {
    [self.iqTracker removeID:trackingID];
}

#pragma mark - Priority/Availability

- (void)updatePresenceWithPriority:(NSInteger)priorityValue {
	NSXMLElement *priority = [NSXMLElement elementWithName:@"priority" stringValue:[@(priorityValue) stringValue]];
	XMPPPresence * presence = [XMPPPresence presenceWithType:(priorityValue >= 0) ? @"available" : @"unavailable"];
	[presence addChild:priority];
	[self.xmppStream sendElement:presence];
}

- (void)setShouldSuspendIncomingMessages:(BOOL)shouldSuspendIncomingMessages {
	_shouldSuspendIncomingMessages = shouldSuspendIncomingMessages;
	if ([self.xmppStream isConnected]) {
		if (shouldSuspendIncomingMessages) {
			[self updatePresenceWithPriority:-1];
		} else {
			[self updatePresenceWithPriority:24];
		}
	}
}

#pragma mark - Queued Messages

- (NSArray *)queuedMessagesForType:(MMXOutboxEntryMessageType)type {
    NSString * username  = self.xmppStream.myJID.user ?: self.username;
    NSMutableArray * messageArray = @[].mutableCopy;
    NSArray * archivedMessages = [[MMXDataModel sharedDataModel] outboxEntriesForUser:username outboxEntryMessageType:type];
    for (MMXOutboxEntry * entry in archivedMessages) {
        [[MMXLogger sharedLogger] verbose:@"MMXOutboxEntry = %@",entry];
        MMXInternalMessageAdaptor * message = [[MMXDataModel sharedDataModel] extractMessageFromOutboxEntry:entry];
        if (type == MMXOutboxEntryMessageTypeDefault) {
            [messageArray addObject:[MMXOutboundMessage initWithMessage:message]];
        } else if (type == MMXOutboxEntryMessageTypePubSub) {
            [messageArray addObject:[MMXPubSubMessage initWithMessage:message]];
        }
    }
    return messageArray.copy;
}

- (NSArray *)queuedMessages {
    return [self queuedMessagesForType:MMXOutboxEntryMessageTypeDefault];
}

- (NSArray *)deleteQueuedMessages:(NSArray *)messages {
    if (!messages || !messages.count) {
        return @[];
    } else {
        NSMutableArray * failedArray = @[].mutableCopy;
        for (MMXOutboundMessage * message in messages) {
            [[MMXLogger sharedLogger] verbose:@"Deleting message with ID = %@", message.messageID];
            if (![[MMXDataModel sharedDataModel] deleteOutboxEntryForMessage:message.messageID]) {
                [failedArray addObject:message];
            }
        }
        return failedArray.copy;
    }
}

- (NSArray *)queuedPubSubMessages {
    return [self queuedMessagesForType:MMXOutboxEntryMessageTypePubSub];
}

- (NSArray *)deleteQueuedPubSubMessages:(NSArray *)messages {
    if (!messages || !messages.count) {
        return @[];
    } else {
        NSMutableArray * failedArray = @[].mutableCopy;
        for (MMXOutboundMessage * message in messages) {
            [[MMXLogger sharedLogger] verbose:@"Deleting message with ID = %@", message.messageID];
            if (![[MMXDataModel sharedDataModel] deleteOutboxEntryForMessage:message.messageID]) {
                [failedArray addObject:message];
            }
        }
        return failedArray.copy;
    }
}


#pragma mark - Archived Messages

- (void)sendArchivedMessages {
	NSString * username  = self.xmppStream.myJID.user ?: self.username;
    NSArray * archivedMessages = [[MMXDataModel sharedDataModel] outboxEntriesForUser:username outboxEntryMessageType:MMXOutboxEntryMessageTypeDefault];
    for (MMXOutboxEntry * entry in archivedMessages) {
        [[MMXLogger sharedLogger] verbose:@"MMXOutboxEntry = %@",entry];
        MMXInternalMessageAdaptor * message = [[MMXDataModel sharedDataModel] extractMessageFromOutboxEntry:entry];
        MMXMessageOptions * options = [[MMXDataModel sharedDataModel] extractMessageOptionsFromOutboxEntry:entry];
        [[MMXDataModel sharedDataModel] deleteOutboxEntryForMessage:message.messageID];
        [self sendMessage:[MMXOutboundMessage initWithMessage:message] withOptions:options];
    }
    NSArray * archivedPubSubMessages = [[MMXDataModel sharedDataModel] outboxEntriesForUser:username outboxEntryMessageType:MMXOutboxEntryMessageTypePubSub];
    for (MMXOutboxEntry * entry in archivedPubSubMessages) {
        [[MMXLogger sharedLogger] verbose:@"MMXOutboxEntry = %@",entry];
        MMXInternalMessageAdaptor * message = [[MMXDataModel sharedDataModel] extractMessageFromOutboxEntry:entry];
        [[MMXDataModel sharedDataModel] deleteOutboxEntryForMessage:message.messageID];

		MMXPubSubMessage *pubMessage = [MMXPubSubMessage initWithMessage:message];
		[self.pubsubManager publishPubSubMessage:pubMessage success:nil failure:^(NSError * error){
			[[MMXDataModel sharedDataModel] addOutboxEntryWithPubSubMessage:pubMessage username:username];
		}];
    }
}

#pragma mark - XMPPReconnect
#pragma mark XMPPReconnectDelegate Callbacks

- (void)xmppReconnect:(XMPPReconnect *)sender didDetectAccidentalDisconnect:(SCNetworkConnectionFlags)connectionFlags {
	[[MMXLogger sharedLogger] error:@"Received didDetectAccidentalDisconnect callback."];
}

- (BOOL)xmppReconnect:(XMPPReconnect *)sender shouldAttemptAutoReconnect:(SCNetworkConnectionFlags)connectionFlags {
	/*
		isNetworkReachable logic borrowed from AFNetworking/AFNetworkReachabilityManager
		https://github.com/AFNetworking/AFNetworking/blob/master/AFNetworking/AFNetworkReachabilityManager.m
	 */
	
	BOOL isReachable = ((connectionFlags & kSCNetworkReachabilityFlagsReachable) != 0);
	BOOL needsConnection = ((connectionFlags & kSCNetworkReachabilityFlagsConnectionRequired) != 0);
	BOOL canConnectionAutomatically = (((connectionFlags & kSCNetworkReachabilityFlagsConnectionOnDemand ) != 0) || ((connectionFlags & kSCNetworkReachabilityFlagsConnectionOnTraffic) != 0));
	BOOL canConnectWithoutUserInteraction = (canConnectionAutomatically && (connectionFlags & kSCNetworkReachabilityFlagsInterventionRequired) == 0);
	BOOL isNetworkReachable = (isReachable && (!needsConnection || canConnectWithoutUserInteraction));
	
	if (isNetworkReachable) {
		if (self.connectionStatus != MMXConnectionStatusReconnecting) {
			[self updateConnectionStatus:MMXConnectionStatusReconnecting error:nil];
		}
		return YES;
	}
	return NO;
}



#pragma mark - XMPPStreamDelegate
#pragma mark - XMPPStreamDelegate Connection Lifecycle Methods

- (void)xmppStream:(XMPPStream *)sender willSecureWithSettings:(NSMutableDictionary *)settings {
    settings[GCDAsyncSocketManuallyEvaluateTrust] = @(YES);
}

- (void)xmppStream:(XMPPStream *)sender
   didReceiveTrust:(SecTrustRef)trust
 completionHandler:(void (^)(BOOL shouldTrustPeer))completionHandler {
    BOOL shouldTrustPeer = NO;
    if (self.configuration.allowInvalidCertificates) {
       shouldTrustPeer = YES;
    } else {
        NSMutableArray *policies = [NSMutableArray array];
        [policies addObject:(__bridge_transfer id)SecPolicyCreateBasicX509()];

        SecTrustSetPolicies(trust, (__bridge CFArrayRef)policies);

        if (MMXServerTrustIsValid(trust)) {
            shouldTrustPeer = YES;
        }

    }
    completionHandler(shouldTrustPeer);
}

- (void)xmppStreamDidConnect:(XMPPStream *)sender {
	[self updateConnectionStatus:MMXConnectionStatusConnected error:nil];
	self.reconnectionTryCount = 0;
    [[MMXLogger sharedLogger] verbose:@"Successfully created TCP connection"];
    [self authenticate];
}

- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(NSXMLElement *)error {
	NSError *authError = [MMXClient errorWithTitle:@"Authentication Failure" message:@"Not Authorized. Please check your credentials and try again." code:401];
	[self updateConnectionStatus:MMXConnectionStatusAuthenticationFailure error:authError];
}

- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender {
	[self postAuthenticationTasks];
	[self updateConnectionStatus:MMXConnectionStatusAuthenticated error:nil];
}

- (void)postAuthenticationTasks {
	if (self.shouldSuspendIncomingMessages) {
		[self updatePresenceWithPriority:-1];
	} else {
		[self updatePresenceWithPriority:24];
	}
	[self sendArchivedMessages];
}

- (void)xmppStreamDidDisconnect:(XMPPStream *)sender withError:(NSError *)error {
	if (error) {
		[self updateConnectionStatus:MMXConnectionStatusDisconnected error:error];
		[[MMXLogger sharedLogger] error:@"%@\ncode=%li", error.localizedDescription,(long)error.code];
	}
	if (self.connectionStatus == MMXConnectionStatusReconnecting) {
		if (self.reconnectionTryCount >= kMaxReconnectionTries) {
			self.reconnectionTryCount = 0;
			[self.xmppReconnect stop];
		} else {
			self.reconnectionTryCount++;
			return;
		}
	}
}

#pragma mark - XMPPStreamDelegate Message/IQ Methods

- (BOOL)xmppStream:(XMPPStream *)stream didReceiveIQ:(XMPPIQ *)iq {
    NSString *type = [iq type];
    if ([type isEqualToString:@"result"] || [type isEqualToString:@"error"]) {
        return [self.iqTracker invokeForID:[iq elementID] withObject:iq];
    }
    return NO;
}

- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)xmppMessage {
	if ([xmppMessage isErrorMessage]) {
		MMXInternalMessageAdaptor * message = [MMXInternalMessageAdaptor initWithXMPPMessage:xmppMessage];
		if ([message.messageContent containsString:@"recipient_unavailable"]) {
			NSData *jsonData = [message.messageContent dataUsingEncoding:NSUTF8StringEncoding];
			NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil] ?: @{};
			if ([self.delegate respondsToSelector:@selector(client:didFailToSendMessage:recipients:error:)]) {
				dispatch_async(self.callbackQueue, ^{
					NSError *error = [MMXClient errorWithTitle:@"Invalid User" message:@"The user you are trying to send a message to does not exist or does not have a valid device associated with them." code:500];
					NSArray *paramsArray = jsonDictionary[@"params"] ?: @[];
					NSString *username = paramsArray.firstObject;
					MMUser *user = [MMUser new];
					user.userName = username ?: @"Unknown";
					[self.delegate client:self didFailToSendMessage:jsonDictionary[@"msgId"] ?: @"Unknown" recipients:@[user] error:error];
				});
			}
		} else if ([self.delegate respondsToSelector:@selector(client:didReceiveError:severity:messageID:)]) {
			if ([message.mType isEqualToString:@"mmxerror"]) {
				[self handleErrorMessage:message];
			} else {
				dispatch_async(self.callbackQueue, ^{
					[self.delegate client:self didReceiveError:[xmppMessage errorMessage] severity:MMXErrorSeverityUnknown messageID:@""];
				});
			}
		}
		return;
	}
	if ([MMXClient isPubSubMessage:xmppMessage]) {
		NSArray * messageArray = [MMXPubSubMessage pubSubMessagesFromXMPPMessage:xmppMessage];
		[self handlePubSubMessages:messageArray];
		return;
	} else if ([xmppMessage elementsForXmlns:MXnsDataPayload].count) {
		XMPPJID *to = [xmppMessage to] ;
		XMPPJID *from =[xmppMessage from];
		NSString *msgId = [xmppMessage elementID];
		MMXInternalMessageAdaptor* inMessage = [MMXInternalMessageAdaptor initWithXMPPMessage:xmppMessage];
		if ([inMessage.mType isEqualToString:@"invitation"]) {
			//Channel Invitation Message
			[self handleInviteMessageFromInternalMessageAdaptor:inMessage from:from to:to messageID:msgId];
		} else if ([inMessage.mType isEqualToString:@"invitationResponse"]) {
			//Channel Invitation Response Message
			[self handleInviteResponseMessageFromInternalMessageAdaptor:inMessage from:from to:to messageID:msgId];
		} else {
			//User to User Message
			[self handleInboundMessageFromInternalMessageAdaptor:inMessage from:from to:to messageID:msgId];
		}
	} else if ([xmppMessage elementsForXmlns:MXnsServerSignal].count) {
		NSArray* mmxElements = [xmppMessage elementsForName:MXmmxElement];
		NSXMLElement *mmxElement = mmxElements[0];
		NSArray* mmxMetaElements = [mmxElement elementsForName:MXmmxMetaElement];
		NSXMLElement *recipientElement = mmxMetaElements[0];
		NSString* metaJSON = [recipientElement stringValue];
		if (metaJSON && [metaJSON length] > 0) {
			NSData* jsonData = [metaJSON dataUsingEncoding:NSUTF8StringEncoding];
			NSError* readError;
			NSDictionary * mmxMetaDict = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&readError];
			if (readError == nil) {
				NSDictionary *serverackDict = mmxMetaDict[@"endack"];
				if (serverackDict) {
					NSString *ackForMsgId = serverackDict[@"ackForMsgId"];
					NSArray *badReceiversArray = serverackDict[@"badReceivers"];
					NSArray *invalidUsers = badReceiversArray ? [badReceiversArray valueForKey:@"userId"] : @[];
					if (ackForMsgId && [self.delegate respondsToSelector:@selector(client:didReceiveServerAckForMessageID:invalidUsers:)]) {
						dispatch_async(self.callbackQueue, ^{
							[self.delegate client:self didReceiveServerAckForMessageID:ackForMsgId invalidUsers:[NSSet setWithArray:invalidUsers]];
						});
					}
				}
			}
		}
    } else {
        NSXMLElement *mmxElement = [xmppMessage elementForName:MXreceivedElement];
		if (mmxElement) {
			XMPPJID* to = [xmppMessage to] ;
			XMPPJID* from =[xmppMessage from];
			NSString* msgId = [xmppMessage elementID];
			[self sendSDKAckMessageId:msgId sourceFrom:from sourceTo:to];
			if ([self.delegate respondsToSelector:@selector(client:didDeliverMessage:recipient:)]) {
				dispatch_async(self.callbackQueue, ^{
					NSString *confirmedMessageID = [[mmxElement attributeForName:@"id"] stringValue];
					[self.delegate client:self didDeliverMessage:confirmedMessageID recipient:[MMXUserID userIDWithUsername:[[from usernameWithoutAppID] jidUnescapedString]]];
				});
			}
		} else {
			[[MMXLogger sharedLogger] verbose:@"No mmx element %@", mmxElement];
		}
    }
}

- (void)xmppStream:(XMPPStream *)sender didSendMessage:(XMPPMessage *)message {
	
}

- (void)xmppStream:(XMPPStream *)sender didFailToSendMessage:(XMPPMessage *)message error:(NSError *)error {
	if (error) {
		[[MMXLogger sharedLogger] error:@"%@", error.localizedDescription];
	}
    MMXInternalMessageAdaptor* outboundMessage = [MMXInternalMessageAdaptor initWithXMPPMessage:message];

	if ([self.delegate respondsToSelector:@selector(client:didFailToSendMessage:recipients:error:)]) {
		dispatch_async(self.callbackQueue, ^{
			[self.delegate client:self didFailToSendMessage:outboundMessage.messageID recipients:outboundMessage.recipients error:error];
		});
    }
}

#pragma mark - Message Handling

- (void)handleInboundMessageFromInternalMessageAdaptor:(MMXInternalMessageAdaptor *)message
												  from:(XMPPJID *)from
													to:(XMPPJID *)to
											 messageID:(NSString *)messageID {
	
	NSMutableArray *usernamesArray = [NSMutableArray arrayWithArray:[message.recipients valueForKey:@"username"]];
	BOOL recipientsContainSender = NO;
	if ([usernamesArray containsObject:message.senderUserID.username]) {
		recipientsContainSender = YES;
	} else {
		[usernamesArray addObject:message.senderUserID.username];
	}
	[usernamesArray addObject:message.senderUserID.username];
	[MMUser usersWithUserIDs:usernamesArray success:^(NSArray *users) {
		MMUser *sender;
		NSMutableArray *usersCopy = users.mutableCopy;
		for (MMUser *user in users) {
			if ([user.userID.lowercaseString isEqualToString:message.senderUserID.username.lowercaseString]) {
				sender = user.copy;
			}
		}
		if (!recipientsContainSender) {
			[usersCopy removeObject:sender];
		}
		
		MMXMessage *msg = [MMXMessage messageToRecipients:[NSSet setWithArray:usersCopy]
										   messageContent:message.metaData];
		
		msg.messageType = MMXMessageTypeDefault;
		
		msg.sender = sender;
		msg.timestamp = message.timestamp;
		msg.messageID = message.messageID;
		msg.senderDeviceID = message.senderEndpoint.deviceID;
		[[NSNotificationCenter defaultCenter] postNotificationName:MMXDidReceiveMessageNotification
															object:nil
														  userInfo:@{MMXMessageKey:msg}];
		if (![message.mType isEqualToString:@"normal"]) {
			//Send server ack after successfully parsed message and notification to dev sent
			[self sendSDKAckMessageId:messageID sourceFrom:from sourceTo:to];
		}
	} failure:^(NSError * error) {
		[[MMLogger sharedLogger] error:@"Failed to get users for Inbound Message\n%@",error];
	}];
	
}

- (void)handleInviteMessageFromInternalMessageAdaptor:(MMXInternalMessageAdaptor *)message
												 from:(XMPPJID *)from
												   to:(XMPPJID *)to
											messageID:(NSString *)messageID {
	MMXInvite *invite = [MMXInvite inviteFromMMXInternalMessage:message];
	[MMUser usersWithUserIDs:@[message.senderUserID.username] success:^(NSArray *users) {
		if (users.count) {
			invite.sender = users.firstObject;
		}
		[[NSNotificationCenter defaultCenter] postNotificationName:MMXDidReceiveChannelInviteNotification
															object:nil
														  userInfo:@{MMXInviteKey:invite}];
		//Send server ack after successfully parsed message and notification to dev sent
		[self sendSDKAckMessageId:messageID sourceFrom:from sourceTo:to];
	} failure:^(NSError * error) {
		[[MMLogger sharedLogger] error:@"Failed to get users for Invite\n%@",error];
	}];
}

- (void)handleInviteResponseMessageFromInternalMessageAdaptor:(MMXInternalMessageAdaptor *)message
														 from:(XMPPJID *)from
														   to:(XMPPJID *)to
													messageID:(NSString *)messageID {

	MMXInviteResponse *inviteResponse = [MMXInviteResponse inviteResponseFromMMXInternalMessage:message];
	[MMUser usersWithUserIDs:@[message.senderUserID.username] success:^(NSArray *users) {
		if (users.count) {
			inviteResponse.sender = users.firstObject;
		}
		[[NSNotificationCenter defaultCenter] postNotificationName:MMXDidReceiveChannelInviteResponseNotification
															object:nil
														  userInfo:@{MMXInviteResponseKey:inviteResponse}];
		//Send server ack after successfully parsed message and notification to dev sent
		[self sendSDKAckMessageId:messageID sourceFrom:from sourceTo:to];
	} failure:^(NSError * error) {
		[[MMLogger sharedLogger] error:@"Failed to get users for Invite Response\n%@",error];
	}];

}

- (void)handlePubSubMessages:(NSArray *)messageArray {
	NSArray *usernames = [[messageArray valueForKey:@"senderUserID"] valueForKey:@"username"];
	if (usernames && usernames.count) {
		[MMUser usersWithUserIDs:usernames success:^(NSArray *users) {
			for (MMXPubSubMessage *pubMsg in messageArray) {
				NSPredicate *usernamePredicate = [NSPredicate predicateWithFormat:@"userID = %@",pubMsg.senderUserID.username];
				MMUser *sender = [users filteredArrayUsingPredicate:usernamePredicate].firstObject;
				MMXMessage *channelMessage = [MMXMessage messageFromPubSubMessage:pubMsg sender:sender];
				[[NSNotificationCenter defaultCenter] postNotificationName:MMXDidReceiveMessageNotification
																	object:nil
																  userInfo:@{MMXMessageKey:channelMessage}];
	
			}
		} failure:^(NSError * error) {
			[[MMLogger sharedLogger] error:@"Failed to get users for MMXMessages from Channels\n%@",error];
		}];
		return;
	}
	[[MMLogger sharedLogger] error:@"Failed to get users for MMXMessages from Channels\n"];
}

#pragma mark Error Message Handling

- (void)handleErrorMessage:(MMXInternalMessageAdaptor *)message {
    NSString* jsonContent =  message.messageContent;
    NSError* error;
    NSData* jsonData = [jsonContent dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
    if (error) {
        return;
    }
    error = [MMXClient errorWithTitle:@"Error from server." message:mmxNullSafeConversion(jsonDictionary[@"message"]) code:[mmxNullSafeConversion(jsonDictionary[@"code"]) intValue]];
    MMXErrorSeverity severity = [MMXClient severityFromString:mmxNullSafeConversion(jsonDictionary[@"severity"])];
    NSString * messageID = mmxNullSafeConversion(jsonDictionary[@"msgId"]);
	dispatch_async(self.callbackQueue, ^{
		[self.delegate client:self didReceiveError:error severity:severity messageID:messageID];
	});
}

+ (MMXErrorSeverity)severityFromString:(NSString *)severity {
    if (severity && ![severity isEqualToString:@""]) {
        if ([severity isEqualToString:@"NONE"]) {
            return MMXErrorSeverityNone;
        }
        if ([severity isEqualToString:@"TRIVIAL"]) {
            return MMXErrorSeverityTrivial;
        }
        if ([severity isEqualToString:@"TEMPORARY"]) {
            return MMXErrorSeverityTemporary;
        }
        if ([severity isEqualToString:@"MAJOR"]) {
            return MMXErrorSeverityMajor;
        }
        if ([severity isEqualToString:@"CRITICAL"]) {
            return MMXErrorSeverityCritical;
        }
    }
    return MMXErrorSeverityUnknown;
}

#pragma mark - Helper Methods

- (BOOL)hasActiveConnection {
	if (self.connectionStatus != MMXConnectionStatusAuthenticated &&
		self.connectionStatus != MMXConnectionStatusConnected) {
		return NO;
	}
	return YES;
}

- (BOOL)hasValidCredentials {
	if (!self.configuration.credential) {
		NSError * error = [MMXClient errorWithTitle:@"Credentials not set." message:@"Please set the credential property in on your configuration to a valid NSURLCredential object." code:400];
		[self updateConnectionStatus:MMXConnectionStatusFailed error:error];
		return NO;
	}
    if (![MMXClient validateCharacterSet:self.configuration.credential.user]) {
        NSError * error = [MMXClient errorWithTitle:@"Invalid Characters" message:@"There are invalid characters used in the login information provided." code:400];
        [self updateConnectionStatus:MMXConnectionStatusFailed error:error];
        return NO;
    }
    if (self.configuration.credential.user.length > kMaxUsernameLength || self.configuration.credential.user.length < kMinUsernameLength || self.configuration.credential.password.length > kMaxPasswordLength || self.configuration.credential.password.length < kMinPasswordLength) {
        NSError * error = [MMXClient errorWithTitle:@"Invalid Character Count" message:@"There is an invalid length of characters used in the login information provided." code:400];
        [self updateConnectionStatus:MMXConnectionStatusFailed error:error];
        return NO;
    }
    return YES;
}

+ (BOOL)isPubSubMessage:(XMPPMessage *)message {
    NSXMLElement *event = [message elementForName:@"event" xmlns:@"http://jabber.org/protocol/pubsub#event"];
    return (event != nil);
}

+ (BOOL)validateCharacterSet:(NSString *)string {
    NSCharacterSet *allowedSet = [NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890_-.@"];
    NSCharacterSet *invalidSet = [allowedSet invertedSet];
    NSRange r = [string rangeOfCharacterFromSet:invalidSet];
    if (r.location != NSNotFound) {
        return NO;
    }
    return YES;
}

+ (NSError *)errorWithTitle:(NSString *)title message:(NSString *)message code:(int)code {
    NSDictionary *userInfo = @{
                               NSLocalizedDescriptionKey: NSLocalizedString(title, nil),
                               NSLocalizedFailureReasonErrorKey: NSLocalizedString(message, nil),
                               };
    NSError *error = [NSError errorWithDomain:MMXErrorDomain
                                         code:code
                                     userInfo:userInfo];
    
    return error;
}

+ (NSError *)connectionStatusError {
	return [MMXClient errorWithTitle:@"Not currently connected." message:@"The feature you are trying to use requires an active connection." code:503];
}

- (void)updateConnectionStatus:(MMXConnectionStatus)status error:(NSError *)error {
	if (error) {
		[[MMXLogger sharedLogger] error:@"%@", error.localizedDescription];
	}
    self.connectionStatus = status;
    if ([self.delegate respondsToSelector:@selector(client:didReceiveConnectionStatusChange:error:)]) {
		dispatch_async(self.callbackQueue, ^{
			[self.delegate client:self didReceiveConnectionStatusChange:status error:error];
		});
    }
}

#pragma mark - Private implementation

- (NSString *)sanitizeDeviceToken:(NSData *)deviceToken {

    NSString *token = [NSString stringWithFormat:@"%@", [deviceToken description]];
    token = [token stringByReplacingOccurrencesOfString:@" " withString:@""];
    token = [token stringByReplacingOccurrencesOfString:@"<" withString:@""];
    token = [token stringByReplacingOccurrencesOfString:@">" withString:@""];

    return token;
}

- (NSURLProtectionSpace *)protectionSpace {
    return [[NSURLProtectionSpace alloc] initWithHost:self.configuration.baseURL.host
                                                 port:[self.configuration.baseURL.port integerValue]
                                             protocol:kMMXXMPPProtocol
                                                realm:nil
                                 authenticationMethod:NSURLAuthenticationMethodHTTPDigest];
}

- (NSDictionary *)allCredentialsForProtectionSpace {
    return [NSURLCredentialStorage.sharedCredentialStorage credentialsForProtectionSpace:self.protectionSpace];
}

- (NSURLCredential *)savedCredential {
    __block NSURLCredential *credential;
    [self.allCredentialsForProtectionSpace enumerateKeysAndObjectsUsingBlock:^(NSURLProtectionSpace *protectionSpace, NSURLCredential *savedCredential, BOOL *stop) {
        credential = savedCredential;
        *stop = YES;
    }];
    return credential;
}

- (void)clearCredentialsForProtectionSpace {
    [self.allCredentialsForProtectionSpace enumerateKeysAndObjectsUsingBlock:^(NSURLProtectionSpace *protectionSpace, NSURLCredential *savedCredential, BOOL *stop) {
        [NSURLCredentialStorage.sharedCredentialStorage removeCredential:savedCredential forProtectionSpace:self.protectionSpace];
    }];
}

@end
