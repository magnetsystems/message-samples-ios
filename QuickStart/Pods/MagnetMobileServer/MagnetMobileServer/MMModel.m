/**
 * Copyright (c) 2012-2015 Magnet Systems, Inc. All rights reserved.
 */

#import <objc/runtime.h>
#import "MMModel.h"
#import "MMValueTransformer.h"
#import "MMUtilities.h"

@interface MMModel()

+ (NSValueTransformer *)transformerForClass:(Class)clazz
                                        key:(NSString *)key;

+ (Class)classFromPropertyType:(NSString *)propertyType;

+ (NSString *)propertyTypeAttributeForKey:(NSString *)key;

@end

@implementation MMModel

#pragma mark - MTLModel

// Removes all nil objects from the dictionary
//- (NSDictionary *)dictionaryValue {
//    NSMutableDictionary *modifiedDictionaryValue = [[super dictionaryValue] mutableCopy];
//
//    for (NSString *originalKey in [super dictionaryValue]) {
//        if ([self valueForKey:originalKey] == nil) {
//            [modifiedDictionaryValue removeObjectForKey:originalKey];
//        }
//    }
//
//    return [modifiedDictionaryValue copy];
//}

#pragma mark - MTLJSONSerializing

+ (NSDictionary *)attributeMappings {
    return [NSDictionary mtl_identityPropertyMapWithModel:self];
}

+ (NSDictionary *)listAttributeTypes {
    return nil;
}

+ (NSDictionary *)mapAttributeTypes {
    return nil;
}

+ (NSDictionary *)enumAttributeTypes {
    return nil;
}

+ (NSArray *)charAttributes {
    return nil;
}

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return [self attributeMappings];
}

//+ (Class)classForParsingJSONDictionary:(NSDictionary *)JSONDictionary {
//    NSString *magnetType = JSONDictionary[@"magnet-type"];
//    if (magnetType != nil) {
//        NSString *classString = [MMNodeMetaData metaDataWithMagnetTypeAsKeys][magnetType];
//        return NSClassFromString(classString);
//    }
//
//    //NSAssert(NO, @"No matching class for the JSON dictionary '%@'.", JSONDictionary);
//    NSMutableDictionary *temp = [NSMutableDictionary dictionaryWithDictionary:JSONDictionary];
//    [temp removeObjectForKey:@"magnet-type"];
//    JSONDictionary = [NSDictionary dictionaryWithDictionary:temp];
//    return self;
//}

+ (NSValueTransformer *)JSONTransformerForKey:(NSString *)key {
    NSString *typeAttribute = [self propertyTypeAttributeForKey:key];
    NSString *propertyType = [typeAttribute substringFromIndex:1];
    const char *rawPropertyType = [propertyType UTF8String];

    if (strcmp(rawPropertyType, @encode(char)) == 0) {
        if (![[self charAttributes] containsObject:key]) {
            return [MMValueTransformer booleanTransformer];
        }
    } else if (strcmp(rawPropertyType, @encode(unichar)) == 0) {
        return [MMValueTransformer unicharTransformer];
    } else if (strcmp(rawPropertyType, @encode(NSUInteger)) == 0) { // Enum case
        return [MMValueTransformer enumTransformerForContainerClass:[self enumAttributeTypes][key]];
    } else if ([typeAttribute hasPrefix:@"T@"]) {
        Class clazz = [self classFromPropertyType:typeAttribute];
        return [self transformerForClass:clazz key:key];
    }

    return nil;
}

#pragma mark - Private implementation

+ (NSValueTransformer *)transformerForClass:(Class)clazz
                                        key:(NSString *)key {
    if ([clazz isSubclassOfClass:[NSDate class]]) {
        return [MMValueTransformer dateTransformer];
    } else if ([clazz isSubclassOfClass:[NSURL class]]) {
        return [MMValueTransformer urlTransformer];
    } else if ([clazz isSubclassOfClass:[NSData class]]) {
        return [MMValueTransformer dataTransformer];
    } else if ([clazz isSubclassOfClass:[MMModel class]]) {
        return [MMValueTransformer resourceNodeTransformerForClass:clazz];
    } /* else if ([clazz isSubclassOfClass:[MMData class]]) {
        return [MMValueTransformer binaryDataTransformer];
    }*/ else if ([clazz isSubclassOfClass:[NSArray class]]) {
        MMServiceIOType type = [MMUtilities serviceTypeForClass:[self listAttributeTypes][key]];
        return [MMValueTransformer listTransformerForType:type clazz:[self listAttributeTypes][key]];
    } else if ([clazz isSubclassOfClass:[NSDictionary class]]) {
        MMServiceIOType type = [MMUtilities serviceTypeForClass:[self mapAttributeTypes][key]];
        return [MMValueTransformer mapTransformerForType:type clazz:[self mapAttributeTypes][key]];
    } else if ([clazz isSubclassOfClass:[NSDecimalNumber class]]) {
        return [MMValueTransformer bigDecimalTransformer];
    }
    return nil;
}

+ (Class)classFromPropertyType:(NSString *)propertyType {
    NSString * typeClassName = [propertyType substringWithRange:NSMakeRange(3, [propertyType length] - 4)];  //turns @"NSDate" into NSDate
    Class typeClass = NSClassFromString(typeClassName);
    return typeClass;
}

+ (NSString *)propertyTypeAttributeForKey:(NSString *)key {
    const char *keyAsChar = [key UTF8String];
    const char *propertyAttributesAsChar = property_getAttributes(class_getProperty([self class], keyAsChar));
    NSString *propertyAttributesString = [NSString stringWithUTF8String:propertyAttributesAsChar];
    NSArray *propertyAttributes = [propertyAttributesString componentsSeparatedByString:@","];
    NSString *propertyTypeAttribute = propertyAttributes[0];
    return propertyTypeAttribute;
}

@end