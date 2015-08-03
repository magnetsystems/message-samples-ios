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

#import "MMXConfiguration.h"
#import "MMXAssert.h"
#import "MMXConfigurationRegistry.h"


@implementation MMXConfiguration

+ (instancetype)configurationWithName:(NSString *)name {

    MMXParameterAssert(name);

    NSDictionary *endpointDict = [MMXConfigurationRegistry sharedConfigurationRegistry][name];
    MMXConfiguration *controllerConfiguration = [[self alloc] initWithBaseURL:[NSURL URLWithString:endpointDict[@"BaseURL"]]];
    controllerConfiguration.appID = endpointDict[@"AppId"];
    controllerConfiguration.apiKey = endpointDict[@"ApiKey"];
    controllerConfiguration.anonymousSecret = endpointDict[@"AnonymousSecret"];
    controllerConfiguration.shouldForceTLS = [endpointDict[@"ShouldForceTLS"] boolValue];
    controllerConfiguration.allowInvalidCertificates = [endpointDict[@"AllowInvalidCertificates"] boolValue];
	if (endpointDict[@"DomainName"] && ![endpointDict[@"DomainName"] isEqualToString:@""]) {
		controllerConfiguration.domain = endpointDict[@"DomainName"];
	}
	if (endpointDict[@"PublicAPIPort"]) {
		controllerConfiguration.publicAPIPort = [endpointDict[@"PublicAPIPort"] integerValue];;
	}
	MMXAssert(![controllerConfiguration.appID isEqualToString:@"Invalid"],@"You must have a valid Configurations.plist file. You can download this file on the Settings page of the Magnet Message Web Interface.");

	MMXAssert(controllerConfiguration.appID != nil && ![controllerConfiguration.appID isEqualToString:@""],@"MMXConfiguration appID cannot be nil");
	MMXAssert(controllerConfiguration.apiKey != nil && ![controllerConfiguration.apiKey isEqualToString:@""],@"MMXConfiguration apiKey cannot be nil");
	MMXAssert(controllerConfiguration.anonymousSecret != nil && ![controllerConfiguration.anonymousSecret isEqualToString:@""],@"MMXConfiguration anonymousSecret cannot be nil");
	MMXAssert(controllerConfiguration.baseURL != nil,@"MMXConfiguration baseURL cannot be nil");

    return controllerConfiguration;
}

- (instancetype)initWithBaseURL:(NSURL *)baseURL {

    MMXParameterAssert(baseURL);

    self = [super init];
    if (self) {
		self.baseURL = baseURL;
		self.publicAPIPort = 5220;
        self.shouldForceTLS = YES;
        self.allowInvalidCertificates = NO;
    }
    return self;
}

- (NSString *)domain {
	return _domain ?: @"mmx";
}

#pragma mark - Equality

- (BOOL)isEqual:(id)other {
    if (other == self)
        return YES;
    if (!other || ![[other class] isEqual:[self class]])
        return NO;

    return [self isEqualToConfiguration:other];
}

- (BOOL)isEqualToConfiguration:(MMXConfiguration *)configuration {
    if (self == configuration)
        return YES;
    if (configuration == nil)
        return NO;
    if (self.appID != configuration.appID && ![self.appID isEqualToString:configuration.appID])
        return NO;
    if (self.apiKey != configuration.apiKey && ![self.apiKey isEqualToString:configuration.apiKey])
        return NO;
    if (self.anonymousSecret != configuration.anonymousSecret && ![self.anonymousSecret isEqualToString:configuration.anonymousSecret])
        return NO;
    if (self.baseURL != configuration.baseURL && ![self.baseURL isEqual:configuration.baseURL])
        return NO;
    if (self.shouldUseCredentialStorage != configuration.shouldUseCredentialStorage)
        return NO;
	if (self.credential != configuration.credential && ![self.credential isEqual:configuration.credential])
		return NO;
	if (self.publicAPIPort != configuration.publicAPIPort)
		return NO;
    if (self.allowInvalidCertificates != configuration.allowInvalidCertificates)
        return NO;
	if (self.shouldForceTLS != configuration.shouldForceTLS)
		return NO;
	if (self.domain != configuration.domain)
		return NO;
    return YES;
}

- (NSUInteger)hash {
    NSUInteger hash = [self.appID hash];
    hash = hash * 31u + [self.apiKey hash];
    hash = hash * 31u + [self.anonymousSecret hash];
    hash = hash * 31u + [self.baseURL hash];
    hash = hash * 31u + self.shouldUseCredentialStorage;
    hash = hash * 31u + [self.credential hash];
	hash = hash * 31u + self.allowInvalidCertificates;
	hash = hash * 31u + self.publicAPIPort;
	hash = hash * 31u + self.shouldForceTLS;
	hash = hash * 31u + [self.domain hash];
    return hash;
}


#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone {
    MMXConfiguration *copy = [[[self class] allocWithZone:zone] init];

    if (copy != nil) {
        copy.appID = self.appID;
        copy.apiKey = self.apiKey;
        copy.anonymousSecret = self.anonymousSecret;
        copy.baseURL = self.baseURL;
        copy.shouldUseCredentialStorage = self.shouldUseCredentialStorage;
        copy.credential = self.credential;
		copy.publicAPIPort = self.publicAPIPort;
		copy.shouldForceTLS = self.shouldForceTLS;
		copy.allowInvalidCertificates = self.allowInvalidCertificates;
		copy.domain = self.domain;
    }

    return copy;
}


@end