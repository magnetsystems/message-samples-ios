//
//  ContactsViewController.h
//  ChatKit
//
//  Created by Vladimir Yevdokimov on 3/9/16.
//  Copyright © 2016 Vladimir Yevdokimov. All rights reserved.
//

#import "CHKBaseViewController.h"

@import MagnetMax;

@interface ContactsViewController : CHKBaseViewController <UITableViewDelegate, UITableViewDataSource>

/**
 *  Defines if Search bar will be visible. and enabled for searching.
 */
@property (nonatomic, assign) BOOL enableSearch;

/**
 *  Numbers of contacts presenting per page. Default = 0
 *  0 - all at once, no paging,
 *  n - paging with items == n or n -> # of visible items
 */
@property (nonatomic, assign) NSInteger contactsPerPage;

/**
 *  Custom contacts for presentation.
 *  If value will be nil on -viewWillAppear: call - then all users will be presented.
 */
@property (nonatomic, strong) NSArray <MMUser*> *contacts;

/**
 *  NavBar title customization.
 *
 *  String value. Default value "Chats List". Nullable.
 */
@property (nonatomic, copy) NSString *titleString;

/**
 *  NavBar right bar button item onPress interaction hook.
 */
- (void)shouldCreateChatWithSelectedUsers:(NSArray* <MMUser*>)users;

@end
