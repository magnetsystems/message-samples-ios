/**
 * Copyright (c) 2012-2015 Magnet Systems, Inc. All rights reserved.
 */

#import "MMWebSocketRequestOperationManager.h"
#import "MMCPRequest.h"
#import "MMCPCommand.h"
#import "MMCPExecuteApiCommand.h"
#import "MMCPHTTPRequestPayload.h"
#import "MMCPResponse.h"
#import "MMCPExecuteApiResCommand.h"
#import "SRWebSocket.h"
#import <libextobjc/extobjc.h>
#import <MagnetMobileServer/MagnetMobileServer-Swift.h>


@interface MMWebSocketRequestOperationManager () <SRWebSocketDelegate>

@property(nonatomic, strong) SRWebSocket *webSocket;

@property(nonatomic, strong) dispatch_semaphore_t semaphore;

@property(nonatomic, copy) NSString *sessionId;

@property(nonatomic, strong) NSURL *URL;

@property(nonatomic, strong) NSMutableDictionary *callbacks;

@property(nonatomic, readwrite) OperationQueue *operationQueue;

@property(nonatomic, readwrite) OperationQueue *reliableOperationQueue;

@end

@implementation MMWebSocketRequestOperationManager

@synthesize securityPolicy = _securityPolicy;

- (id<MMRequestOperationManager>)initWithBaseURL:(NSURL *)theURL {
    self = [super init];
    if (self) {
        self.URL = theURL;
    }

    return self;
}

- (NSOperation *)requestOperationWithRequest:(NSURLRequest *)request
                                     success:(void (^)(NSURLResponse *response, id responseObject))success
                                     failure:(void (^)(NSError *error))failure {
    @weakify(self);
    NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
        @strongify(self);
        @synchronized(self) {
            if (self.webSocket.readyState != SR_OPEN) {
                [self.webSocket open];
                self.semaphore = dispatch_semaphore_create(0);
                dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
            }
        }

        NSAssert(self.webSocket.readyState == SR_OPEN, @"");
        NSAssert(self.sessionId != nil, @"");

        NSString *commandId = @"1";
        // Create command
        MMCPRequest *mmcpRequest = [[MMCPRequest alloc] init];
        NSString *requestId = [[NSUUID UUID] UUIDString];
        mmcpRequest.requestId = requestId;
        mmcpRequest.sessionId = self.sessionId;
        // TODO: This is hardcoded for now!
        mmcpRequest.executionType = MMCPExecutionTypeParallel;
        // TODO: This is hardcoded for now!
        mmcpRequest.priority = MMCPPriorityHigh;
        MMCPExecuteApiCommand *executeApiCommand = [[MMCPExecuteApiCommand alloc] init];
        executeApiCommand.commandId = commandId;
        executeApiCommand.priority = MMCPPriorityHigh;
        MMCPHTTPRequestPayload *requestPayload = [[MMCPHTTPRequestPayload alloc] init];
        NSString *path = [request.URL.absoluteString stringByReplacingOccurrencesOfString:[[NSURL URLWithString:@"/" relativeToURL:request.URL] absoluteString]
                                                              withString:@""];
        requestPayload.path = [@"/" stringByAppendingString:path];
        requestPayload.requestMethod = MMRequestMethodFromString(request.HTTPMethod);
        requestPayload.headers = request.allHTTPHeaderFields;
        if (request.HTTPBody) {
            requestPayload.body = [[NSString alloc] initWithData:request.HTTPBody encoding:NSUTF8StringEncoding];
        }
        executeApiCommand.payload = requestPayload;
        mmcpRequest.commands = @[executeApiCommand];

        NSDictionary *JSONDictionary = [MTLJSONAdapter JSONDictionaryFromModel:mmcpRequest error:NULL];

        NSError *serializationError;
        NSData *data = [NSJSONSerialization dataWithJSONObject:JSONDictionary options:0 error:&serializationError];

        if (!serializationError) {
            NSString *callbackId = [NSString stringWithFormat:@"%@-%@", requestId, commandId];
            self.callbacks[callbackId] = @{
                    @"success" : success,
                    @"failure" : failure,
            };
            NSString *command = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            [self.webSocket send:command];
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (failure) {
                    failure(serializationError);
                }
            });
        }

    }];
    return operation;
}

