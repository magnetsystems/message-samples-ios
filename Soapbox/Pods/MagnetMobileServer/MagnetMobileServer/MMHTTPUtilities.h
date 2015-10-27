/**
 * Copyright (c) 2012-2015 Magnet Systems, Inc. All rights reserved.
 */

#import <Foundation/Foundation.h>
#ifndef MMHTTPUTILITIES_H
#define MMHTTPUTILITIES_H

/**
 HTTP methods for requests
 */
typedef NS_OPTIONS(NSInteger, MMRequestMethod){
    MMRequestMethodGET          = 1 << 0,
    MMRequestMethodPOST         = 1 << 1,
    MMRequestMethodPUT          = 1 << 2,
    MMRequestMethodDELETE       = 1 << 3,
    MMRequestMethodHEAD         = 1 << 4,
    MMRequestMethodPATCH        = 1 << 5,
    MMRequestMethodOPTIONS      = 1 << 6,
    MMRequestMethodAny          = (MMRequestMethodGET |
            MMRequestMethodPOST |
            MMRequestMethodPUT |
            MMRequestMethodDELETE |
            MMRequestMethodHEAD |
            MMRequestMethodPATCH |
            MMRequestMethodOPTIONS)
};

/**
 HTTP Content-Type for request/response
 */
typedef NS_ENUM(NSInteger, MMHTTPContentType){
    MMHTTPContentTypeApplicationJSON = 0,
    MMHTTPContentTypeTextPlain,
    MMHTTPContentTypeMultipart,
};

/**
 Returns YES if the given HTTP request method is either HTTP or HTTPS.
 */
BOOL MMDoesSchemeHaveHTTPPrefix(NSString *scheme);

/**
 Returns YES if the given HTTP request method is either ws or wss.
 */
BOOL MMDoesSchemeHaveWSPrefix(NSString *scheme);

/**
 Returns YES if the given HTTP request method is an exact match of the MMRequestMethod enum, and NO if it's a bit mask combination.
 */
BOOL MMIsSpecificRequestMethod(MMRequestMethod method);

/**
 Returns the corresponding string for value for a given HTTP request method.

 For example, given `MMRequestMethodGET` would return `@"GET"`.

 @param method The request method to return the corresponding string value for. The given request method must be specific.
 */
NSString *MMStringFromRequestMethod(MMRequestMethod method);

/**
 Returns the corresponding request method value for a given string.

 For example, given `@"PUT"` would return `@"MMRequestMethodPUT"`
 */
MMRequestMethod MMRequestMethodFromString(NSString *);

/**
 Returns the corresponding string for value for a given HTTP content type.

 For example, given `MMHTTPContentTypeApplicationJSON` would return `@"application/json"`.

 @param contentType The content type to return the corresponding string value for.
 */
NSString *MMStringFromHTTPContentType(MMHTTPContentType contentType);

/**
 Returns the corresponding content type value for a given string.

 For example, given `@"application/json"` would return `@"MMHTTPContentTypeApplicationJSON"`
 */
MMHTTPContentType MMHTTPContentTypeFromString(NSString *);

/**
Returns a safe string. Safe for use, say, as a parameter to a URL.

For example, given `@"hell & brimstone + earthly/delight"` would return `@"hell%20%26%20brimstone%20%2B%20earthly%2Fdelight"`.

@param string The string to encode.
@param encoding The encoding to be used.
*/
NSString *MMPercentEscapedQueryStringValueFromStringWithEncoding(NSString *string, NSStringEncoding encoding);

#endif

