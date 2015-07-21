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


#import "TopicListTableViewController.h"
#import "TopicListCell.h"
#import "MessagesViewController.h"
#import <MMX/MMX.h>

@interface TopicListTableViewController () <MMXClientDelegate, UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating>

@property (nonatomic, copy) NSArray * subscribedTopicsList;
@property (nonatomic, copy) NSArray * unSubscribedTopicsList;

@property (nonatomic, copy) NSArray * filteredSubscribedTopicsList;
@property (nonatomic, copy) NSArray * filteredUnSubscribedTopicsList;

@property (nonatomic, strong) UISearchController *searchController;

@end

@implementation TopicListTableViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
	
	[self setupTableViewProperties];
	
	self.subscribedTopicsList = @[];
	self.unSubscribedTopicsList = @[];
	self.filteredSubscribedTopicsList = @[];
	self.filteredUnSubscribedTopicsList = @[];
	
	[self setupTopics];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

	/*
	 *  Setting myself as the delegate to receive the MMXClientDelegate callbacks in this class.
	 *	I only care about client:didReceiveConnectionStatusChange:error:
	 *	All MMXClientDelegate protocol methods are optional.
	 */
	[MMXClient sharedClient].delegate = self;
	
	[MMXClient sharedClient].shouldSuspendIncomingMessages = NO;

	[self fetchTopics];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Create Default Topics

//This is used to create our 2 default topics for this app and subscribe the user to the Announcements topic
- (void)setupTopics {
	/*
	 *  Creating a new MMXTopic object. I could have also used MMXTopic topicWithName:maxItemsToPersist:permissionsLevel:
	 *	I am setting a description to potentially display to future users as part of topic discovery.
	 */
	MMXTopic * companyTopic = [MMXTopic topicWithName:@"company_announcements"];
	companyTopic.topicDescription = @"The Company Announcements topic is designed to distribute information that should be available to all employees.";

	/*
	 *  Creating a new topic by passing my MMXTopic object.
	 *	When a user creates a topic they are NOT automatically subscribed to it.
	 */
	[[MMXClient sharedClient].pubsubManager createTopic:companyTopic success:^(BOOL success) {
		
		/*
		 *  Subscribe the current user to the newly created topic.
		 *	By passing nil to the device parameter all device for the user will receive future MMXPubSubMessages published to this topic.
		 *	If the user only wants to be subscribed on the current device, pass the MMXEndpoint for the device.
		 */
		[[MMXClient sharedClient].pubsubManager subscribeToTopic:companyTopic device:nil success:^(MMXTopicSubscription *subscription) {
			//Fetching topics again to make sure that the company_announcements topic show up under subscribed.
			[self fetchTopics];
		} failure:^(NSError *error) {
			
			/*
			 *  Logging an error.
			 */
			[[MMXLogger sharedLogger] error:@"TopicListTableViewController setupTopics Error = %@",error.localizedFailureReason];
		}];
	} failure:^(NSError *error) {
		//The error code for "duplicate topic" is 409. This means the topic already exists and I can continue to subscribe.
		if (error.code == 409) {

			/*
			 *  Subscribing to a MMXTopic
			 *	By passing nil to the device parameter all device for the user will receive future MMXPubSubMessages published to this topic.
			 *	If the user only wants to be subscribed on the current device, pass the MMXEndpoint for the device.
			 */
			[[MMXClient sharedClient].pubsubManager subscribeToTopic:companyTopic device:nil success:^(MMXTopicSubscription *subscription) {
				//Fetching topics again to make sure that the company_announcements topic show up under subscribed.
				[self fetchTopics];
			}  failure:^(NSError *error) {

				/*
				 *  Logging an error.
				 */
				[[MMXLogger sharedLogger] error:@"TopicListTableViewController setupTopics Error = %@",error.localizedFailureReason];
			}];
		}
	}];

	/*
	 *  Creating a new MMXTopic object. I could have also used MMXTopic topicWithName:maxItemsToPersist:permissionsLevel:
	 *	I am setting a description to potentially display to future users as part of topic discovery.
	 */
	MMXTopic * lunchTopic = [MMXTopic topicWithName:@"lunch_buddies"];
	lunchTopic.topicDescription = @"Lunch Buddies is a topic for finding other people to go to lunch with.";
	
	/*
	 *  Creating a new topic by passing my MMXTopic object.
	 *	I am passing nil to success because there is not any business logic I need to execute upon success.
	 */
	[[MMXClient sharedClient].pubsubManager createTopic:lunchTopic success:nil failure:^(NSError *error) {
		NSLog(@"createTopic for topic %@ Error = %@",lunchTopic.topicName,error);
	}];
}

