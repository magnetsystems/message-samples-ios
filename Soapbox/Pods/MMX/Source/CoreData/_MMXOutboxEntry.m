// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MMXOutboxEntry.m instead.

#import "_MMXOutboxEntry.h"

const struct MMXOutboxEntryAttributes MMXOutboxEntryAttributes = {
	.creationTime = @"creationTime",
	.message = @"message",
	.messageID = @"messageID",
	.messageOptions = @"messageOptions",
	.messageType = @"messageType",
	.username = @"username",
};

@implementation MMXOutboxEntryID
@end

@implementation _MMXOutboxEntry

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"OutboxEntry" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"OutboxEntry";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"OutboxEntry" inManagedObjectContext:moc_];
}

- (MMXOutboxEntryID*)objectID {
	return (MMXOutboxEntryID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];

	if ([key isEqualToString:@"messageTypeValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"messageType"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}

@dynamic creationTime;

@dynamic message;

@dynamic messageID;

@dynamic messageOptions;

@dynamic messageType;

- (int16_t)messageTypeValue {
	NSNumber *result = [self messageType];
	return [result shortValue];
}

- (void)setMessageTypeValue:(int16_t)value_ {
	[self setMessageType:@(value_)];
}

- (int16_t)primitiveMessageTypeValue {
	NSNumber *result = [self primitiveMessageType];
	return [result shortValue];
}

- (void)setPrimitiveMessageTypeValue:(int16_t)value_ {
	[self setPrimitiveMessageType:@(value_)];
}

@dynamic username;

@end

