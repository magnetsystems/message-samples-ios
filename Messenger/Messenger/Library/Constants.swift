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
let vc_id_Support = "support"
let vc_id_Events = "events"
let vc_id_SlideMenu = "SlideMenuVC"
let vc_id_VideoPlayer = "VideoPlayerViewController"
let vc_id_ContactsNav = "ContactsNavigationController"
let vc_id_UserProfile = "userProfileVC"

let kNotificationNetworkOffline = "com.magnet.network.offline"
let kNotificationHideSupportNotifiers = "HideSupportNotifiersNotification"

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
