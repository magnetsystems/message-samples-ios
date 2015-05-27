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
#import "PubSubCell.h"
#import "UIColor+Soapbox.h"
#import <MMX.h>

@interface MessagesViewController () <MMXClientDelegate>

@property (nonatomic, strong) MMXTopic * topic;
@property (nonatomic, copy) NSArray * messageList;
@property (nonatomic, copy) NSArray * colorArray;
@property (nonatomic, assign) BOOL isSubscribed;

@end

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
	if (self.topic == nil) {
		[self topicMissing];
		return;
	}
	
	self.textInputbar.autoHideRightButton = NO;
	
	/**
	 *  MagnetNote: MMXTopic topicName
	 *
	 *  Extracting the MMXTopic topicName property and setting it as the title of the view.
	 */
	self.title = self.topic.topicName;
	self.messageList = @[];
	[self.tableView registerClass:[PubSubCell class] forCellReuseIdentifier:@"PubSubCell"];
	UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(showOptions)];
	self.navigationItem.rightBarButtonItem = rightBarButtonItem;
	self.messageList = @[];
	self.colorArray = @[[UIColor soapboxChatPerson1],
						[UIColor soapboxChatPerson2],
						[UIColor soapboxChatPerson3],
						[UIColor soapboxChatPerson4],
						[UIColor soapboxChatPerson5],
						[UIColor soapboxChatPerson6]];
	
	[self fetchMessages];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	/**
	 *  MagnetNote: MMXClientDelegate
	 *
	 *  Setting myself as the delegate to receive the MMXClientDelegate callbacks in this class.
	 *	I only care about client:didReceiveConnectionStatusChange:error:  and client:didReceivePubSubMessage: in this class.
	 *	All MMXClientDelegate protocol methods are optional.
	 */
	[MMXClient sharedClient].delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - MMXClientDelegate Callbacks

/**
 *  MagnetNote: MMXClientDelegate client:didReceiveConnectionStatusChange:error:
 *
 *  Monitoring the connection status to kick the user back to the Sign In screen if the connection is lost
 */
- (void)client:(MMXClient *)client didReceiveConnectionStatusChange:(MMXConnectionStatus)connectionStatus error:(NSError *)error {
	if (connectionStatus == MMXConnectionStatusDisconnected) {
		[self.navigationController popToRootViewControllerAnimated:YES];
	}
}

/**
 *  MagnetNote: MMXClientDelegate client:didReceivePubSubMessage:
 *
 *  Monitoring for new messages that may be received while the user is viewing the previously fetched messages.
 */
- (void)client:(MMXClient *)client didReceivePubSubMessage:(MMXPubSubMessage *)message {
	if ([message.topic isEqual:self.topic]) {
		
		NSMutableArray *tempMessageList = self.messageList.mutableCopy;
		[tempMessageList insertObject:message atIndex:0];
		self.messageList = tempMessageList.copy;
		
		[self.tableView reloadData];
	}
}

#pragma mark - Fetch Messages

- (void)fetchMessages {

	/**
	 *  MagnetNote: MMXPubSubFetchRequest requestWithTopic:
	 *
	 *  Creating a MMXPubSubFetchRequest
	 *	By setting ascending to YES it will the most recent result up to 25 total (based on the value set for maxItems)
	 */
	MMXPubSubFetchRequest * request = [MMXPubSubFetchRequest requestWithTopic:self.topic];
	request.ascending = YES;
	request.maxItems = 25;
	
	/**
	 *  MagnetNote: MMXPubSubManager fetchItems:success:failure:
	 *
	 *  Passing my MMXPubSubFetchRequest to the fetchItems API. It will return a NSArray of MMXPubSubMessages
	 */
	[[MMXClient sharedClient].pubsubManager fetchItems:request success:^(NSArray *messages) {
		self.messageList = [[messages reverseObjectEnumerator] allObjects];;
		[self.tableView reloadData];
	} failure:^(NSError *error) {
		
		/**
		 *  MagnetNote: MMXLogger
		 *
		 *  Logging an error.
		 */
		[[MMXLogger sharedLogger] error:@"MessagesViewController fetchMessages Error = %@",error.localizedFailureReason];

		[self showAlertWithTitle:@"Failed To Fetch Messages" message:error.localizedFailureReason];
	}];
}

#pragma mark - Subscribe/Unsubscribe

- (void)subscribeToTopic {
	if (self.topic) {
		/**
		 *  MagnetNote: MMXPubSubManager subscribeToTopic:device:success:failure:
		 *
		 *  Subscribing to a MMXTopic
		 *	By passing nil to the device parameter all device for the user will receive future MMXPubSubMessages published to this topic.
		 *	If the user only wants to be subscribed on the current device, pass the MMXEndpoint for the device.
		 */
		[[MMXClient sharedClient].pubsubManager subscribeToTopic:self.topic device:nil success:^(MMXTopicSubscription *subscription) {
			[self showAlertWithTitle:@"Successfully Subscribed" message:@"You have successfully subscribed to the topic."];
			self.isSubscribed = YES;
		} failure:^(NSError *error) {
			[self showAlertWithTitle:@"Failed Subscribe" message:error.localizedFailureReason];
		}];
	}
}

