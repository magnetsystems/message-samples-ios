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

#import "MMXAccountManager_Private.h"
#import "MMXAssert.h"
#import "MMXConstants.h"
#import "MMXDeviceManager.h"
#import "MMXDeviceManager_Private.h"
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

#import "MMXInvite_Private.h"
#import "MMXInviteResponse_Private.h"
#import "MMXNotificationConstants.h"

#import "MMXUtils.h"
#import "MMXMessageUtils.h"

#import "XMPP.h"
#import "XMPPJID+MMX.h"
#import "XMPPReconnect.h"
#import "XMPPIDTracker.h"
#import "MMXConfiguration.h"
#import "NSString+XEP_0106.h"

#import <AssertMacros.h>

@import CoreLocation;

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
int const kMaxReconnectionTries = 4;
int const kReconnectionTimerInterval = 4;

@interface MMXClient () <XMPPStreamDelegate, XMPPReconnectDelegate, MMXDeviceManagerDelegate, MMXAccountManagerDelegate, MMXPubSubManagerDelegate>

@property (nonatomic, readwrite) MMXDeviceManager * deviceManager;
@property (nonatomic, readwrite) MMXAccountManager * accountManager;
@property (nonatomic, readwrite) MMXPubSubManager * pubsubManager;
@property (nonatomic, strong) XMPPReconnect * xmppReconnect;
@property (nonatomic, assign) BOOL switchingUser;
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

