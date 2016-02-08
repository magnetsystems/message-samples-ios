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

#import <Foundation/Foundation.h>
@import MMXXMPPFramework;

@interface MMXOAuthPlatformAuthentication : NSObject <XMPPSASLAuthentication>

/**
 * You should use this init method (as opposed the one defined in the XMPPSASLAuthentication protocol).
 **/
- (id)initWithStream:(XMPPStream *)stream accessToken:(NSString *)accessToken;

@end

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@interface XMPPStream (MMXOAuthPlatformAuthentication)


/**
 * Returns whether or not the server supports MMX-OAuth Platform authentication.
 *
 * This information is available after the stream is connected.
 * In other words, after the delegate has received xmppStreamDidConnect: notification.
 **/
- (BOOL)supportsMMXOAuthPlatformAuthentication;

/**
 * This method attempts to start the mmx oauth authentication process.
 *
 * This method is asynchronous.
 *
 * If there is something immediately wrong,
 * such as the stream is not connected or doesn't have a set appId or accessToken,
 * the method will return NO and set the error.
 * Otherwise the delegate callbacks are used to communicate auth success or failure.
 *
 * @see xmppStreamDidAuthenticate:
 * @see xmppStream:didNotAuthenticate:
 **/
- (BOOL)authenticateWithMMXOAuthAccessToken:(NSString *)accessToken error:(NSError **)errPtr;

@end
