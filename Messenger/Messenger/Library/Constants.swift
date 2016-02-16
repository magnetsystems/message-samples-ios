//
//  Constants.swift
//  MMChat
//
//  Created by Kostya Grishchenko on 1/29/16.
//  Copyright © 2016 Kostya Grishchenko. All rights reserved.
//

import Foundation

struct Constants {
    
    struct ContentKey {
        static let Message = "message"
        static let Type = "type"
        static let Latitude = "latitude"
        static let Longitude = "longitude"
    }
    
}

let kUserDefaultsShowProfile = "kUserDefaultsShowProfile"

 /// IDs for storyboards, ViewControllers and segues

let sb_id_Main = "Main"
let sb_id_Launch = "LaunchScreen"

let vc_id_Chat = "ChatViewController"
let vc_id_Home = "home"
let vc_id_Events = "events"
let vc_id_SlideMenu = "SlideMenuVC"
let vc_id_VideoPlayer = "VideoPlayerViewController"
let vc_id_ContactsNav = "ContactsNavigationController"
let vc_id_UserProfile = "userProfileVC"

let kSegueShowChatFromChatActivity = "showChatFromChannelSummary"
let kSegueShowContactSelector = "showContactsSelector"
let kSegueShowSlideMenu = "showSlideMenuVC"
let kSegueRegisterToHome = "registerToMenuSegue"
let kSegueShowMap = "showMapViewController"
let kSegueShowDetails = "showDetailsSegue"

let kMagnetSupportTag = "magnetsupport"
let kAskMagnetChannel = "askMagnet"
let kMagnetEmailDomain = "@magnet.com"

let kMinPasswordLength = 6
let kMinNameLength = 1