#pragma mark - Fetch all Topics

- (void)fetchTopics {
	[self.refreshControl beginRefreshing];
	
	/*
	 *  Getting the list of all subscriptions for the current user.
	 */
	[[MMXClient sharedClient].pubsubManager listSubscriptionsWithSuccess:^(NSArray *subscriptions) {
		NSMutableArray * tempSubArray = [NSMutableArray arrayWithCapacity:subscriptions.count];

		/*
		 *  Extracting the MMXTopics from the MMXTopicSubscription objects.
		 */
		for (MMXTopicSubscription * topicSub in subscriptions) {
			[tempSubArray addObject:topicSub.topic];
		}
		/*
		 *  Getting the list all topics(max of 100)
		 */
		[[MMXClient sharedClient].pubsubManager listTopics:100 success:^(int totalCount, NSArray *topics) {
			[[MMXClient sharedClient].pubsubManager summaryOfTopics:topics since:[[NSDate date] dateByAddingTimeInterval:-60*60*24] until:[NSDate date] success:^(NSArray *summaries) {
				NSMutableArray *subTopicsList = @[].mutableCopy;
				NSMutableArray *otherTopicsList = @[].mutableCopy;
				for (MMXTopicSummary *summary in summaries) {
					if ([tempSubArray containsObject:summary.topic]) {
						[subTopicsList addObject:summary];
					} else {
						[otherTopicsList addObject:summary];
					}
				}
				self.subscribedTopicsList = subTopicsList;
				self.unSubscribedTopicsList = otherTopicsList;
				[self.tableView reloadData];
				[self.refreshControl endRefreshing];
			} failure:^(NSError *error) {
				[[MMXLogger sharedLogger] error:@"TopicListTableViewController fetchTopics Error = %@",error.localizedFailureReason];
			}];
		} failure:^(NSError *error) {

			/*
			 *  Logging an error.
			 */
			[[MMXLogger sharedLogger] error:@"TopicListTableViewController fetchTopics Error = %@",error.localizedFailureReason];

			[self.tableView reloadData];
			[self.refreshControl endRefreshing];
		}];
	} failure:^(NSError *error) {

		/*
		 *  Logging an error.
		 */
		[[MMXLogger sharedLogger] error:@"TopicListTableViewController fetchTopics Error = %@",error.localizedFailureReason];

		[self.refreshControl endRefreshing];
	}];
}

#pragma mark - MMXClientDelegate Callbacks

/*
 *  Monitoring the connection status to kick the user back to the Sign In screen if the connection is lost
 */
- (void)client:(MMXClient *)client didReceiveConnectionStatusChange:(MMXConnectionStatus)connectionStatus error:(NSError *)error {
	if (connectionStatus == MMXConnectionStatusDisconnected) {
		[self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
	}
}

#pragma mark - Actions

- (IBAction)signoutPressed:(id)sender {
	UIAlertController *alertController = [UIAlertController
										  alertControllerWithTitle:@"Sign Out"
										  message:[NSString stringWithFormat:@"Continue to sign out?"]
										  preferredStyle:UIAlertControllerStyleAlert];
	
	UIAlertAction *okAction = [UIAlertAction
								   actionWithTitle:NSLocalizedString(@"OK", @"OK action")
								   style:UIAlertActionStyleDefault
								   handler:^(UIAlertAction *action)
								   {
									   /*
										*  Ending our session.
										*/
									   [[MMXClient sharedClient] disconnect];
								   }];
	UIAlertAction *cancelAction = [UIAlertAction
								 actionWithTitle:NSLocalizedString(@"Cancel", @"Cancel action")
								 style:UIAlertActionStyleDefault
								 handler:^(UIAlertAction *action)
								 {
								 }];
	
	[alertController addAction:okAction];
	[alertController addAction:cancelAction];
	[self presentViewController:alertController animated:YES completion:nil];

}

#pragma mark - Search

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
	[searchBar resignFirstResponder];
}

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
	// update the filtered array based on the search text
	NSString *searchText = searchController.searchBar.text;
	NSMutableArray *subSearchResults = [self.subscribedTopicsList mutableCopy];
	NSMutableArray *unsubSearchResults = [self.unSubscribedTopicsList mutableCopy];
	
	// strip out all the leading and trailing spaces
	NSString *strippedString = [searchText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
	
	// break up the search terms (separated by spaces)
	NSArray *searchItems = nil;
	if (strippedString.length > 0) {
		searchItems = [strippedString componentsSeparatedByString:@" "];
	}
	
	NSMutableArray *andMatchPredicates = [NSMutableArray array];
	
	for (NSString *searchString in searchItems) {
		NSMutableArray *searchItemsPredicate = [NSMutableArray array];
		NSExpression *lhs = [NSExpression expressionForKeyPath:@"topicName"];
		NSExpression *rhs = [NSExpression expressionForConstantValue:searchString];
		NSPredicate *finalPredicate = [NSComparisonPredicate
									   predicateWithLeftExpression:lhs
									   rightExpression:rhs
									   modifier:NSDirectPredicateModifier
									   type:NSContainsPredicateOperatorType
									   options:NSCaseInsensitivePredicateOption];
		[searchItemsPredicate addObject:finalPredicate];
		
		// at this OR predicate to our master AND predicate
		NSCompoundPredicate *orMatchPredicates = [NSCompoundPredicate orPredicateWithSubpredicates:searchItemsPredicate];
		[andMatchPredicates addObject:orMatchPredicates];
	}
	
	// match up the fields of the Product object
	NSCompoundPredicate *finalCompoundPredicate =
	[NSCompoundPredicate andPredicateWithSubpredicates:andMatchPredicates];
	
	// hand over the filtered results to our search results table
	self.filteredSubscribedTopicsList = [subSearchResults filteredArrayUsingPredicate:finalCompoundPredicate];
	self.filteredUnSubscribedTopicsList = [unsubSearchResults filteredArrayUsingPredicate:finalCompoundPredicate];
	[self.tableView reloadData];
}

