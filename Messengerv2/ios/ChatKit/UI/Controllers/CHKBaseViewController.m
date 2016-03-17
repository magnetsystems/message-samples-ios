//
//  CHKBaseViewController.m
//  ChatKit
//
//  Created by Vladimir Yevdokimov on 3/15/16.
//  Copyright © 2016 Vladimir Yevdokimov. All rights reserved.
//

#import "CHKBaseViewController.h"

@interface CHKBaseViewController ()

@end

@implementation CHKBaseViewController

#pragma mark - Class Methods


+ (UINib *)nib
{
    NSLog(@"You need to override this method!");
    return nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

}

- (void)setupUI
{
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[[self class] nib] instantiateWithOwner:self options:nil];
    [self setupUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
