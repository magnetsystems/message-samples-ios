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
#import "MMCall_Private.h"
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
        MMCall *call = [[MMCall alloc] init];
        call.name = [NSString stringWithFormat:@"%@ %@", MMStringFromRequestMethod(method.requestMethod), method.path];
        call.invocation = anInvocation;
        call.serviceMethod = method;
        call.serviceAdapter = self.serviceAdapter;
        NSString *correlationId = [[NSUUID UUID] UUIDString];
        call.callId = correlationId;
        [call addDependency:self.serviceAdapter.CATTokenOperation];
        [anInvocation retainArguments];
        [anInvocation setReturnValue:&call];
    }
}

@end
