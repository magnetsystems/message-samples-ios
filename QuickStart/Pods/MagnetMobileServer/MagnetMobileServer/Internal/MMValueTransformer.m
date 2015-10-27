/**
 * Copyright (c) 2012-2015 Magnet Systems, Inc. All rights reserved.
 */
 
#import <Mantle/Mantle.h>
#import "MMValueTransformer.h"
#import "MMEnumAttributeContainer.h"
#import "MMUtilities.h"
//#import "MMResourceNode.h"
//#import "MMData.h"
//#import "MMAssert.h"

@interface MMValueTransformer ()

+ (NSDateFormatter *)dateFormatter;

@end

@implementation MMValueTransformer

+ (instancetype)dateTransformer {
    // Cast to id is required to suppress the warning
    id transformer = [MTLValueTransformer reversibleTransformerWithForwardBlock:^(NSString *str) {
        return [[self dateFormatter] dateFromString:str];
    } reverseBlock:^(NSDate *date) {
        return [[self dateFormatter] stringFromDate:date];
    }];
    return transformer;
}

+ (instancetype)urlTransformer {
    return (MMValueTransformer *) [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

+ (instancetype)dataTransformer {
    // Cast to id is required to suppress the warning
    id transformer = [MTLValueTransformer reversibleTransformerWithForwardBlock:^(NSString *str) {
        return [[NSData alloc] initWithBase64EncodedString:str options:(NSDataBase64DecodingOptions) kNilOptions];
    } reverseBlock:^(NSData *value) {
        return [value base64EncodedStringWithOptions:(NSDataBase64EncodingOptions) kNilOptions];
    }];
    return transformer;
}

+ (instancetype)unicharTransformer {
    // Cast to id is required to suppress the warning
    id transformer = [MTLValueTransformer reversibleTransformerWithForwardBlock:^(NSString *str) {
        unichar val = 0;
        if (str.length > 0) {
            val = [str characterAtIndex:0];
        }
        return @(val);
    } reverseBlock:^(NSNumber *value) {
        return [NSString stringWithFormat:@"%C", [value unsignedShortValue]];
    }];
    return transformer;
}

+ (instancetype)floatTransformer {
    // Cast to id is required to suppress the warning
    id transformer = [MTLValueTransformer reversibleTransformerWithForwardBlock:^(NSNumber *jsonValue) {
        return [NSString stringWithFormat:@"%f", [jsonValue floatValue]];
    } reverseBlock:^(NSNumber *value) {
        return [NSString stringWithFormat:@"%f", [value floatValue]];
    }];
    return transformer;
}

+ (instancetype)doubleTransformer {
    // Cast to id is required to suppress the warning
    id transformer = [MTLValueTransformer reversibleTransformerWithForwardBlock:^(NSNumber *jsonValue) {
        return [NSString stringWithFormat:@"%f", [jsonValue doubleValue]];
    } reverseBlock:^(NSNumber *value) {
        return [NSString stringWithFormat:@"%f", [value doubleValue]];
    }];
    return transformer;
}

+ (instancetype)longLongTransformer {
    // Cast to id is required to suppress the warning
    id transformer = [MTLValueTransformer reversibleTransformerWithForwardBlock:^(NSNumber *jsonValue) {
        long long longLongNumber = [[jsonValue description] longLongValue];
        return [NSString stringWithFormat:@"%lli", longLongNumber];
    } reverseBlock:^(NSNumber *value) {
        long long longLongNumber = [[value description] longLongValue];
        return [NSString stringWithFormat:@"%lli", longLongNumber];
    }];
    return transformer;
}

+ (instancetype)booleanTransformer {
    return (MMValueTransformer *) [NSValueTransformer valueTransformerForName:MTLBooleanValueTransformerName];
}

+ (instancetype)enumTransformerForContainerClass:(Class<MMEnumAttributeContainer>)containerClass {
    NSDictionary *mappings = [containerClass mappings];
    return (MMValueTransformer *) [NSValueTransformer mtl_valueMappingTransformerWithDictionary:mappings];
}


+ (instancetype)resourceNodeTransformerForClass:(Class)clazz {

    return (MMValueTransformer *) [NSValueTransformer mtl_JSONDictionaryTransformerWithModelClass:clazz];
}

+ (instancetype)listTransformerForType:(MMServiceIOType)type clazz:(Class)clazz {
    // Cast to id is required to suppress the warning
    id transformer = [MTLValueTransformer reversibleTransformerWithForwardBlock:^(NSArray *values) {
        NSMutableArray *mutableArray;
        if (values) {
            mutableArray = [NSMutableArray arrayWithCapacity:values.count];
        }
        for (id obj in values) {
            id objectToAdd = obj;
            MMValueTransformer *valueTransformer = [self transformerForType:type clazz:clazz];
            if (valueTransformer) {
                objectToAdd = [valueTransformer transformedValue:obj];
            }
            [mutableArray addObject:objectToAdd];
        }

        return [mutableArray copy];
    } reverseBlock:^(NSArray *values) {
        NSMutableArray *mutableArray;
        if (values) {
            mutableArray = [NSMutableArray arrayWithCapacity:values.count];
        }
        for (id obj in values) {
            id objectToAdd = obj;
            MMValueTransformer *valueTransformer = [self transformerForType:type clazz:clazz];
            if (valueTransformer) {
                objectToAdd = [valueTransformer reverseTransformedValue:obj];
            }
            [mutableArray addObject:objectToAdd];
        }
        return [mutableArray copy];
    }];
    return transformer;
}

+ (instancetype)mapTransformerForType:(MMServiceIOType)type clazz:(Class)clazz {
    // Cast to id is required to suppress the warning
    id transformer = [MTLValueTransformer reversibleTransformerWithForwardBlock:^(NSDictionary *values) {
        NSMutableDictionary *mutableDictionary;
        if (values) {
            mutableDictionary = [NSMutableDictionary dictionaryWithCapacity:values.count];
        }
        [values enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            id objectToAdd = obj;
            MMValueTransformer *valueTransformer = [self transformerForType:type clazz:clazz];
            if (valueTransformer) {
                objectToAdd = [valueTransformer transformedValue:obj];
            }
            mutableDictionary[key] = objectToAdd;
        }];

        return [mutableDictionary copy];
    } reverseBlock:^(NSDictionary *values) {
        NSMutableDictionary *mutableDictionary;
        if (values) {
            mutableDictionary = [NSMutableDictionary dictionaryWithCapacity:values.count];
        }
        [values enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            id objectToAdd = obj;
            MMValueTransformer *valueTransformer = [self transformerForType:type clazz:clazz];
            if (valueTransformer) {
                objectToAdd = [valueTransformer reverseTransformedValue:obj];
            }
            mutableDictionary[key] = objectToAdd;
        }];

        return [mutableDictionary copy];
    }];
    return transformer;
}

