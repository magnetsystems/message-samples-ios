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

#import "MMXTopic_Private.h"
#import "MMXUserProfile_Private.h"
#import "MMXUtils.h"
#import "NSString+XEP_0106.h"

@implementation MMXTopic

#pragma mark - Init Methods

- (instancetype)init {
    if (self = [super init]) {
        _nameSpace = @"*";
        _isCollection = NO;
        _publishPermissions = MMXPublishPermissionsAnyone;
        _maxItemsToBePersisted = -1;
    }
    return self;
}
+ (instancetype)topicWithName:(NSString *)name {
	MMXTopic * topic = [[MMXTopic alloc] init];
	topic.topicName = name;
	return topic;
}


+ (instancetype)topicWithName:(NSString *)name
			maxItemsToPersist:(int)maxItems
		   publishPermissions:(MMXPublishPermissions)publishPermissions {
	MMXTopic * topic = [MMXTopic topicWithName:name];
	topic.maxItemsToBePersisted = maxItems;
	topic.publishPermissions = publishPermissions;
	return topic;
}

+ (instancetype)topicFromQueryResult:(NSDictionary *)topicDict {
    MMXTopic * topic = [[MMXTopic alloc] init];
    topic.topicName = topicDict[@"topicName"];
	if (topicDict[@"userId"] && ![topicDict[@"userId"] isKindOfClass:[NSNull class]]) {
		topic.nameSpace = topicDict[@"userId"];
	}
	if (topicDict[@"creationDate"] && ![topicDict[@"creationDate"] isKindOfClass:[NSNull class]]) {
		topic.creationDate = [MMXUtils dateFromiso8601Format:topicDict[@"creationDate"]];
	}
	if (topicDict[@"creator"] && ![topicDict[@"creator"] isKindOfClass:[NSNull class]]) {
		NSString * username = [MMXUserID stripUsername:topicDict[@"creator"]];
		if ([MMXUtils objectIsValidString:username]) {
			topic.topicCreator = [MMXUserID userIDWithUsername:[username jidUnescapedString]];
		}
	}
    topic.isCollection = [topicDict[@"isCollection"] boolValue];
    topic.topicDescription = topicDict[@"description"];
	topic.publishPermissions = [MMXTopic publishPermissionsFromString:topicDict[@"publisherType"]];
    topic.isMuted = [topicDict[@"isPushMutedByUser"] boolValue];
    return topic;
}

+ (instancetype)topicFromNode:(NSString *)node {
    NSArray *splitTopic = [node componentsSeparatedByString:@"/"];
	if (splitTopic.count < 4) {
		return nil;
	}
	NSString * tempTopicName = splitTopic[3];
	NSMutableString * topicName = tempTopicName.mutableCopy;
	if (splitTopic.count > 4) {
		for (int i = 4; i < splitTopic.count; i++) {
			[topicName appendFormat:@"/%@",splitTopic[i]];
		}
	}
	MMXTopic * topic = [MMXTopic topicWithName:topicName];
	if ([splitTopic[2] isEqualToString:@"*"]) {
		topic.nameSpace = @"*";
	} else {
		topic.nameSpace = [splitTopic[2] jidUnescapedString];
	}
    return topic;
}

+ (instancetype)geoLocationTopicForUsername:(NSString *)username {
	MMXTopic * topic = [[MMXTopic alloc] init];
	topic.nameSpace = username;
	topic.topicName = @"com.magnet.geoloc";
	return topic;
}

#pragma mark - As Dictionary

- (NSDictionary *)dictionaryRepresentation {
    if  (!self.topicName) {
        return nil;
    }
    NSDictionary * options = @{@"maxItems":@(self.maxItemsToBePersisted),
                               @"description":self.topicDescription ? self.topicDescription :[NSNull null],
							   @"publisherType":[MMXTopic publishPermissionsAsString:self.publishPermissions],
							   @"subscribeOnCreate":@(YES)
                               };
    return @{@"topicName":self.topicName,
             @"isPersonal":@([self inUserNameSpace]),
             @"isCollection":@(self.isCollection),
             @"options":options
             };
}

- (NSDictionary *)dictionaryRepresentationForDeletion {
    if  (!self.topicName) {
        return nil;
    }
    return @{@"topicName":self.topicName,
             @"isPersonal":@([self inUserNameSpace]),
             };
}

- (NSDictionary *)dictionaryForTopicSummary {
    id username;
    if ([self inUserNameSpace]) {
        username = [self.nameSpace jidEscapedString];
    } else {
        username = [NSNull null];
    }

	return  @{@"userId":username,
			  @"topicName":self.topicName};
}

#pragma mark - Helper Methods

