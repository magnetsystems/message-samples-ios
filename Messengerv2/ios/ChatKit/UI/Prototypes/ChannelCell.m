//
//  ChannelCell.m
//  ChatKit
//
//  Created by Vladimir Yevdokimov on 3/7/16.
//  Copyright © 2016 Vladimir Yevdokimov. All rights reserved.
//

#import "ChannelCell.h"

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
    
    if (_channel.subscribers.count) {
        self.imageView.image = [UIImage imageNamed:@"user_group"];
    } else {
        self.imageView.image = [UIImage imageNamed:@"user_default"];
    }
    
    self.textLabel.text = _channel.name;
}

@end
