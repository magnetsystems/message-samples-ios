//
//  ViewController.m
//  Messenger
//
//  Created by Vladimir Yevdokimov on 3/22/16.
//  Copyright © 2016 Vladimir Yevdokimov. All rights reserved.
//

#import "LoginVC.h"

@interface LoginVC ()

@property (weak, nonatomic) IBOutlet UITextField *loginTF;
@property (weak, nonatomic) IBOutlet UITextField *passTF;

@property (weak, nonatomic) IBOutlet UIButton *rememberMeBtn;

@property (nonatomic, assign) BOOL rememberMe;

@end

@implementation LoginVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.rememberMe = YES;
}

- (void)viewDidAppear:(BOOL)animated
{
//    []
    [MMUser resumeSession:^{
        [self loginDidSuccess];
    } failure:^(NSError * _Nonnull err) {
        NSLog(@"no resumed session");
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setRememberMe:(BOOL)rememberMe
{
    _rememberMe = rememberMe;
    [_rememberMeBtn setTitle:[NSString stringWithFormat:@"Remember me (%@)",_rememberMe?@"YES":@"NO"] forState:UIControlStateNormal];
}

#pragma mark - Actions

- (IBAction)toggleRememberMeBtn:(UIButton*)sender
{
    self.rememberMe = !self.rememberMe;
}

- (IBAction)signin:(UIButton*)sender
{
    [_loginTF resignFirstResponder];
    [_passTF resignFirstResponder];
    
    if (!_loginTF.text.length) {
        [_loginTF becomeFirstResponder];
        return;
    }
    if (!_passTF.text.length) {
        [_passTF becomeFirstResponder];
        return;
    }

    
    NSURLCredential *creds = [NSURLCredential credentialWithUser:_loginTF.text password:_passTF.text persistence:NSURLCredentialPersistenceNone];

    [MMUser login:creds  rememberMe:_rememberMe success:^{
        
        [self loginDidSuccess];
        
    } failure:^(NSError * _Nonnull error) {
        
    }];
}

- (void)loginDidSuccess {
    [self presentViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"ChatsNC"] animated:YES completion:^{
        
    }];
}

@end
