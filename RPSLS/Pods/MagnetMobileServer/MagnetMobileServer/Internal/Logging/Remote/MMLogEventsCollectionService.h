/**
 * Copyright (c) 2012-2015 Magnet Systems, Inc. All rights reserved.
 */

#import <Foundation/Foundation.h>
#import "MMService.h"

@class MMLogEvent;
@class MMData;
@class MMCall;

@protocol MMLogEventsCollectionServiceProtocol <NSObject>

@optional
/**
 
 POST /api/collections/events/batch
 @param file style:QUERY
 @param options
 */
- (MMCall *)addEventsFromFile:(MMData *)file
                      success:(void (^)())success
                      failure:(void (^)(NSError *error))failure;
/**
 
 POST /api/collections/events
 @param body style:BODY
 @param options
 */
- (MMCall *)addEvents:(NSArray *)body
              success:(void (^)(BOOL response))success
              failure:(void (^)(NSError *error))failure;

@end

@interface MMLogEventsCollectionService : MMService<MMLogEventsCollectionServiceProtocol>

@end
