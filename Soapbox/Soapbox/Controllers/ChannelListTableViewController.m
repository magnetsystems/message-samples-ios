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


#import "ChannelListTableViewController.h"
#import "ChannelListCell.h"
#import "MessagesViewController.h"
#import <MMX/MMX.h>

@interface ChannelListTableViewController () <UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating>

@property (nonatomic, copy) NSArray *subscribedChannelsList;
@property (nonatomic, copy) NSArray *unSubscribedChannelsList;

@property (nonatomic, copy) NSArray *filteredSubscribedChannelsList;
@property (nonatomic, copy) NSArray *filteredUnSubscribedChannelsList;

@property (nonatomic, strong) UISearchController *searchController;
//@property (nonatomic, strong) UIRefreshControl *refreshControl;

- (void)goToLoginScreen;
@end

@implementation ChannelListTableViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.refreshControl = [[UIRefreshControl alloc]init];
    [self.tableView addSubview:self.refreshControl];
    [self.refreshControl addTarget:self action:@selector(fetchChannels) forControlEvents:UIControlEventValueChanged];
	
    // Indicate that you are ready to receive and send messages now!
    [MMX start];
	
	[self setupTableViewProperties];
	
	self.subscribedChannelsList = @[];
	self.unSubscribedChannelsList = @[];
	self.filteredSubscribedChannelsList = @[];
	self.filteredUnSubscribedChannelsList = @[];

    [self setupChannels];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	self.navigationController.navigationBarHidden = NO;

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didDisconnect:)
                                                 name:MMXDidDisconnectNotification
                                               object:nil];

    [self fetchChannels];
	[[NSNotificationCenter defaultCenter] addObserver: self
											 selector: @selector(handleResignActive)
												 name: UIApplicationWillResignActiveNotification
											   object: nil];
	
}

- (void)handleResignActive {
	[self goToLoginScreen];
}

- (void)viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didDisconnect:(NSNotification *)notification {

    // Indicate that you are not ready to send and receive messages now!
    [MMX stop];
    
    [self goToLoginScreen];
}

#pragma mark - Create Default Channels

// This is used to create our 2 default channels for this app and subscribe the user to the Announcements channel
- (void)setupChannels {
    /*
	 *  Creating a new MMXChannel object.
	 *	I am setting a summary to potentially display to future users as part of channel discovery.
	 */
	NSString *channelName = @"company_announcements";
	NSString *channelSummary = @"The Company Announcements channel is designed to distribute information that should be available to all employees.";
	
	/*
	 *  Creating a new channel by passing my MMXChannel object.
	 *	When a user creates a channel they are automatically subscribed to it.
	 */
	[MMXChannel createWithName:channelName summary:channelSummary isPublic:YES success:^(MMXChannel *channel) {
		
		// Fetching channels again to make sure that the company_announcements channel show up under subscribed.
		[self fetchChannels];
    } failure:^(NSError *error) {
        //The error code for "duplicate channel" is 409. This means the channel already exists and I can continue to subscribe.
        if (error.code == 409) {
			[MMXChannel channelForName:channelName isPublic:YES success:^(MMXChannel *channel) {
				[channel subscribeWithSuccess:^{
					// Fetching channels again to make sure that the company_announcements channel show up under subscribed.
					[self fetchChannels];
				} failure:^(NSError *subscribeError) {
					/*
					 *  Logging an error.
					 */
					[[MMXLogger sharedLogger] error:@"ChannelListTableViewController setupChannels subscribeWithSuccess Error = %@", subscribeError.localizedFailureReason];
				}];
			} failure:^(NSError *error) {
				/*
				 *  Logging an error.
				 */
				[[MMXLogger sharedLogger] error:@"ChannelListTableViewController setupChannels channelForName Error = %@", error.localizedFailureReason];
			}];
        }
    }];

	NSString *lunchChannelName = @"lunch_buddies";
	NSString *lunchChannelSummary = @"Lunch Buddies is a channel for finding other people to go to lunch with.";
	[MMXChannel createWithName:lunchChannelName summary:lunchChannelSummary isPublic:YES success:^(MMXChannel *channel) {
	} failure:^(NSError *error) {
		NSLog(@"createChannel for channel %@ Error = %@", lunchChannelName, error);
	}];
}

#pragma mark - Fetch all Channels

