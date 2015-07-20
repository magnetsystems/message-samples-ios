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

#import "StatsScreenViewController.h"
#import "RPSLSConstants.h"
#import "RPSLSUserStats.h"
#import "RPSLSUser.h"
#import "RPSLSMessageTypes.h"
#import "RPSLSUtils.h"
#import "GameViewController.h"
#import "AvailablePlayersTableViewController.h"
#import "MMXInboundMessage+RPSLS.h"
#import <MMX/MMX.h>

@interface StatsScreenViewController () <MMXClientDelegate, UIPopoverPresentationControllerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *connectedLabel;
@property (weak, nonatomic) IBOutlet UILabel *winsLabel;
@property (weak, nonatomic) IBOutlet UILabel *lossesLabel;
@property (weak, nonatomic) IBOutlet UILabel *tiesLabel;
@property (nonatomic, assign) BOOL inGame;

@end

@implementation StatsScreenViewController


#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	[self.navigationItem setHidesBackButton:YES animated:YES];

	self.inGame = NO;
	self.connectedLabel.text = [NSString stringWithFormat:@"Connecting as %@",[RPSLSUser me].username];
	self.winsLabel.text = [NSString stringWithFormat:@"Wins: %lu",(unsigned long)[RPSLSUser me].stats.wins];
	self.lossesLabel.text = [NSString stringWithFormat:@"Losses: %lu",(unsigned long)[RPSLSUser me].stats.losses];
	self.tiesLabel.text = [NSString stringWithFormat:@"Ties: %lu",(unsigned long)[RPSLSUser me].stats.ties];

	/**
	 *  MagnetNote: MMXClientDelegate
	 *
	 *  Setting myself as the delegate to receive the MMXClientDelegate callbacks in this class.
	 *	I only care about client:didReceiveConnectionStatusChange:error: and client:didReceiveUserAutoRegistrationResult:error: in this class.
	 *	All MMXClientDelegate protocol methods are optional.
	 */
	[MMXClient sharedClient].delegate = self;
	
	[MMXClient sharedClient].shouldSuspendIncomingMessages = NO;

	[self setupDefaultTopic];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resigningActive) name:UIApplicationWillResignActiveNotification object:nil];

	/**
	 *  MagnetNote: MMXClient connectionStatus
	 *
	 *  Checking current MMXConnectionStatus
	 */
	if ([MMXClient sharedClient].connectionStatus != MMXConnectionStatusAuthenticated) {

		/**
		 *  MagnetNote: MMXClient connectWithCredentials
		 *
		 *  Calling connectWithCredentials will try to create a new session using the NSURLCredential object we set on our MMXConfiguration.
		 *	Since shouldAutoCreateUser is set as YES it create a new user with the provided credentials if the user does not already exist.
		 */
		[[MMXClient sharedClient] connectWithCredentials];
	} else {
		[self postAvailabilityStatusAs:YES];
	}
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:(BOOL)animated];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Availability

- (void)postAvailabilityStatusAs:(BOOL)available {

	/**
	 *  MagnetNote: MMXPubSubManager publishPubSubMessage:success:failure:
	 *
	 *  Publishing our availability message. In this case I do not need to do anything on success.
	 */
	[[MMXClient sharedClient].pubsubManager publishPubSubMessage:[RPSLSUtils availablilityMessage:available] success:nil failure:^(NSError *error) {
		[[MMXLogger sharedLogger] error:@"postAvailability error= %@",error];
	}];
}

#pragma mark - Invite Message

- (void)replyToInvite:(MMXInboundMessage *)invite accept:(BOOL)accept {
	
	/**
	 *  MagnetNote: MMXOutboundMessage messageTo:withContent:metaData:
	 *  MagnetNote: MMXInboundMessage senderUserID
	 *
	 *  Creating new MMXOutboundMessage. Taking the MMXUserID from the MMXInboundMessage senderUserID property
	 */
	MMXOutboundMessage * message = [MMXOutboundMessage messageTo:invite.senderUserID
													 withContent:@"This is an invite reply message"
														metaData:@{kMessageKey_Username	:[RPSLSUser me].username,
																   kMessageKey_Timestamp:[RPSLSUtils timestamp],
																   kMessageKey_Type		:kMessageTypeValue_Accept,
																   kMessageKey_Result	:@(accept),
																   kMessageKey_GameID	:invite.metaData[kMessageKey_GameID],
																   kMessageKey_Wins		:[@([RPSLSUser me].stats.wins) stringValue],
																   kMessageKey_Losses	:[@([RPSLSUser me].stats.losses) stringValue],
																   kMessageKey_Ties		:[@([RPSLSUser me].stats.ties) stringValue]}];
	
	/**
	 *  MagnetNote: MMXMessageOptions
	 *
	 *  Creating MMXMessageOptions object. Using defaults.
	 */
	MMXMessageOptions * options = [[MMXMessageOptions alloc] init];
	
	/**
	 *  MagnetNote: MMXClient sendMessage:withOptions:
	 *
	 *  Sending my message.
	 */
	[[MMXClient sharedClient] sendMessage:message withOptions:options];
	
	if (accept) {
		self.inGame = YES;
		[self startGame:invite];
	}
}

