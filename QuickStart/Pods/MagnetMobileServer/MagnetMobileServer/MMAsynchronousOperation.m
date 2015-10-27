/**
 * Copyright (c) 2012-2015 Magnet Systems, Inc. All rights reserved.
 */

#import "MMAsynchronousOperation.h"


@interface MMAsynchronousOperation ()

- (NSString *)isExecutingKey;

- (NSString *)isFinishedKey;

@end

@implementation MMAsynchronousOperation {
    BOOL _executing;
    BOOL _finished;
}

- (BOOL)isAsynchronous {
    return YES;
}

- (BOOL)isFinished {
    return _finished;
}

- (BOOL)isExecuting {
    return _executing;
}

- (void)start {
    [self willChangeValueForKey:[self isExecutingKey]];
    _executing = YES;
    [self didChangeValueForKey:[self isExecutingKey]];

    [self execute];
}

- (void)execute {
    // FIXME: Throw exception
    // Subclasses should override this method!
}

- (void)finish {
    [self willChangeValueForKey:[self isExecutingKey]];
    _executing = NO;
    [self didChangeValueForKey:[self isExecutingKey]];

    [self willChangeValueForKey:[self isFinishedKey]];
    _finished = YES;
    [self didChangeValueForKey:[self isFinishedKey]];
}

#pragma mark - Private implementation

- (NSString *)isExecutingKey {
    return NSStringFromSelector(@selector(isExecuting));
}

- (NSString *)isFinishedKey {
    return NSStringFromSelector(@selector(isFinished));
}

@end