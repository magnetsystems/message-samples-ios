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

#import "MMXOAuthPlatformAuthentication.h"
#import "XMPP.h"
#import "XMPPLogging.h"
#import "XMPPInternal.h"
#import "NSData+XMPP.h"

#import <objc/runtime.h>

#if ! __has_feature(objc_arc)
#warning This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif

// Log levels: off, error, warn, info, verbose
#if DEBUG
static const int xmppLogLevel = XMPP_LOG_LEVEL_INFO; // | XMPP_LOG_FLAG_TRACE;
#else
static const int xmppLogLevel = XMPP_LOG_LEVEL_WARN;
#endif

@interface MMXOAuthPlatformAuthentication () {
#if __has_feature(objc_arc_weak)
	__weak XMPPStream *xmppStream;
#else
	__unsafe_unretained XMPPStream *xmppStream;
#endif
	
	BOOL awaitingChallenge;
	
	NSString *appId;
	NSString *accessToken;
	NSString *nonce;
	NSString *method;
}

- (NSDictionary *)dictionaryFromChallenge:(NSXMLElement *)challenge;
- (NSString *)base64EncodedFullResponse;

@end

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@implementation MMXOAuthPlatformAuthentication

+ (NSString *)mechanismName {
	return @"X-MMX_BF_OAUTH2";
}

- (id)initWithStream:(XMPPStream *)stream password:(NSString *)password {
	if ((self = [super init])) {
		xmppStream = stream;
	}
	return self;
}

- (id)initWithStream:(XMPPStream *)stream accessToken:(NSString *)inAccessToken {
	if ((self = [super init])) {
		xmppStream = stream;
		accessToken = inAccessToken;
	}
	return self;
}

- (BOOL)start:(NSError **)errPtr {
	if (!accessToken) {
		NSString *errMsg = @"Missing MMX accessToken.";
		NSDictionary *info = @{NSLocalizedDescriptionKey : errMsg};
		
		NSError *err = [NSError errorWithDomain:XMPPStreamErrorDomain code:XMPPStreamInvalidState userInfo:info];
		
		if (errPtr) *errPtr = err;
		return NO;
	}
	
	// <auth xmlns="urn:ietf:params:xml:ns:xmpp-sasl"mechanism="X-MMX_BF_OAUTH2">
	
	NSXMLElement *auth = [NSXMLElement elementWithName:@"auth" xmlns:@"urn:ietf:params:xml:ns:xmpp-sasl"];
	[auth addAttributeWithName:@"mechanism" stringValue:@"X-MMX_BF_OAUTH2"];
	[auth setStringValue:[self basicAuthorization]];
	
	[xmppStream sendAuthElement:auth];
	awaitingChallenge = NO;
	
	return YES;
}

- (XMPPHandleAuthResponse)handleAuth1:(NSXMLElement *)authResponse {
	XMPPLogTrace();
	
	// We're expecting a challenge response.
	// If we get anything else we're going to assume it's some kind of failure response.
	
	if (![[authResponse name] isEqualToString:@"challenge"])
	{
		return XMPP_AUTH_FAIL;
	}
	
	// Extract components from incoming challenge
	
	NSDictionary *auth = [self dictionaryFromChallenge:authResponse];
	
	nonce  = auth[@"nonce"];
	method = auth[@"method"];
	
	// Create and send challenge response element
	
	NSXMLElement *response = [NSXMLElement elementWithName:@"response" xmlns:@"urn:ietf:params:xml:ns:xmpp-sasl"];
	[response setStringValue:[self base64EncodedFullResponse]];
	
	[xmppStream sendAuthElement:response];
	awaitingChallenge = NO;
	
	return XMPP_AUTH_CONTINUE;
}

- (NSString *)basicAuthorization {
	NSString * authString = [NSString stringWithFormat:@"\0%@\0%@",xmppStream.myJID.user,accessToken];
	NSData *nsdata = [authString dataUsingEncoding:NSUTF8StringEncoding];
 
	return [NSString stringWithFormat:@"%@",[nsdata base64EncodedStringWithOptions:0]];
}


- (XMPPHandleAuthResponse)handleAuth2:(NSXMLElement *)authResponse {
	XMPPLogTrace();
	
	// We're expecting a success response.
	// If we get anything else we can safely assume it's the equivalent of a failure response.
	
	if ([[authResponse name] isEqualToString:@"success"]) {
		return XMPP_AUTH_SUCCESS;
	} else {
		return XMPP_AUTH_FAIL;
	}
}

