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

import UIKit
import MagnetMax

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        // Initialize MagnetMax
        guard let configurationFile = NSBundle.mainBundle().pathForResource("MagnetMax", ofType: "plist"), let configuration = MMPropertyListConfiguration(contentsOfFile: configurationFile) else {
            fatalError("MagnetMax.plist is either not found in the project or is invalid. Please add a valid MagnetMax.plist file to the project and try again.")
        }
        MagnetMax.configure(configuration)
        
        // Register push notifications
        let settings = UIUserNotificationSettings(forTypes: [.Badge,.Alert,.Sound], categories: nil)
        application.registerUserNotificationSettings(settings)
        
        application.applicationIconBadgeNumber = 0
        
        return true
    }
    
    
   // MARK: Push Notification Control
    
    
    func application(application: UIApplication, didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings) {
        application.registerForRemoteNotifications()
    }
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        MMDevice.updateCurentDeviceToken(deviceToken, success: { () -> Void in
            print("Successfully updated device token")
        }, failure:{ (error) -> Void in
            print("Error updating device token. \(error)")
        })
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        print("didFailToRegisterForRemoteNotificationsWithError \nCode = \(error.code) \nlocalizedDescription = \(error.localizedDescription) \nlocalizedFailureReason = \(error.localizedFailureReason)")
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        if MMXRemoteNotification.isWakeupRemoteNotification(userInfo) {
            //Send local notification to the user or connect via MMXUser logInWithCredential:success:failure:
        } else if MMXRemoteNotification.isMMXRemoteNotification(userInfo) {
            MMXRemoteNotification.acknowledgeRemoteNotification(userInfo, completion: nil)
        }
        
        let msg : MMXPushMessage = MMXPushMessage.init(pushUserInfo: userInfo)
        
        let body : String = msg.body != nil ? msg.body! : ""
        let title : String = msg.title != nil ? msg.title! : "No Title"
        
        print("Body: \(body) title: \(title)\nContent Dictionary: \(msg.messageContent)")
    }
}

