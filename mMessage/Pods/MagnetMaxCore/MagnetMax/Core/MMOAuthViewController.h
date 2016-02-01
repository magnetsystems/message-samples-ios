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

#import <UIKit/UIKit.h>

#ifndef NS_DESIGNATED_INITIALIZER
#if __has_attribute(objc_designated_initializer)
#define NS_DESIGNATED_INITIALIZER __attribute__((objc_designated_initializer))
#else
#define NS_DESIGNATED_INITIALIZER
#endif
#endif

/**
`MMOAuthViewController` displays a URL in a webView with a `UIToolbar` containing controls like back, forward, refresh and close.

 It works out-of-the-box in a `UINavigationController`, but it can also serve as an example of other implementations.
 */
@interface MMOAuthViewController : UIViewController <UIWebViewDelegate>

/**
 The authorization URL to load in the webView.
 */
@property (nonatomic, strong) NSURL *URL;

/**
 If this property is set to YES, the toolbar is not visible. The default value of this property is NO.
 */
@property(nonatomic, getter=isToolbarHidden) BOOL toolbarHidden;

/**
 Initializes an `MMOAuthViewController` object with the specified URL.

 This is the designated initializer.

 @param url The authorization URL for the webView.

 @return The newly-initialized view controller.
*/
- (instancetype)initWithURL:(NSURL *)url;

/**
 Sets a callback to be executed when OAuth flow is cancelled.

 @param block A block object to be executed when the OAuth flow is cancelled by the user. This block has no return value and takes no arguments.
 */
- (void)setCancellation:(void (^)(void))block;

/**
 Sets a callback to be executed when OAuth flow is complete.

 @param block A block object to be executed when the OAuth flow is complete. This block has no return value and takes no arguments.
 */
- (void)setCompletionBlock:(void (^)(void))block;

@end
