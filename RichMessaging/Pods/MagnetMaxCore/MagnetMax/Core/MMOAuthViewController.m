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

#import "MMOAuthViewController.h"

typedef void (^MMOAuthFlowCancellationBlock)(void);

typedef void (^MMOAuthFlowCompletionBlock)(void);

#define kOAuthRedirectUriParameter @"redirect_uri"
#define kIsRedirectUri @"magnet_connector_oauth_redirect_uri"
#define kOAuthDoneUriHeader @"X-OAuth-Done-Uri"
#define kCloseRedirectUri @"http://close/"

@interface MMOAuthViewController ()

@property (nonatomic, strong) UIWebView *webView;

@property (readwrite, nonatomic, copy) MMOAuthFlowCancellationBlock cancellation;

@property (readwrite, nonatomic, copy) MMOAuthFlowCompletionBlock completion;

@property (strong, nonatomic) UIBarButtonItem *stopLoadingButton;
@property (strong, nonatomic) UIBarButtonItem *reloadButton;
@property (strong, nonatomic) UIBarButtonItem *backButton;
@property (strong, nonatomic) UIBarButtonItem *forwardButton;

@property (assign, nonatomic) BOOL toolbarPreviouslyHidden;

@property (nonatomic, assign) BOOL isRedirectUri;

@property(nonatomic, strong) NSURL *magnetRedirectURL;

- (NSURL *)redirectURL:(NSURL *)URL;

@end

@implementation MMOAuthViewController

- (instancetype)initWithURL:(NSURL *)url {
    self = [super init];
    if (self) {
        _URL = url;
    }

    return self;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    return [self initWithURL:nil];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    return [self initWithURL:nil];
}

- (void)setCancellation:(void (^)(void))block {
    self.cancellation = block;
}

- (void)setCompletionBlock:(void (^)(void))block {
    self.completion = block;
}

#pragma mark - View controller lifecycle

- (void)loadView
{
    self.webView = [[UIWebView alloc] init];
    self.webView.scalesPageToFit = YES;
    self.view = self.webView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupToolBarItems];
}

- (void)load
{
    NSURLRequest *request = [NSURLRequest requestWithURL:self.URL cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:4.0];
    [self.webView loadRequest:request];

    if (self.navigationController.toolbarHidden) {
        self.toolbarPreviouslyHidden = YES;
        if (!self.isToolbarHidden) {
            [self.navigationController setToolbarHidden:NO animated:YES];
        }
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.webView.delegate = self;
    if (self.URL) {
        [self load];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.webView stopLoading];
    self.webView.delegate = nil;
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];

    if (self.toolbarPreviouslyHidden && !self.isToolbarHidden) {
        [self.navigationController setToolbarHidden:YES animated:YES];
    }
}

#pragma mark - Helpers

- (UIImage *)backButtonImage
{
    static UIImage *image;

    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        CGSize size = CGSizeMake(12.0, 21.0);
        UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);

        UIBezierPath *path = [UIBezierPath bezierPath];
        path.lineWidth = 1.5;
        path.lineCapStyle = kCGLineCapButt;
        path.lineJoinStyle = kCGLineJoinMiter;
        [path moveToPoint:CGPointMake(11.0, 1.0)];
        [path addLineToPoint:CGPointMake(1.0, 11.0)];
        [path addLineToPoint:CGPointMake(11.0, 20.0)];
        [path stroke];

        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    });

    return image;
}

- (UIImage *)forwardButtonImage
{
    static UIImage *image;

    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        UIImage *backButtonImage = [self backButtonImage];

        CGSize size = backButtonImage.size;
        UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);

        CGContextRef context = UIGraphicsGetCurrentContext();

        CGFloat x_mid = size.width / 2.0;
        CGFloat y_mid = size.height / 2.0;

        CGContextTranslateCTM(context, x_mid, y_mid);
        CGContextRotateCTM(context, M_PI);

        [backButtonImage drawAtPoint:CGPointMake(-x_mid, -y_mid)];

        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    });

    return image;
}

