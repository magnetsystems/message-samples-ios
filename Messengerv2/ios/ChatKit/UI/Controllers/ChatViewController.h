//
//  ChatViewController.h
//  ChatKit
//
//  Created by Vladimir Yevdokimov on 3/7/16.
//  Copyright © 2016 Vladimir Yevdokimov. All rights reserved.
//

#import "CHKBaseViewController.h"

@import MagnetMax;

@protocol ChatViewControllerDelegate <NSObject>

@optional
- (void)messageWillBeSend;
- (void)messageDidSent;
- (void)messageFailedTotSend:(NSError*)error;


@end

@interface ChatViewController : CHKBaseViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate,ChatViewControllerDelegate>

@property (nonatomic, strong) MMXChannel *chatChannel;

@property (nonatomic, copy) NSString *titleString; // default - description of channel

@end
