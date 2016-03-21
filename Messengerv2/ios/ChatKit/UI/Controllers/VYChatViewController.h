//
//  ChatViewController.h
//  ChatKit
//
//  Created by Vladimir Yevdokimov on 3/7/16.
//  Copyright © 2016 Vladimir Yevdokimov. All rights reserved.
//

#import "CHKBaseViewController.h"

@import MagnetMax;

@protocol VYChatViewControllerDelegate <NSObject>

@optional
- (void)messageWillBeSend;
- (void)messageDidSent;
- (void)messageFailedTotSend:(NSError*)error;

- (UIView*)messageBubbleContentViewForMessage:(MMXMessage*)message maxBubbleWidth:(CGFloat)bubbleWidth;
- (CGFloat)messageBubbleContentHeightForMessage:(MMXMessage*)message;

@end

@interface VYChatViewController : CHKBaseViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate,VYChatViewControllerDelegate>

@property (nonatomic, strong) MMXChannel *chatChannel;

@property (nonatomic, copy) NSString *titleString; // default - description of channel

@end
