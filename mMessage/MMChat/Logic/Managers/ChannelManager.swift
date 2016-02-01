//
//  ChannelManager.swift
//  MMChat
//
//  Created by Kostya Grishchenko on 1/19/16.
//  Copyright © 2016 Kostya Grishchenko. All rights reserved.
//

import UIKit
import MagnetMax

class ChannelManager {
    
    static let sharedInstance = ChannelManager()

    let formatter = DateFormatter()
    var channels : [MMXChannel]?
    var channelSummaries : [MMXChannelSummaryResponse]?
    
    func channelForName(name: String) -> MMXChannel? {
        
        if nil == channels { return nil }
        
        for channel in channels! {
            if channel.name == name {
                return channel
            }
        }
        
        return nil
    }
    
    func channelSummaryForChannelName(name: String) -> MMXChannelSummaryResponse? {
        
        if nil == channels || nil == channelSummaries { return nil }
        
        if let channel = channelForName(name) {
            for summary in channelSummaries! {
                if summary.channelName == channel.name {
                    return summary
                }
            }
        }
        
        return nil
    }
    
    func isOwnerForChat(name: String) -> MMXChannel? {
        if let channel = channelForName(name) where channel.ownerUserID == MMUser.currentUser()?.userID {
            return channel
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
    
    func getLastViewTimeForChannel(name: String) -> NSDate? {
        if let decoded = NSUserDefaults.standardUserDefaults().objectForKey(name) as? NSData {
            let decodedTime = NSKeyedUnarchiver.unarchiveObjectWithData(decoded) as! UserViewTimestamp
            if decodedTime.userName == MMUser.currentUser()?.userName {
                return decodedTime.date
            }
        }
        return nil
    }
    
    func removeLastViewTimeForChannel(name: String) {
        NSUserDefaults.standardUserDefaults().removeObjectForKey(name)
    }
    
    // MARK: - Private implementation
    
    private init() {

    }
    
}
