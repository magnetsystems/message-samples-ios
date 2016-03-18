//
//  ChannelCell.m
//  ChatKit
//
//  Created by Vladimir Yevdokimov on 3/7/16.
//  Copyright © 2016 Vladimir Yevdokimov. All rights reserved.
//

#import "ChannelCell.h"

#import "CHKUtils.h"

@implementation ChannelCell


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)setChannel:(MMXChannel *)channel
{
    _channel = channel;
    
    self.imageView.image = [CHKUtils chk_imageNamed:@"user_default"];
    
    if (_channel.subscribers) {
            NSMutableArray *usernames = @[].mutableCopy;
        
            if (_channel.subscribers.count > 2) {
                self.imageView.image = [CHKUtils chk_imageNamed:@"user_group"];
            } else {
                self.imageView.image = [CHKUtils chk_imageNamed:@"user_default"];
            }
            
            for (MMUser* user in _channel.subscribers) {
                [usernames addObject:[NSString stringWithFormat:@"%@%@%@",
                                      user.firstName.length?user.firstName:@"",
                                      user.lastName.length?@" ":@"",
                                      user.lastName.length?user.lastName:@""]];
            }
            self.textLabel.text = [usernames componentsJoinedByString:@","];

    } else {
        self.textLabel.text = _channel.summary;
        [_channel subscribersWithLimit:100 offset:0 success:^(int totalCount, NSArray<MMUser *> * _Nonnull subscribers) {
        if (subscribers.count) {
            self.imageView.image = [CHKUtils chk_imageNamed:@"user_group"];
        } else {
            self.imageView.image = [CHKUtils chk_imageNamed:@"user_default"];
        }
        } failure:^(NSError * _Nonnull error) {
        
        }];
    }
    
    
    
    
}

@end
