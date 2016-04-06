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

#import "MMXWhitelistOperation.h"
#import "MMXClient_Private.h"
#import "XMPPIQ+XEP_0060.h"
#import "DDXML.h"
#import "XMPP.h"
#import "XMPPJID+MMX.h"
#import "MMXIQResponse.h"
#import "MMXConstants.h"
#import "MMXClient.h"
#import "MMXChannel.h"
#import "MMUser.h"

@interface MMXWhitelistOperation ()

@property(nonatomic, copy) void (^completion)(NSError *error);
@property(nonnull, copy) NSString *nodeID;

@end

@implementation MMXWhitelistOperation

- (instancetype)init:(MMXClient *)client channel:(MMXChannel *)channel users:(NSArray<MMUser*>*)users makeMember:(BOOL)makeMember completion : (void (^) (NSError * __nullable error)) completion {
    if (self = [super init]) {
        _users = users;
        _makeMember = makeMember;
        _completion = completion;
        _client = client;
        NSString *nameSpace = channel.isPublic ? @"*" : channel.ownerUserID;
        self.nodeID = [NSString stringWithFormat:@"/%@/%@/%@", self.client.appID, nameSpace, channel.name.lowercaseString];
        
    }
    
    return self;
}

- (void) execute {
    
    XMPPIQ *pushIQ = [[XMPPIQ alloc] initWithType:@"set" child:nil];
    
    NSString *messageID = [self.client generateMessageID];
    [pushIQ addAttributeWithName:@"from" stringValue:[[self.client currentJID] full]];
    [pushIQ addAttributeWithName:@"id" stringValue:messageID];
    [pushIQ addAttributeWithName:@"to" stringValue:@"pubsub.mmx"];
    DDXMLElement *mmxElement = [[DDXMLElement alloc] initWithName:@"pubsub" xmlns:XMLNS_PUBSUB_OWNER];
    DDXMLElement *affiliations = [[DDXMLElement alloc] initWithName:@"affiliations"];
    
    [affiliations addAttributeWithName:@"node" stringValue:self.nodeID];
    [mmxElement addChild:affiliations];
    [pushIQ addChild:mmxElement];
    NSString *affiliationValue = self.makeMember ? @"member" : @"outcast";
    
    for (MMUser* user in self.users) {
        DDXMLElement *affiliation = [[DDXMLElement alloc]  initWithName:@"affiliation"];
        NSString *username = [NSString stringWithFormat:@"%@%%%@",[user userID], self.client.appID];
        XMPPJID *userAddress = [XMPPJID jidWithUser:username domain:[[self.client currentJID] domain] resource:nil];
        [affiliation addAttributeWithName:@"jid" stringValue:userAddress.full];
        [affiliation addAttributeWithName:@"affiliation" stringValue:affiliationValue];
        [affiliations addChild:affiliation];
    }
    
    
    NSLog(@"iq --- %@", pushIQ.XMLString);
    [self.client sendIQ:pushIQ completion:^(id obj, id<XMPPTrackingInfo> info) {
        if (obj) {
            XMPPIQ * iq = (XMPPIQ *)obj;
            NSLog(@"return iq --- %@", iq.XMLString);
            
            DDXMLElement *errorElement = iq.childErrorElement;
            if (!errorElement) {
                self.completion(nil);
            } else {
                NSDictionary *userInfo = @{
                                           NSLocalizedDescriptionKey: NSLocalizedString(@"Error setting whitelist", nil)
                                           };
                NSError *error = [NSError errorWithDomain:MMXErrorDomain code:(NSInteger)[errorElement attributeForName:@"code"] userInfo:userInfo];
                self.completion(error);
            }
            [self finish];
        } else {
            NSError * error = [MMXClient errorWithTitle:@"IQ Error" message:@"Timed Out" code:401];
            self.completion(error);
            [self finish];
        }
    }];
}

@end
