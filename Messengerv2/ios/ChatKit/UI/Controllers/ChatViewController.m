//
//  ChatViewController.m
//  ChatKit
//
//  Created by Vladimir Yevdokimov on 3/7/16.
//  Copyright © 2016 Vladimir Yevdokimov. All rights reserved.
//

#import "ChatViewController.h"

@interface ChatViewController ()

@property (weak, nonatomic) IBOutlet UITableView *chatTable;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelBBI;

@property (nonatomic, strong) NSMutableArray *presentingMessages;

@end

@implementation ChatViewController


+ (UINib *)nib
{
    return [UINib nibWithNibName:NSStringFromClass([ChatViewController class])
                          bundle:[NSBundle bundleForClass:[ChatViewController class]]];
}

#pragma mark - Interface Methods


- (void)setupUI
{
    if (self.navigationController) {
        self.navigationItem.leftBarButtonItems = [self leftBarButtonItems];
        
        self.titleString = _chatChannel.description;
    }
}

- (NSArray *)leftBarButtonItems
{
    return _cancelBBI?@[_cancelBBI]:@[];
}

- (void)setTitleString:(NSString *)titleString
{
    _titleString = titleString;
    self.navigationItem.title = _titleString;
}

#pragma mark - UITableViewDelegate, UITableViewDataSource



@end
