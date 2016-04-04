//
//  HomeSplitViewController.m
//  Messenger
//
//  Created by Vladimir Yevdokimov on 3/22/16.
//  Copyright © 2016 Vladimir Yevdokimov. All rights reserved.
//

#import "HomeSplitViewController.h"

@interface HomeSplitViewController ()

@end

@implementation HomeSplitViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.maximumPrimaryColumnWidth = 300;
    self.minimumPrimaryColumnWidth = 30;
    self.preferredDisplayMode = UISplitViewControllerDisplayModeAllVisible;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