+ (instancetype)bigDecimalTransformer {
    // Cast to id is required to suppress the warning
    id transformer = [MTLValueTransformer reversibleTransformerWithForwardBlock:^(NSString *jsonValue) {
        return [NSDecimalNumber decimalNumberWithString:jsonValue];
    } reverseBlock:^(NSDecimalNumber *value) {
        return [value stringValue];
    }];
    return transformer;
}


+ (instancetype)transformerForType:(MMServiceIOType)type clazz:(Class)clazz {

    MMValueTransformer *valueTransformer;

    switch (type) {
        case MMServiceIOTypeVoid:break;
        case MMServiceIOTypeString:break;
        case MMServiceIOTypeEnum:{
            valueTransformer = [self enumTransformerForContainerClass:clazz];
            break;
        }
        case MMServiceIOTypeBoolean:break;
        case MMServiceIOTypeChar:break;
        case MMServiceIOTypeUnichar:break;
        case MMServiceIOTypeShort:break;
        case MMServiceIOTypeInteger:break;
        case MMServiceIOTypeLongLong:break;
        case MMServiceIOTypeFloat:break;
        case MMServiceIOTypeDouble:break;
        case MMServiceIOTypeBigDecimal:
        case MMServiceIOTypeBigInteger:{
            valueTransformer = [MMValueTransformer bigDecimalTransformer];
            break;
        }
        case MMServiceIOTypeDate:{
            valueTransformer = [MMValueTransformer dateTransformer];
            break;
        }
        case MMServiceIOTypeUri:{
            valueTransformer = [MMValueTransformer urlTransformer];
            break;
        }
        case MMServiceIOTypeArray:{
            MMServiceIOType serviceType = [MMUtilities serviceTypeForClass:clazz];
            valueTransformer = [self listTransformerForType:serviceType clazz:clazz];
            break;
        }
        case MMServiceIOTypeDictionary:{
            MMServiceIOType serviceType = [MMUtilities serviceTypeForClass:clazz];
            valueTransformer = [self mapTransformerForType:serviceType clazz:clazz];
            break;
        }
        case MMServiceIOTypeData:break;
        case MMServiceIOTypeBytes:break;
        case MMServiceIOTypeMagnetNode:{
            valueTransformer = [self resourceNodeTransformerForClass:clazz];
            break;
        }
    };

    return valueTransformer;
}

#pragma mark - Private implementation

+ (NSDateFormatter *)dateFormatter {
    static NSDateFormatter *__dateFormatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __dateFormatter = [[NSDateFormatter alloc] init];
        __dateFormatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
        [__dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
        __dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'";
    });
    return __dateFormatter;
}

@end
