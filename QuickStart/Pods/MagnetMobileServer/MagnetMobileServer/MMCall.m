/**
* Copyright (c) 2012-2015 Magnet Systems, Inc. All rights reserved.
*/

#import <AFNetworking/AFURLResponseSerialization.h>
#import "MMRestHandler.h"
#import "MMCall_Private.h"
#import "MMServiceMethod.h"
#import "MMServiceAdapter_Private.h"
#import "MMValueTransformer.h"
#import "MTLJSONAdapter.h"
#import "MMRequestOperationManager.h"
#import <AFNetworking/AFHTTPSessionManager.h>
#import <MagnetMobileServer/MagnetMobileServer-Swift.h>

@implementation MMCall

#pragma mark - NSOperation

- (void)execute {
    
    if (self.isCancelled) {
        return;
    }
    
    [self internalQueue].suspended = YES;
    
    BOOL isReachable = self.serviceAdapter.sessionManager.reachabilityManager.isReachable;
    BOOL useCache = (self.cacheOptions != nil);
    
    if (useCache) {
        BOOL doesMethodSupportCaching = (self.serviceMethod.requestMethod & (MMRequestMethodGET | MMRequestMethodHEAD | MMRequestMethodOPTIONS)) != 0;
        NSAssert(doesMethodSupportCaching, @"Caching is only supported for calls with the following HTTP methods: HEAD, GET and OPTIONS.");
    }
    
    BOOL isReliable = (self.reliableCallOptions != nil);
    if (isReliable) {
        BOOL doesMethodSupportReliability = (self.serviceMethod.requestMethod & (MMRequestMethodPOST | MMRequestMethodPUT | MMRequestMethodDELETE | MMRequestMethodPATCH)) != 0;
        NSAssert(doesMethodSupportReliability, @"Only calls with the HTTP methods: POST, PUT, DELETE and PATCH can be made reliable.");
    }
    
    if (!self.underlyingOperation) {
        
        if (self.isCancelled) {
            return;
        }
        
        NSTimeInterval maxCacheAge = self.cacheOptions.maxCacheAge;
        
        if (!isReachable && useCache && self.cacheOptions.alwaysUseCacheIfOffline) {
            maxCacheAge = [[NSDate date] timeIntervalSince1970];
        }
        
        NSURLRequest *request = [MMRestHandler requestWithInvocation:self.invocation
                                                       serviceMethod:self.serviceMethod
                                                      serviceAdapter:self.serviceAdapter
                                                             useMock:self.useMock
                                                            useCache:useCache
                                                            cacheAge:maxCacheAge];
        
        __block MMReliableCall *reliableCall;
        if (isReliable) {
            [[MMCoreDataStack sharedContext] performChanges:^{
                reliableCall = [MMReliableCall insertIntoContext:[MMCoreDataStack sharedContext]
                                                          callID:self.callId
                                                           clazz:NSStringFromClass(self.serviceMethod.clazz)
                                                          method:NSStringFromSelector(self.serviceMethod.selector)
                                                         request:request
                                                        response:nil];
            }];
        }
        
        typedef void(^FailureBlock)(NSError *);
        //        typedef void(^SuccessBlock)(NSArray *);

        //            __unsafe_unretained MMOptions *options = nil;
        NSUInteger numberOfArguments = [[self.invocation methodSignature] numberOfArguments];

        // Get success and failure blocks
        //[self.invocation getArgument:&options atIndex:(numberOfArguments - 3)]; // options is always the third to last argument
        __unsafe_unretained id success = nil;
        __unsafe_unretained FailureBlock failure = nil;
        [self.invocation getArgument:&success atIndex:(numberOfArguments - 2)]; // success block is always the second to last argument (penultimate)
        [self.invocation getArgument:&failure atIndex:(numberOfArguments - 1)]; // failure block is always the last argument
        id successBlock = [success copy];
        FailureBlock failureBlock = [failure copy];
        self.underlyingOperation = [self.serviceAdapter.requestOperationManager requestOperationWithRequest:request success:^(NSURLResponse *URLResponse, id responseObject) {
            
            if (isReliable) {
                [[MMCoreDataStack sharedContext] performChanges:^{
                    reliableCall.response = URLResponse;
                }];
            }
            
            if (successBlock) {
                // Magnet payloads are under the "value" keyPath
                id response;
                NSString *responseString;
                if ([responseObject isKindOfClass:[NSDictionary class]]) {
                    // FIXME:
                    response = responseObject[@"value"];
                } else if ([responseObject isKindOfClass:[NSData class]]) {
                    responseString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
                    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
                    response = [formatter numberFromString:responseString];
                } else if ([responseObject isKindOfClass:[NSString class]]) {
                    responseString = responseObject;
                    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
                    response = [formatter numberFromString:responseString];
                }
                switch (self.serviceMethod.returnType) {

                    case MMServiceIOTypeVoid: {
                        typedef void(^SuccessBlock)(id);
                        SuccessBlock successBlockToExecute = successBlock;
                        successBlockToExecute(nil);
                        break;
                    }
                    case MMServiceIOTypeString: {
                        typedef void(^SuccessBlock)(NSString *);
                        SuccessBlock successBlockToExecute = successBlock;
                        successBlockToExecute(responseString);
                        break;
                    }
                    case MMServiceIOTypeEnum: {
                        typedef void(^SuccessBlock)(NSUInteger);
                        SuccessBlock successBlockToExecute = successBlock;
                        // FIXME: Hack - Server returns a double-quoted string.
                        if ([responseString hasPrefix:@"\""] && [responseString hasSuffix:@"\""]) {
                            responseString = [responseString substringWithRange:NSMakeRange(1, responseString.length - 2)];
                        }
                        NSUInteger enumValue = [[[MMValueTransformer enumTransformerForContainerClass:self.serviceMethod.returnTypeClass] transformedValue:responseString] unsignedIntegerValue];
                        successBlockToExecute(enumValue);
                        break;
                    }
                    case MMServiceIOTypeBoolean: {
                        typedef void(^SuccessBlock)(BOOL);
                        SuccessBlock successBlockToExecute = successBlock;
                        // FIXME: Can we modify the transformer instead?
                        successBlockToExecute([[[MMValueTransformer booleanTransformer] transformedValue:@([responseString isEqualToString:@"true"])] boolValue]);
                        break;
                    }
                    case MMServiceIOTypeChar: {
                        typedef void(^SuccessBlock)(char);
                        SuccessBlock successBlockToExecute = successBlock;
                        char val = (char) [response integerValue];
                        successBlockToExecute(val);
                        break;
                    }
                    case MMServiceIOTypeUnichar: {
                        typedef void(^SuccessBlock)(unichar);
                        SuccessBlock successBlockToExecute = successBlock;
                        unichar val = [[[MMValueTransformer unicharTransformer] transformedValue:responseString] unsignedShortValue];
                        successBlockToExecute(val);
                        break;
                    }
                    case MMServiceIOTypeShort: {
                        typedef void(^SuccessBlock)(short);
                        SuccessBlock successBlockToExecute = successBlock;
                        short val = (short) [response integerValue];
                        successBlockToExecute(val);
                        break;
                    }
                    case MMServiceIOTypeInteger: {
                        typedef void(^SuccessBlock)(int);
                        SuccessBlock successBlockToExecute = successBlock;
                        int val = [response intValue];
                        successBlockToExecute(val);
                        break;
                    }
                    case MMServiceIOTypeLongLong: {
                        typedef void(^SuccessBlock)(long long);
                        SuccessBlock successBlockToExecute = successBlock;
                        long long val = [[[MMValueTransformer longLongTransformer] transformedValue:response] longLongValue];
                        successBlockToExecute(val);
                        break;
                    }
                    case MMServiceIOTypeFloat: {
                        typedef void(^SuccessBlock)(float);
                        SuccessBlock successBlockToExecute = successBlock;
                        successBlockToExecute([responseString floatValue]);
                        break;
                    }
                    case MMServiceIOTypeDouble: {
                        typedef void(^SuccessBlock)(double);
                        SuccessBlock successBlockToExecute = successBlock;
                        successBlockToExecute([responseString doubleValue]);
                        break;
                    };
                    case MMServiceIOTypeBigDecimal:
                        break;
                    case MMServiceIOTypeBigInteger: {
                        typedef void(^SuccessBlock)(NSDecimalNumber *);
                        SuccessBlock successBlockToExecute = successBlock;
                        NSDecimalNumber *val = [NSDecimalNumber decimalNumberWithString:responseObject];
                        successBlockToExecute(val);
                        break;
                    };
                    case MMServiceIOTypeDate: {
                        typedef void(^SuccessBlock)(NSDate *);
                        SuccessBlock successBlockToExecute = successBlock;
                        NSDate *val = [[MMValueTransformer dateTransformer] transformedValue:responseString];
                        successBlockToExecute(val);
                        break;
                    };
                    case MMServiceIOTypeUri: {
                        typedef void(^SuccessBlock)(NSURL *);
                        SuccessBlock successBlockToExecute = successBlock;
                        NSURL *val = [[MMValueTransformer urlTransformer] transformedValue:response];
                        successBlockToExecute(val);
                        break;
                    }
                    case MMServiceIOTypeMagnetNode:
                    case MMServiceIOTypeArray: {
                        typedef void(^SuccessBlock)(id);
                        SuccessBlock successBlockToExecute = successBlock;
                        NSError *serializationError;
                        id res;
                        if ([responseObject isKindOfClass:[NSDictionary class]] || [responseObject isKindOfClass:[NSArray class]]) {
                            res = responseObject;
                        } else {
                            res = [[AFJSONResponseSerializer serializer] responseObjectForResponse:URLResponse data:responseObject error:&serializationError];
                        }
                        if (!serializationError) {
                            if (self.serviceMethod.returnTypeClass) {
                                NSError *hydrationError;
                                if ([res isKindOfClass:[NSArray class]]) {
                                    Class clazz = self.serviceMethod.returnTypeClass;
                                    res = [[MMValueTransformer listTransformerForType:self.serviceMethod.returnComponentType clazz:clazz] transformedValue:res];
                                } else if ([res isKindOfClass:[NSDictionary class]]) {
                                    res = [MTLJSONAdapter modelOfClass:self.serviceMethod.returnTypeClass fromJSONDictionary:res error:&hydrationError];
                                }
                                if (!hydrationError) {
                                    successBlockToExecute(res);
                                } else {
                                    if (failureBlock) {
                                        failureBlock(hydrationError);
                                    }
                                }
                            } else {
                                if (self.serviceMethod.returnType == MMServiceIOTypeArray) {
                                }
                                successBlockToExecute(res);
                            }
                        } else {
                            if (failureBlock) {
                                failureBlock(serializationError);
                            }
                        }
                        break;
                    }
                    case MMServiceIOTypeDictionary: {
                        typedef void(^SuccessBlock)(NSDictionary *);
                        SuccessBlock successBlockToExecute = successBlock;
                        NSError *serializationError;
                        id res;
                        if ([responseObject isKindOfClass:[NSDictionary class]]) {
                            res = responseObject;
                        } else {
                            res = [[AFJSONResponseSerializer serializer] responseObjectForResponse:URLResponse data:responseObject error:&serializationError];
                        }
                        Class clazz = self.serviceMethod.returnTypeClass;
                        res = [[MMValueTransformer mapTransformerForType:self.serviceMethod.returnComponentType clazz:clazz] transformedValue:res];
                        if (!serializationError) {
                            if (successBlock) {
                                successBlockToExecute(res);
                            }
                        } else {
                            if (failureBlock) {
                                failureBlock(serializationError);
                            }
                        }
                        break;
                    };
                    case MMServiceIOTypeData: {
                        typedef void(^SuccessBlock)(NSData *);
                        SuccessBlock successBlockToExecute = successBlock;
                        NSData *decodedData = [[MMValueTransformer dataTransformer] transformedValue:response];
                        successBlockToExecute(decodedData);
                        break;
                    }
                    case MMServiceIOTypeBytes:
                        break;
                };
            }
        }                                                                                                failure:^(NSError *error) {
            if (failureBlock) {
                failureBlock(error);
            }
        }];
    }

    if (self.isCancelled) {
        return;
    }

    self.underlyingOperation.name = self.callId;
    [[self internalQueue] addOperation:self.underlyingOperation];

    
    NSBlockOperation *finalOperation = [NSBlockOperation blockOperationWithBlock:^{
        [self finish];
    }];

    finalOperation.name = self.callId;
    [finalOperation addDependency:self.underlyingOperation];

    [[self internalQueue] addOperation:finalOperation];

    if (self.reliableCallOptions != nil) {
        if (isReachable) {
            [self internalQueue].suspended = NO;
        }
    } else {
        [self internalQueue].suspended = NO;
    }
}

#pragma mark - Public API

- (void)executeInBackground:(MMCacheOptions *)cacheOptions {
    self.cacheOptions = cacheOptions;
    [[self internalQueue] addOperation:self];
}

- (void)executeEventually:(MMReliableCallOptions *)reliableCallOptions {
    self.reliableCallOptions = reliableCallOptions;
    [[self internalQueue] addOperation:self];
}

#pragma mark - Private methods

- (NSOperationQueue *)internalQueue {
    
    if (self.reliableCallOptions != nil) {
        return self.serviceAdapter.requestOperationManager.reliableOperationQueue;
    }
    
    return self.serviceAdapter.requestOperationManager.operationQueue;
}

@end