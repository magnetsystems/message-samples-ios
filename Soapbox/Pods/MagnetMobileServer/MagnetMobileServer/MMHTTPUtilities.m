/**
 * Copyright (c) 2012-2015 Magnet Systems, Inc. All rights reserved.
 */
 
#import "MMHTTPUtilities.h"

BOOL MMDoesSchemeHaveHTTPPrefix(NSString *scheme)
{
    return [scheme hasPrefix:@"http"];
}

BOOL MMDoesSchemeHaveWSPrefix(NSString *scheme)
{
    return [scheme hasPrefix:@"ws"];
}

BOOL MMIsSpecificRequestMethod(MMRequestMethod method)
{
    // check for a power of two
    return !(method & (method - 1));
}

NSString *MMStringFromRequestMethod(MMRequestMethod method)
{
    switch (method) {
        case MMRequestMethodGET:     return @"GET";
        case MMRequestMethodPOST:    return @"POST";
        case MMRequestMethodPUT:     return @"PUT";
        case MMRequestMethodPATCH:   return @"PATCH";
        case MMRequestMethodDELETE:  return @"DELETE";
        case MMRequestMethodHEAD:    return @"HEAD";
        case MMRequestMethodOPTIONS: return @"OPTIONS";
        default:                     break;
    }
    return nil;
}

MMRequestMethod MMRequestMethodFromString(NSString *methodName)
{
    if      ([methodName isEqualToString:@"GET"])     return MMRequestMethodGET;
    else if ([methodName isEqualToString:@"POST"])    return MMRequestMethodPOST;
    else if ([methodName isEqualToString:@"PUT"])     return MMRequestMethodPUT;
    else if ([methodName isEqualToString:@"DELETE"])  return MMRequestMethodDELETE;
    else if ([methodName isEqualToString:@"HEAD"])    return MMRequestMethodHEAD;
    else if ([methodName isEqualToString:@"PATCH"])   return MMRequestMethodPATCH;
    else if ([methodName isEqualToString:@"OPTIONS"]) return MMRequestMethodOPTIONS;
    else                                              @throw [NSException exceptionWithName:NSInvalidArgumentException
                                                                                     reason:[NSString stringWithFormat:@"The given HTTP request method name `%@` does not correspond to any known request methods.", methodName]
                                                                                   userInfo:nil];
}

NSString *MMStringFromHTTPContentType(MMHTTPContentType contentType)
{
    switch (contentType) {
        case MMHTTPContentTypeApplicationJSON:  return @"application/json";
        case MMHTTPContentTypeTextPlain:        return @"text/plain";
        case MMHTTPContentTypeMultipart:        return @"multipart/form-data";
        default:                                break;
    }
    return nil;
}

MMHTTPContentType MMHTTPContentTypeFromString(NSString *contentType)
{
    if      ([contentType hasPrefix:@"application/json"])     return MMHTTPContentTypeApplicationJSON;
    else if ([contentType hasPrefix:@"text/plain"])           return MMHTTPContentTypeTextPlain;
    else                                              @throw [NSException exceptionWithName:NSInvalidArgumentException
                                                                                     reason:[NSString stringWithFormat:@"The given HTTP content type name `%@` does not correspond to any known content types.", contentType]
                                                                                   userInfo:nil];
}

static NSString * const kMMCharactersToBeEscapedInQueryString = @":/?&=;+!@#$()',*";

NSString *MMPercentEscapedQueryStringValueFromStringWithEncoding(NSString *string, NSStringEncoding encoding) {
    return (__bridge_transfer  NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (__bridge CFStringRef)string, NULL, (__bridge CFStringRef)kMMCharactersToBeEscapedInQueryString, CFStringConvertNSStringEncodingToEncoding(encoding));
}