- (void)fetchChannels {
	[MMXChannel allPublicChannelsWithLimit:100 offset:0 success:^(int totalCount, NSArray *channels) {

        NSPredicate *subscribedPredicate = [NSPredicate predicateWithFormat:@"isSubscribed == YES"];
        NSPredicate *notSubscribedPredicate = [NSPredicate predicateWithFormat:@"isSubscribed == NO"];

        self.subscribedChannelsList = [channels filteredArrayUsingPredicate:subscribedPredicate];
        self.unSubscribedChannelsList = [channels filteredArrayUsingPredicate:notSubscribedPredicate];

        if (self.refreshControl.isRefreshing) {
            [self.refreshControl endRefreshing];
        }

        [self.tableView reloadData];
        
        

    } failure:^(NSError *error) {
        /*
         *  Logging an error.
         */
        [[MMXLogger sharedLogger] error:@"ChannelListTableViewController fetchChannels Error = %@", error.localizedFailureReason];

        if (self.refreshControl.isRefreshing) {
            [self.refreshControl endRefreshing];
        }

    }];
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
                                       [MMXUser logOutWithSuccess:^{
                                           [self goToLoginScreen];
                                       } failure:^(NSError *error) {

                                       }];

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

	// strip out all the leading and trailing spaces
	NSString *strippedString = [searchText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
	
	// break up the search terms (separated by spaces)
	NSArray *searchItems = nil;
	if (strippedString.length > 0) {
		searchItems = [strippedString componentsSeparatedByString:@" "];
	}


	
	NSMutableArray *searchStringPredicates = [NSMutableArray array];
	
	for (NSString *searchString in searchItems) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name CONTAINS[c] %@", searchString];
		[searchStringPredicates addObject:predicate];
	}

    // match up the fields of the Product object
	NSCompoundPredicate *finalCompoundPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:searchStringPredicates];
	
	// hand over the filtered results to our search results table
	self.filteredSubscribedChannelsList = [self.subscribedChannelsList filteredArrayUsingPredicate:finalCompoundPredicate];
	self.filteredUnSubscribedChannelsList = [self.unSubscribedChannelsList filteredArrayUsingPredicate:finalCompoundPredicate];
	[self.tableView reloadData];
}

#pragma mark - Set up lists

- (void)setSubscribedChannelsList:(NSArray *)subscribedChannelsList {
	_subscribedChannelsList = subscribedChannelsList;
	self.filteredSubscribedChannelsList = subscribedChannelsList.copy;
}

- (void)setUnSubscribedChannelsList:(NSArray *)unSubscribedChannelsList {
	_unSubscribedChannelsList = unSubscribedChannelsList;
	self.filteredUnSubscribedChannelsList = unSubscribedChannelsList.copy;
}

#pragma mark - TableView

- (void)setupTableViewProperties {
	UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
 
	// Configure Refresh Control
    [refreshControl addTarget:self action:@selector(fetchChannels) forControlEvents:UIControlEventValueChanged];
 
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
	ChannelListCell *cell = (ChannelListCell *)[tableView cellForRowAtIndexPath:indexPath];
	[self performSegueWithIdentifier:@"ChannelMessagesSegue" sender:cell];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (section == 0) {
		return self.filteredSubscribedChannelsList.count;
	} else if (section == 1) {
		return self.filteredUnSubscribedChannelsList.count;
	}
	return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	if (section == 0) {
		return @"Subscriptions";
	} else if (section == 1) {
		return @"Other Channels";
	}
	return @"";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *CellIdentifier = @"ChannelListCell";
	
	ChannelListCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (!cell) {
		[tableView registerNib:[UINib nibWithNibName:@"ChannelListCell" bundle:nil] forCellReuseIdentifier:CellIdentifier];
		cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	}
	
	if (indexPath.section == 0) {
        cell.channel = self.filteredSubscribedChannelsList[indexPath.row];
	} else {
        cell.channel = self.filteredUnSubscribedChannelsList[indexPath.row];
	}

	return cell;
}

#pragma mark - Actions & UIStoryboardSegue

- (IBAction)createNewChannel:(id)sender {
	[self performSegueWithIdentifier:@"NewChannelSegue" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	self.searchController.active = NO;
	if ([[segue identifier] isEqualToString:@"ChannelMessagesSegue"]) {
		MessagesViewController *vc = [segue destinationViewController];
		ChannelListCell *cell = (ChannelListCell *)sender;
		vc.channel = cell.channel;
	}
}

#pragma mark - Private implementation

- (void)goToLoginScreen {
	[self.navigationController popToRootViewControllerAnimated:YES];
}

@end
