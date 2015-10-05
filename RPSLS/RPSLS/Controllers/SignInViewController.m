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


#import "SignInViewController.h"
#import <MMX/MMX.h>

@interface SignInViewController ()

@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *signInButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) NSURLCredential * currentCredential;

- (BOOL)validateUsername:(NSString *)username password:(NSString *)password;

@end

@implementation SignInViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismisKeyboard:)];
    [self.view addGestureRecognizer:tap];
}

- (void)dismisKeyboard:(UITapGestureRecognizer *)sender
{
    [self.view endEditing:YES];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	self.navigationController.navigationBarHidden = YES;

	[self setInputsEnabled:YES];
}

#pragma mark - Actions

- (IBAction)signInPressed:(id)sender {

    if ([self validateUsername:self.usernameTextField.text password:self.passwordTextField.text]) {
        
        /*
         *  Creating a new NSURLCredential.
         */
        self.currentCredential = [NSURLCredential credentialWithUser:self.usernameTextField.text
                                                                 password:self.passwordTextField.text
                                                              persistence:NSURLCredentialPersistenceNone];
        
        [self logInWithCredential:self.currentCredential];
    }
}

- (IBAction)registerPressed:(id)sender {
    
    if ([self validateUsername:self.usernameTextField.text password:self.passwordTextField.text]) {
        
        /*
         *  Creating a new NSURLCredential.
         */
        NSURLCredential *credential = [NSURLCredential credentialWithUser:self.usernameTextField.text
                                                                 password:self.passwordTextField.text
                                                              persistence:NSURLCredentialPersistenceNone];
        
        MMXUser *user = [[MMXUser alloc] init];
        user.displayName = self.usernameTextField.text;
        
        [user registerWithCredential:credential success:^{
            [self logInWithCredential:credential];
        } failure:^(NSError *error) {
            [self showAlertWithTitle:@"Error Registering User" message:error.localizedFailureReason];
            [self setInputsEnabled:YES];
        }];
    }
}

- (void)logInWithCredential:(NSURLCredential *)credential {
    [MMXUser logInWithCredential:credential success:^(MMXUser *user) {
        [self performSegueWithIdentifier:@"ShowStatsScreen" sender:nil];
    } failure:^(NSError *error) {
        [self showAlertWithTitle:@"Error" message:error ? error.localizedFailureReason : @"An unknown error occurred. Please try logging in again"];
        [self setInputsEnabled:YES];
    }];
}

#pragma mark - Enable/Disable UI Elements

- (void)setInputsEnabled:(BOOL)enabled {
	if (enabled) {
		[self.activityIndicator stopAnimating];
	} else {
		[self.activityIndicator startAnimating];
	}
	self.signInButton.enabled = enabled;
	self.usernameTextField.enabled = enabled;
	self.passwordTextField.enabled = enabled;
}

#pragma mark - UIAlertController

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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	self.navigationController.navigationBarHidden = NO;
}

#pragma mark - Validate username and password

- (BOOL)validateUsername:(NSString *)username password:(NSString *)password {
    
    [self setInputsEnabled:NO];
    if (self.usernameTextField.text.length < 5) {
		[self showAlertWithTitle:@"Error" message:@"Username must be at least 5 characters in length."];
		[self setInputsEnabled:YES];
		
		return NO;
	} else if (self.passwordTextField.text.length < 1) {
		[self showAlertWithTitle:@"Error" message:@"You must provide a password"];
		[self setInputsEnabled:YES];
		
		return NO;
	} else {
		return YES;
    }
    
    return NO;
}

@end
