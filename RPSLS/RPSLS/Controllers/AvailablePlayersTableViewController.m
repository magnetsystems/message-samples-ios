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

#import "AvailablePlayersTableViewController.h"
#import "RPSLSConstants.h"
#import "RPSLSUserStats.h"
#import "RPSLSUser.h"
#import "RPSLSMessageTypes.h"
#import "RPSLSUtils.h"
#import "GameViewController.h"
#import "AvailablePlayersTableViewCell.h"
#import "MMXInboundMessage+RPSLS.h"
#import <MMX/MMX.h>

@interface AvailablePlayersTableViewController () <MMXClientDelegate>

@property (nonatomic, copy) NSArray * availablePlayersList;
@property (nonatomic, strong) MMXUserID * oponent;
@property (nonatomic, assign) BOOL inGame;

@end

@implementation AvailablePlayersTableViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.availablePlayersList = @[];

	UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
 	[refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
 	[self setRefreshControl:refreshControl];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

	self.title = @"Available Players";

	/**
	 *  MagnetNote: MMXClientDelegate
	 *
	 *  Setting myself as the delegate to receive the MMXClientDelegate callbacks in this class.
	 *	I only care about client:didReceiveConnectionStatusChange:error:
	 *	All MMXClientDelegate protocol methods are optional.
	 */
	[MMXClient sharedClient].delegate = self;
	
	self.inGame = NO;
	
	/**
	 *  MagnetNote: MMXClient connectionStatus
	 *
	 *  Checking current MMXConnectionStatus
	 */
	if ([MMXClient sharedClient].connectionStatus == MMXConnectionStatusAuthenticated) {
		[self postAvailabilityStatusAs:YES];
	}
	
	[self collectListOfAvailablePlayers];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resigningActive) name:UIApplicationWillResignActiveNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:(BOOL)animated];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - MMXClientDelegate Callbacks

