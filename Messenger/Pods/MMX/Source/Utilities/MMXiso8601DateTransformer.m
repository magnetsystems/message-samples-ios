/**
 * Copyright (c) 2012-2015 Magnet Systems, Inc. All rights reserved.
 */

#import "MMXiso8601DateTransformer.h"

@implementation MMXiso8601DateTransformer

+ (Class)transformedValueClass {
	return [NSDate class];
}

+ (BOOL)allowsReverseTransformation {
	return YES;
}

- (NSDate *)transformedValue:(NSString *)dateString {
	return [[MMXiso8601DateTransformer dateFormatter] dateFromString:dateString];
}

- (NSString *)reverseTransformedValue:(NSDate *)date {
	return [[MMXiso8601DateTransformer dateFormatter] stringFromDate:date];
}

+ (NSDateFormatter *)dateFormatter {
	static NSDateFormatter *__dateFormatter = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		__dateFormatter = [[NSDateFormatter alloc] init];
		[__dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
		__dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'";
	});
	return __dateFormatter;
}
@end
