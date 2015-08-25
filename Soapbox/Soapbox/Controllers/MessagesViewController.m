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
#import "Announcement.h"
#import <MMX/MMX.h>

@interface MessagesViewController ()

@property (nonatomic, copy) NSArray * messageList;
@property (nonatomic, copy) NSArray * colorArray;

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

	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(didReceiveMessage:)
												 name:MMXDidReceiveMessageNotification
											   object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver: self
											 selector: @selector(handleResignActive)
												 name: UIApplicationWillResignActiveNotification
											   object: nil];
	

	if (self.channel == nil) {
        [self channelMissing];
		return;
	}
	
	self.textInputbar.autoHideRightButton = NO;
	
	/*
	 *  Extracting the MMXTopic topicName property and setting it as the title of the view.
	 */
	self.title = self.channel.name;
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

- (void)handleResignActive {
	[self goToLoginScreen];
}


- (void)didReceiveMessage:(NSNotification *)notification {
    MMXMessage *message = notification.userInfo[MMXMessageKey];
    if (message.messageType == MMXMessageTypeChannel && [message.channel isEqual:self.channel]) {

		NSMutableArray *tempMessageList = self.messageList.mutableCopy;
		[tempMessageList insertObject:message atIndex:0];
		self.messageList = tempMessageList;

		[self.tableView reloadData];
	}
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Fetch Messages

- (void)fetchMessages {

    [self.channel fetchMessagesBetweenStartDate:nil endDate:nil limit:25 ascending:NO success:^(int totalCount, NSArray *messages) {
        self.messageList = messages;
        [self.tableView reloadData];
    } failure:^(NSError *error) {
        /*
         *  Logging an error.
         */
        [[MMXLogger sharedLogger] error:@"MessagesViewController fetchMessages Error = %@",error.localizedFailureReason];
        
        [self showAlertWithTitle:@"Failed To Fetch Messages" message:error.localizedFailureReason];
    }];
}

#pragma mark - Subscribe/Unsubscribe

- (void)subscribeToChannel {
	if (self.channel) {
		/*
		 *  Subscribing to a MMXTopic
		 *	By passing nil to the device parameter all device for the user will receive future MMXPubSubMessages published to this topic.
		 *	If the user only wants to be subscribed on the current device, pass the MMXEndpoint for the device.
		 */
        [self.channel subscribeWithSuccess:^{
            [self showAlertWithTitle:@"Successfully Subscribed" message:@"You have successfully subscribed to the topic."];
        } failure:^(NSError *error) {
            [self showAlertWithTitle:@"Failed Subscribe" message:error.localizedFailureReason];
        }];
	}
}

- (void)unSubscribeToChannel {
	if (self.channel) {
		/*
		 *  Subscribing to a MMXTopic
		 *	By passing nil to the subscriptionID parameter all devices for the user will unsubscribed from this topic.
		 *	If the user only wants to be unsubscribed for a specific device pass the subscriptionID for that subscription.
		 */
		[self.channel unSubscribeWithSuccess:^{
            [self showAlertWithTitle:@"Successfully Unsubscribed" message:@"You have successfully unsubscribed from the topic."];
        } failure:^(NSError *error) {
            [self showAlertWithTitle:@"Failed Unsubscribe" message:error.localizedFailureReason];
        }];
	}
}

#pragma mark - Publish Message

- (void)didPressRightButton:(id)sender {
	[self.textView refreshFirstResponder];
	
	/*
	 *  Creating a new MMXPubSubMessage. The topic cannot be nil.
	 *  By default the PubSub is anonymous and MMXPubSubMessage does not include the sender's username.
	 *	We are passing the username of the sender in the metaData of the message to be able to show the sender as part of our app functionality.
	 */
    Announcement *announcement = [Announcement announcementWithContent:self.textView.text];
    NSDictionary *messageContent = [MTLJSONAdapter JSONDictionaryFromModel:announcement];
    MMXMessage *messageToSend = [MMXMessage messageToChannel:self.channel messageContent:messageContent];
    /*
	 *  Publishing our message. In this case I do not need to do anything on success. I will receive the MMXClientDelegate callback client:didReceivePubSubMessage:
	 *	I can then treat the message that was sent the same way as any other message I receive.
	 */
    [self.channel publish:messageToSend.messageContent success:nil failure:^(NSError *error) {
        [self showAlertWithTitle:@"Failed to Publish" message:error ? error.localizedFailureReason : @"An unknown error occured when trying to send your message."];
    }];
	
	[super didPressRightButton:sender];
}

#pragma mark - TableView

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	PubSubCell *cell = (PubSubCell *)[tableView dequeueReusableCellWithIdentifier:@"PubSubCell" forIndexPath:indexPath];
	MMXMessage * message = self.messageList[indexPath.row];
	NSString *senderName = message.sender.username;
	UIColor *color = [UIColor soapboxLightGray];
	if (senderName && ![senderName isEqualToString:@""]) {
		color = [self colorForName:senderName];
	}
	
	/*
	 *  Checking the current username against the username of the poster.
	 */
	BOOL isCurrentUser = [senderName isEqualToString:[MMXUser currentUser].username];
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
								actionWithTitle:self.channel.isSubscribed ? @"Unsubscribe" : @"Subscribe"
								style:self.channel.isSubscribed ? UIAlertActionStyleDestructive : UIAlertActionStyleDefault
								handler:^(UIAlertAction *action)
								{
									if (self.channel.isSubscribed) {
										[self unSubscribeToChannel];
									} else {
										[self subscribeToChannel];
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

- (void)channelMissing {
	UIAlertController *alertController = [UIAlertController
										  alertControllerWithTitle:@"Channel Missing"
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

#pragma mark - Private implementation

- (void)goToLoginScreen {
	[self.navigationController popToRootViewControllerAnimated:YES];
}

@end
