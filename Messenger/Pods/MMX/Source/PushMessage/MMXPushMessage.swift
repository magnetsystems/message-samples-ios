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


import MagnetMaxCore
import UIKit

struct LoggedInCondition: OperationCondition {
    static let name = "LoggedInCondition"
    static let isMutuallyExclusive = false
    
    func dependencyForOperation(operation: Operation) -> NSOperation? {
        return nil
    }
    
    func evaluateForOperation(operation: Operation, completion: OperationConditionResult -> Void) {
        
        if MMXClient.sharedClient().connectionStatus == .Authenticated {
            completion(.Satisfied)
        } else {
            let error = NSError(code: .ConditionFailed, userInfo: [
                OperationConditionKey: self.dynamicType.name,
                ])
            
            completion(.Failed(error))
        }
    }
    
}

extension MMXChannel {
    public class func subscriptionsWithSuccess(success: (([MMXChannel]) -> Void)?, failure: ((NSError) -> Void)?) -> NSOperation? {
        var groupOperation = GroupOperation(operations: [])
        
        groupOperation.addCondition(LoggedInCondition())
        
        var _subscriptions: [MMXTopicSubscription] = []
        let listSubscriptionsOperation = BlockOperation { continuation in
            MMXClient.sharedClient().pubsubManager.listSubscriptionsWithSuccess({ subscriptions in
                _subscriptions = subscriptions
                continuation()
            }, failure: { error in
                groupOperation.aggregateError(error)
                continuation()
            })
        }
        
        var _topics: [MMXTopic] = []
        let topicsFromTopicSubscriptionsOperation = BlockOperation { continuation in
            guard _subscriptions.count > 0 else {
                continuation()
                return
            }
            MMXClient.sharedClient().pubsubManager.topicsFromTopicSubscriptions(_subscriptions, success: { topics in
                _topics = topics
                continuation()
            }, failure: { error in
                groupOperation.aggregateError(error)
                continuation()
            })
        }
        topicsFromTopicSubscriptionsOperation.addDependency(listSubscriptionsOperation)
        
        var _channels: [MMXChannel] = []
        let summaryOfTopicsOperation = BlockOperation { continuation in
            guard _subscriptions.count > 0 && _topics.count > 0 else {
                continuation()
                return
            }
            MMXClient.sharedClient().pubsubManager.summaryOfTopics(_topics, since: nil, until: nil, success: { summaries in
                _channels = MMXChannel.channelsFromTopics(_topics, summaries: summaries, subscriptions: _subscriptions)
                continuation()
            }, failure: { error in
                groupOperation.aggregateError(error)
                continuation()
            })
        }
        summaryOfTopicsOperation.addDependency(topicsFromTopicSubscriptionsOperation)
        
        groupOperation.addOperations([listSubscriptionsOperation, topicsFromTopicSubscriptionsOperation, summaryOfTopicsOperation])
        
        let groupOperationObserver = BlockObserver(startHandler: nil, produceHandler: nil) { operation, errors in
            if errors.count > 0 {
                failure?(errors.last!)
            } else {
                success?(_channels)
            }
        }
        
        groupOperation.addObserver(groupOperationObserver)
        
       // OperationQueue().addOperation(groupOperation)
        
        return groupOperation
    }
}


@objc public class MMXPushMessage : NSObject {
    
    
    //********************************************************************************
    // MARK: Public Properies
    //********************************************************************************
    
    
    public var recipients : Set<MMUser>?
    
    
    //********************************************************************************
    // MARK: Read-only Properies
    //********************************************************************************
    
    
    // message content dictionary contains the actual values that will be sent via push
    private(set) public var messageContent : Dictionary<String, String>?
    
    // the following properties reflect the values stored in message content
    private(set) public var body : String?
    private(set) public var title : String?
    private(set) public var badge : String?
    private(set) public var sound : String?
    private(set) public var userDefinedObjects : Dictionary<String, String>?
    
    
    //********************************************************************************
    // MARK: Initializers
    //********************************************************************************
    
    
    /**
    The designated initializer.
    */
    public override init() {
        super.init()
    }
    