- (void)unSubscribeFromTopic {
	if (self.topic) {
		/**
		 *  MagnetNote: MMXPubSubManager unsubscribeFromTopic:subscriptionID:success:failure:
		 *
		 *  Subscribing to a MMXTopic
		 *	By passing nil to the subscriptionID parameter all devices for the user will unsubscribed from this topic.
		 *	If the user only wants to be unsubscribed for a specific device pass the subscriptionID for that subscription.
		 */
		[[MMXClient sharedClient].pubsubManager unsubscribeFromTopic:self.topic subscriptionID:nil success:^(BOOL success) {
			[self showAlertWithTitle:@"Successfully Unsubscribed" message:@"You have successfully unsubscribed from the topic."];
			self.isSubscribed = NO;
		} failure:^(NSError *error) {
			[self showAlertWithTitle:@"Failed Unsubscribe" message:error.localizedFailureReason];
		}];
	}
}

#pragma mark - Publish Message

- (void)didPressRightButton:(id)sender {
	[self.textView refreshFirstResponder];
	
	/**
	 *  MagnetNote: MMXPubSubMessage pubSubMessageToTopic:content:metaData:
	 *
	 *  Creating a new MMXPubSubMessage. The topic cannot be nil.
	 *  By default the PubSub is anonymous and MMXPubSubMessage does not include the sender's username.
	 *	We are passing the username of the sender in the metaData of the message to be able to show the sender as part of our app functionality.
	 */
	MMXPubSubMessage * message = [MMXPubSubMessage pubSubMessageToTopic:self.topic
																content:self.textView.text.copy
															   metaData:@{@"username":[MMXClient sharedClient].configuration.credential.user}];
	
	/**
	 *  MagnetNote: MMXPubSubManager publishPubSubMessage:success:failure:
	 *
	 *  Publishing our message. In this case I do not need to do anything on success. I will receive the MMXClientDelegate callback client:didReceivePubSubMessage:
	 *	I can then treat the message that was sent the same way as any other message I receive.
	 */
	[[MMXClient sharedClient].pubsubManager publishPubSubMessage:message success:nil failure:^(NSError *error) {
		[self showAlertWithTitle:@"Failed to Publish" message:error ? error.localizedFailureReason : @"An unknown error occured when trying to send your message."];
	}];
	
	[super didPressRightButton:sender];
}

#pragma mark - TableView

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	PubSubCell *cell = (PubSubCell *)[tableView dequeueReusableCellWithIdentifier:@"PubSubCell" forIndexPath:indexPath];
	MMXPubSubMessage * message = self.messageList[indexPath.row];
	NSString * senderName = message.metaData[@"username"];
	UIColor *color = [UIColor soapboxLightGray];
	if (senderName && ![senderName isEqualToString:@""]) {
		color = [self colorForName:senderName];
	}
	
	/**
	 *  MagnetNote: MMXClient
	 *  MagnetNote: MMXConfiguration
	 *
	 *  Checking the current username against the username of the poster.
	 */
	BOOL isCurrentUser = [senderName isEqualToString:[MMXClient sharedClient].configuration.credential.user];
	if (isCurrentUser) {
		color = [UIColor soapboxChatCurrentUser];
	}
	[cell setMessage:message isCurrentUser:isCurrentUser color:color];
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
	return [PubSubCell estimatedHeightForMessage:self.messageList[indexPath.row] cellWidth:tableView.frame.size.width];
}

#pragma mark - Helpers

- (void)setTopic:(MMXTopic *)topic isSubscribed:(BOOL)isSubscribed {
	self.topic = topic;
	self.isSubscribed = isSubscribed;
}

- (UIColor *)colorForName:(NSString *)name {
	int index = (int)([name hash] % self.colorArray.count);
	return self.colorArray[index];
}

#pragma mark - UIAlertController

- (void)showOptions {
	UIAlertController *alertController = [UIAlertController
										  alertControllerWithTitle:nil
										  message:nil
										  preferredStyle:UIAlertControllerStyleActionSheet];
	
	UIAlertAction *subAction = [UIAlertAction
								actionWithTitle:self.isSubscribed ? @"Unsubscribe" : @"Subscribe"
								style:self.isSubscribed ? UIAlertActionStyleDestructive : UIAlertActionStyleDefault
								handler:^(UIAlertAction *action)
								{
									if (self.isSubscribed) {
										[self unSubscribeFromTopic];
									} else {
										[self subscribeToTopic];
									}
								}];
	[alertController addAction:subAction];
	UIAlertAction *cancelAction = [UIAlertAction
								   actionWithTitle:@"Cancel"
								   style:UIAlertActionStyleCancel
								   handler:^(UIAlertAction *action)
								   {
								   }];
	[alertController addAction:cancelAction];
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

- (void)topicMissing {
	UIAlertController *alertController = [UIAlertController
										  alertControllerWithTitle:@"Topic Missing"
										  message:@"Unfortunately something went wrong and this topic was not loaded correctly."
										  preferredStyle:UIAlertControllerStyleAlert];
	
	UIAlertAction *cancelAction = [UIAlertAction
								   actionWithTitle:@"OK"
								   style:UIAlertActionStyleDefault
								   handler:^(UIAlertAction *action)
								   {
									   [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
								   }];
	[alertController addAction:cancelAction];
	[self presentViewController:alertController animated:YES completion:nil];
}

@end
