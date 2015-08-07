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


#import "MessagesViewController.h"
#import "MessageTextView.h"
#import "MessageCell.h"
#import "QuickStartUtils.h"
#import "UIColor+QuickStart.h"
#import <MMX.h>

@interface MessagesViewController () <MMXClientDelegate>

@property (nonatomic, copy) NSArray * messageList;
@property (nonatomic, copy) NSArray * colorArray;
@property (nonatomic, assign) BOOL isSubscribed;

@property (nonatomic, strong) MMXUserID * currentRecipient;

@end

NSString * const kDefaultUsername = @"QuickstartUser1";
NSString * const kEchoBotUsername = @"echo_bot";
NSString * const kAmazingBotUsername = @"amazing_bot";
NSString * const kMeString = @"Me";

@implementation MessagesViewController

#pragma mark - Lifecycle

- (id)init {
	self = [super initWithTableViewStyle:UITableViewStylePlain];
	if (self) {
		// Register a subclass of SLKTextView, if you need any special appearance and/or behavior customisation.
		[self registerClassForTextView:[MessageTextView class]];
	}
	return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
	[self setupUI];

	[self setupClient];
	
	self.currentRecipient = [self me];
	
	self.messageList = @[];
	[self.tableView registerClass:[MessageCell class] forCellReuseIdentifier:@"MessageCell"];
	self.messageList = @[];
	self.colorArray = @[[UIColor quickstartChatPerson1],
						[UIColor quickstartChatPerson2],
						[UIColor quickstartChatPerson3],
						[UIColor quickstartChatPerson4],
						[UIColor quickstartChatPerson5],
						[UIColor quickstartChatPerson6]];

	//Calling connectWithCredentials will try to create a new session using the NSURLCredential object we set on our MMXConfiguration.
	//Since shouldAutoCreateUser is set as YES it creates a new user with the provided credentials if the user does not already exist.
	[[MMXClient sharedClient] connectWithCredentials];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - MMXClient Setup


- (void)setupClient {
	//Create configuration
	MMXConfiguration * config = [MMXConfiguration configurationWithName:@"default"];
	
	//Initialize MMXClient with configuration and delegate
	[MMXClient sharedClient].configuration = config;
	[MMXClient sharedClient].delegate = self;
	
	//If you want to create a user automatically when logging in for the first time
	[MMXClient sharedClient].shouldAutoCreateUser = YES;
	
	//Creating a new NSURLCredential and setting it as the credential propery on our MMXConfiguration.
	[MMXClient sharedClient].configuration.credential = [NSURLCredential credentialWithUser:kDefaultUsername password:kDefaultUsername persistence:NSURLCredentialPersistenceNone];
}

#pragma mark - MMXClientDelegate Callbacks

//Monitoring the connection status change to handle accordingly.
- (void)client:(MMXClient *)client didReceiveConnectionStatusChange:(MMXConnectionStatus)connectionStatus error:(NSError *)error {
	switch (connectionStatus) {
		case MMXConnectionStatusAuthenticated:
			[self showAlertWithTitle:@"Logged In" message:[NSString stringWithFormat:@"You are logged in as %@.\n\nTry sending a message below.",[MMXClient sharedClient].configuration.credential.user]];
			break;
		case MMXConnectionStatusFailed:
			[self showAlertWithTitle:@"Failed!" message:@"Something went wrong while trying to authenticate. Please check your server settings and configuration then try again."];
			break;
		case MMXConnectionStatusDisconnected:
			[self showReconnect];
			break;
		case MMXConnectionStatusAuthenticationFailure:
			[self showAlertWithTitle:@"Authentication Failure!" message:@"Something went wrong while trying to authenticate. Please check your server settings and configuration then try again."];
			break;
		case MMXConnectionStatusConnected:
			[self showAlertWithTitle:@"Connected" message:@"You are connected as an anonymous user."];
			break;
		case MMXConnectionStatusNotConnected:
			[self showAlertWithTitle:@"Not Connected" message:@"You are not currently connected."];
			break;
		default:
			break;
	}
}

//Updating the UI when receiving a message
- (void)client:(MMXClient *)client didReceiveMessage:(MMXInboundMessage *)message deliveryReceiptRequested:(BOOL)receiptRequested {
	
	NSDictionary *messageDict = @{@"messageContent":message.messageContent,
								  @"timestampString":[[QuickStartUtils friendlyDateFormatter] stringFromDate:message.timestamp],
								  @"senderUsername":message.senderUserID.username,
								  @"isOutboundMessage":@(NO)};
	
	NSMutableArray *tempMessageList = self.messageList.mutableCopy;
	[tempMessageList insertObject:messageDict atIndex:0];
	self.messageList = tempMessageList.copy;
	
	[self.tableView reloadData];
}

//Monitoring for registration errors to alert the user and allow them to try again.
- (void)client:(MMXClient *)client didReceiveUserAutoRegistrationResult:(BOOL)success error:(NSError *)error {
	if	(error) {
		if ([error.localizedFailureReason isEqualToString:@"userId is taken"]) {
			[self showAlertWithTitle:@"Error Logging In" message:@"There was an error when trying to log in. Make sure you are using the correct username and password. If this is your first time logging the username you are trying to use may already be taken."];
		} else {
			[self showAlertWithTitle:@"Error Registering User" message:error.localizedFailureReason];
		}
	}
}

#pragma mark - Helpers

//Created convenience method to get my MMXUserID
- (MMXUserID *)me {
	MMXUserID * userID = [MMXUserID userIDWithUsername:[MMXClient sharedClient].configuration.credential.user];
	return userID;
}

//Added methods to get the MMUserIDs for the bots
- (MMXUserID *)echoBot {
	MMXUserID * userID = [MMXUserID userIDWithUsername:kEchoBotUsername];
	return userID;
}

- (MMXUserID *)amazingBot {
	MMXUserID * userID = [MMXUserID userIDWithUsername:kAmazingBotUsername];
	return userID;
}

#pragma mark - Send Message

//This is the callback specified by the SLKTextViewController
- (void)didPressRightButton:(id)sender {
	[self.textView refreshFirstResponder];
	
	if ([MMXClient sharedClient].connectionStatus == MMXConnectionStatusAuthenticated) {
		//Creating a MMXOutboundMessage with the contents of the text box
		MMXOutboundMessage * msg = [MMXOutboundMessage messageTo:@[self.currentRecipient]
													 withContent:self.textView.text.copy
														metaData:nil];
		
		//Sending the message
		[[MMXClient sharedClient] sendMessage:msg];
		
		NSDictionary *messageDict = @{@"messageContent":msg.messageContent,
									  @"timestampString":[[QuickStartUtils friendlyDateFormatter] stringFromDate:[NSDate date]],
									  @"senderUsername":kMeString,
									  @"isOutboundMessage":@(YES)};
		
		NSMutableArray *tempMessageList = self.messageList.mutableCopy;
		[tempMessageList insertObject:messageDict atIndex:0];
		self.messageList = tempMessageList.copy;
		
		[self.tableView reloadData];
	} else {
		[self showAlertWithTitle:@"Not Connected" message:@"Sending a message requires that you be connected. Please check your server settings and configuration then try again."];
	}
	
	[super didPressRightButton:sender];
}

#pragma mark - TableView

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	MessageCell *cell = (MessageCell *)[tableView dequeueReusableCellWithIdentifier:@"MessageCell" forIndexPath:indexPath];
	NSDictionary *messageDict = self.messageList[indexPath.row];
	NSString *senderUsername = messageDict[@"senderUsername"];
	BOOL isOutboundMessage = [messageDict[@"isOutboundMessage"] boolValue];
	[cell setMessageContent:messageDict[@"messageContent"]
			 senderUsername:senderUsername
			timestampString:messageDict[@"timestampString"]
		  isOutboundMessage:isOutboundMessage
					  color:[self colorForName:senderUsername]];
	
	cell.transform = self.tableView.transform;
	return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return self.messageList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSDictionary *messageDict = self.messageList[indexPath.row];
	return [MessageCell estimatedHeightForMessageContent:messageDict[@"messageContent"] ?: @""
											   cellWidth:tableView.frame.size.width];
}

