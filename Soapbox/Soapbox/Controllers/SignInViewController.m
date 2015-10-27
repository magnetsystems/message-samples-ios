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
@import MagnetMax;
@import MMX;

@interface SignInViewController ()

@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *signInButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

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
        [self logInWithUsername:self.usernameTextField.text password:self.passwordTextField.text];
    }
}

- (IBAction)registerPressed:(id)sender {
    
    if ([self validateUsername:self.usernameTextField.text password:self.passwordTextField.text]) {
		/*
		 *  Creating a new MMUser.
		 */
		MMUser *newUser = [MMUser new];
		newUser.userName = self.usernameTextField.text;
		newUser.password = self.passwordTextField.text;
		newUser.firstName = self.usernameTextField.text;
		
		[newUser register:^(MMUser * user) {
			[self logInWithUsername:self.usernameTextField.text password:self.passwordTextField.text];
		} failure:^(NSError * error) {
			[self showAlertWithTitle:@"Error Registering User" message:error.localizedFailureReason];
			[self setInputsEnabled:YES];
		}];

    }
}

- (void)logInWithUsername:(NSString *)username password:(NSString *)password {
	
	/*
	 *  Creating a new NSURLCredential.
	 */
	NSURLCredential *credential = [NSURLCredential credentialWithUser:username
															 password:password
														  persistence:NSURLCredentialPersistenceNone];

	//Log in the user
	[MMUser login:credential success:^{
		//Initialize MMX
		[MagnetMax initModule:[MMX sharedInstance] success:^{
			//We will wait to call [MMX start] until we get to the next ViewController where I am better set up to receive messages.
			[self performSegueWithIdentifier:@"ShowChannelList" sender:nil];
		} failure:^(NSError * error) {
			NSLog(@"initModule error = %@", error.localizedDescription);
		}];
	} failure:^(NSError * error) {
		NSString *errorMessage;
		if (error) {
			errorMessage = error.localizedFailureReason ?: error.localizedDescription;
		}
		[self showAlertWithTitle:@"Error" message:(errorMessage && ![errorMessage isEqualToString:@""]) ? errorMessage : @"An unknown error occurred. Please try logging in again"];
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