+ (NSString *)publishPermissionsAsString:(MMXPublishPermissions)publishPermissions {
	switch (publishPermissions) {
		case MMXPublishPermissionsAnyone:
			return @"anyone";
			break;
		case MMXPublishPermissionsSubscribers:
			return @"subscribers";
			break;
		case MMXPublishPermissionsOwnerOnly:
			return @"owner";
			break;
		default:
			return @"anyone";
			break;
	}
}

+ (MMXPublishPermissions)publishPermissionsFromString:(NSString *)publishPermissionsString {
	if ([publishPermissionsString isEqualToString:@"owner"]) {
		return MMXPublishPermissionsOwnerOnly;
	} else if ([publishPermissionsString isEqualToString:@"subscribers"]) {
		return MMXPublishPermissionsSubscribers;
	} else {
		return MMXPublishPermissionsAnyone;
	}
}

- (NSString *)nameSpace {
	return _nameSpace ? _nameSpace : @"*";
}

- (NSString *)identifier {
	return [NSString stringWithFormat:@"/%@/%@",[self nameSpace], [self topicName]];
}

- (BOOL)isValid:(NSError **)error {
	NSRange range = [self.topicName rangeOfString:@"/"];
	
	if (range.location != NSNotFound) {
		if (error != NULL) {
			*error = [MMXUtils mmxErrorWithTitle:@"Invalid Name" message:@"Name cannot contain the / character." code:500];
		}
		return NO;
	}
	if (![MMXUtils validateAgainstDefaultCharacterSet:self.topicName allowSpaces:NO]) {
		if (error != NULL) {
			*error = [MMXUtils mmxErrorWithTitle:@"Invalid Name" message:@"The name contains invalid characters." code:500];
		}
		return NO;
	}
	if (self.topicName.length > 50 || self.topicName.length < 1) {
		if (error != NULL) {
			*error = [MMXUtils mmxErrorWithTitle:@"Invalid Name" message:@"Name cannot contain more than 50 characters or less than 1." code:500];
		}
		return NO;
	}

	return YES;
}

#pragma mark - Equality

- (BOOL)isEqual:(id)other {
	if (other == self)
		return YES;
	if (!other || ![[other class] isEqual:[self class]])
		return NO;
	
	return [self isEqualToTopic:other];
}

- (BOOL)isEqualToTopic:(MMXTopic *)topic {
	if (self == topic)
		return YES;
	if (topic == nil)
		return NO;
	if (self.topicName != topic.topicName && ![self.topicName.lowercaseString isEqualToString:topic.topicName.lowercaseString])
		return NO;
	if (self.nameSpace != topic.nameSpace && ![self.nameSpace.lowercaseString isEqualToString:topic.nameSpace.lowercaseString])
		return NO;
	return YES;
}

- (NSUInteger)hash {
	NSUInteger hash = [self.topicName hash];
	hash = hash * 31u + [self.nameSpace hash];
	return hash;
}

#pragma mark - NSCoding

- (id)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        self.topicName = [coder decodeObjectForKey:@"self.topicName"];
        self.topicDescription = [coder decodeObjectForKey:@"self.topicDescription"];
        self.nameSpace = [coder decodeObjectForKey:@"self.nameSpace"];
        self.maxItemsToBePersisted = [coder decodeIntForKey:@"self.maxItemsToBePersisted"];
        self.publishPermissions = (MMXPublishPermissions) [coder decodeIntForKey:@"self.publishPermissions"];
        self.isCollection = [coder decodeBoolForKey:@"self.isCollection"];
    }

    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.topicName forKey:@"self.topicName"];
    [coder encodeObject:self.topicDescription forKey:@"self.topicDescription"];
    [coder encodeObject:self.nameSpace forKey:@"self.nameSpace"];
    [coder encodeInt:self.maxItemsToBePersisted forKey:@"self.maxItemsToBePersisted"];
    [coder encodeInt:self.publishPermissions forKey:@"self.publishPermissions"];
    [coder encodeBool:self.isCollection forKey:@"self.isCollection"];
}

- (BOOL)inUserNameSpace {
	if (self.nameSpace && ![self.nameSpace isEqualToString:@""] && ![self.nameSpace isEqualToString:@"*"]) {
		return YES;
	}
	return NO;
}

- (id)copyWithZone:(NSZone *)zone {
	MMXTopic *copy = [[[self class] allocWithZone:zone] init];
	if (copy != nil) {
		copy.topicName = self.topicName;
		copy.topicDescription = self.topicDescription;
		copy.nameSpace = self.nameSpace;
		copy.maxItemsToBePersisted = self.maxItemsToBePersisted;
		copy.publishPermissions = self.publishPermissions;
		copy.isCollection = self.isCollection;
	}
	return copy;
}

@end