- (IBAction)changeUserPressed:(id)sender {
	UIAlertController *alertController = [UIAlertController
										  alertControllerWithTitle:@"Send Messages To:"
										  message:nil
										  preferredStyle:UIAlertControllerStyleAlert];
	
	UIAlertAction *meAction = [UIAlertAction
									  actionWithTitle:[self me].username
									  style:UIAlertActionStyleDefault
									  handler:^(UIAlertAction *action)
									  {
										  dispatch_async(dispatch_get_main_queue(), ^{
											  self.currentRecipient = [self me];
										  });
									  }];
	UIAlertAction *echoAction = [UIAlertAction
									  actionWithTitle:[self echoBot].username
									  style:UIAlertActionStyleDefault
									  handler:^(UIAlertAction *action)
									  {
										  dispatch_async(dispatch_get_main_queue(), ^{
											  self.currentRecipient = [self echoBot];
										  });
									  }];
	UIAlertAction *amazingAction = [UIAlertAction
									actionWithTitle:[self amazingBot].username
									style:UIAlertActionStyleDefault
									handler:^(UIAlertAction *action)
									{
										dispatch_async(dispatch_get_main_queue(), ^{
											self.currentRecipient = [self amazingBot];
										});
									}];
	UIAlertAction *cancelAction = [UIAlertAction
									actionWithTitle:@"Cancel"
									style:UIAlertActionStyleCancel
									handler:^(UIAlertAction *action)
									{
									}];
	[alertController addAction:meAction];
	[alertController addAction:echoAction];
	[alertController addAction:amazingAction];
	[alertController addAction:cancelAction];
	[self presentViewController:alertController animated:YES completion:nil];

}

