/*
* Copyright (c) 2016 Magnet Systems, Inc.
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

import UIKit

import MagnetMax

class ChannelObserver {
    
    
    //MARK: Public properties
    
    
    var channel : MMXChannel?
    weak var object : AnyObject?
    var selector : Selector?
}


public class ChannelManager {
    
    
    //MARK: Static properties
    
    
    public static let sharedInstance = ChannelManager()
    
    
    //MARK: Public properties
    
    public let formatter = DateFormatter()
    
    
    //MARK: Private properties
    
    
    private var channelObservers : [ChannelObserver] = []
    
    
    //MARK: - Public implementation
    
    
    public func addChannelMessageObserver(target : AnyObject, channel : MMXChannel?, selector : Selector) {
        if let ch = channel {
            removeChannelMessageObserver(target, channel: ch)
        }
        
        let observer = ChannelObserver.init()
        observer.object = target
        observer.channel = channel
        observer.selector = selector
        channelObservers.append(observer)
    }
    
    public func getLastMessageForChannel(channel: MMXChannel) -> String? {
        let name = identifierForChannel(channel)
        
        return MMUser.currentUser()?.extras["\(name)_last_message_id"]
    }
    
    public func getLastViewTimeForChannel(channel: MMXChannel) -> NSDate? {
        
        let name = identifierForChannel(channel)
        
        if let string = MMUser.currentUser()?.extras[name] {
            if let interval : NSTimeInterval = NSTimeInterval(string)  {
                return NSDate(timeIntervalSince1970: interval)
            }
        }
        
        return nil
    }
    
    public func identifierForChannel(channel: MMXChannel) -> String {
        let key = channel.channelID
        
        return key
    }
    
    public func saveLastViewTimeForChannel(channel: MMXChannel, date : NSDate) {
        saveLastViewTimeForChannel(channel, message: nil, date: date)
    }
    
    public func saveLastViewTimeForChannel(channel: MMXChannel, message : MMXMessage?, date : NSDate) {
        let name = identifierForChannel(channel)
        
        if let user = MMUser.currentUser() {
            user.extras[name] = "\(date.timeIntervalSince1970)"
            if let msg = message {
            user.extras["\(name)_last_message_id"] = msg.messageID
            }
            
            let updateRequest = MMUpdateProfileRequest.init(user: user)
            updateRequest.password = nil
            MMUser.updateProfile(updateRequest, success: { (user) -> Void in
                }, failure: { (error) -> Void in
                    print("[UPDATE] FAILED : \(error.localizedDescription)")
            })
        }
    }
    
    public func removeChannelMessageObserver(object : AnyObject) {
        
        channelObservers = channelObservers.filter({
            if $0.object !== object && $0.object != nil {
                return true
            }
            
            return false
        })
    }
    
    
    //MARK: - Private implementation
    
    
    @objc private func didReceiveMessage(notification: NSNotification) {
        let tmp : [NSObject : AnyObject] = notification.userInfo!
        let mmxMessage = tmp[MMXMessageKey] as! MMXMessage
        let channel = mmxMessage.channel
        
        let observers : [ChannelObserver] = channelObservers.filter({
            if $0.channel == channel || $0.channel == nil  {
                return true
            }
            
            return false
        })
        
        for observer in observers {
            guard let object = observer.object, let selector = observer.selector else {
                removeChannelMessageObserver(observer)
                continue
            }
            
            object.performSelector(selector, withObject:mmxMessage)
        }
    }
    
    private init() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didReceiveMessage:", name: MMXDidReceiveMessageNotification, object: nil)
    }
    
    private func removeChannelMessageObserver(observer : ChannelObserver) {
        channelObservers = channelObservers.filter({
            if $0 !== observer {
                return true
            }
            
            return false
        })
    }
    
    private func removeChannelMessageObserver(object : AnyObject, channel : MMXChannel) {
        channelObservers = channelObservers.filter({
            if ($0 !== object || $0.channel != channel) && $0.object != nil {
                return true
            }
            
            return false
        })
    }
}
