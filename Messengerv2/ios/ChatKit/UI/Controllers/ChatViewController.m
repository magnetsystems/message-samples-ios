//
//  ChatViewController.m
//  ChatKit
//
//  Created by Vladimir Yevdokimov on 3/7/16.
//  Copyright © 2016 Vladimir Yevdokimov. All rights reserved.
//

#import "ChatViewController.h"

@interface ChatViewController ()<UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *chatTable;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelBBI;

@property (nonatomic, strong) NSMutableArray *presentingMessages;

//send bar items
@property (weak, nonatomic) IBOutlet UIButton *sendBtn;
@property (weak, nonatomic) IBOutlet UITextField *inputTF;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *btmLC;

@property (nonatomic, strong) MMAttachment *outMessageAttachment;
@property (nonatomic, copy) NSString *outMessageType;

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
        
        self.titleString = _chatChannel.summary;
    }
    
    _sendBtn.enabled = NO;
    _inputTF.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width - 140, _inputTF.frame.size.height);
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeHidden:) name:UIKeyboardWillHideNotification object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedMessage:) name:MMXDidReceiveMessageNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldDidChange) name:UITextFieldTextDidChangeNotification object:nil];
    
    NSDate *endDate = [NSDate dateWithTimeIntervalSince1970:([NSDate date].timeIntervalSince1970 - 24*60*60)];
    
    [_chatChannel messagesBetweenStartDate:endDate endDate:[NSDate date] limit:1000 offset:0 ascending:YES success:^(int totalCount, NSArray<MMXMessage *> * _Nonnull messages) {
        _presentingMessages = messages.mutableCopy;
        [_chatTable reloadData];
    } failure:^(NSError * _Nonnull error) {
        
    }];
}

- (void)viewDidAppear:(BOOL)animated
{
    
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

- (IBAction)sendMessage:(UIButton*)sender
{
    _outMessageType = @"text";
    MMXMessage *msg = [MMXMessage messageToChannel:_chatChannel messageContent:@{@"type" : _outMessageType,
                                                                                 @"message" : _inputTF.text}];

    [self messageWillBeSend];
    [msg sendWithSuccess:^(NSSet<NSString *> * _Nonnull invalidUsers) {
        _inputTF.text = nil;
        [_inputTF resignFirstResponder];
        [self messageDidSent];
    } failure:^(NSError * _Nonnull error) {
        [self messageFailedTotSend:error];
    }];
}

- (IBAction)attachData:(UIButton*)sender
{
    
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidChange
{
    if (_inputTF.text.length) {
        _sendBtn.enabled = YES;
    } else {
        _sendBtn.enabled = NO;
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
    if (notification.userInfo) {
        NSDictionary *info = notification.userInfo;
        if (info[MMXMessageKey]) {
            MMXMessage *message = info[MMXMessageKey];
            if ([message.channel.name.lowercaseString isEqualToString:_chatChannel.name.lowercaseString]) {
                if (!_presentingMessages.count) {
                    _presentingMessages = @[].mutableCopy;
                }
                
                [_chatTable beginUpdates];
                [_presentingMessages addObject:message];
                [_chatTable insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:_presentingMessages.count-1 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
                [_chatTable endUpdates];
                
                [_chatTable scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:_presentingMessages.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
            }
        }
    }
    NSLog(@"we got message \n%@",notification.userInfo);
}

#pragma mark - Content processing

- (UIView*)messageBubbleContentViewForMessage:(MMXMessage*)message maxBubbleWidth:(CGFloat)bubbleWidth;
{
    UIView *resultView = nil;
    if (message) {
        NSDictionary *content = message.messageContent;
        if (content[@"type"]) {
            if ([content[@"type"] isEqualToString:@"web_template"]) {
                resultView = [self webCellContentForMessage:message];
            } else  if ([content[@"type"] isEqualToString:@"text"]){
                resultView = [self textCellContentForMessage:message];
            } else if ([content[@"type"] isEqualToString:@"photo"]) {
                resultView = [self imageCellContentForMessage:message];
            }
        } else {
            resultView = [self textCellContentForMessage:message];
        }
    }
    return resultView;
}

- (UIView*)contentCellViewForMessage:(MMXMessage*)message
{
    BOOL selfMessage = [message.sender.userID isEqualToString:[MMUser currentUser].userID];

    UIView *bubbleContent = nil;
    UIView * contentV = nil;
    
    if (message) {
        // bubble content
        bubbleContent = [self messageBubbleContentViewForMessage:message maxBubbleWidth:self.view.frame.size.width-2*45];        
        
        contentV = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width,
                                                            bubbleContent.frame.size.height + 20)];
        //avatar
        CGRect avatarRect = CGRectZero;
        if (selfMessage) {
            avatarRect = CGRectMake(contentV.frame.size.width-30-5, contentV.frame.size.height-5-30, 30, 30);
        } else {
            avatarRect = CGRectMake(5, contentV.frame.size.height-5-30, 30, 30);
        }
        
        UIView *avaV = [[UIView alloc] initWithFrame:avatarRect];
        
        if (selfMessage) {
            avaV.backgroundColor = [UIColor blueColor];
        } else {
            avaV.backgroundColor = [UIColor blueColor];
        }
        
        avaV.layer.cornerRadius = avaV.frame.size.width/2;
        avaV.layer.masksToBounds = YES;
        [contentV addSubview:avaV];
        
        //bubble
        UIView *buble = [[UIView alloc] initWithFrame:CGRectMake(40,
                                                                 5,
                                                                 self.view.frame.size.width-2*40,
                                                                 bubbleContent.frame.size.height+10)];
        if (selfMessage) {
            buble.backgroundColor = [UIColor lightGrayColor];
        } else {
            buble.backgroundColor = [UIColor lightGrayColor];
        }
        
        buble.layer.cornerRadius = 10;
        buble.layer.masksToBounds = YES;
        [contentV addSubview:buble];
        
        bubbleContent.frame = CGRectMake(5, 5, bubbleContent.frame.size.width, bubbleContent.frame.size.height);
        [buble addSubview:bubbleContent];
        
    }
    return contentV;
}

- (UIView*)webCellContentForMessage:(MMXMessage*)message
{

    NSDictionary *content = message.messageContent;

    //webView
    NSString *urlStr = content[@"message"];
    UIWebView *webV = [[UIWebView alloc] initWithFrame:CGRectMake(0,
                                                                  0,
                                                                  self.view.frame.size.width-2*45,
                                                                  215)];
    webV.scalesPageToFit = YES;
    webV.scrollView.scrollEnabled = NO;
    webV.delegate = self;
    
    webV.layer.cornerRadius = 10;
    webV.layer.masksToBounds = YES;
    webV.backgroundColor = [UIColor grayColor];
    
    [webV loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlStr]]];
    
    return webV;
}

- (UIView*)textCellContentForMessage:(MMXMessage*)message
{
    NSDictionary *content = message.messageContent;

    UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(0,
                                                             0,
                                                             self.view.frame.size.width-2*45,
                                                             0)];
    lbl.text = [content[@"message"] length]?content[@"message"]:@" ";
    lbl.numberOfLines = 0;
    lbl.lineBreakMode = NSLineBreakByWordWrapping;
    [lbl sizeToFit];
    
    return lbl;
}

