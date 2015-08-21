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
#import "MMXErrorSeverityEnum.h"
#import "MMXAddressable.h"

@class MMXClient;
@class MMXAccountManager;
@class MMXDeviceManager;
@class MMXPubSubManager;
@class MMXInboundMessage;
@class MMXOutboundMessage;
@class MMXPubSubMessage;
@class MMXTopic;
@class MMXMessageOptions;
@class MMXConfiguration;
@class CLLocation;
@class MMXUserID;

/**
 *  Values representing the connection status of the MMXClient.
 */
typedef NS_ENUM(NSInteger, MMXConnectionStatus){
	/**
	 *  Not yet connected or authenticated.
	 */
    MMXConnectionStatusNotConnected = 0,
	/**
	 *  Connected to the server as an anonymous user.
	 */
    MMXConnectionStatusConnected,
	/**
	 *  No longer connected to the server.
	 */
    MMXConnectionStatusDisconnected,
	/**
	 *  Logged in to the server as an authenticated user.
	 */
    MMXConnectionStatusAuthenticated,
	/**
	 *	Last try to log in as a authenticated user failed.
	 */
    MMXConnectionStatusAuthenticationFailure,
	/**
	 *  Something occured which caused the connection to fail.
	 */
	MMXConnectionStatusFailed,
	/**
	 *  An accidental disconnect occurred and the SDK will automatically try to reconnect.
	 */
	MMXConnectionStatusReconnecting,
};

#pragma mark - MMXClientDelegate Protocol
/**
 *  The MMXClientDelegate protocol defines the methods that a delegate of a MMXClient object can adopt. 
 *	The methods of the protocol allow the delegate to monitor the connection lifecycle, user registration, incoming messages, message failures and errors. 
 *	All methods are optional.
 */
@protocol MMXClientDelegate <NSObject>

@optional

/**
 *  This method is called whenever the connection status changes
 *
 *  @param client			- The client providing the status change
 *  @param connectionStatus - The value of the new status
 *  @param error			- The error will typically be nil unless the status is MMXConnectionStatusAuthenticationFailure or MMXConnectionStatusFailed
 */
- (void)client:(MMXClient *)client didReceiveConnectionStatusChange:(MMXConnectionStatus)connectionStatus error:(NSError*)error;

/**
 *  This method is called after auto registration is complete because shouldAutoCreateUser was set to YES
 *
 *  @param client  - The client providing the registration result
 *  @param success - The block called in a successful result.
 *  @param error   - The block called in an unsuccessful result. Includes an NSError
 */
- (void)client:(MMXClient *)client didReceiveUserAutoRegistrationResult:(BOOL)success error:(NSError*)error;

/**
 *  This method is called when a delivery message was received.
 *
 *  @param client       - The client providing the message result.
 *  @param messageID    - The message ID of the message that was sent.
 *  @param recipient    - The MMXUserID or MMXEndpoint the message was targeted for.
 */
- (void)client:(MMXClient *)client didDeliverMessage:(NSString *)messageID recipient:(id<MMXAddressable>)recipient;

/**
 *  This method is called when a message is not sent successfully.
 *
 *  @param client       - The client providing the message result.
 *  @param messageID    - The message ID of the message failed to send.
 *  @param recipients   - The MMXUserIDs and/or MMXEndpoints the message was targeted for.
 *  @param error		- Information about the error that occured.
 */
- (void)client:(MMXClient *)client didFailToSendMessage:(NSString *)messageID recipients:(NSArray *)recipients error:(NSError *)error;

/**
 *  This method is called when a message is received.
 *
 *  @param client           - The client providing the message.
 *  @param message          - The MMXInboundMessage object that was received.
 *  @param receiptRequested - BOOL will be YES if the sender requested a delivery confirmation message.
 */
- (void)client:(MMXClient *)client didReceiveMessage:(MMXInboundMessage *)message deliveryReceiptRequested:(BOOL)receiptRequested;

/**
 *  This method is called when an error message is received.
 *
 *  @param client    - The client providing the message.
 *  @param error     - An NSError with details about the error that was received.
 *  @param severity  - Severity as defined in MMXErrorSeverityEnum.h
 *  @param messageID - The message ID of the message that led to the error
 */
- (void)client:(MMXClient *)client didReceiveError:(NSError *)error severity:(MMXErrorSeverity)severity messageID:(NSString *)messageID;

/**
 *  This method is called when the server successfully receives a message after sending
 *
 *  @param client    - The client providing the message.
 *  @param messageID - The message ID of the message that was received by the server
 *  @param recipient - The MMXUserID of the user the message was addressed to.
 */
- (void)client:(MMXClient *)client didReceiveServerAckForMessageID:(NSString *)messageID recipient:(MMXUserID *)recipient;

// PubSub
/**
 *  This method is called when a PubSub message is received.
 *
 *  @param client  - The client providing the message.
 *  @param message - The MMXPubSubMessage object that was received.
 */
- (void)client:(MMXClient *)client didReceivePubSubMessage:(MMXPubSubMessage *)message;

@end

#pragma mark - MMXClient Interface
/**
 *  MMXClient is the primary class for using Magnet Message. 
 *	MMXClient has properties for accessing the manager classes that expose advanced functionality, configuration, connection status and important settings. 
 *	It also contains the majority of the core methods for task like; connection lifecycle, sending messages, message state and queued messages.
 */
@interface MMXClient : NSObject

#pragma mark - MMXClient Properties

/**
 *  Class that implements the MMXClientDelegate Protocol.
 */
@property (nonatomic, weak)     id<MMXClientDelegate> delegate;

/**
 *  Current instance of the MMXDeviceManager. See MMXDeviceManager.h for usage.
 *	Must have an active connection to be able to use the MMXDeviceManager.
 */
