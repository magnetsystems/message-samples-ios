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
#import "StatsScreenViewController.h"
#import "MMX/MMX.h"

@interface SignInViewController () <MMXClientDelegate>

@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *signInButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end

@implementation SignInViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

	/**
	 *  MagnetNote: MMXConfiguration configurationWithName:
	 *  MagnetNote: MMXClient configuration
	 *
	 *  Creating a new MMXConfiguration using the "default" profile from the Configurations.plist file.
	 *	The Configurations.plist file can contain multiple profiles.
	 *	Setting the configuration property of our MMXClient.
	 */
	MMXConfiguration * config = [MMXConfiguration configurationWithName:@"default"];
	[MMXClient sharedClient].configuration = config;
	
	/**
	 *  MagnetNote: MMXLogger startLogging
	 *  MagnetNote: MMXLogger level
	 *
	 *  Starting the logger and setting the level to get the most information possible.
	 */
	[[MMXLogger sharedLogger] startLogging];
	[MMXLogger sharedLogger].level = MMXLoggerLevelVerbose;
	
	/**
	 *  MagnetNote: MMXClient shouldAutoCreateUser
	 *
	 *  Setting the value of the MMXClient shouldAutoCreateUser property to YES.
	 *	By setting this value to yes the SDK will try and create a new user with the provided credentials if the user does not already exist.
	 */
	[MMXClient sharedClient].shouldAutoCreateUser = YES;
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

	/**
	 *  MagnetNote: MMXClientDelegate
	 *
	 *  Setting myself as the delegate to receive the MMXClientDelegate callbacks in this class.
	 *	I only care about client:didReceiveConnectionStatusChange:error: and client:didReceiveUserAutoRegistrationResult:error: in this class.
	 *	All MMXClientDelegate protocol methods are optional.
	 */
	[MMXClient sharedClient].delegate = self;
	[self setInputsEnabled:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - MMXClientDelegate Callbacks

/**
 *  MagnetNote: MMXClientDelegate client:didReceiveConnectionStatusChange:error:
 *
 *  Monitoring the connection status change to MMXConnectionStatusAuthenticated.
 */
- (void)client:(MMXClient *)client didReceiveConnectionStatusChange:(MMXConnectionStatus)connectionStatus error:(NSError *)error {
	if (connectionStatus == MMXConnectionStatusAuthenticated) {
		[self performSegueWithIdentifier:@"ShowStatsScreen" sender:nil];
	} else {
		[self showAlertWithTitle:@"Error" message:error ? error.localizedFailureReason : @"An unknown error occurred. Please try logging in again"];
		[self setInputsEnabled:YES];
	}
	NSLog(@"Status = %ld",(long)connectionStatus);
}

/**
 *  MagnetNote: MMXClientDelegate client:didReceiveUserAutoRegistrationResult:error:
 *
 *  Monitoring for registration errors to alert the user and allow them to try again.
 */
- (void)client:(MMXClient *)client didReceiveUserAutoRegistrationResult:(BOOL)success error:(NSError *)error {
	if	(error) {
		if ([error.localizedFailureReason isEqualToString:@"userId is taken"]) {
			[self showAlertWithTitle:@"Error Logging In" message:@"There was an error when trying to log in. Make sure you are using the correct username and password. If this is your first time logging the username you are trying to use may already be taken."];
		} else {
			[self showAlertWithTitle:@"Error Registering User" message:error.localizedFailureReason];
		}
		[self setInputsEnabled:YES];
	}
}

#pragma mark - Actions

- (IBAction)signInPressed:(id)sender {
	[self setInputsEnabled:NO];
	if (self.usernameTextField.text.length >= 5 && self.passwordTextField.text.length >= 5) {

		/**
		 *  MagnetNote: MMXConfiguration credential
		 *
		 *  Creating a new NSURLCredential and setting it as the credential propery on our MMXConfiguration.
		 */
		[MMXClient sharedClient].configuration.credential = [NSURLCredential credentialWithUser:self.usernameTextField.text password:self.passwordTextField.text persistence:NSURLCredentialPersistenceNone];
		
		/**
		 *  MagnetNote: MMXClient connectWithCredentials
		 *
		 *  Calling connectWithCredentials will try to create a new session using the NSURLCredential object we set on our MMXConfiguration.
		 *	Since shouldAutoCreateUser is set as YES it create a new user with the provided credentials if the user does not already exist.
		 */
		[[MMXClient sharedClient] connectWithCredentials];
	} else {
		[self showAlertWithTitle:@"Error" message:@"Username and password must be at least 5 charaters in length."];
		[self setInputsEnabled:YES];
	}
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



@end
