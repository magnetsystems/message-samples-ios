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

#import "MMRestHandler.h"
#import "MMServiceAdapter_Private.h"
#import "MMServiceMethod.h"
#import "MMEndPoint.h"
#import "MMServiceMethodParameter.h"
#import "MMValueTransformer.h"
#import "MMModel.h"
#import "MMData.h"
#import <MagnetMaxCore/MagnetMaxCore-Swift.h>
#import <AFNetworking/AFURLRequestSerialization.h>

// arguments 0 and 1 are reserved
static int const kNumberOfReservedArguments = 2;
// options, success and failure
static int const kNumberOfCommonArguments = 2;

static NSString *const kHTTPContentType = @"Content-Type";

@implementation MMRestHandler

+ (NSMutableURLRequest *)requestWithInvocation:(NSInvocation *)anInvocation
                                 serviceMethod:(MMServiceMethod *)method
                                serviceAdapter:(MMServiceAdapter *)adapter {
    return [self requestWithInvocation:anInvocation serviceMethod:method serviceAdapter:adapter useMock:NO useCache:NO cacheAge:0];
}

+ (NSMutableURLRequest *)requestWithInvocation:(NSInvocation *)anInvocation
                                 serviceMethod:(MMServiceMethod *)method
                                serviceAdapter:(MMServiceAdapter *)adapter
                                       useMock:(BOOL)useMock
                                      useCache:(BOOL)useCache
                                      cacheAge:(NSTimeInterval)cacheAge {

    NSString *basePath = method.path;
    NSMutableDictionary *headers = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *queryParameters = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *bodyParameters = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *formDataParameters = [[NSMutableDictionary alloc] init];


    // Iterate through the argument list and figure out the type of the argument and the HTTP semantics.
    NSUInteger numberOfArguments = [[anInvocation methodSignature] numberOfArguments];
    // The cast is required so that we don't go out of bounds when numberOfArguments is 0.

    // FIXME: Comment out when options are back!
//    int const numberOfCommonArguments = (kNumberOfCommonArguments + 1);
    int const numberOfCommonArguments = kNumberOfCommonArguments;

    for (int i = 0; i < (int)(numberOfArguments - kNumberOfReservedArguments - numberOfCommonArguments); i++) {
        //            http://stackoverflow.com/questions/13268502/exc-bad-access-when-accessing-parameters-in-anddo-of-ocmock/13831074#13831074
        id argument;
        int index = (i + kNumberOfReservedArguments);

        MMServiceMethodParameter *parameter = method.parameters[i];

        // Transform the argument
        switch (parameter.type) {

            case MMServiceIOTypeVoid:{
                NSAssert(NO, @"");
                break;
            }
            case MMServiceIOTypeString:{
                __unsafe_unretained id arg;
                [anInvocation getArgument:&arg atIndex:index];
                argument = arg;
                break;
            }
            case MMServiceIOTypeEnum:{
                NSUInteger a;
                [anInvocation getArgument:&a atIndex:index];
                argument = [[MMValueTransformer enumTransformerForContainerClass:parameter.typeClass] reverseTransformedValue:@(a)];
                break;
            }
            case MMServiceIOTypeBoolean:{
                BOOL a;
                [anInvocation getArgument:&a atIndex:index];
                argument = [[MMValueTransformer booleanTransformer] reverseTransformedValue:@(a)];
                break;
            }
            case MMServiceIOTypeChar:{
                char a;
                [anInvocation getArgument:&a atIndex:index];
                argument = @(a);
                break;
            }
            case MMServiceIOTypeUnichar:{
                unichar a;
                [anInvocation getArgument:&a atIndex:index];
                argument = [NSString stringWithFormat:@"%C", a];
                break;
            }
            case MMServiceIOTypeShort:{
                short a;
                [anInvocation getArgument:&a atIndex:index];
                argument = @(a);
                break;
            }
            case MMServiceIOTypeInteger:{
                int a;
                [anInvocation getArgument:&a atIndex:index];
                argument = @(a);
                break;
            }
            case MMServiceIOTypeLongLong:{
                long long a;
                [anInvocation getArgument:&a atIndex:index];
                argument = @(a);
                break;
            }
            case MMServiceIOTypeFloat:{
                float a;
                [anInvocation getArgument:&a atIndex:index];
                argument = @(a);
                break;
            }
            case MMServiceIOTypeDouble:{
                double a;
                [anInvocation getArgument:&a atIndex:index];
                argument = @(a);
                break;
            }
            case MMServiceIOTypeBigDecimal:{
                break;
            }
            case MMServiceIOTypeBigInteger:{
                break;
            }
            case MMServiceIOTypeDate:{
                __unsafe_unretained NSDate *a;
                [anInvocation getArgument:&a atIndex:index];
                argument = [[MMValueTransformer dateTransformer] reverseTransformedValue:a];
                break;
            }
            case MMServiceIOTypeUri:{
                __unsafe_unretained NSURL *a;
                [anInvocation getArgument:&a atIndex:index];
                argument = [[MMValueTransformer urlTransformer] reverseTransformedValue:a];
                break;
            }
            case MMServiceIOTypeMagnetNode:{
                __unsafe_unretained MMModel *a;
                [anInvocation getArgument:&a atIndex:index];
                argument = [[MMValueTransformer resourceNodeTransformerForClass:parameter.typeClass] reverseTransformedValue:a];
                break;
            }
            case MMServiceIOTypeArray:{
                __unsafe_unretained NSArray *a;
                [anInvocation getArgument:&a atIndex:index];
                Class clazz = parameter.typeClass;
                argument = [[MMValueTransformer listTransformerForType:parameter.componentType clazz:clazz] reverseTransformedValue:a];
                break;
            }
            case MMServiceIOTypeDictionary: {
                __unsafe_unretained NSDictionary *a;
                [anInvocation getArgument:&a atIndex:index];
                Class clazz = parameter.typeClass;
                argument = [[MMValueTransformer mapTransformerForType:parameter.componentType clazz:clazz] reverseTransformedValue:a];
                break;
            }
            case MMServiceIOTypeData:{
                __unsafe_unretained NSData *data;
                [anInvocation getArgument:&data atIndex:index];
                argument = data;
                break;
            }
            case MMServiceIOTypeBytes:{
                __unsafe_unretained NSData *data;
                [anInvocation getArgument:&data atIndex:index];
                argument = [[MMValueTransformer dataTransformer] reverseTransformedValue:data];
                break;
            }
        };

        /* Do not include nil arguments */
        if (argument) {
            NSString *parameterName = parameter.name;
            if (parameterName && ![parameterName isEqualToString:@""]) {
                // FIXME: Can we modify the transformer instead?
                if (parameter.type == MMServiceIOTypeBoolean) {
                    argument = [argument boolValue] ? @"true" : @"false";
                }
                switch (parameter.requestParameterType) {

                    case MMServiceMethodParameterTypeHeader:{
                        if ([argument respondsToSelector:@selector(stringValue)]) {
                            argument = [argument stringValue];
                        }
                        headers[parameterName] = argument;
                        break;
                    }
                    case MMServiceMethodParameterTypePath:{
                        if ([argument respondsToSelector:@selector(stringValue)]) {
                            argument = [argument stringValue];
                        }
                        basePath = [basePath stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"{%@}", parameterName]
                                                                       withString:MMPercentEscapedQueryStringValueFromStringWithEncoding(argument, NSUTF8StringEncoding)
                                                                          options:NSCaseInsensitiveSearch
                                                                            range:NSMakeRange(0, [basePath length])];
                        break;
                    }
                    case MMServiceMethodParameterTypeQuery:{
                        queryParameters[parameterName] = argument;
                        break;
                    }
                    case MMServiceMethodParameterTypeForm:{
                        bodyParameters[parameterName] = argument;
                        break;
                    }
                    case MMServiceMethodParameterTypeFormData:{
                        if ([argument respondsToSelector:@selector(stringValue)]) {
                            argument = [argument stringValue];
                        }
                        formDataParameters[parameterName] = argument;
                        break;
                    }
                    case MMServiceMethodParameterTypeBody:{
                        // FIXME: I don't like how bodyParameters are handled
                        // Need to clean this up
                        if (parameter.isComplex) {
                            bodyParameters = argument;
                        } else {
                            bodyParameters[parameterName] = argument;
                        }
                        break;
                    }
                };
            }

        } else {
            NSAssert(parameter.isOptional, @"%@ should not be nil", parameter.name);
        }
    }

    NSString *URLString = [[NSURL URLWithString:basePath relativeToURL:adapter.endPoint.URL] absoluteString];
    if (useMock) {
        URLString = [URLString stringByReplacingOccurrencesOfString:@"/api/" withString:@"/mock/api/"];
    }
    // If a FORM-style param is present, then we will use a AFHTTPRequestSerializer
    NSArray *allParameterTypes = [method.parameters valueForKey:@"requestParameterType"];
    AFHTTPRequestSerializer *serializer;
    NSUInteger numberOfParameters = method.parameters.count;
    MMServiceMethodParameter *firstParameter = method.parameters.firstObject;
    BOOL shouldRequestHaveNonJSONBody = (
            numberOfParameters == 1 &&
            firstParameter.requestParameterType == MMServiceMethodParameterTypeBody &&
            !firstParameter.isComplex
    );
    if ([allParameterTypes containsObject:@(MMServiceMethodParameterTypeForm)] || [allParameterTypes containsObject:@(MMServiceMethodParameterTypeFormData)] || shouldRequestHaveNonJSONBody) {
        serializer = [AFHTTPRequestSerializer serializer];
    } else {
        serializer = [AFJSONRequestSerializer serializer];
    }
    serializer.HTTPMethodsEncodingParametersInURI = [NSSet setWithObjects:MMStringFromRequestMethod(MMRequestMethodGET), MMStringFromRequestMethod(MMRequestMethodHEAD), nil];

    if ([queryParameters count] > 0) {
        switch (method.requestMethod) {

            case MMRequestMethodGET:
            case MMRequestMethodHEAD:{
                [bodyParameters addEntriesFromDictionary:queryParameters];
                break;
            }

            case MMRequestMethodDELETE:
            case MMRequestMethodPOST:
            case MMRequestMethodPUT:
            case MMRequestMethodPATCH:{
                // Handle query parameters
//                [[MMLogger sharedLogger] verbose:@"Processing query string(s) for a NON-GET request"];

                NSError *error;
                NSMutableURLRequest *request = [serializer requestWithMethod:MMStringFromRequestMethod(MMRequestMethodGET) URLString:URLString parameters:queryParameters error:&error];

                if (error) {
//                    [[MMLogger sharedLogger] error:@"Error processing query string = %@", error];
                }

                URLString = [request.URL absoluteString];
                break;
            }
            case MMRequestMethodOPTIONS:break;
            case MMRequestMethodAny:break;
        };
    }

    NSError *serializationError;
    NSMutableURLRequest *request;
    NSString *multipart = MMStringFromHTTPContentType(MMHTTPContentTypeMultipart);
    if ([method.consumes containsObject:multipart]) {
        request = [serializer multipartFormRequestWithMethod:MMStringFromRequestMethod(method.requestMethod)
                                         URLString:URLString
                                        parameters:nil
                         constructingBodyWithBlock:^(id <AFMultipartFormData> formData) {
                             for(NSString *key in formDataParameters) {
                                 id paramValue = formDataParameters[key];
                                 if([paramValue isKindOfClass:[MMData class]]) {
                                     MMData *data = paramValue;
                                     if (key && ![key isEqualToString:@""]) {
                                         data.name = key;
                                     }
                                     if (data.fileName && data.mimeType && data.name) {
                                         [formData appendPartWithFileData:data.binaryData name:data.name fileName:data.fileName mimeType:data.mimeType];
                                     } else if (data.name) {
                                         [formData appendPartWithFormData:data.binaryData name:data.name];
                                     } else {
                                         [formData appendPartWithHeaders:nil body:data.binaryData];
                                     }
                                 } else if([paramValue isKindOfClass:[NSString class]]) {
                                     NSString *stringValue = paramValue;
                                     [formData appendPartWithFormData:[stringValue dataUsingEncoding:NSUTF8StringEncoding] name:key];
                                 } else {
                                     NSString *stringValue = [paramValue description];
                                     [formData appendPartWithFormData:[stringValue dataUsingEncoding:NSUTF8StringEncoding] name:key];
                                 }
                             }
                         } error:&serializationError];
    } else {
        request = [serializer requestWithMethod:MMStringFromRequestMethod(method.requestMethod)
                                          URLString:URLString
                                         parameters:(bodyParameters.count ? bodyParameters : nil)
                                              error:&serializationError];
    }
    
    // If this a GET request with an array parameter, delete []
    // https://github.com/AFNetworking/AFNetworking/issues/437
    if (method.requestMethod == MMRequestMethodGET && [[method.parameters filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"type = %@", @(MMServiceIOTypeArray)]] count] > 0) {
        NSString *absoluteString = request.URL.absoluteString;
        absoluteString = [absoluteString stringByReplacingOccurrencesOfString:@"%5B%5D" withString:@""];
        request.URL = [NSURL URLWithString:absoluteString];
    }

    if (shouldRequestHaveNonJSONBody) {
        NSArray *values = [bodyParameters allValues];
        if ([values count] > 0) {
            NSString *value;
            if ([values[0] isKindOfClass:[NSString class]]) {
                value = values[0];
            } else if ([values[0] respondsToSelector:@selector(stringValue)]) {
                value = [values[0] stringValue];
            }
            request.HTTPBody = [value dataUsingEncoding:NSUTF8StringEncoding];
            NSString *applicationJSON = MMStringFromHTTPContentType(MMHTTPContentTypeApplicationJSON);
            NSString *textPlain = MMStringFromHTTPContentType(MMHTTPContentTypeTextPlain);
            if ([method.consumes containsObject:applicationJSON] || firstParameter.type == MMServiceIOTypeEnum) {
                [request setValue:applicationJSON forHTTPHeaderField:kHTTPContentType];
            } else if ([method.consumes containsObject:textPlain]) {
                [request setValue:textPlain forHTTPHeaderField:kHTTPContentType];
            } else {
                [request setValue:textPlain forHTTPHeaderField:kHTTPContentType];
            }
        }
    }

    request.timeoutInterval = adapter.client.timeoutInterval;
    // Add headers
    [headers enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [request setValue:obj forHTTPHeaderField:key];
    }];

    if (useCache) {
        [NSURLProtocol setProperty:@(cacheAge) forKey:[MMURLProtocol cacheAgeKey] inRequest:request];
    }
	
	[request setValue:[adapter bearerAuthorization] forHTTPHeaderField:@"Authorization"];

//    if (serializationError) {
//        if (failure) {
//#pragma clang diagnostic push
//#pragma clang diagnostic ignored "-Wgnu"
//            dispatch_async(self.completionQueue ?: dispatch_get_main_queue(), ^{
//                failure(nil, serializationError);
//            });
//#pragma clang diagnostic pop
//        }
//
//        return nil;
//    }
//
//    return [self HTTPRequestOperationWithRequest:request success:success failure:failure];

    return request;
}

@end