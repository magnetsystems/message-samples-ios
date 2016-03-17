//
//  ChatViewController.h
//  ChatKit
//
//  Created by Vladimir Yevdokimov on 3/7/16.
//  Copyright © 2016 Vladimir Yevdokimov. All rights reserved.
//

#import "CHKBaseViewController.h"

@import MagnetMax;

@interface ChatViewController : CHKBaseViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) MMXChannel *chatChannel;

@property (nonatomic, copy) NSString *titleString; // default - description of channel

@end
