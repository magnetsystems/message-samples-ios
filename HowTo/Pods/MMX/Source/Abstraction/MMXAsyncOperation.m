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

#import "MMXAsyncOperation.h"

@interface MMXAsyncOperation ()

- (NSString *)isExecutingKey;

- (NSString *)isFinishedKey;

@end

@implementation MMXAsyncOperation {
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
