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
#import "MMXMessage+RPSLS.h"

@interface StatsScreenViewController () <UIPopoverPresentationControllerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *connectedLabel;
@property (weak, nonatomic) IBOutlet UILabel *winsLabel;
@property (weak, nonatomic) IBOutlet UILabel *lossesLabel;
@property (weak, nonatomic) IBOutlet UILabel *tiesLabel;
@property (nonatomic, assign) BOOL inGame;

- (void)goToLoginScreen;

@end

@implementation StatsScreenViewController


#pragma mark - Lifecycle

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	[self.navigationItem setHidesBackButton:YES animated:YES];

	self.inGame = NO;
	self.connectedLabel.text = [NSString stringWithFormat:@"Connecting as %@",[RPSLSUser me].messageUserObject.userName];
	self.winsLabel.text = [NSString stringWithFormat:@"Wins: %lu",(unsigned long)[RPSLSUser me].stats.wins];
	self.lossesLabel.text = [NSString stringWithFormat:@"Losses: %lu",(unsigned long)[RPSLSUser me].stats.losses];
	self.tiesLabel.text = [NSString stringWithFormat:@"Ties: %lu",(unsigned long)[RPSLSUser me].stats.ties];
    
    // Indicate that you are ready to receive messages now!
    [MMX start];

	[self setupDefaultTopic];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resigningActive) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveMessage:)
                                                 name:MMXDidReceiveMessageNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didDisconnect:)
                                                 name:MMXDidDisconnectNotification
                                               object:nil];
	[[NSNotificationCenter defaultCenter] addObserver: self
											 selector: @selector(handleResignActive)
												 name: UIApplicationWillResignActiveNotification
											   object: nil];

	[self postAvailabilityStatusAs:YES];
}

- (void)didReceiveMessage:(NSNotification *)notification {
    MMXMessage *message = notification.userInfo[MMXMessageKey];
    // Do something with the message
    /*
	 *  Checking the incoming message and sending a confirmation if necessary.
	 */
    if ([message isTimelyMessage]) {
        [self handleMessage:message];
    }
}

- (void)didDisconnect:(NSNotification *)notification {
    
    // Indicate that you are not ready to receive messages now!
    [MMX start];
    
    [self goToLoginScreen];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:(BOOL)animated];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)handleResignActive {
	[self goToLoginScreen];
}

#pragma mark - Availability

- (void)postAvailabilityStatusAs:(BOOL)available {
	/*
	 *  Publishing our availability message. In this case I do not need to do anything on success.
	 */
	[MMXChannel channelForName:kPostStatus_ChannelName isPublic:YES success:^(MMXChannel *channel) {
		[channel publish:[RPSLSUtils availablilityMessageContent:available] success:nil failure:^(NSError *error) {
			[[MMXLogger sharedLogger] error:@"channelForName error= %@",error];
		}];
	} failure:^(NSError *error) {
		[[MMXLogger sharedLogger] error:@"channelForName error= %@",error];
	}];
}

#pragma mark - Invite Message

- (void)replyToInvite:(MMXMessage *)invite accept:(BOOL)accept {

    NSDictionary *messageContent = @{kMessageKey_Username : [RPSLSUser me].messageUserObject.userName,
            kMessageKey_Timestamp : [RPSLSUtils timestamp],
            kMessageKey_Type : kMessageTypeValue_Accept,
            kMessageKey_Result : accept ? @"true" : @"false",
            kMessageKey_GameID : invite.messageContent[kMessageKey_GameID],
            kMessageKey_Wins : [@([RPSLSUser me].stats.wins) stringValue],
            kMessageKey_Losses : [@([RPSLSUser me].stats.losses) stringValue],
            kMessageKey_Ties : [@([RPSLSUser me].stats.ties) stringValue]};

    [invite replyWithContent:messageContent success:^(NSSet *invalidUsers) {
	} failure:^(NSError *error) {
	}];

    if (accept) {
		self.inGame = YES;
		[self startGame:invite];
	}
}

- (void)startGame:(MMXMessage *)message {
	RPSLSUser * user = [RPSLSUser playerFromInvite:message];
	GameViewController* game = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:NSStringFromClass([GameViewController class])];
	[game setupGameWithID:message.messageContent[kMessageKey_GameID] opponent:user];
	[self presentViewController:game animated:YES completion:nil];
}

#pragma mark - Message Logic

- (void)handleMessage:(MMXMessage *)message {
	RPSLSMessageType type = [self typeForMessage:message];
	switch (type) {
  case RPSLSMessageTypeUnknown:
			break;
  case RPSLSMessageTypeInvite:
			[self showInviteAlertForUser:message.messageContent[kMessageKey_Username] invite:message];
			break;
  case RPSLSMessageTypeAccept:
			if ([RPSLSUtils isTrue:message.messageContent[kMessageKey_Result]]) {
				[self startGame:message];
			}
			break;
  case RPSLSMessageTypeChoice:
			break;
  default:
			break;
	}
}

- (RPSLSMessageType)typeForMessage:(MMXMessage *)message {

	/*
	 *  Extracting information from the MMXInboundMessage metaData property.
	 */
	if (message == nil || message.messageContent == nil || message.messageContent[kMessageKey_Type] == nil || [message.messageContent[kMessageKey_Type] isEqualToString:@""]) {
		return RPSLSMessageTypeUnknown;
	}
	if ([message.messageContent[kMessageKey_Type] isEqualToString:kMessageTypeValue_Invite]) {
		return RPSLSMessageTypeInvite;
	}
	if ([message.messageContent[kMessageKey_Type] isEqualToString:kMessageTypeValue_Accept]) {
		return RPSLSMessageTypeAccept;
	}
	if ([message.messageContent[kMessageKey_Type] isEqualToString:kMessageTypeValue_Choice]) {
		return RPSLSMessageTypeChoice;
	}
	return 0;
}

#pragma mark - UIAlertController

- (void)showInviteAlertForUser:(NSString *)username invite:(MMXMessage *)invite {
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

    self.connectedLabel.text = [NSString stringWithFormat:@"Connected as %@",[RPSLSUser me].messageUserObject.userName];
    [self postAvailabilityStatusAs:YES];

	[MMXChannel createWithName:kPostStatus_ChannelName summary:kPostStatus_ChannelName isPublic:YES publishPermissions:MMXPublishPermissionsAnyone success:nil failure:^(NSError *error) {
		//The error code for "duplicate topic" is 409. This means the topic already exists and I can continue to subscribe.
		if (error.code == 409) {
			
			/*
			 *  Subscribing to a MMXChannel
			 *	By passing nil to the device parameter all device for the user will receive future MMXMessages published to this topic.
			 *	I am passing nil to success because there is not any business logic I need to execute upon success.
			 */
			[MMXChannel channelForName:kPostStatus_ChannelName isPublic:YES success:^(MMXChannel *channel) {
				[channel subscribeWithSuccess:nil failure:^(NSError *subscribeError) {
					[[MMXLogger sharedLogger] error:@"setupDefaultTopic subscribeWithSuccess Error = %@", subscribeError.localizedFailureReason];
				}];
			} failure:^(NSError *error) {
				[[MMXLogger sharedLogger] error:@"setupDefaultTopic channelForName Error = %@", error.localizedFailureReason];
			}];
		}
	}];
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

#pragma mark - Private implementation

- (void)goToLoginScreen {
	[self.navigationController popToRootViewControllerAnimated:YES];
}

@end