- (XMPPHandleAuthResponse)handleAuth:(NSXMLElement *)authResponse {
	if (awaitingChallenge) {
		return [self handleAuth1:authResponse];
	} else {
		return [self handleAuth2:authResponse];
	}
}

- (NSDictionary *)dictionaryFromChallenge:(NSXMLElement *)challenge {
	// The value of the challenge stanza is base 64 encoded.
	// Once "decoded", it's just a string of key=value pairs separated by ampersands.
	
	NSData *base64Data = [[challenge stringValue] dataUsingEncoding:NSASCIIStringEncoding];
	NSData *decodedData = [base64Data xmpp_base64Decoded];
	
	NSString *authStr = [[NSString alloc] initWithData:decodedData encoding:NSUTF8StringEncoding];
	
	XMPPLogVerbose(@"%@: decoded challenge: %@", THIS_FILE, authStr);
	
	NSArray *components = [authStr componentsSeparatedByString:@"&"];
	NSMutableDictionary *auth = [NSMutableDictionary dictionaryWithCapacity:3];
	
	for (NSString *component in components) {
		NSRange separator = [component rangeOfString:@"="];
		if (separator.location != NSNotFound) {
			NSString *key = [[component substringToIndex:separator.location]
							 stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
			
			NSString *value = [[component substringFromIndex:separator.location+1]
							   stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
			
			if ([value hasPrefix:@"\""] && [value hasSuffix:@"\""] && [value length] > 2) {
				// Strip quotes from value
				value = [value substringWithRange:NSMakeRange(1,([value length]-2))];
			}
			
			auth[key] = value;
		}
	}
	
	return auth;
}

//FIXME - This needs to change to fit our scheme
- (NSString *)base64EncodedFullResponse {
	if (!accessToken || !method || !nonce) {
		return nil;
	}
	
	srand([[NSDate date] timeIntervalSince1970]);
	
	NSMutableString *buffer = [NSMutableString stringWithCapacity:250];
	[buffer appendFormat:@"method=%@&", method];
	[buffer appendFormat:@"nonce=%@&", nonce];
	[buffer appendFormat:@"access_token=%@&", accessToken];
	[buffer appendFormat:@"call_id=%d&", rand()];
	[buffer appendFormat:@"v=%@",@"1.0"];
	
	XMPPLogVerbose(@"MMXOAuthPlatformAuthentication: response for mmx: %@", buffer);
	
	NSData *utf8data = [buffer dataUsingEncoding:NSUTF8StringEncoding];
	
	return [utf8data xmpp_base64Encoded];
}

@end

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@implementation XMPPStream (MMXOAuthPlatformAuthentication)

- (BOOL)supportsMMXOAuthPlatformAuthentication {
	return [self supportsAuthenticationMechanism:[MMXOAuthPlatformAuthentication mechanismName]];
}

/**
 * This method attempts to connect to the MMX Chat servers
 * using the MMX OAuth token returned by the Blowfish OAuth 2.0 authentication process.
 **/
- (BOOL)authenticateWithMMXOAuthAccessToken:(NSString *)accessToken error:(NSError **)errPtr
{
	XMPPLogTrace();
	
	__block BOOL result = YES;
	__block NSError *err = nil;
	
	dispatch_block_t block = ^{ @autoreleasepool {
		
		if ([self supportsMMXOAuthPlatformAuthentication])
		{
			MMXOAuthPlatformAuthentication *mmxAuth =
			[[MMXOAuthPlatformAuthentication alloc] initWithStream:self
													   accessToken:accessToken];
			
			result = [self authenticate:mmxAuth error:&err];
		}
		else
		{
			NSString *errMsg = @"The server does not support MMX-OAuth Platform authentication.";
			NSDictionary *info = @{NSLocalizedDescriptionKey : errMsg};
			
			err = [NSError errorWithDomain:XMPPStreamErrorDomain code:XMPPStreamUnsupportedAction userInfo:info];
			
			result = NO;
		}
	}};
	
	if (dispatch_get_specific(self.xmppQueueTag))
		block();
	else
		dispatch_sync(self.xmppQueue, block);
	
	if (errPtr)
		*errPtr = err;
	
	return result;
}

@end
