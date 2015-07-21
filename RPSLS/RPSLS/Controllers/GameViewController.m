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

#import "GameViewController.h"
#import "RPSLSEngine.h"
#import "RPSLSConstants.h"
#import "RPSLSMessageTypes.h"
#import "RPSLSUser.h"
#import "RPSLSUserStats.h"
#import "RPSLSUtils.h"
#import "MMXInboundMessage+RPSLS.h"
#import <MMX/MMX.h>

@interface GameViewController () <MMXClientDelegate>

@property (nonatomic, strong, readwrite) NSString * gameID;
@property (nonatomic, strong, readwrite) RPSLSUser * opponent;
@property (nonatomic, assign) RPSLSValue myChoice;
@property (nonatomic, assign) RPSLSValue opponentChoice;
@property (nonatomic, strong) NSArray * buttonArray;
@property (nonatomic, strong) NSTimer * timer;

@end

@implementation GameViewController

#pragma mark - Lifecycle

- (instancetype)init {
	if (self = [super init]) {
		_myChoice = RPSLSValueNotSet;
		_opponentChoice = RPSLSValueNotSet;
	}
	return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	[self postAvailabilityStatusAs:NO];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	self.timer = [NSTimer scheduledTimerWithTimeInterval:30 target:self selector:@selector(handleTimer) userInfo:nil repeats:YES];
	[self layoutButtons];
	[MMXClient sharedClient].shouldSuspendIncomingMessages = NO;
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}

