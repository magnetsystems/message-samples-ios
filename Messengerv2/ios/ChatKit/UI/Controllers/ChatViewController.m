//
//  ChatViewController.m
//  ChatKit
//
//  Created by Vladimir Yevdokimov on 3/7/16.
//  Copyright © 2016 Vladimir Yevdokimov. All rights reserved.
//

#import "ChatViewController.h"

@interface ChatViewController ()

@property (weak, nonatomic) IBOutlet UITableView *chatTable;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelBBI;

@property (nonatomic, strong) NSMutableArray *presentingMessages;

@end

@implementation ChatViewController


+ (UINib *)nib
{
    return [UINib nibWithNibName:NSStringFromClass([ChatViewController class])
                          bundle:[NSBundle bundleForClass:[ChatViewController class]]];
}

#pragma mark - Interface Methods


- (void)setupUI
{
    if (self.navigationController) {
        self.navigationItem.leftBarButtonItems = [self leftBarButtonItems];
        
        self.titleString = _chatChannel.description;
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedMessage:) name:MMXDidReceiveMessageNotification object:nil];
    
    NSDate *endDate = [NSDate dateWithTimeIntervalSince1970:([NSDate date].timeIntervalSince1970 - 24*60*60)];
    
    [_chatChannel messagesBetweenStartDate:[NSDate date] endDate:endDate limit:1000 offset:0 ascending:YES success:^(int totalCount, NSArray<MMXMessage *> * _Nonnull messages) {
        _presentingMessages = messages.mutableCopy;
        [_chatTable reloadData];
    } failure:^(NSError * _Nonnull error) {
        
    }];
}

- (NSArray *)leftBarButtonItems
{
    return _cancelBBI?@[_cancelBBI]:@[];
}

- (void)setTitleString:(NSString *)titleString
{
    _titleString = titleString;
    self.navigationItem.title = _titleString;
}

#pragma mark - Actions

- (IBAction)leftBtnPress:(UIBarButtonItem*)sender
{
    if (self.presentingViewController) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else if (self.navigationController) {
        if (self.navigationController.presentingViewController) {
            if (self.navigationController.viewControllers.count == 1) {
                
                [self.navigationController dismissViewControllerAnimated:YES completion:nil];
            } else {
                [self.navigationController popViewControllerAnimated:YES];
                
            }
        } else {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

#pragma mark - UITableViewDelegate, UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _presentingMessages.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 44;
    MMXMessage *msg = _presentingMessages[indexPath.row];
    
    UIView *view = [self contentCellViewForMessage:msg];
    height = view.frame.size.height;
    
    return height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = @"messageCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    [cell.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    UIView *newSub = [self contentCellViewForMessage:_presentingMessages[indexPath.row]];
    [cell.contentView addSubview:newSub];
    
    return cell;
}

#pragma mark - MMX

- (void)receivedMessage:(NSNotification*)notification
{
    
    NSLog(@"we got message \n%@",notification.userInfo);
}

#pragma mark - Content processing

- (UIView*)contentCellViewForMessage:(MMXMessage*)message
{
    UIView * contentV = nil;
    if (message) {
        NSDictionary *content = message.messageContent;
        if (content[@"type"]) {
            if ([content[@"type"] isEqualToString:@"web_template"]) {
                contentV = [self webCellContentForMessage:message];
            }
        } else  if ([content[@"type"] isEqualToString:@"text"]){
            contentV = [self textCellContentForMessage:message];
        } else {
            contentV = [self textCellContentForMessage:message];
        }
    }
    return contentV;
}

- (UIView*)webCellContentForMessage:(MMXMessage*)message
{
    UIView * contentV = nil;
    NSDictionary *content = message.messageContent;
    contentV = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 220)];
    //avatar
    UIView *avaV = [[UIView alloc] initWithFrame:CGRectMake(5, contentV.frame.size.height-5-30, 30, 30)];
    avaV.backgroundColor = [UIColor lightGrayColor];
    avaV.layer.cornerRadius = avaV.frame.size.width/2;
    avaV.layer.masksToBounds = YES;
    [contentV addSubview:avaV];
    //bubble
    UIView *buble = [[UIView alloc] initWithFrame:CGRectMake(40,
                                                             5,
                                                             self.view.frame.size.width-2*40,
                                                             200)];
    buble.backgroundColor = [UIColor lightGrayColor];
    buble.layer.cornerRadius = 10;
    buble.layer.masksToBounds = YES;
    [contentV addSubview:buble];
    //webView
    NSString *urlStr = content[@"url"];
    UIWebView *webV = [[UIWebView alloc] initWithFrame:CGRectMake(5,
                                                                  5,
                                                                  buble.bounds.size.width-10,
                                                                  buble.bounds.size.height-10)];
    webV.scalesPageToFit = YES;
    webV.scrollView.scrollEnabled = NO;
    
    webV.layer.cornerRadius = 10;
    webV.layer.masksToBounds = YES;
    
    [buble addSubview:webV];
    [webV loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlStr]]];
    
    return contentV;
}

- (UIView*)textCellContentForMessage:(MMXMessage*)message
{
    UIView * contentV = nil;
    NSDictionary *content = message.messageContent;

    UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 0)];
    lbl.text = content[@"message"];
    lbl.numberOfLines = 0;
    lbl.lineBreakMode = NSLineBreakByWordWrapping;
    [lbl sizeToFit];
    
    contentV = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width,
                                                        lbl.frame.size.height+20)];
    //avatar
    UIView *avaV = [[UIView alloc] initWithFrame:CGRectMake(5, contentV.frame.size.height-5-30, 30, 30)];
    avaV.backgroundColor = [UIColor lightGrayColor];
    avaV.layer.cornerRadius = avaV.frame.size.width/2;
    avaV.layer.masksToBounds = YES;
    [contentV addSubview:avaV];
    //bubble
    UIView *buble = [[UIView alloc] initWithFrame:CGRectMake(40,
                                                             5,
                                                             self.view.frame.size.width-2*40,
                                                             lbl.frame.size.height+5)];
    buble.backgroundColor = [UIColor lightGrayColor];
    buble.layer.cornerRadius = 10;
    buble.layer.masksToBounds = YES;
    [contentV addSubview:buble];
    
    [buble addSubview:lbl];
    lbl.frame = CGRectMake(5, 5, lbl.frame.size.width, lbl.frame.size.height);
    
    return contentV;
}

@end