    /**
     Convience initializer.
     
     - parameter Dictionary: The Remote Dictionary is the UserInfo recieved from a push notification.
     */
    convenience public init(pushUserInfo : NSDictionary) {
        self.init()
        let mmxDictionary : Dictionary? = pushUserInfo["_mmx"] as? Dictionary<String, AnyObject>;
        let apsDictionary : AnyObject? = pushUserInfo["aps"];
        var messageContent : Dictionary = [String : String]()
        
        if let mmx = mmxDictionary {
            if let mmxCustom : Dictionary<String, AnyObject> = mmx["custom"] as? Dictionary<String, AnyObject> {
                for ( key, value ) in mmxCustom {
                    messageContent[key] = "\(value)"
                }
            }
            
            let userObjects = messageContent
            self.userDefinedObjects = userObjects
        } else {
            
            return
        }
        
        if let aps = apsDictionary as? Dictionary<String, AnyObject> {
            
            if let alert : String = aps["alert"] as? String {
                self.body = alert
                messageContent["body"] = alert
            } else {
                
                if let body : String = aps["alert"]?["body"] as? String {
                    self.body = body
                    messageContent["body"] = body
                }
                
                if let title : String = aps["alert"]?["title"] as? String {
                    self.title = title
                    messageContent["title"] = title
                    if self.body == nil {
                        self.body = self.title
                    }
                }
            }
            if let badge : Int = aps["badge"] as? Int {
                self.badge = "\(badge)"
                messageContent["badge"] = self.badge!
            }
            if let sound : String = aps["sound"] as? String {
                self.sound = sound
                messageContent["sound"] = sound
            }
        }
        
        self.messageContent = messageContent
    }
    
    
    //********************************************************************************
    // MARK: Factory Methods
    //********************************************************************************
    
    
    /**
    Factory Methods for generating a push message.
    
    - parameter Dictionary: The Remote Dictionary is the UserInfo recieved from a push notification.
    
    - Returns: a new MMXPushMessage object
    */
    public class func pushMessageWithRecipients(recipients : Set <MMUser>, body : String) -> MMXPushMessage {
        return pushMessageWithRecipients(recipients, body: body, title : nil, sound: nil, badge: nil, userDefinedObjects: nil)
    }
    
    public class func pushMessageWithRecipients(recipients : Set <MMUser>, body : String, title : String?, sound : String?, badge : NSNumber?) -> MMXPushMessage {
        return pushMessageWithRecipients(recipients, body: body, title : title, sound: sound, badge: badge, userDefinedObjects: nil)
    }
    
    public class func pushMessageWithRecipients(recipients : Set <MMUser>, body : String, title : String?, sound : String?, badge : NSNumber?, userDefinedObjects : Dictionary<String, String>?) -> MMXPushMessage {
        
        var messageContent : Dictionary = [String : String]()
        
        let msg: MMXPushMessage = MMXPushMessage.init()
        msg.userDefinedObjects = userDefinedObjects
        
        if let userObjects = userDefinedObjects {
            for ( key, value ) in userObjects {
                messageContent[key] = value
            }
        }
        
        messageContent["body"] = body
        msg.body = body
        
        if let _ = title {
            messageContent["title"] = title
            msg.title = title
        }
        
        if let _ = sound {
            messageContent["sound"] = sound
            msg.sound = sound
        }
        
        if let _ = badge {
            messageContent["badge"] = badge?.stringValue
            msg.badge = badge?.stringValue
        }
        
        
        msg.messageContent = messageContent
        msg.recipients = recipients
        
        return msg
    }
    
    public class func pushMessageWithRecipient(recipient : MMUser, body : String) -> MMXPushMessage {
        return pushMessageWithRecipients([recipient], body: body)
    }
    
    public class func pushMessageWithRecipient(recipient : MMUser, body : String, title : String, sound : String?, badge : NSNumber?) -> MMXPushMessage {
        return pushMessageWithRecipients([recipient], body: body, title : title, sound: sound, badge: badge)
    }
    
    public class func pushMessageWithRecipient(recipient : MMUser, body : String, title : String, sound : String?, badge : NSNumber?, userDefinedObjects : Dictionary<String, String>?) -> MMXPushMessage {
        return pushMessageWithRecipients([recipient], body: body, title : title, sound: sound, badge: badge, userDefinedObjects: userDefinedObjects)
    }
    
    
    //********************************************************************************
    // MARK: Public Methods
    //********************************************************************************
    
    
    /**
    Sends the push message.
    
    - parameters:
    - success: a closure to run upon success
    - failure: a closure to run upon failure
    
    - Returns: a new MMXPushMessage object
    */
    public func sendPushMessage(success : (() -> Void)?, failure : ((error : NSError) -> Void)?) {
        if MMXMessageUtils.isValidMetaData(self.messageContent) == false {
            let error : NSError = MMXClient.errorWithTitle("Not Valid", message: "All values must be strings.", code: 401)
            failure?(error : error)
        }
        
        if MMUser.currentUser() == nil {
            let error : NSError = MMXClient.errorWithTitle("Not Logged In", message: "You must be logged in to send a message.", code: 401)
            failure?(error : error)
        }
        
        MagnetDelegate.sharedDelegate().sendPushMessage(self, success: { (invalidDevices : Set<NSObject>!) -> Void in
            success?()
            }, failure: { error in
                failure?(error: error)
        });
    }
    
}
