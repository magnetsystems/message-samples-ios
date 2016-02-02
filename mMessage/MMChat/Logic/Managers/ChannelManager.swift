//
//  ChannelManager.swift
//  MMChat
//
//  Created by Kostya Grishchenko on 1/19/16.
//  Copyright © 2016 Kostya Grishchenko. All rights reserved.
//

import UIKit
import MagnetMax

class ChannelObserver : NSObject {
    var channel : MMXChannel?
    weak var object : AnyObject?
    var selector : Selector?
}

class ChannelManager {
    
    static let sharedInstance = ChannelManager()
    
    let formatter = DateFormatter()
    var channels : [MMXChannel]?
    var channelDetails : [MMXChannelDetailResponse]?
    private var channelObservers : [ChannelObserver] = []
    
    func channelForName(name: String) -> MMXChannel? {
        
        if nil == channels { return nil }
        
        for channel in channels! {
            if channel.name == name {
                return channel
            }
        }
        
        return nil
    }
    
    func channelDetailForChannelName(name: String) -> MMXChannelDetailResponse? {
        
        if nil == channels || nil == channelDetails { return nil }
        
        if let channel = channelForName(name) {
            for detail in channelDetails! {
                if detail.channelName == channel.name {
                    return detail
                }
            }
        }
        
        return nil
    }
    
    func addChannelMessageObserver(target : AnyObject, channel : MMXChannel, selector : Selector) {
        removeChannelMessageObserver(target, channel: channel)
        
        let observer = ChannelObserver.init()
        observer.object = target
        observer.channel = channel
        observer.selector = selector
        channelObservers.append(observer)
    }
    
    func isOwnerForChat(name: String) -> MMXChannel? {
        if let channel = channelForName(name) where channel.ownerUserID == MMUser.currentUser()?.userID {
            return channel
        }
        
        return nil
    }
    
    func getLastViewTimeForChannel(name: String) -> NSDate? {
        if let decoded = NSUserDefaults.standardUserDefaults().objectForKey(name) as? NSData {
            let decodedTime = NSKeyedUnarchiver.unarchiveObjectWithData(decoded) as! UserViewTimestamp
            if decodedTime.userName == MMUser.currentUser()?.userName {
                return decodedTime.date
                
            }
        }
        return nil
    }
    
    func saveLastViewTimeForChannel(name: String) {
        if let user = MMUser.currentUser() {
            let lastViewTime = UserViewTimestamp(userName: user.userName, date: NSDate())
            let userDefaults = NSUserDefaults.standardUserDefaults()
            let encodedData = NSKeyedArchiver.archivedDataWithRootObject(lastViewTime)
            userDefaults.setObject(encodedData, forKey: name)
            userDefaults.synchronize()
        }
    }
    
    func removeChannelMessageObserver(object : AnyObject) {
        
        channelObservers = channelObservers.filter({
            if $0.object !== object && $0.object != nil {
                return true
            }
            
            return false
        })
    }
    
    func removeLastViewTimeForChannel(name: String) {
        NSUserDefaults.standardUserDefaults().removeObjectForKey(name)
    }
    
    // MARK: - Private implementation
    
    @objc private func didReceiveMessage(notification: NSNotification) {
        let tmp : [NSObject : AnyObject] = notification.userInfo!
        let mmxMessage = tmp[MMXMessageKey] as! MMXMessage
        let channel = mmxMessage.channel
        
        let observers : [ChannelObserver] = channelObservers.filter({
            if $0.channel?.name == channel?.name {
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
            if ($0 !== object || $0.channel?.name != channel.name) && $0.object != nil {
                return true
            }
            
            return false
        })
    }
}
