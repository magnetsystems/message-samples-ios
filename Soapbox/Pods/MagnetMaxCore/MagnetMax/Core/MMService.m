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

#import "MMService_Private.h"
#import "MMServiceAdapter_Private.h"
#import "MMServiceMethod.h"
#import "MMRestHandler.h"
#import "MMValueTransformer.h"
#import "MMRequestOperationManager.h"
#import "MMModel.h"
#import <AFNetworking/AFURLResponseSerialization.h>
#import <MagnetMaxCore/MagnetMaxCore-Swift.h>

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