#pragma mark - Set up lists

- (void)setSubscribedTopicsList:(NSArray *)subscribedTopicsList {
	_subscribedTopicsList = subscribedTopicsList;
	self.filteredSubscribedTopicsList = subscribedTopicsList.copy;
}

- (void)setUnSubscribedTopicsList:(NSArray *)unSubscribedTopicsList {
	_unSubscribedTopicsList = unSubscribedTopicsList;
	self.filteredUnSubscribedTopicsList = unSubscribedTopicsList.copy;
}

#pragma mark - TableView

- (void)setupTableViewProperties {
	UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
 
	// Configure Refresh Control
	[refreshControl addTarget:self action:@selector(fetchTopics) forControlEvents:UIControlEventValueChanged];
 
	// Configure View Controller
	[self setRefreshControl:refreshControl];
	
	self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
	self.searchController.searchResultsUpdater = self;
	[self.searchController.searchBar sizeToFit];
	
	self.searchController.delegate = self;
	self.searchController.dimsBackgroundDuringPresentation = NO; // default is YES
	self.searchController.searchBar.delegate = self; // so we can monitor text changes + others
	
	self.tableView.tableHeaderView = self.searchController.searchBar;
	
	self.tableView.estimatedRowHeight = 40.0;
	self.tableView.rowHeight = UITableViewAutomaticDimension;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	TopicListCell *cell = (TopicListCell *)[tableView cellForRowAtIndexPath:indexPath];
	[self performSegueWithIdentifier:@"TopicMessagesSegue" sender:cell];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (section == 0) {
		return self.filteredSubscribedTopicsList.count;
	} else if (section == 1) {
		return self.filteredUnSubscribedTopicsList.count;
	}
	return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	if (section == 0) {
		return @"Subscriptions";
	} else if (section == 1) {
		return @"Other Topics";
	}
	return @"";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *CellIdentifier = @"TopicListCell";
	
	TopicListCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (!cell) {
		[tableView registerNib:[UINib nibWithNibName:@"TopicListCell" bundle:nil] forCellReuseIdentifier:CellIdentifier];
		cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	}
	
	MMXTopicSummary *topicSummary;
	if (indexPath.section == 0) {
		topicSummary = self.filteredSubscribedTopicsList[indexPath.row];
		[cell setTopicSummary:topicSummary isSubscribed:YES];
	} else {
		topicSummary = self.filteredUnSubscribedTopicsList[indexPath.row];
		[cell setTopicSummary:topicSummary isSubscribed:NO];
	}

	return cell;
}

#pragma mark - Actions & UIStoryboardSegue

- (IBAction)createNewTopic:(id)sender {
	[self performSegueWithIdentifier:@"NewTopicSegue" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	self.searchController.active = NO;
	if ([[segue identifier] isEqualToString:@"TopicMessagesSegue"]) {
		MessagesViewController *vc = [segue destinationViewController];
		TopicListCell *cell = (TopicListCell *)sender;
		[vc setTopic:cell.topicSummary.topic isSubscribed:cell.isSubscribed];
	}
}

@end
