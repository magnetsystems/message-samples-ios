//
//  AppDelegate.swift
//  MMChat
//
//  Created by Kostya Grishchenko on 12/23/15.
//  Copyright © 2015 Kostya Grishchenko. All rights reserved.
//

import UIKit
import MagnetMax
import Fabric
import Crashlytics

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    weak var baseViewController : UIViewController?
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        let URLCache = NSURLCache(memoryCapacity: 4 * 1024 * 1024, diskCapacity: 100 * 1024 * 1024, diskPath: nil)
        NSURLCache.setSharedURLCache(URLCache)
        
        // Initialize MagnetMax
        let configurationFile = NSBundle.mainBundle().pathForResource("MagnetMax", ofType: "plist")
        let configuration = MMPropertyListConfiguration(contentsOfFile: configurationFile!)
        MagnetMax.configure(configuration!)
        
        
        let settings = UIUserNotificationSettings(forTypes: [.Badge,.Alert,.Sound], categories: nil)
        application.registerUserNotificationSettings(settings);
        
//        is user alread logged In ?
        setMainWindow(launchViewController())
        self.window?.makeKeyAndVisible()
        
        if MMUser.sessionStatus() != .NotLoggedIn {
            MMUser.resumeSession({ () -> Void in
                if let navController : UINavigationController = self.rootViewController() as? UINavigationController {
                    if MMUser.sessionStatus() == .LoggedIn {
                        
                        MMX.start()
                        
                        if let viewController = navController.storyboard?.instantiateViewControllerWithIdentifier(vc_id_SlideMenu) as? SWRevealViewController {
                            navController.pushViewController(viewController, animated: false)
                        }
                    }
                    self.appendToMainWindow(navController, animated: false)
                }
                }, failure: { (error) -> Void in
                    self.setMainWindow(self.rootViewController())
            })
        } else {
            setMainWindow(rootViewController())
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "sessionEnded", name: MMXUserDidLogOutNotification, object: nil)
        Fabric.with([Crashlytics.self])
        return true
    }
    
    func launchViewController() -> UIViewController {
        let storyboard = UIStoryboard(name: sb_id_Launch, bundle: nil)
        return storyboard.instantiateInitialViewController()!;
    }
    
    func rootViewController() -> UIViewController {
        let storyboard = UIStoryboard(name: sb_id_Main, bundle: nil)
        return storyboard.instantiateInitialViewController()!
    }
    
    func setMainWindow(viewController : UIViewController) {
        if self.window == nil {
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        self.window?.backgroundColor = UIColor.whiteColor()
        }
        self.window?.rootViewController = viewController
        self.baseViewController = viewController
    }
    
    func appendToMainWindow(viewController : UIViewController, animated : Bool) {
        viewController.modalTransitionStyle = .CrossDissolve
        self.window?.rootViewController?.presentViewController(viewController, animated: animated, completion: nil)
        self.baseViewController = viewController
    }
    
    func sessionEnded() {
        print("[SESSION]: SESSION ENDED")
        if let mainNav = self.baseViewController as? UINavigationController {
            print("[SESSION]: WILL DISPLAY LOGIN")
            mainNav.popToRootViewControllerAnimated(true)
        }
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(application: UIApplication, didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings) {
        application.registerForRemoteNotifications()
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        print("didFailToRegisterForRemoteNotificationsWithError \nCode = \(error.code) \nlocalizedDescription = \(error.localizedDescription) \nlocalizedFailureReason = \(error.localizedFailureReason)")
    }
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        MMDevice.updateCurentDeviceToken(deviceToken, success: { () -> Void in
            print("Successfully updated device token")
            }, failure:{ (error) -> Void in
                print("Error updating device token. \(error)")
        })
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        if MMXRemoteNotification.isWakeupRemoteNotification(userInfo) {
            //Send local notification to the user or connect via MMXUser logInWithCredential:success:failure:
        } else if MMXRemoteNotification.isMMXRemoteNotification(userInfo) {
            MMXRemoteNotification.acknowledgeRemoteNotification(userInfo, completion: nil)
        }
    }
    
}