- (void)setupToolBarItems
{
    self.stopLoadingButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop
                                                                           target:self.webView
                                                                           action:@selector(stopLoading)];

    self.reloadButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                                                      target:self.webView
                                                                      action:@selector(reload)];

    self.backButton = [[UIBarButtonItem alloc] initWithImage:[self backButtonImage]
                                                       style:UIBarButtonItemStylePlain
                                                      target:self.webView
                                                      action:@selector(goBack)];

    self.forwardButton = [[UIBarButtonItem alloc] initWithImage:[self forwardButtonImage]
                                                          style:UIBarButtonItemStylePlain
                                                         target:self.webView
                                                         action:@selector(goForward)];

    self.backButton.enabled = NO;
    self.forwardButton.enabled = NO;

    UIBarButtonItem *actionButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop
                                                                                  target:self
                                                                                  action:@selector(action:)];

    UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                           target:nil
                                                                           action:nil];

    UIBarButtonItem *space_ = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                                                            target:nil
                                                                            action:nil];
    space_.width = 60.0f;

    self.toolbarItems = @[self.stopLoadingButton, space, self.backButton, space_, self.forwardButton, space, actionButton];
}

- (void)toggleState
{
    self.backButton.enabled = self.webView.canGoBack;
    self.forwardButton.enabled = self.webView.canGoForward;

    NSMutableArray *toolbarItems = [self.toolbarItems mutableCopy];
    if (self.webView.loading) {
        toolbarItems[0] = self.stopLoadingButton;
    } else {
        toolbarItems[0] = self.reloadButton;
    }
    self.toolbarItems = [toolbarItems copy];
}

- (void)finishLoad
{
    [self toggleState];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

#pragma mark - Button actions

- (void)action:(id)sender
{
    if (self.cancellation) {
        self.cancellation();
    }
}

#pragma mark - Web view delegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    //    NSLog(@"Request URL = %@", [request.URL absoluteString]);
    //    NSLog(@"Request headers = %@", request.allHTTPHeaderFields);
    if ([[request.URL absoluteString] hasPrefix:kCloseRedirectUri]) {
        NSLog(@"Redirecting to %@", kCloseRedirectUri);
        if (self.completion) {
            self.completion();
            return NO;
        }
    }

    if ([self isRedirectUri:request.URL] && ![[request valueForHTTPHeaderField:kOAuthDoneUriHeader] isEqualToString:kCloseRedirectUri]) {
        NSLog(@"Will redirect to %@", kCloseRedirectUri);
        NSMutableURLRequest *mutableURLRequest = [NSMutableURLRequest requestWithURL:request.URL];
        [mutableURLRequest setValue:kCloseRedirectUri forHTTPHeaderField:kOAuthDoneUriHeader];

        [webView loadRequest:mutableURLRequest];
        return NO;
    }

    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [self toggleState];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self finishLoad];
    self.title = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [self finishLoad];
}

#pragma mark - Overriden getters

- (BOOL)isRedirectUri:(NSURL *)URL {
    NSString *redirectURLString = [URL query];
    __block BOOL isRedirectUri = NO;
    [[redirectURLString componentsSeparatedByString:@"&"] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSArray *queryStringComponents = [obj componentsSeparatedByString:@"="];
        if ([queryStringComponents count] == 2) {
            if ([queryStringComponents[0] isEqualToString:kIsRedirectUri]) {
                if ([queryStringComponents[1] isEqualToString:@"true"]) {
                    isRedirectUri = YES;
                    *stop = YES;
                }
            }
        }
    }];
    return isRedirectUri;
}

- (NSURL *)magnetRedirectURL {

    if (!_magnetRedirectURL) {
        _magnetRedirectURL = [self redirectURL:self.URL];
    }

    return _magnetRedirectURL;
}

#pragma mark - Private implementation

- (NSURL *)redirectURL:(NSURL *)URL {
    NSString *redirectURLString = [URL query];
    __block NSURL *urlToReturn = nil;
    [[redirectURLString componentsSeparatedByString:@"&"] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSArray *queryStringComponents = [obj componentsSeparatedByString:@"="];
        if ([queryStringComponents count] > 1) {
            if ([queryStringComponents[0] isEqualToString:kOAuthRedirectUriParameter]) {
                urlToReturn = [NSURL URLWithString:[queryStringComponents[1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
            }
        }
    }];
    return urlToReturn;
}

@end