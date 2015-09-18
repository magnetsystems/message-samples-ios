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
#import <MMX/MMX.h>
@interface MessagesViewController ()

@property (nonatomic, copy) NSArray * messageList;
@property (nonatomic, copy) NSArray * colorArray;
@property (nonatomic, assign) BOOL isSubscribed;

@property (nonatomic, strong) MMXUser * currentRecipient;
@property (nonatomic, strong) NSURLCredential * currentCredential;

@end

NSString * const kDefaultUsername = @"QuickstartUser1";
NSString * const kEchoBotUsername = @"echo_bot";
NSString * const kAmazingBotUsername = @"amazing_bot";
NSString * const kMeString = @"Me";
NSString * const kTextContent = @"textContent";

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

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveMessage:) name:MMXDidReceiveMessageNotification object:nil];
	
	[self setupUI];

	[self setupClient];
	
	self.messageList = @[];
	[self.tableView registerClass:[MessageCell class] forCellReuseIdentifier:@"MessageCell"];
	self.messageList = @[];
	self.colorArray = @[[UIColor quickstartChatPerson1],
						[UIColor quickstartChatPerson2],
						[UIColor quickstartChatPerson3],
						[UIColor quickstartChatPerson4],
						[UIColor quickstartChatPerson5],
						[UIColor quickstartChatPerson6]];

	[[NSNotificationCenter defaultCenter] addObserver: self
											 selector: @selector(handleReturnToForeground)
												 name: UIApplicationWillEnterForegroundNotification
											   object: nil];

}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
}

- (void)handleReturnToForeground {
	[self logIn];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - MMXClient Setup


- (void)setupClient {

	//Creating a new NSURLCredential
	self.currentCredential = [NSURLCredential credentialWithUser:kDefaultUsername password:kDefaultUsername persistence:NSURLCredentialPersistenceNone];
	MMXUser *user = [MMXUser new];
	user.username = kDefaultUsername;
    user.displayName = kDefaultUsername;
    
	[user registerWithCredential:self.currentCredential success:^{
		[self logIn];
	} failure:^(NSError *error) {
		if (error.code == 409) {
			//Already registered
			[self logIn];
		}
	}];
}

- (void)logIn {
	if (self.currentCredential != nil) {
		[MMXUser logInWithCredential:self.currentCredential success:^(MMXUser *user) {
			self.currentRecipient = [self me];
			// Indicate that you are ready to receive messages now!
			[MMX start];

			[self showAlertWithTitle:@"Logged In" message:[NSString stringWithFormat:@"You are logged in as %@.\n\nTry sending a message below.",kDefaultUsername]];
            self.textInputbar.textView.text = @"Hello World";
		} failure:^(NSError *error) {
			[self showAlertWithTitle:@"Authentication Failure!" message:@"Something went wrong while trying to authenticate. Please check your server settings and configuration then try again."];
			NSLog(@"logInWithCredentials Failure = %@",error);
		}];
	}
}

/*
 
 */

#pragma mark - Helpers

//Created convenience method to get my MMXUser
- (MMXUser *)me {
	MMXUser *me = [MMXUser new];
	me.username = kDefaultUsername;
	return me;
}

//Added methods to get the MMXUser for the bots
- (MMXUser *)echoBot {
	MMXUser * user = [MMXUser new];
	user.username = kEchoBotUsername;
	return user;
}

- (MMXUser *)amazingBot {
	MMXUser * user = [MMXUser new];
	user.username = kAmazingBotUsername;
	return user;
}

#pragma mark - Send Message

//This is the callback specified by the SLKTextViewController
- (void)didPressRightButton:(id)sender {
	[self.textView refreshFirstResponder];
	
	if (/* DISABLES CODE */ (YES)) {
		MMXMessage *msg = [MMXMessage messageToRecipients:[NSSet setWithArray:@[self.currentRecipient]] messageContent:@{kTextContent:self.textView.text}];
		[msg sendWithSuccess:nil failure:nil];
		
		NSDictionary *messageDict = @{@"messageContent":self.textView.text,
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

- (void)didReceiveMessage:(NSNotification*) noti {
	if (noti.userInfo) {
		NSDictionary *notificationDict =  noti.userInfo;
		MMXMessage *message = notificationDict[MMXMessageKey];
		if (message) {
			NSDictionary *messageDict = @{@"messageContent":message.messageContent[kTextContent] ?: @"Message content missing",
										  @"timestampString":[[QuickStartUtils friendlyDateFormatter] stringFromDate:message.timestamp],
										  @"senderUsername":message.sender.username,
										  @"isOutboundMessage":@(NO)};
			
			NSMutableArray *tempMessageList = self.messageList.mutableCopy;
			[tempMessageList insertObject:messageDict atIndex:0];
			self.messageList = tempMessageList.copy;
			
			[self.tableView reloadData];
		}
	}
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
									  actionWithTitle:kDefaultUsername
									  style:UIAlertActionStyleDefault
									  handler:^(UIAlertAction *action)
									  {
											  self.currentRecipient = [self me];
									  }];
	UIAlertAction *echoAction = [UIAlertAction
									  actionWithTitle:[self echoBot].username
									  style:UIAlertActionStyleDefault
									  handler:^(UIAlertAction *action)
									  {
											  self.currentRecipient = [self echoBot];
									  }];
	UIAlertAction *amazingAction = [UIAlertAction
									actionWithTitle:[self amazingBot].username
									style:UIAlertActionStyleDefault
									handler:^(UIAlertAction *action)
									{
											self.currentRecipient = [self amazingBot];
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
									[self logIn];
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

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
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
}

@end