#pragma mark - Overriden getters

- (OperationQueue *)operationQueue {
    if (!_operationQueue) {
        _operationQueue = [[OperationQueue alloc] init];
    }

    return _operationQueue;
}

- (OperationQueue *)reliableOperationQueue {
    if (!_reliableOperationQueue) {
        _reliableOperationQueue = [[OperationQueue alloc] init];
    }
    
    return _reliableOperationQueue;
}

- (SRWebSocket *)webSocket {
    if (!_webSocket) {
        // http://stackoverflow.com/a/15897956/400552
        // Should give ws://localhost:8443/
//        NSURL *URL = [[NSURL URLWithString:@"/" relativeToURL:self.request.URL] absoluteURL];
        _webSocket = [[SRWebSocket alloc] initWithURL:self.URL protocols:nil securityPolicy:self.securityPolicy];
        _webSocket.delegate = self;
        [_webSocket setDelegateOperationQueue:self.operationQueue];
    }

    return _webSocket;
}

- (NSMutableDictionary *)callbacks {
    if (!_callbacks) {
        _callbacks = [NSMutableDictionary dictionary];
    }

    return _callbacks;
}


#pragma mark - SRWebSocketDelegate methods

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message {

    NSAssert(![NSThread isMainThread], @"Cannot parse HTTP response on the main thread!");

    NSData *messageData = [message dataUsingEncoding:NSUTF8StringEncoding];

    NSError *jsonParsingError;
    NSDictionary *messageDictionary = [NSJSONSerialization JSONObjectWithData:messageData
                                                         options:0
                                                           error:&jsonParsingError];

    if (!jsonParsingError) {
        NSError *deserializationError;
        MMCPEnvelope *envelopePayload = [MTLJSONAdapter modelOfClass:MMCPEnvelope.class
                                                  fromJSONDictionary:messageDictionary
                                                               error:&deserializationError];
        if (!deserializationError) {
            switch (envelopePayload.operationType) {

                case MMCPOperationTypeRequest:{
                    break;
                }
                case MMCPOperationTypeResponse:{
                    NSError *responseDeserializationError;
                    MMCPResponse *responsePayload = [MTLJSONAdapter modelOfClass:MMCPResponse.class
                                                              fromJSONDictionary:messageDictionary
                                                                           error:&responseDeserializationError];
                    if (!responseDeserializationError) {
                        typedef void(^SuccessBlock)(NSURLResponse *, id);
                        typedef void(^FailureBlock)(NSError *);

                        for (MMCPExecuteApiResCommand *responseCommand in responsePayload.commands) {
                            NSString *callbackId = [NSString stringWithFormat:@"%@-%@", responsePayload.requestId, responseCommand.commandId];
                            SuccessBlock successBlock = self.callbacks[callbackId][@"success"];
                            FailureBlock __unused failureBlock = self.callbacks[callbackId][@"failure"];
                            [self.callbacks removeObjectForKey:callbackId];

                            id responseDictionary = responseCommand.payload.body;
                            dispatch_async(dispatch_get_main_queue(), ^{
                                if (successBlock) {
                                    successBlock(nil, responseDictionary);
                                }
                            });
                        }
                    } else {

                    }
                    break;
                }
                case MMCPOperationTypeAckConnected:{
                    self.sessionId = envelopePayload.sessionId;
                    dispatch_semaphore_signal(self.semaphore);
                    break;
                }
                case MMCPOperationTypeAckReceived:break;
            };
        } else {
            // TODO: Log me
        }
    } else {
        // TODO: Log me
    }
}

- (void)webSocketDidOpen:(SRWebSocket *)webSocket {

}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error {
    NSLog(@"error = %@", error);
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean {

}

@end