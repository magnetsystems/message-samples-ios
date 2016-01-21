// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MMXOutboxEntry.h instead.

@import CoreData;

extern const struct MMXOutboxEntryAttributes {
	__unsafe_unretained NSString *creationTime;
	__unsafe_unretained NSString *message;
	__unsafe_unretained NSString *messageID;
	__unsafe_unretained NSString *messageOptions;
	__unsafe_unretained NSString *messageType;
	__unsafe_unretained NSString *username;
} MMXOutboxEntryAttributes;

@class NSObject;

@class NSObject;

@interface MMXOutboxEntryID : NSManagedObjectID {}
@end

@interface _MMXOutboxEntry : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) MMXOutboxEntryID* objectID;

@property (nonatomic, strong) NSDate* creationTime;

//- (BOOL)validateCreationTime:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) id message;

//- (BOOL)validateMessage:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* messageID;

//- (BOOL)validateMessageId:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) id messageOptions;

//- (BOOL)validateMessageOptions:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* messageType;

@property (atomic) int16_t messageTypeValue;
- (int16_t)messageTypeValue;
- (void)setMessageTypeValue:(int16_t)value_;

//- (BOOL)validateMessageType:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* username;

//- (BOOL)validateUsername:(id*)value_ error:(NSError**)error_;

@end

@interface _MMXOutboxEntry (CoreDataGeneratedPrimitiveAccessors)

- (NSDate*)primitiveCreationTime;
- (void)setPrimitiveCreationTime:(NSDate*)value;

- (id)primitiveMessage;
- (void)setPrimitiveMessage:(id)value;

- (NSString*)primitiveMessageId;
- (void)setPrimitiveMessageId:(NSString*)value;

- (id)primitiveMessageOptions;
- (void)setPrimitiveMessageOptions:(id)value;

- (NSNumber*)primitiveMessageType;
- (void)setPrimitiveMessageType:(NSNumber*)value;

- (int16_t)primitiveMessageTypeValue;
- (void)setPrimitiveMessageTypeValue:(int16_t)value_;

- (NSString*)primitiveUsername;
- (void)setPrimitiveUsername:(NSString*)value;

@end
