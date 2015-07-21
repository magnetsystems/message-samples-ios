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


#import "NewTopicTableViewController.h"
#import "NewTopicNameCell.h"
#import "NewTopicTagCell.h"
#import <MMX.h>

@interface NewTopicTableViewController () <MMXClientDelegate>

@property (nonatomic, copy) NSArray *tagsArray;

@end

@implementation NewTopicTableViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
	
	/*
	 *  Create Array of potential tags.
	 *	Tags are strings. They cannot contain spaces.
	 */
	self.tagsArray = @[@"announcements",@"food",@"funny",@"localevents",@"scheduling",@"testing"];
	
	UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStylePlain target:self action:@selector(createTopic)];
	self.navigationItem.rightBarButtonItem = rightBarButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	/*
	 *  Setting myself as the delegate to receive the MMXClientDelegate callbacks in this class.
	 *	I only care about client:didReceiveConnectionStatusChange:error: in this class.
	 *	All MMXClientDelegate protocol methods are optional.
	 */
	[MMXClient sharedClient].delegate = self;

	[MMXClient sharedClient].shouldSuspendIncomingMessages = NO;
}

#pragma mark - MMXClientDelegate Callbacks

/*
 *  Monitoring the connection status to kick the user back to the Sign In screen if the connection is lost
 */
- (void)client:(MMXClient *)client didReceiveConnectionStatusChange:(MMXConnectionStatus)connectionStatus error:(NSError *)error {
	if (connectionStatus == MMXConnectionStatusDisconnected) {
		[self.navigationController popToRootViewControllerAnimated:YES];
	}
}

#pragma mark - Create Topic

- (void)createTopic {
	
	//Extracting the topic name from the cell
	NSIndexPath * path = [NSIndexPath indexPathForRow:0 inSection:0];
	NewTopicNameCell * cell = (NewTopicNameCell *)[self.tableView cellForRowAtIndexPath:path];
	NSString * topicName = cell.topicName;
	
	//Doing some local validation
	if (topicName == nil || [topicName isEqualToString:@""]) {
		[self showAlertForSuccess:NO title:@"Invalid Topic Name" description:@"Please check that you have entered a valid topic name. The field cannot be blank."];
	} else if ([topicName rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@" "]].location != NSNotFound) {
		[self showAlertForSuccess:NO title:@"Invalid Topic Name" description:@"Topic name cannot contain spaces."];
	} else {
		
		/*
		 *  Creating a new MMXTopic object. I could have also used MMXTopic topicWithName: as the values I passed in are same as the defaults.
		 */
		MMXTopic * topic = [MMXTopic topicWithName:topicName maxItemsToPersist:-1 permissionsLevel:MMXPublishPermissionsLevelAnyone];
		
		/*
		 *  Creating a new topic by passing my MMXTopic object.
		 *	When a user creates a topic they are NOT automatically subscribed to it.
		 */
		[[MMXClient sharedClient].pubsubManager createTopic:topic success:^(BOOL success) {
			NSArray * tagsArray = [self topicTags];
			if (tagsArray.count) {
				
				/*
				 *  Setting tags on the newly created topic.
				 *	There are also APIs to get the list of existing tags, add tags and remove tags.
				 */
				[[MMXClient sharedClient].pubsubManager setTags:tagsArray topic:topic success:^(BOOL success) {
					[self showSubscriptionDialog:topic description:@"Topic created successfully. Would you like to subscribe to this topic?"];
				} failure:^(NSError *error) {
					[self showSubscriptionDialog:topic description:@"Topic was created successfully but there was an error adding the tags. Would you like to subscribe to this topic?"];
				}];
			} else {
				[self showAlertForSuccess:YES title:@"Topic Created" description:@"Topic created successfully."];
			}
		} failure:^(NSError *error) {
			[self showAlertForSuccess:NO title:@"Topic Creation Failure" description:error.localizedFailureReason];
		}];
	}
	
}

- (NSArray *)topicTags {
	NSMutableArray *tags = @[].mutableCopy;
	for (NSInteger i = 0; i < [self.tableView numberOfRowsInSection:1]; ++i)
	{
		NewTopicTagCell * cell = (NewTopicTagCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:1]];
		if (cell.isSelected) {
			[tags addObject:cell.tagName];
		}
	}
	return tags.copy;
}

#pragma mark - Show UIAlertController

- (void)showSubscriptionDialog:(MMXTopic *)topic description:(NSString *)description {

	UIAlertController *alertController = [UIAlertController
										  alertControllerWithTitle:@"Topic Created"
										  message:description
										  preferredStyle:UIAlertControllerStyleAlert];
	
	
	UIAlertAction *subscribeAction = [UIAlertAction
								 actionWithTitle:NSLocalizedString(@"YES", @"YES action")
								 style:UIAlertActionStyleDefault
								 handler:^(UIAlertAction *action) {

									 /*
									  *  Subscribing to a MMXTopic
									  *	By passing nil to the device parameter all device for the user will receive future MMXPubSubMessages published to this topic.
									  *	If the user only wants to be subscribed on the current device, pass the MMXEndpoint for the device.
									  */
									 [[MMXClient sharedClient].pubsubManager subscribeToTopic:topic device:nil success:^(MMXTopicSubscription *subscription) {
										 [self showAlertForSuccess:YES title:@"Subscribed to Topic" description:@"You have successfully subscribed to the topic."];
									 } failure:^(NSError *error) {
										 [self showAlertForSuccess:YES title:@"Subscription Failed" description:@"Please try again later."];
									 }];
								 }];
	UIAlertAction *doneAction = [UIAlertAction
								 actionWithTitle:NSLocalizedString(@"NO", @"NO action")
								 style:UIAlertActionStyleDefault
								 handler:^(UIAlertAction *action) {
									[self.navigationController popToRootViewControllerAnimated:YES];
								 }];
	[alertController addAction:subscribeAction];
	[alertController addAction:doneAction];
	[self presentViewController:alertController animated:YES completion:nil];
}


- (void)showAlertForSuccess:(BOOL)success title:(NSString *)title description:(NSString *)description {
	UIAlertController *alertController = [UIAlertController
										  alertControllerWithTitle:title
										  message:description
										  preferredStyle:UIAlertControllerStyleAlert];
	
	
	UIAlertAction *doneAction = [UIAlertAction
								 actionWithTitle:NSLocalizedString(@"OK", @"OK action")
								 style:UIAlertActionStyleDefault
								 handler:^(UIAlertAction *action) {
									 if (success) {
										 [self.navigationController popToRootViewControllerAnimated:YES];
									 }
								 }];
	[alertController addAction:doneAction];
	[self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (section == 0) {
		return 1;
	} else if (section == 1) {
		return self.tagsArray.count;
	}
	return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	if (section == 0) {
		return @"Topic Name";
	} else if (section == 1) {
		return @"Tags";
	}
	return @"";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 0) {
		NewTopicNameCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NewTopicNameCell" forIndexPath:indexPath];
		return cell;
	} else {
		NewTopicTagCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NewTopicTagCell" forIndexPath:indexPath];
		[cell setupCellWithName:self.tagsArray[indexPath.row]];
		return cell;
	}
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 0) {
		return;
	} else if (indexPath.section == 1) {
		NewTopicTagCell *cell = (NewTopicTagCell *)[self.tableView cellForRowAtIndexPath:indexPath];
		return [cell updateSelection];
	}
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 0) {
		return;
	} else if (indexPath.section == 1) {
		NewTopicTagCell *cell = (NewTopicTagCell *)[self.tableView cellForRowAtIndexPath:indexPath];
		return [cell updateSelection];
	}
}

@end