- (UIView*)imageCellContentForMessage:(MMXMessage*)message
{
    UIImageView *iv = [[UIImageView alloc]  initWithFrame:CGRectMake(0,
                                                                     0,
                                                                     self.view.frame.size.width-2*45,
                                                                     100)];
    iv.contentMode = UIViewContentModeScaleAspectFit;
    if (message.attachments.count) {
        MMAttachment *attach = message.attachments.firstObject;
        if (attach.data) {
            iv.image = [UIImage imageWithData:attach.data];
        } else if (attach.downloadURL) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSData *data = [NSData dataWithContentsOfURL:attach.downloadURL];
                if (data.length) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        iv.image = [UIImage imageWithData:data];
                    });
                }
            });

        }
    }
    return iv;
}

#pragma mark - ChatViewControllerDelegate

- (void)messageWillBeSend {}
- (void)messageDidSent {}
- (void)messageFailedTotSend:(NSError *)error {}

#pragma mark - Keyboard

- (void)keyboardWasShown:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    [UIView animateWithDuration:0.2f animations:^{
        _btmLC.constant = kbSize.height;
    }];
}

- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    [UIView animateWithDuration:0.2f animations:^{
        _btmLC.constant = 0;
    }];
}


#pragma mark - UIWebViewDelegate

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    NSLog(@"did start load web");
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    NSLog(@"did fail to load web %@",error);
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if ([request.URL.scheme isEqualToString:@"inapp"]) {
        NSString *message = @"n/a";
        if ([request.URL.host isEqualToString:@"nocancel"]) {
            message = @"No, cancel";
            // do capture action
        } else if ([request.URL.host isEqualToString:@"yesagree"]) {
            message = @"Yes, I agree";
        }
        MMXMessage *msg = [MMXMessage messageToChannel:_chatChannel messageContent:@{@"type" : @"text",
                                                                                     @"message" : message}];
                [msg sendWithSuccess:^(NSSet<NSString *> * _Nonnull invalidUsers) {
        } failure:^(NSError * _Nonnull error) {
        }];

        return NO;
    }
    return YES;
}


@end