- (void)dismissView {
	[self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Status

- (void)postAvailabilityStatusAs:(BOOL)available {
	
	/**
	 *  MagnetNote: MMXPubSubManager publishPubSubMessage:success:failure:
	 *
	 *  Publishing our availability message. In this case I do not need to do anything on success.
	 */
	[[MMXClient sharedClient].pubsubManager publishPubSubMessage:[RPSLSUtils availablilityMessage:available] success:nil failure:^(NSError *error) {
		[[MMXLogger sharedLogger] error:@"postAvailability error= %@",error];
	}];
}

- (void)handleTimer {
	if (self.myChoice < 0 && self.opponentChoice < 0) {
		[self showOptions:@"No one has chosen yet. Do you want to keep playing?"];
	} else if (self.myChoice < 0){
		[self showOptions:@"Your opponent is waiting on you. Do you want to keep playing?"];
	} else {
		[self showOptions:@"Waiting on your opponent. Do you want to keep playing?"];
	}
}

#pragma mark - MMXClientDelegate Callbacks

/**
 *  MagnetNote: MMXClientDelegate client:didReceiveConnectionStatusChange:error:
 *
 *  Monitoring the connection status to kick the user back to the Sign In screen if the connection is lost
 */
- (void)client:(MMXClient *)client didReceiveConnectionStatusChange:(MMXConnectionStatus)connectionStatus error:(NSError *)error {
	if (connectionStatus == MMXConnectionStatusDisconnected) {
		[self.navigationController popToRootViewControllerAnimated:YES];
	}
}

- (void)client:(MMXClient *)client didReceiveMessage:(MMXInboundMessage *)message deliveryReceiptRequested:(BOOL)receiptRequested {
	
	/**
	 *  MagnetNote: MMXClientDelegate client:didReceiveMessage:deliveryReceiptRequested:
	 *
	 *  Checking the incoming message and sending a confirmation if necessary.
	 */
	if ([message isTimelyMessage]) {
		[self handleMessage:message];
	}
	if (receiptRequested) {
		
		/**
		 *  MagnetNote: MMXClient sendDeliveryConfirmationForMessage:
		 *
		 *  Sending delivery confirmation.
		 */
		[[MMXClient sharedClient] sendDeliveryConfirmationForMessage:message];
	}
}

- (void)client:(MMXClient *)client didReceiveError:(NSError *)error severity:(MMXErrorSeverity)severity messageID:(NSString *)messageID {
	/**
	 *  MagnetNote: MMXClientDelegate client:didReceiveMessage:deliveryReceiptRequested:
	 *
	 *  Could be checking to see if something went wrong when sending my choice.
	 */
}

- (void)client:(MMXClient *)client didDeliverMessage:(NSString *)messageID recipient:(id<MMXAddressable>)recipient {

	/**
	 *  MagnetNote: MMXLogger info
	 *
	 *  Logging info.
	 */
	[[MMXLogger sharedLogger] info:@"Message %@ was delivered",messageID];
}

#pragma mark - Messages

- (void)sendMyChoice:(RPSLSValue)choice {
	
	/**
	 *  MagnetNote: MMXOutboundMessage
	 *
	 *  Composing a new MMXOutboundMessage. Most of the relevant data for our usecase is being placed in the MMXOutboundMessage metaData property.
	 *	In other usecases it may make more sense to serialize the data and use the messageContent property.
	 */
	MMXOutboundMessage * message = [MMXOutboundMessage messageTo:[MMXUserID userIDWithUsername:self.opponent.username]
													 withContent:[NSString stringWithFormat:@"I chose %@",[RPSLSEngine valueToString:choice]]
														metaData:@{kMessageKey_Username	:[RPSLSUser me].username,
																   kMessageKey_Timestamp:[RPSLSUtils timestamp],
																   kMessageKey_Choice	:[RPSLSEngine valueToString:choice],
																   kMessageKey_Type		:kMessageTypeValue_Choice,
																   kMessageKey_GameID	:self.gameID,
																   kMessageKey_Wins		:[@([RPSLSUser me].stats.wins) stringValue],
																   kMessageKey_Losses	:[@([RPSLSUser me].stats.losses) stringValue],
																   kMessageKey_Ties		:[@([RPSLSUser me].stats.ties) stringValue]}];
	
	/**
	 *  MagnetNote: MMXMessageOptions
	 *
	 *  Creating MMXMessageOptions object. Using defaults.
	 */
	MMXMessageOptions * options = [[MMXMessageOptions alloc] init];
	
	/**
	 *  MagnetNote: MMXClient sendMessage:withOptions:
	 *
	 *  Sending my message.
	 */
	[[MMXClient sharedClient] sendMessage:message withOptions:options];
	
}

- (void)handleMessage:(MMXInboundMessage *)message {
	
	RPSLSMessageType type = [self typeForMessage:message];
	switch (type) {
		case RPSLSMessageTypeUnknown:
			break;
		case RPSLSMessageTypeInvite:
			break;
		case RPSLSMessageTypeAccept:
			break;
		case RPSLSMessageTypeChoice:
			[self opponentMadeChoice:[RPSLSEngine stringToValue:message.metaData[kMessageKey_Choice]]];
			break;
		default:
			break;
	}
}

- (RPSLSMessageType)typeForMessage:(MMXInboundMessage *)message {
	
	/**
	 *  MagnetNote: MMXInboundMessage metaData
	 *
	 *  Extracting information from the MMXInboundMessage metaData property.
	 */
	if (message == nil || message.metaData == nil || message.metaData[kMessageKey_Type] == nil || [message.metaData[kMessageKey_Type] isEqualToString:@""]) {
		return RPSLSMessageTypeUnknown;
	}
	if ([message.metaData[kMessageKey_Type] isEqualToString:kMessageTypeValue_Invite]) {
		return RPSLSMessageTypeInvite;
	}
	if ([message.metaData[kMessageKey_Type] isEqualToString:kMessageTypeValue_Accept]) {
		return RPSLSMessageTypeAccept;
	}
	if ([message.metaData[kMessageKey_Type] isEqualToString:kMessageTypeValue_Choice]) {
		return RPSLSMessageTypeChoice;
	}
	return 0;
}

#pragma mark - Actions

- (IBAction)rockPressed:(id)sender {
	[self iMadeChoice:RPSLSValueRock];
	[self disableButtons];
}

- (IBAction)paperPressed:(id)sender {
	[self iMadeChoice:RPSLSValuePaper];
	[self disableButtons];
}

- (IBAction)scissorsPressed:(id)sender {
	[self iMadeChoice:RPSLSValueScissors];
	[self disableButtons];
}

- (IBAction)lizardPressed:(id)sender {
	[self iMadeChoice:RPSLSValueLizard];
	[self disableButtons];
}

- (IBAction)spockPressed:(id)sender {
	[self iMadeChoice:RPSLSValueSpock];
	[self disableButtons];
}

- (void)disableButtons {
	for (UIButton * button in self.buttonArray) {
		button.enabled = NO;
	}
}

#pragma mark - Choice Logic

- (void)opponentMadeChoice:(RPSLSValue)choice {
	self.opponentChoice = choice;
	[self.timer invalidate];
	if (self.myChoice >= 0) {
		[self endGame];
	} else {
		self.timer = [NSTimer scheduledTimerWithTimeInterval:20 target:self selector:@selector(handleTimer) userInfo:nil repeats:YES];
	}
}

- (void)iMadeChoice:(RPSLSValue)choice {
	self.myChoice = choice;
	[self sendMyChoice:choice];
	[self.timer invalidate];
	if (self.opponentChoice >= 0) {
		[self endGame];
	} else {
		self.timer = [NSTimer scheduledTimerWithTimeInterval:20 target:self selector:@selector(handleTimer) userInfo:nil repeats:YES];
		[self showWaitingViewWithChoice:choice];
	}
}

- (void)iChose:(RPSLSValue)choice {
	int computerChoice = arc4random() % 5;
	NSLog(@"I chose %@ and the computer chose %@",[RPSLSEngine valueToString:choice],[RPSLSEngine valueToString:computerChoice]);
	NSLog(@"%@",[RPSLSEngine resultAsString:[RPSLSEngine myResult:choice them:computerChoice]]);
}


#pragma mark - Setup

- (void)setupGameWithID:(NSString *)gameID opponent:(RPSLSUser *)opponent {
	self.gameID = gameID;
	self.opponent = opponent;
	self.myChoice = RPSLSValueNotSet;
	self.opponentChoice = RPSLSValueNotSet;
}

- (NSArray *)buttonList {
	return @[@"rock",@"paper",@"scissors",@"lizard",@"spock"];
}

- (void)layoutButtons {
	int index = 0;
	CGFloat sideLength = self.view.frame.size.width / 4.0;
	CGFloat radius = self.view.frame.size.width / 3.0;
	CGPoint center = CGPointMake(self.view.frame.size.width / 2.0, self.view.frame.size.width / 1.5);
	
	NSArray * buttonNameArray = [self buttonList];
	
	NSMutableArray * tempButtonArray = @[].mutableCopy;
	
	for (NSString * buttonName in buttonNameArray) {
		UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
		[button setBackgroundImage:[UIImage imageNamed:buttonName] forState:UIControlStateNormal];
		SEL selector = NSSelectorFromString([NSString stringWithFormat:@"%@Pressed:",buttonName]);
		if ([self respondsToSelector:selector]) {
			[button addTarget:self
					   action:selector
			 forControlEvents:UIControlEventTouchUpInside];
			
			//Using -90 to start at the top(up)
			CGFloat degrees = -90.0;
			if (index > 0) {
				degrees = -90.0 + 360.0 / buttonNameArray.count * index;
			}
			button.frame = [self frameForButtonAtAngleInDegrees:degrees
													 sideLength:sideLength
													 withRadius:radius
														 center:center];
			
			[self.view addSubview:button];
			button.layer.cornerRadius = sideLength / 2.0;
			button.layer.borderWidth = 1.0;
			button.layer.borderColor = [UIColor grayColor].CGColor;
			button.clipsToBounds = YES;
			[tempButtonArray addObject:button];
		}
		index++;
	}
	self.buttonArray = tempButtonArray.copy;
}

- (CGRect)frameForButtonAtAngleInDegrees:(CGFloat)degrees sideLength:(CGFloat)sideLength withRadius:(CGFloat)radius center:(CGPoint)center {
	CGPoint buttonCenter;
	CGFloat angle = ((degrees) / 180.0 * M_PI);
	buttonCenter.x = center.x + radius * cos(angle);
	buttonCenter.y = center.y + radius * sin(angle);
	CGRect buttonRect = CGRectMake(buttonCenter.x - sideLength/2.0, buttonCenter.y - sideLength/2.0, sideLength, sideLength);
	return buttonRect;
}

#pragma mark - UIAlertController

- (void)showOptions:(NSString *)message {
	UIAlertController *alertController = [UIAlertController
										  alertControllerWithTitle:@"Continue?"
										  message:message
										  preferredStyle:UIAlertControllerStyleActionSheet];
	
	UIAlertAction *continueAction = [UIAlertAction
								actionWithTitle:@"Continue"
								style:UIAlertActionStyleDefault
								handler:^(UIAlertAction *action)
								{
									[self.timer invalidate];
									self.timer = [NSTimer scheduledTimerWithTimeInterval:20 target:self selector:@selector(handleTimer) userInfo:nil repeats:YES];
								}];
	UIAlertAction *leaveAction = [UIAlertAction
								   actionWithTitle:@"Leave"
								   style:UIAlertActionStyleDestructive
								   handler:^(UIAlertAction *action)
								   {
									   [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
								   }];
	[alertController addAction:continueAction];
	[alertController addAction:leaveAction];
	[self presentViewController:alertController animated:YES completion:nil];
}

- (void)showInviteAlertForResult:(NSString *)result description:(NSString *)description {
	UIAlertController *alertController = [UIAlertController
										  alertControllerWithTitle:result
										  message:description
										  preferredStyle:UIAlertControllerStyleAlert];
	
	
	UIAlertAction *doneAction = [UIAlertAction
								   actionWithTitle:NSLocalizedString(@"OK", @"OK action")
								   style:UIAlertActionStyleDefault
								   handler:^(UIAlertAction *action)
								   {
									   [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
								   }];
	[alertController addAction:doneAction];
	[self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - Game Logic

- (NSString *)stringFromResult:(RPSLSResult)result myChoice:(RPSLSValue)myChoice opponentChoice:(RPSLSValue)opponentChoice {
	switch (result) {
		case RPSLSResultWin:
			return @"Winner!";
		case RPSLSResultLoss:
			return @"Loser!";
		case RPSLSResultTie:
			return @"Tie!";
		default:
			break;
	}
	return @"";
}

- (void)endGame {
	RPSLSResult result = [RPSLSEngine myResult:self.myChoice them:self.opponentChoice];
	NSString * imageName;
	switch (result) {
		case RPSLSResultWin: {
			[RPSLSUserStats incrementMyWins];
			imageName = [NSString stringWithFormat:@"%@_vs_%@",[RPSLSEngine valueToString:self.myChoice].lowercaseString,[RPSLSEngine valueToString:self.opponentChoice].lowercaseString];
			[self showOverlayWithTitle:[self stringFromResult:result myChoice:self.myChoice opponentChoice:self.opponentChoice]
							 imageName:imageName
							showButton:YES];
			break;
		}
		case RPSLSResultLoss: {
			[RPSLSUserStats incrementMyLosses];
			imageName = [NSString stringWithFormat:@"%@_vs_%@",[RPSLSEngine valueToString:self.opponentChoice].lowercaseString,[RPSLSEngine valueToString:self.myChoice].lowercaseString];
			[self showOverlayWithTitle:[self stringFromResult:result myChoice:self.myChoice opponentChoice:self.opponentChoice]
							 imageName:imageName
							showButton:YES];
			break;
		}
		case RPSLSResultTie: {
			[RPSLSUserStats incrementMyTies];
			[self showOverlayWithTitle:[self stringFromResult:result myChoice:self.myChoice opponentChoice:self.opponentChoice]
							 imageName:@"draw"
							showButton:YES];
			break;
		}
		default:
			break;
	}
}

- (void)showWaitingViewWithChoice:(RPSLSValue)choice {
	[self showOverlayWithTitle:[NSString stringWithFormat:@"You chose %@",[RPSLSEngine valueToString:self.myChoice]]
					 imageName:[RPSLSEngine valueToString:self.myChoice].lowercaseString
					showButton:NO];
}

- (void)showOverlayWithTitle:(NSString *)title imageName:(NSString *)imageName showButton:(BOOL)showButton {
	CGFloat width = self.view.frame.size.width * 0.9;
	CGFloat height = self.view.frame.size.height * 0.8;
	CGFloat xPos = (self.view.frame.size.width - width) / 2.0;
	CGFloat yPos = (self.view.frame.size.height - height) / 2.0;
	
	UIView * waitingView = [[UIView alloc] initWithFrame:CGRectMake(xPos, yPos, width, height)];
	waitingView.backgroundColor = [UIColor whiteColor];
	waitingView.layer.cornerRadius = self.view.frame.size.width * 0.1;
	waitingView.clipsToBounds = YES;
	waitingView.layer.borderWidth = 1.0;
	waitingView.layer.borderColor = [UIColor grayColor].CGColor;
	
	UILabel *choiceLabel = [[UILabel alloc]initWithFrame:CGRectMake(width * 0.05, width * 0.05, width * 0.9, height * 0.1)];
	choiceLabel.adjustsFontSizeToFitWidth = YES;
	choiceLabel.textAlignment = NSTextAlignmentCenter;
	choiceLabel.text = @"You chose...";
	[waitingView addSubview:choiceLabel];
	
	UIImageView * imageView = [[UIImageView alloc] initWithFrame:CGRectMake(width * 0.15, width * 0.2, width * 0.7, width * 0.7)];
	imageView.contentMode = UIViewContentModeScaleAspectFit;
	UIImage * image = [UIImage imageNamed:imageName];
	imageView.image = image;
//	imageView.layer.cornerRadius = width * 0.35;
	imageView.layer.borderWidth = 1.0;
	imageView.layer.borderColor = [UIColor grayColor].CGColor;
	imageView.clipsToBounds = YES;
	[waitingView addSubview:imageView];
	
	if (showButton) {
		UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
		[button addTarget:self
				   action:@selector(dismissView)
		 forControlEvents:UIControlEventTouchUpInside];
		
		[button setTitle:@"OK" forState:UIControlStateNormal];
		button.frame = CGRectMake(0, height * 0.8, width, height * 0.2);
		button.titleLabel.font = [GameViewController regularFontForSize:30];

		[waitingView addSubview:button];
		choiceLabel.text = title;
	}
	[self.view addSubview:waitingView];
}

+ (UIFont *)regularFontForSize:(int)fontSize {
	UIFont * font = [UIFont fontWithName:@"Helvetica" size:fontSize];
	return font;
}

@end