- (void)startGame:(MMXInboundMessage *)message {
	RPSLSUser * user = [RPSLSUser playerFromInvite:message];
	GameViewController* game = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:NSStringFromClass([GameViewController class])];
	[game setupGameWithID:message.metaData[kMessageKey_GameID] opponent:user];
	
	/**
	 *  MagnetNote: MMXClientDelegate
	 *
	 *  Setting GameViewController as the delegate to receive the MMXClientDelegate callbacks.
	 */
	[MMXClient sharedClient].delegate = (id<MMXClientDelegate>)game;
	[self presentViewController:game animated:YES completion:nil];
}

#pragma mark - Message Logic

- (void)handleMessage:(MMXInboundMessage *)message {
	RPSLSMessageType type = [self typeForMessage:message];
	switch (type) {
  case RPSLSMessageTypeUnknown:
			break;
  case RPSLSMessageTypeInvite:
			[self showInviteAlertForUser:message.metaData[kMessageKey_Username] invite:message];
			break;
  case RPSLSMessageTypeAccept:
			if ([message.metaData[kMessageKey_Result] boolValue]) {
				[self startGame:message];
			}
			break;
  case RPSLSMessageTypeChoice:
			break;
  default:
			break;
	}
}

- (RPSLSMessageType)typeForMessage:(MMXInboundMessage *)message {

	/**
	 *  MagnetNote: MMXInboundMessage metaData
	 *
	 *  Extracting information from the MMXInboundMessage metaData property.
	 */
	if (message == nil || message.metaData == nil || message.metaData[kMessageKey_Type] == nil || [message.metaData[kMessageKey_Type] isEqualToString:@""]) {
		return RPSLSMessageTypeUnknown;
	}
	if ([message.metaData[kMessageKey_Type] isEqualToString:kMessageTypeValue_Invite]) {
		return RPSLSMessageTypeInvite;
	}
	if ([message.metaData[kMessageKey_Type] isEqualToString:kMessageTypeValue_Accept]) {
		return RPSLSMessageTypeAccept;
	}
	if ([message.metaData[kMessageKey_Type] isEqualToString:kMessageTypeValue_Choice]) {
		return RPSLSMessageTypeChoice;
	}
	return 0;
}

#pragma mark - MMXClientDelegate Callbacks

- (void)client:(MMXClient *)client didReceiveConnectionStatusChange:(MMXConnectionStatus)connectionStatus error:(NSError *)error {
	if (connectionStatus == MMXConnectionStatusDisconnected) {
		[self.navigationController popToRootViewControllerAnimated:YES];
	}
}

- (void)client:(MMXClient *)client didReceiveMessage:(MMXInboundMessage *)message deliveryReceiptRequested:(BOOL)receiptRequested {
	/**
	 *  MagnetNote: MMXClientDelegate client:didReceiveMessage:deliveryReceiptRequested:
	 *
	 *  Checking the incoming message and sending a confirmation if necessary.
	 */
	if ([message isTimelyMessage]) {
		[self handleMessage:message];
	}
	if (receiptRequested) {
		
		/**
		 *  MagnetNote: MMXClient sendDeliveryConfirmationForMessage:
		 *
		 *  Sending delivery confirmation.
		 */
		[[MMXClient sharedClient] sendDeliveryConfirmationForMessage:message];
	}
}


#pragma mark - UIAlertController

- (void)showInviteAlertForUser:(NSString *)username invite:(MMXInboundMessage *)invite {
	UIAlertController *alertController = [UIAlertController
										  alertControllerWithTitle:@"Invitation"
										  message:[NSString stringWithFormat:@"You received an invitation from %@",username]
										  preferredStyle:UIAlertControllerStyleAlert];
	
	UIAlertAction *acceptAction = [UIAlertAction
								   actionWithTitle:NSLocalizedString(kMessageResultValue_Accept, @"Accept action")
								   style:UIAlertActionStyleDefault
								   handler:^(UIAlertAction *action)
								   {
									   [self replyToInvite:invite accept:YES];
								   }];
	UIAlertAction *declineAction = [UIAlertAction
								 actionWithTitle:NSLocalizedString(@"Decline", @"Decline action")
								 style:UIAlertActionStyleDefault
								 handler:^(UIAlertAction *action)
								 {
									 [self replyToInvite:invite accept:NO];
								 }];
	
	[alertController addAction:acceptAction];
	[alertController addAction:declineAction];
	[self presentViewController:alertController animated:YES completion:nil];
}

- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message {
	UIAlertController *alertController = [UIAlertController
										  alertControllerWithTitle:title
										  message:message
										  preferredStyle:UIAlertControllerStyleAlert];
	
	UIAlertAction *cancelAction = [UIAlertAction
								   actionWithTitle:@"OK"
								   style:UIAlertActionStyleDefault
								   handler:^(UIAlertAction *action)
								   {
								   }];
	[alertController addAction:cancelAction];
	[self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - Setup Default Topic

- (void)setupDefaultTopic {
	/**
	 *  MagnetNote: MMXClient connectionStatus
	 *
	 *  If we get a status other than MMXConnectionStatusAuthenticated we are trying to reconnect
	 */
	if ([MMXClient sharedClient].connectionStatus == MMXConnectionStatusAuthenticated) {
		self.connectedLabel.text = [NSString stringWithFormat:@"Connected as %@",[RPSLSUser me].username];
		[self postAvailabilityStatusAs:YES];
		/**
		 *  MagnetNote: MMXPubSubManager createTopic:success:failure:
		 *
		 *  Creating a new topic by passing my MMXTopic object.
		 *	When a user creates a topic they are NOT automatically subscribed to it.
		 */
		[[MMXClient sharedClient].pubsubManager createTopic:[RPSLSUtils availablePlayersTopic] success:^(BOOL success) {
			
			/**
			 *  MagnetNote: MMXPubSubManager subscribeToTopic:device:success:failure:
			 *
			 *  Subscribing to a MMXTopic
			 *	By passing nil to the device parameter all device for the user will receive future MMXPubSubMessages published to this topic.
			 *	If the user only wants to be subscribed on the current device, pass the MMXEndpoint for the device.
			 *	I am passing nil to success because there is not any business logic I need to execute upon success.
			 */
			[[MMXClient sharedClient].pubsubManager subscribeToTopic:[RPSLSUtils availablePlayersTopic] device:nil success:nil failure:^(NSError *error) {
				
				/**
				 *  MagnetNote: MMXLogger error
				 *
				 *  Logging an error.
				 */
				[[MMXLogger sharedLogger] error:@"TopicListTableViewController setupTopics Error = %@",error.localizedFailureReason];
			}];
		} failure:^(NSError *error) {
			//The error code for "duplicate topic" is 409. This means the topic already exists and I can continue to subscribe.
			if (error.code == 409) {
				
				/**
				 *  MagnetNote: MMXPubSubManager subscribeToTopic:device:success:failure:
				 *
				 *  Subscribing to a MMXTopic
				 *	By passing nil to the device parameter all device for the user will receive future MMXPubSubMessages published to this topic.
				 *	If the user only wants to be subscribed on the current device, pass the MMXEndpoint for the device.
				 *	I am passing nil to success because there is not any business logic I need to execute upon success.
				 */
				[[MMXClient sharedClient].pubsubManager subscribeToTopic:[RPSLSUtils availablePlayersTopic] device:nil success:nil failure:^(NSError *error) {
					
					/**
					 *  MagnetNote: MMXLogger error
					 *
					 *  Logging an error.
					 */
					[[MMXLogger sharedLogger] error:@"TopicListTableViewController setupTopics Error = %@",error.localizedFailureReason];
				}];
			}
		}];
	}
}

#pragma mark - Segues/Popover

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	if ([segue.identifier isEqualToString:@"InviteSegue"]) {
		AvailablePlayersTableViewController * nvc = segue.destinationViewController;
		UIPopoverPresentationController * pvc = nvc.popoverPresentationController;
		pvc.delegate = self;
	}
}

- (UIModalPresentationStyle) adaptivePresentationStyleForPresentationController: (UIPresentationController * ) controller {
	return UIModalPresentationOverFullScreen;
}

- (UIViewController *)presentationController:(UIPresentationController *)controller viewControllerForAdaptivePresentationStyle:(UIModalPresentationStyle)style {
	UINavigationController * nav = [[UINavigationController alloc] initWithRootViewController:controller.presentedViewController];
	UIVisualEffectView * fxView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
	[nav.view insertSubview:fxView atIndex:0];
	return nav;
}

#pragma mark - Utils

- (void)resigningActive {
	[self postAvailabilityStatusAs:NO];
}

@end