- (void)client:(MMXClient *)client didReceiveConnectionStatusChange:(MMXConnectionStatus)connectionStatus error:(NSError *)error {
	
	/**
	 *  MagnetNote: MMXClientDelegate client:didReceiveConnectionStatusChange:error:
	 *
	 *  If we get a status other than MMXConnectionStatusAuthenticated we are trying to reconnect
	 */
	if (connectionStatus == MMXConnectionStatusAuthenticated) {
		[self postAvailabilityStatusAs:YES];
	} else {
		
		/**
		 *  MagnetNote: MMXClient connectWithCredentials
		 *
		 *  If something happens I will try to reconnect.
		 */
		[[MMXClient sharedClient] connectWithCredentials];
	}
	
	/**
	 *  MagnetNote: MMXLogger info
	 *
	 *  Logging info.
	 */
	[[MMXLogger sharedLogger] info:@"Connection Status Change = %@",[RPSLSUtils statusToString:connectionStatus]];
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

- (void)client:(MMXClient *)client didReceivePubSubMessage:(MMXPubSubMessage *)message {
	
	/**
	 *  MagnetNote: MMXClientDelegate client:didReceivePubSubMessage:
	 *
	 *  Checking to see if the message is from the availability topic and ignoring all others
	 */
	if ([message.topic.topicName isEqualToString:kPostStatus_TopicName]) {
		[self updateListWithMessage:message];
	}
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

#pragma mark - Request Available Players

- (MMXPubSubFetchRequest *)requestForAvailablePlayers {
	
	/**
	 *  MagnetNote: MMXPubSubFetchRequest
	 *
	 *  Creating a fetch request to get the all the availability topic posts for the last 10 minutes with a max of 100 messages.
	 */
	MMXPubSubFetchRequest *request = [[MMXPubSubFetchRequest alloc] init];
	request.topic = [RPSLSUtils availablePlayersTopic];
	request.since = [NSDate dateWithTimeIntervalSinceNow:kAvailableTimeFrame];
	request.maxItems = 100;
	return request;
}

- (void)collectListOfAvailablePlayers {
	
	/**
	 *  MagnetNote: MMXPubSubManager fetchItems:success:failure:
	 *
	 *  Passing my MMXPubSubFetchRequest to the fetchItems API. It will return a NSArray of MMXPubSubMessages
	 */
	[[MMXClient sharedClient].pubsubManager fetchItems:[self requestForAvailablePlayers] success:^(NSArray *messages) {
		[self refreshAvailablePlayersWithMessages:messages];
	} failure:^(NSError *error) {
		
		/**
		 *  MagnetNote: MMXLogger error
		 *
		 *  Logging an error.
		 */
		[[MMXLogger sharedLogger] error:@"collectListOfAvailablePlayers error = %@",error];
	}];
}

#pragma mark - Available Players

- (void)refreshAvailablePlayersWithMessages:(NSArray *)messages {
	NSMutableArray *tempArray = @[].mutableCopy;
	for (MMXPubSubMessage *msg in messages) {
		RPSLSUser * user = [RPSLSUser availablePlayerFromPubSubMessage:msg];
		[tempArray addObject:user];
	}
	
	NSOrderedSet * set = [NSOrderedSet orderedSetWithArray:tempArray];
	NSArray *unique = set.array;
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(isAvailable == YES) AND (username != %@)",[RPSLSUser me].username];
	NSArray *filtered  = [unique filteredArrayUsingPredicate:predicate];
	
	self.availablePlayersList = filtered;
	
	[self.tableView reloadData];
	[self.refreshControl endRefreshing];
}

- (void)updateListWithMessage:(MMXPubSubMessage *)message {
	RPSLSUser * user = [RPSLSUser availablePlayerFromPubSubMessage:message];
	
	if (![user isEqual:[RPSLSUser me]]) {
		if (!user.isAvailable) {
			
			NSPredicate *predicate = [NSPredicate predicateWithFormat:@"username != %@",user.username];
			NSMutableArray *filtered  = [self.availablePlayersList filteredArrayUsingPredicate:predicate].mutableCopy;
			self.availablePlayersList = filtered.copy;
			
		} else if (NSNotFound == [self.availablePlayersList indexOfObject:user]){
			
			self.availablePlayersList = [@[user] arrayByAddingObjectsFromArray:self.availablePlayersList];
		
		}
		[self.tableView reloadData];
	}
}

#pragma mark - Refresh

- (void)refresh {
	
	self.availablePlayersList = @[];
	[self.tableView reloadData];
	[self.refreshControl beginRefreshing];
	[self collectListOfAvailablePlayers];
	
}

#pragma mark - Invite

- (void)sendInviteTo:(NSString *)username {

	/**
	 *  MagnetNote: MMXUserID userIDWithUsername:
	 *
	 *  Creating a MMXUserID from a NSString username.
	 */
	MMXUserID * recipient = [MMXUserID userIDWithUsername:username];
	
	/**
	 *  MagnetNote: MMXOutboundMessage messageTo:withContent:metaData:
	 *
	 *  Creating new MMXOutboundMessage.
	 */
	MMXOutboundMessage * message = [MMXOutboundMessage messageTo:recipient
													 withContent:@"This is an invite message"
														metaData:@{kMessageKey_Username	:[RPSLSUser me].username,
																   kMessageKey_Timestamp:[RPSLSUtils timestamp],
																   kMessageKey_Type		:kMessageTypeValue_Invite,
																   kMessageKey_GameID	:[AvailablePlayersTableViewController newGameID],
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
}

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
				self.inGame = YES;
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

#pragma mark - Invite Alert View

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

#pragma mark - TableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	RPSLSUser * user = self.availablePlayersList[indexPath.row];
	AvailablePlayersTableViewCell *cell = (AvailablePlayersTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
	[cell showSent];
	[cell setSelected:NO];
	[self sendInviteTo:user.username];
}

#pragma mark - TableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return self.availablePlayersList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *CellIdentifier = @"AvailablePlayersTableViewCell";
	
	AvailablePlayersTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (!cell) {
		cell = [[AvailablePlayersTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
	}
	RPSLSUser * user = self.availablePlayersList[indexPath.row];
	[cell setUserForCell:user];
	
	return cell;
}

#pragma mark - Utils

+ (NSString *)newGameID {
	return [NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970]];
}

- (void)resigningActive {
	[self postAvailabilityStatusAs:NO];
}



@end
