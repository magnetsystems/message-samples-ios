//
//  ChannelCell.h
//  ChatKit
//
//  Created by Vladimir Yevdokimov on 3/7/16.
//  Copyright © 2016 Vladimir Yevdokimov. All rights reserved.
//

@import MagnetMax;


@interface ChannelCell : UITableViewCell

/**
 *  Using custom inherited class, you should override setter for this property.
 */
@property (nonatomic, strong) MMXChannel *channel;

@end
