/**
 * Copyright (c) 2012-2015 Magnet Systems, Inc. All rights reserved.
 */

#import "MMService_Private.h"
#import "MMServiceAdapter_Private.h"
#import "MMServiceMethod.h"
#import "MMRestHandler.h"
#import "MMValueTransformer.h"
#import "MMRequestOperationManager.h"
#import "MMModel.h"
#import <AFNetworking/AFURLResponseSerialization.h>
#import <libextobjc/extobjc.h>
#import <MagnetMobileServer/MagnetMobileServer-Swift.h>

@implementation MMService

+ (NSDictionary *)metaData {
    return nil;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.serviceAdapter = [MMCoreConfiguration serviceAdapter];
    }
    
    return self;
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
    return [super methodSignatureForSelector:aSelector];
}

- (void)forwardInvocation:(NSInvocation *)anInvocation {
    
    NSDictionary *metaData = [[self class] metaData];
    NSString *selectorString = NSStringFromSelector(anInvocation.selector);
    MMServiceMethod *method = metaData[selectorString];
    if (!method) {
        [super forwardInvocation:anInvocation];
    } else {
        
        NSMutableURLRequest *request = [MMRestHandler requestWithInvocation:anInvocation
                                                              serviceMethod:method
                                                             serviceAdapter:self.serviceAdapter];
        
        typedef void(^FailureBlock)(NSError *);
        NSUInteger numberOfArguments = [[anInvocation methodSignature] numberOfArguments];
        
        // Get success and failure blocks
        __unsafe_unretained id success = nil;
        __unsafe_unretained FailureBlock failure = nil;
        [anInvocation getArgument:&success atIndex:(numberOfArguments - 2)]; // success block is always the second to last argument (penultimate)
        [anInvocation getArgument:&failure atIndex:(numberOfArguments - 1)]; // failure block is always the last argument
        id successBlock = [success copy];
        FailureBlock failureBlock = [failure copy];
        
        NSString *correlationId = [[NSUUID UUID] UUIDString];
        MMCall *call = [[MMCall alloc] initWithCallID:correlationId serviceAdapter:self.serviceAdapter serviceMethod:method request:request successBlock:successBlock failureBlock:failureBlock];
        [call addDependency:self.serviceAdapter.CATTokenOperation];
        [anInvocation retainArguments];
        [anInvocation setReturnValue:&call];
    }
}

@end
