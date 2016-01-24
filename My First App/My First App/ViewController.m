//
//  ViewController.m
//
//
//
//  Copyright (c) 2016 Magnet Systems, Inc. All rights reserved.
//

#import "ViewController.h"

@import MagnetMax;


@interface ViewController ()

@property (nonatomic, weak) IBOutlet UITextField *messageText;

@end


@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Register for a notification to receive the message
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveMessage:)
                                                 name:MMXDidReceiveMessageNotification
                                               object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // Begin the user registration process
    [self createAndRegisterUser];
}


/***
 *
 *
 *                                      MAGNET MESSAGE DEMO METHODS
 *
 *   (This view controller is preconfigured with settings and code to send and recieve basic messages)
 *                         See documentation at https://developer.magnet.com/docs
 *
 *
 *
 ***/


//MARK: Notifications


- (void)didReceiveMessage:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    //retrieve MMXMessage from userInfo
    MMXMessage *message = userInfo[MMXMessageKey];
    
    [self showAlert:@"Received message"
            message:[NSString stringWithFormat:@"content: %@", message.messageContent]];
    NSLog(@"Received message content: %@", message.messageContent);
}


//MARK: Private Methods


// Creates and registers a generic user.
- (void)createAndRegisterUser {
    // Create a user object
    MMUser *user = [[MMUser alloc] init];
    
    // Optional
    user.firstName = @"John";
    user.lastName = @"Doe";
    
    // Required
    user.userName = @"john.doe@magnet.com";
    user.password = @"magnet";
    
    // Register the user
    [user register:^(MMUser * currentUser) {
        [self loginUser:currentUser.userName password:currentUser.password];
    } failure:^(NSError * error) {
        // 409 = the user is already registered
        if (error.code == 409) {
            // If a user is already already registered automatically login
            [self loginUser:user.userName password:user.password];
        }else {
            NSLog(@"[ERROR]: Failed to register: %@", error.localizedDescription);
        }
    }];
}

- (void)loginUser:(NSString *)username password:(NSString *)password {
    // Log in user with an NSURLCredential
    NSURLCredential *credential = [[NSURLCredential alloc] initWithUser:username password:password persistence:NSURLCredentialPersistenceNone];
    [MMUser login:credential success:^{
        
        // Indicate that you are ready to receive messages now!
        [MMX start];
        
        // Send an initial message
        [self sendMessage:self.messageText.text];
    } failure:^(NSError * error) {
        NSLog(@"[ERROR]: Failed to login: %@", error.localizedDescription);
    }];
}

- (void)sendMessage:(NSString *)messageString {
    if (![MMUser currentUser] || !messageString) {
        return;
    }
    // Dictionary to send
    NSDictionary *content = @{@"message": messageString};
    // Create message recipient -> yourself
    MMXMessage *message = [MMXMessage messageToRecipients:[NSSet setWithObject:[MMUser currentUser]] messageContent:content];
    
    // Uncomment to add attachment
    //    MMAttachment *attachment = [[MMAttachment alloc]  initWithFileURL:imageUrl mimeType:@"image/jpg"];
    //    [message addAttachment:attachment];
    
    //send the message
    [message sendWithSuccess:^(NSSet<NSString *> *invalidUsers) {
        NSLog(@"[INFO]: Sent message with content: %@", message.messageContent);
    } failure:^(NSError *error) {
        NSLog(@"[ERROR]: Failed to send message: %@", error.localizedDescription);
    }];
}

- (void)showAlert:(NSString *)title message:(NSString *)message {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title
                                                                             message:message
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"ok"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction * action) {
                                                          [alertController dismissViewControllerAnimated:NO completion:nil];
                                                      }]];
    
    [self presentViewController:alertController animated:NO completion:nil];
}


//MARK: Actions


- (IBAction)send:(id)sender {
    [self sendMessage:self.messageText.text];
}

@end
