//
//  ChatsList.m
//  ChatKit
//
//  Created by Vladimir Yevdokimov on 3/2/16.
//  Copyright © 2016 Vladimir Yevdokimov. All rights reserved.
//

#import "VYChannelsViewController.h"

#import "VYContactsViewController.h"
#import "VYChatViewController.h"

#import "VYChannelCell.h"

@interface VYChannelsViewController ()

@property (nonatomic,strong) NSMutableArray <MMXChannel*> *presentingChannels;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelBBI;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *createBBI;

@property (weak, nonatomic) IBOutlet UITableView *channelsTable;

@property (nonatomic, strong) UIRefreshControl *tableRefreshControl;


@end

@implementation VYChannelsViewController

+ (UINib*)nib {
    return [UINib nibWithNibName:NSStringFromClass([VYChannelsViewController class])
                          bundle:[NSBundle bundleForClass:[VYChannelsViewController class]]];
}

#pragma mark - UI and Loading

- (void)viewDidLoad
{
    [super viewDidLoad];
    
   
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(messageSendError:) name:MMXMessageSendErrorNotification object:nil];
    
}

- (void)setupUI
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateTableDataUI) name:MMXDidReceiveChannelInviteNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(messageIncome:) name:MMXDidReceiveMessageNotification object:nil];
    
    _tableRefreshControl = [UIRefreshControl new];
    [_channelsTable addSubview:_tableRefreshControl];
    [_tableRefreshControl addTarget:self action:@selector(loadChannels) forControlEvents:UIControlEventValueChanged];

    
    if (self.navigationController) {
        self.navigationItem.leftBarButtonItems = [self leftBarButtonItems];
        self.navigationItem.rightBarButtonItems = [self rightBarButtonItems];
        
        self.navigationItem.title = [self titleString];
        self.navigationController.navigationBarHidden = NO;

    }
}

- (void)viewDidAppear:(BOOL)animated
{
    if (_channels) {
        _presentingChannels = _channels.mutableCopy;
        [_channelsTable reloadData];
    } else {
        //loading default subscribed channels
        [self loadChannels];
    }
}

- (void)updateTableDataUI
{
    [_channelsTable reloadData];
}

- (void)messageIncome:(NSNotification*)notification
{
    [self loadChannels];
    NSLog(@"Got message income notification\n %@",notification);
}

#pragma mark - Interface Methods

- (NSArray *)leftBarButtonItems
{
    return _cancelBBI?@[_cancelBBI]:@[];
}

- (NSArray *)rightBarButtonItems
{
    return _createBBI?@[_createBBI]:@[];
}

- (void)didPressChatCreate
{
    NSLog(@"Activated didPressChatCreate. You should override this method to catch this interaction.");
    
    VYContactsViewController *vc = [VYContactsViewController new];
    
    if (self.navigationController) {
        [self.navigationController pushViewController:vc animated:YES];
    } else {
        UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:vc];
        
        [self presentViewController:nc animated:YES completion:nil];
    }
}

- (void)didPressCancel
{
    NSLog(@"Activated didPressCancel. You should override this method to catch this interaction.");

    if (self.navigationController) {
        if (self.navigationController.presentingViewController) {
            if (self.navigationController.viewControllers.count == 1) {
                
                [self.navigationController dismissViewControllerAnimated:YES completion:nil];
            } else {
                [self.navigationController popViewControllerAnimated:YES];
                
            }
        } else {
            [self.navigationController popViewControllerAnimated:YES];
        }
    } else if (self.presentingViewController) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (NSString *)titleString
{
    return @"Chats List";
}

- (UITableViewRowAction *)swipeLeftActionForChatCellAtIndex:(NSIndexPath *)indexPath
{
    UITableViewRowAction *defaultActionButton = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"Leave" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath)
                                    {
                                        if (_presentingChannels.count > 0 && indexPath.row < _presentingChannels.count) {
                                            MMXChannel *channelToRemove = _presentingChannels[indexPath.row];
                                            [channelToRemove unSubscribeWithSuccess:^{
                                                NSLog(@"channel unsubscribed");
                                            } failure:^(NSError * _Nonnull error) {
                                                NSLog(@"channel unsubscribe error %@",error);
                                            }];
                                            [self.presentingChannels removeObjectAtIndex:indexPath.row];
                                        }
                                    }];
    defaultActionButton.backgroundColor = [UIColor redColor];
    return defaultActionButton;
}


- (void)shouldOpenChatChannel:(MMXChannel*)channel;
{
    if (channel) {
        if (self.navigationController) {
            VYChatViewController *vc = [VYChatViewController new];
            vc.chatChannel = channel;
            [self.navigationController pushViewController:vc animated:YES];
            
        } else {
            VYChatViewController *vc = [VYChatViewController new];
            vc.chatChannel = channel;
            [self.presentingViewController presentViewController:vc animated:YES completion:nil];
        }
    }
    
    NSLog(@"Activated shouldOpenChatForCellAtIndex. You should override this method to catch this interaction.");
}

#pragma mark - Life Cycle

- (void)loadChannels
{
    [MMXChannel subscribedChannelsWithSuccess:^(NSArray<MMXChannel *> * _Nonnull channels) {
        [_tableRefreshControl endRefreshing];
        _channels = channels;
        _presentingChannels = _channels.mutableCopy;
        [_channelsTable reloadData];
        
    } failure:^(NSError * _Nonnull error) {
        [_tableRefreshControl endRefreshing];
        NSLog(@"some error due loading default channels \n%@",error);
    }];
}

#pragma mark UITableViewDelegate, UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = NSStringFromClass([VYChannelCell class]);
    VYChannelCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[VYChannelCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    cell.channel = _presentingChannels[indexPath.row];
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _presentingChannels.count;
}

- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @[[self swipeLeftActionForChatCellAtIndex:indexPath]];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_presentingChannels.count) {
        MMXChannel *channel = _presentingChannels[indexPath.row];
        [self shouldOpenChatChannel:channel];
    }
    
}

#pragma mark Actions

- (IBAction)rightBtnPress:(UIBarButtonItem*)sender
{
    [self didPressChatCreate];
}

- (IBAction)leftBtnPress:(UIBarButtonItem*)sender
{
    [self didPressCancel];
}

@end