@property (nonatomic, readonly) MMXDeviceManager * deviceManager;

/**
 *  Current instance of the MMXAccountManager. See MMXAccountManager.h for usage.
 *	Must have an active connection to be able to use the MMXAccountManager.
 */
@property (nonatomic, readonly) MMXAccountManager * accountManager;

/**
 *  Current instance of the MMXPubSubManager. See MMXPubSubManager.h for usage.
 */
@property (nonatomic, readonly) MMXPubSubManager * pubsubManager;

/**
 *  The callback dispatch queue. Value is initially set to the main queue.
 */
@property (nonatomic, assign) dispatch_queue_t callbackQueue;

/**
 *  Current status of connection with the server. See "MMXConnectionStatus" for possible values.
 */
@property (nonatomic, readonly) MMXConnectionStatus connectionStatus;

/**
 *  Token used for APNS notifications.
 */
@property (nonatomic, readonly) NSString *deviceToken;

/**
 *  If set to YES will attempt to create user if login fails.
 */
@property (nonatomic, assign)   BOOL shouldAutoCreateUser;

/**
 *  If set to YES the server will hold all messages targeted for this device.
 */
@property (nonatomic, assign)   BOOL shouldSuspendIncomingMessages;

/**
 *  Connection configuration settings. See MMXConfiguration.h
 */
@property(nonatomic, strong) MMXConfiguration *configuration;


#pragma mark - MMXClient Methods
/**
 * Retrieves the shared client instance.
 */
+ (instancetype)sharedClient;

/**
 *  Create new instance of an MMXClient
 *
 *  @param configuration - Connection configuration settings. See MMXConfiguration.h
 *  @param delegate      -  Class that conforms to MMXClientDelegate protocol
 *
 *  @return New instance of MMXClient
 */
- (id)initWithConfiguration:(MMXConfiguration *)configuration
                   delegate:(id<MMXClientDelegate>)delegate;

/**
 *  Creates a session as an anonymous user.
 */
- (void)connectAnonymous;

/**
 *  Creates a session as a named user using the NSURLCredential set as the credentials property of the configuration property.
 */
- (void)connectWithCredentials;

/**
 *  This method degrades a session using a named account to an anonymous session.
 */
- (void)goAnonymous;

/**
 *  This closes the connection to the server. The device will still receive push notifications to be alerted to
 *  new messages/content.
 */
- (void)disconnect;

/**
 *  This method deregisters the current device so it will no longer be a valid endpoint for receiving messages and
 *  push notifications and closes the connection to the server. You must be currently connected to the server to
 *  use this API.
 *
 *  @param success - Block with BOOL. Value should be YES.
 *  @param failure - Block with an NSError with details about the call failure.
 */
- (void)disconnectAndDeactivateWithSuccess:(void (^)(BOOL success))success
								   failure:(void (^)(NSError * error))failure;

/**
 *  Sends a message to a desired user. MMXMessageOptions are set to default values.
 *
 *  @param message           - The MMXMessage to send.
 *
 *  @return - The UUID of the message for use in tracking.
 */
- (NSString *)sendMessage:(MMXOutboundMessage *)message;

/**
 *  Sends a message to a desired user.
 *
 *  @param message	- The MMXMessage to send.
 *  @param options	- MMXMessageOptions object that sets the value for requesting a delivery receipt and performance optimization
 *
 *  @return - The UUID of the message for use in tracking.
 */
- (NSString *)sendMessage:(MMXOutboundMessage *)message
			  withOptions:(MMXMessageOptions *)options;

/**
 *  Optionally send delivery confirmation for inbound message when requested.
 *
 *  @param message - Pass in the message that you want to send a confirmation for.
 *
 *  @return - The message ID of the confirmation message that is sent.
 */
- (NSString *)sendDeliveryConfirmationForMessage:(MMXInboundMessage *)message;

/**
 *  Query an array of message IDs to find out their status.
 *
 *  @param messageIDs - An array of message IDs that you want the status of.
 *  @param success    - A dictionary containing the message IDs as keys and their status as the value.
 *  @param failure	  - Block with an NSError with details about the call failure.
 */
- (void)queryStateForMessages:(NSArray *)messageIDs
                      success:(void (^)(NSDictionary * response))success
                      failure:(void (^)(NSError * error))failure;


/**
 *	Messages are queued if sent when the user is not connected.
 *  Returns an array of MMXOutboundMessage objects that are currently queued to be sent.
 *  This feature is only available offline as the messages will be sent the next time the user is authenticated
 */
- (NSArray *)queuedMessages;

/**
 *  Delete queued messages that you no longer want to send.
 *  This feature is only available offline as the messages will be sent the next time the user is authenticated.
 *
 *  @param messages - An array of the messages you wish to delete.
 *
 *  @return - An array of any messages that failed to be deleted.
 */
- (NSArray *)deleteQueuedMessages:(NSArray *)messages;

/**
 *	Messages are queued if sent when the user is not connected.
 *  Get a list of MMXPubSubMessages that are queued to be sent the next time the user connects.
 *  This feature is only available offline as the messages will be sent the next time the user is authenticated.
 *
 *  @return - An array of MMXPubSubMessage objects that are currently queued to be sent.
 */
- (NSArray *)queuedPubSubMessages;

/**
 *  Delete queued messages that you no longer want to send.
 *  This feature is only available offline as the messages will be sent the next time the user is authenticated.
 *
 *  @param messages - An array of the messages you wish to delete.
 *
 *  @return - An array of any messages that failed to be deleted.
 */
- (NSArray *)deleteQueuedPubSubMessages:(NSArray *)messages;

/**
 *  Updates the device token.
 *
 *  @param deviceToken - The device token.
 */
- (void)updateRemoteNotificationDeviceToken:(NSData *)deviceToken;

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
