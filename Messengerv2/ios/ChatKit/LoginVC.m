//
//  LoginVC.m
//  ChatKit
//
//  Created by Vladimir Yevdokimov on 3/16/16.
//  Copyright © 2016 Vladimir Yevdokimov. All rights reserved.
//

#import "LoginVC.h"

#import "VYChannelsViewController.h"

#import "AuthManager.h"
#import "SVProgressHUD.h"

@implementation LoginVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [SVProgressHUD showWithStatus:@"Loading.."];
    
    [MMUser resumeSession:^{
        [SVProgressHUD dismiss];
        
        [self initMMX];
        
    } failure:^(NSError * _Nonnull error) {
        [SVProgressHUD dismiss];
        
    }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.passwordPlaceholder = @"my custom pass";
    self.logoImage = [UIImage imageNamed:@"qr"];
    self.minimupPasswordLength = 3;
}

- (void)shouldSubmitCredentials:(NSString *)login password:(NSString *)password
{
    [SVProgressHUD showWithStatus:@"Loading.."];

    [[AuthManager shared] loginUserWithEmail:login password:password rememberMe:self.rememberMe callback:^(BOOL success, NSError *error) {
        [SVProgressHUD dismiss];
        if (success) {
            [self initMMX];
        } else {
            UIAlertController *alc = [UIAlertController alertControllerWithTitle:@"error" message:[NSString stringWithFormat:@"error %@",error.localizedDescription] preferredStyle:UIAlertControllerStyleAlert];
            [alc addAction:[UIAlertAction actionWithTitle:@"close" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {}]];
            [self presentViewController:alc animated:YES completion:nil];
            
        }
    }];
}


- (void)initMMX
{
    [SVProgressHUD showWithStatus:@"Connecting.."];

    [MagnetMax initModule:[MMX sharedInstance] success:^{
        [SVProgressHUD dismiss];
        VYChannelsViewController *vc = [VYChannelsViewController new];
        
        UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:vc];
        
        [self presentViewController:nc animated:YES completion:nil];
        
    } failure:^(NSError * _Nonnull error) {
        [SVProgressHUD dismiss];
        UIAlertController *alc = [UIAlertController alertControllerWithTitle:@"error" message:[NSString stringWithFormat:@"error %@",error.localizedDescription] preferredStyle:UIAlertControllerStyleAlert];
        [alc addAction:[UIAlertAction actionWithTitle:@"close" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {}]];
        [self presentViewController:alc animated:YES completion:nil];
    }];
}

@end