- (id)initWithConfiguration:(MMXConfiguration *)configuration delegate:(id <MMXClientDelegate>)delegate {
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

#pragma mark - Connection Lifecycle

- (BOOL)openStream {
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
	
	NSMutableString *userWithAppId = [[NSMutableString alloc] initWithString:[self.configuration.credential.user jidEscapedString]];
    [userWithAppId appendString:@"%"];
    [userWithAppId appendString:self.configuration.appID];
    
    NSString *host = self.configuration.baseURL.host;

    [self.xmppStream setMyJID:[XMPPJID jidWithUser:userWithAppId
											domain:self.configuration.domain ? self.configuration.domain : host
										  resource:[MMXDeviceManager deviceUUID]]];

    [self.xmppStream setHostName:host];
	[self.xmppStream setHostPort:[self.configuration.baseURL.port integerValue]];
	
    if (self.configuration.shouldForceTLS) {
        self.xmppStream.startTLSPolicy = XMPPStreamStartTLSPolicyRequired;
    }
    
    [self.xmppStream addDelegate:self delegateQueue:self.mmxQueue];
    
    self.switchingUser = NO;
    
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

#pragma mark - Connection Lifecycle - Public APIs

- (void)connectAnonymous {
    self.anonymousConnection = YES;
	self.configuration.credential = [self anonymousCredentials];
	[self openStream];
}

- (void)connectWithCredentials {
	if (self.configuration.credential && [self.configuration.credential.user hasPrefix:@"_anon-"]) {
		self.configuration.credential = nil;
	}
    if (![self hasValidCredentials]) {
        return;
    }
    self.anonymousConnection = NO;
    // If credential was not set, look for saved credential
    if (!self.configuration.credential && self.configuration.shouldUseCredentialStorage) {
        self.configuration.credential = [self savedCredential];
    }
    if (self.xmppStream && [self.xmppStream isConnected]) {
        self.switchingUser = YES;
    }
    [self openStream];
}

- (void)authenticate {
    NSError* error;
    if ([self.xmppStream authenticateWithPassword:self.configuration.credential.password error:&error]) {
        if (error) {
            [[MMXLogger sharedLogger] verbose:@"ERROR = %@",error];
        }
        [[MMXLogger sharedLogger] verbose:@"connection completed"];
    } else {
        [[MMXLogger sharedLogger] verbose:@"Authentication Attempt Error:%@", error.description];
    }
}

- (void)goAnonymous {
    if (self.anonymousConnection && self.xmppStream && [self.xmppStream isConnected]) {
        return;
    }
    [self clearCredentialsForProtectionSpace];
    if (self.xmppStream && [self.xmppStream isConnected]) {
        self.switchingUser = YES;
    }
    [self connectAnonymous];
}

- (void)disconnect {
    if (self.xmppStream && [self.xmppStream isConnected]) {
        [self.xmppStream disconnect];
    }
}

- (void)disconnectAndDeactivateWithSuccess:(void (^)(BOOL ))success
								   failure:(void (^)(NSError * error))failure {
	[self.deviceManager deactivateCurrentDeviceSuccess:^(BOOL successful) {
		[self disconnect];
		if (success) {
			dispatch_async(dispatch_get_main_queue(), ^{
				success(YES);
			});
		}
	} failure:failure];
}

- (void)updateRemoteNotificationDeviceToken:(NSData *)deviceToken {

    NSString *deviceTokenString = [self sanitizeDeviceToken:deviceToken];

    self.deviceToken = deviceTokenString;

    if (self.connectionStatus == MMXConnectionStatusAuthenticated || self.connectionStatus == MMXConnectionStatusConnected) {
        [self.deviceManager registerCurrentDeviceWithSuccess:nil failure:nil];
    }
}

#pragma mark - Credentials

- (NSURLCredential *)anonymousCredentials {
    return [MMXDeviceManager anonymousCredentials];
}

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

#pragma mark - Device Manager

- (MMXDeviceManager *)deviceManager {
    if (!_deviceManager) {
        MMXAssert((self.xmppStream && [self.xmppStream isConnected] && self.iqTracker && self.mmxQueue), @"You must be connected or logged in to use the MMXDeviceManager");
        _deviceManager = [[MMXDeviceManager alloc] initWithDelegate:self];
    }
    return _deviceManager;
}

#pragma mark - Account Manager

- (MMXAccountManager *)accountManager {
    if (!_accountManager) {
        _accountManager = [[MMXAccountManager alloc] initWithDelegate:self];
    }
    return _accountManager;
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
	[mmxElement addChild:[MMXInternalMessageAdaptor xmlFromRecipients:outboundMessage.recipients senderAddress:self.currentProfile.address]];
	[mmxElement addChild:[outboundMessage contentToXML]];

    if (outboundMessage.metaData) {
        [mmxElement addChild:[outboundMessage metaDataToXML]];
    }
	
	XMPPMessage *xmppMessage;
	NSUInteger sentCount = 0;
	NSMutableArray *failedList = @[].mutableCopy;
	for (id<MMXAddressable> recipient in outboundMessage.recipients) {
		MMXInternalAddress *address = recipient.address;
		if (address) {
			NSString *fullUsername = [NSString stringWithFormat:@"%@%%%@",address.username,self.configuration.appID];
			XMPPJID *toAddress = [XMPPJID jidWithUser:fullUsername domain:[[self currentJID] domain] resource:address.deviceID];
			xmppMessage = [[XMPPMessage alloc] initWithType:mType to:toAddress];
			[xmppMessage addAttributeWithName:@"from" stringValue: [[self currentJID] full]];

			if (options && options.shouldRequestDeliveryReceipt) {
				NSXMLElement *deliveryReceiptElement = [[NSXMLElement alloc] initWithName:MXrequestElement xmlns:MXnsDeliveryReceipt];
				[xmppMessage addChild:deliveryReceiptElement];
			}
			
			[xmppMessage addChild:mmxElement.copy];
			[xmppMessage addAttributeWithName:@"id" stringValue:outboundMessage.messageID];
			
			[[MMXLogger sharedLogger] verbose:@"About to send the message %@", outboundMessage.messageID];
			
			[self.xmppStream sendElement: xmppMessage];
			sentCount++;
		} else {
			[failedList addObject:recipient];
		}
	}
	
	if (failedList.count > 0) {
		if ([self.delegate respondsToSelector:@selector(client:didFailToSendMessage:recipients:error:)]) {
			NSError * error = [MMXClient errorWithTitle:@"Recipient not valid" message:@"Recipient must conform to the MMXAddressable protocol." code:401];
			[self.delegate client:self didFailToSendMessage:outboundMessage.messageID recipients:failedList.copy error:error];
		}
	}
	
	if (sentCount > 0) {
		return outboundMessage.messageID;
	} else {
		return nil;
	}
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
	NSString *sender = [NSString stringWithFormat:@"%@%%%@@%@", address.username, self.configuration.appID, self.configuration.domain];
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
    NSString * username  = self.xmppStream.myJID.user;
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
    NSString * username  = self.xmppStream.myJID.user;
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
#pragma mark - XMPPReconnectDelegate Callbacks

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
	self.reconnectionTryCount = 0;
    [[MMXLogger sharedLogger] verbose:@"Successfully created TCP connection"];
    [self authenticate];
}

- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(NSXMLElement *)error {
        if (self.anonymousConnection) {
            __weak __typeof__(self) weakSelf = self;
            [self.accountManager registerAnonymousWithSuccess:^(BOOL success){
                __typeof__(self) strongSelf = weakSelf;
                [strongSelf authenticate];
            } failure:^ (NSError * error) {
				__typeof__(self) strongSelf = weakSelf;
                [strongSelf updateConnectionStatus:MMXConnectionStatusFailed error:error];
            }];
        } else if (self.shouldAutoCreateUser) {
            if ([self hasValidCredentials]) {
                __weak __typeof__(self) weakSelf = self;
                MMXUserProfile * user = [MMXUserProfile initWithUsername:self.configuration.credential.user displayName:[MMXUtils deviceName] email:@"" tags:nil];
				[self.accountManager registerUser:user password:self.configuration.credential.password success:^(BOOL success){
                    __typeof__(self) strongSelf = weakSelf;
                    [strongSelf authenticate];
                    if (!self.anonymousConnection && [self.delegate respondsToSelector:@selector(client:didReceiveUserAutoRegistrationResult:error:)]) {
						dispatch_async(self.callbackQueue, ^{
							[self.delegate client:self didReceiveUserAutoRegistrationResult:YES error:nil];
						});
                    }
                } failure:^ (NSError * error) {
					__typeof__(self) strongSelf = weakSelf;
                    if (!strongSelf.anonymousConnection && [strongSelf.delegate respondsToSelector:@selector(client:didReceiveUserAutoRegistrationResult:error:)]) {
						dispatch_async(self.callbackQueue, ^{
							[strongSelf.delegate client:strongSelf didReceiveUserAutoRegistrationResult:NO error:error];
						});
                    }
                }];
            }
        } else {
			NSError *authError = [MMXClient errorWithTitle:@"Authentication Failure" message:@"Not Authorized. Please check your credentials and try again." code:401];
            [self updateConnectionStatus:MMXConnectionStatusAuthenticationFailure error:authError];
        }
}

- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender {
    [self.deviceManager registerCurrentDeviceWithSuccess:^(BOOL success) {
		[self postAuthenticationTasks];
    } failure:^(NSError *error) {
		[self postAuthenticationTasks];
    }];
	if (self.anonymousConnection) {
		[self updateConnectionStatus:MMXConnectionStatusConnected error:nil];
	} else {
		// Save the credentials
		[[NSURLCredentialStorage sharedCredentialStorage] setCredential:self.configuration.credential forProtectionSpace:self.protectionSpace];
		[self updateConnectionStatus:MMXConnectionStatusAuthenticated error:nil];
	}
}

- (void)postAuthenticationTasks {
	if (self.shouldSuspendIncomingMessages) {
		[self updatePresenceWithPriority:-1];
	} else {
		[self updatePresenceWithPriority:24];
	}
	if (!self.anonymousConnection) {
		[self sendArchivedMessages];
	}
}

- (void)xmppStreamDidDisconnect:(XMPPStream *)sender withError:(NSError *)error {
	if (error) {
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
    if (!self.switchingUser) {
        [self updateConnectionStatus:MMXConnectionStatusDisconnected error:error];
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
			if ([self.delegate respondsToSelector:@selector(client:didFailToSendMessage:recipients:error:)]) {
				dispatch_async(self.callbackQueue, ^{
					NSError *error = [MMXClient errorWithTitle:@"Invalid User" message:@"The user you are trying to send a message to does not exist or does not have a valid device associated with them." code:500];
					[self.delegate client:self didFailToSendMessage:message.messageID recipients:message.recipients error:error];
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
		if ([self.delegate respondsToSelector:@selector(client:didReceivePubSubMessage:)]) {
			NSArray * messageArray = [MMXPubSubMessage pubSubMessagesFromXMPPMessage:xmppMessage];
			for (MMXPubSubMessage * pubMsg in messageArray) {
				dispatch_async(self.callbackQueue, ^{
					[self.delegate client:self didReceivePubSubMessage:pubMsg];
				});
			}
		}
        return;
    }
    if ([xmppMessage elementsForXmlns:MXnsDataPayload].count) {
		XMPPJID* to = [xmppMessage to] ;
		XMPPJID* from =[xmppMessage from];
		NSString* msgId = [xmppMessage elementID];
		MMXInternalMessageAdaptor* inMessage = [MMXInternalMessageAdaptor initWithXMPPMessage:xmppMessage];
		if (![inMessage.mType isEqualToString:@"normal"]) {
			[self sendSDKAckMessageId:msgId sourceFrom:from sourceTo:to];
		}
		if ([inMessage.mType isEqualToString:@"invitation"]) {
			MMXInvite *invite = [MMXInvite inviteFromMMXInternalMessage:inMessage];
			[[NSNotificationCenter defaultCenter] postNotificationName:MMXDidReceiveChannelInviteNotification
																object:nil
															  userInfo:@{MMXInviteKey:invite}];
		} else if ([inMessage.mType isEqualToString:@"invitationResponse"]) {
			MMXInviteResponse *inviteResponse = [MMXInviteResponse inviteResponseFromMMXInternalMessage:inMessage];
				[[NSNotificationCenter defaultCenter] postNotificationName:MMXDidReceiveChannelInviteResponseNotification
																	object:nil
																  userInfo:@{MMXInviteResponseKey:inviteResponse}];

		} else {
			if ([self.delegate respondsToSelector:@selector(client:didReceiveMessage:deliveryReceiptRequested:)]) {
				MMXInboundMessage * inboundMessage = [MMXInboundMessage initWithMessage:inMessage];
				dispatch_async(self.callbackQueue, ^{
					[self.delegate client:self didReceiveMessage:inboundMessage deliveryReceiptRequested:inMessage.deliveryReceiptRequested];
				});
			}
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
				NSDictionary *serverackDict = mmxMetaDict[@"serverack"];
				if (serverackDict) {
					NSString *ackForMsgId = serverackDict[@"ackForMsgId"];
					NSDictionary *receiverDict = serverackDict[@"receiver"];
					NSString *receiver = receiverDict[@"userId"];
					if (ackForMsgId && [self.delegate respondsToSelector:@selector(client:didReceiveServerAckForMessageID:recipient:)]) {
						dispatch_async(self.callbackQueue, ^{
							MMXUserID *userID = [MMXUserID userIDWithUsername:receiver];
							[self.delegate client:self didReceiveServerAckForMessageID:ackForMsgId recipient:userID.username ? userID : nil];
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

#pragma mark Helper Methods

- (BOOL)hasActiveConnection {
	if (self.connectionStatus != MMXConnectionStatusAuthenticated &&
		self.connectionStatus != MMXConnectionStatusConnected) {
		return NO;
	}
	return YES;
}

- (BOOL)areCurrentCredentialsAnonymous {
	NSString *anonymousUsername = [NSString stringWithFormat:@"_anon-%@",[MMXDeviceManager deviceUUID]];
	if ([self.configuration.credential.user isEqualToString:anonymousUsername]) {
		return YES;
	}
	return NO;
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