#pragma mark - Helpers

- (UIColor *)colorForName:(NSString *)name {
	
	if ([name isEqualToString:kDefaultUsername]) {
		return [UIColor quickstartChatPerson2];
	} else if ([name isEqualToString:kMeString]) {
		return [UIColor quickstartChatCurrentUser];
	} else if ([name isEqualToString:kEchoBotUsername]) {
		return [UIColor quickstartChatPerson3];
	} else if ([name isEqualToString:kAmazingBotUsername]) {
		return [UIColor quickstartChatPerson1];
	} else {
		int index = (int)([name hash] % self.colorArray.count);
		return self.colorArray[index];
	}
}

#pragma mark - UIAlertController

- (void)showReconnect {
	UIAlertController *alertController = [UIAlertController
										  alertControllerWithTitle:@"Connection Lost"
										  message:nil
										  preferredStyle:UIAlertControllerStyleAlert];
	
	UIAlertAction *reconnectAction = [UIAlertAction
								actionWithTitle:@"Reconnect"
								style:UIAlertActionStyleDefault
								handler:^(UIAlertAction *action)
								{
									[[MMXClient sharedClient] connectWithCredentials];
								}];
	[alertController addAction:reconnectAction];
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

#pragma mark - Appearance

- (void)setupUI {
	
	self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	UIColor *myColor = [UIColor quickstartLightGray];
	UIImageView * imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"navbar_logo"]];
	imageView.frame = CGRectMake(0, 0, self.view.frame.size.width, 44.0);
	imageView.contentMode = UIViewContentModeScaleAspectFit;
	self.navigationItem.titleView = imageView;
	self.textInputbar.autoHideRightButton = NO;
	self.textInputbar.backgroundColor = myColor;
	self.textInputbar.textView.text = @"Hello World";
}

@end
