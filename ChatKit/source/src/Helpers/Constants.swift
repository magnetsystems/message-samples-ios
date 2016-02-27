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

import Foundation

struct Constants {
    
    struct ContentKey {
        static let Latitude = "latitude"
        static let Longitude = "longitude"
        static let Message = "message"
        static let Type = "type"
    }
    
}

let kUserDefaultsShowProfile = "kUserDefaultsShowProfile"
let kMagnetEmailDomain = "@magnet.com"
let kMagnetSupportTag = "magnetsupport"

let kMinNameLength = 1
let kMinPasswordLength = 6

let kNotificationNetworkOffline = "com.magnet.network.offline"
let kNotificationHideSupportNotifiers = "HideSupportNotifiersNotification"

 /// IDs for storyboards, ViewControllers and segues

let kSegueRegisterToHome = "registerToMenuSegue"
let kSegueShowChatFromChatActivity = "showChatFromChannelSummary"
let kSegueShowContactSelector = "showContactsSelector"
let kSegueShowDetails = "showDetailsSegue"
let kSegueShowSlideMenu = "showSlideMenuVC"
let kSegueShowMap = "showMapViewController"

let sb_id_Launch = "LaunchScreen"
let sb_id_Main = "Main"

let vc_id_Chat = "ChatViewController"
let vc_id_ContactsNav = "ContactsNavigationController"
let vc_id_Events = "events"
let vc_id_Home = "home"
let vc_id_SlideMenu = "SlideMenuVC"
let vc_id_Support = "support"
let vc_id_UserProfile = "userProfileVC"
let vc_id_VideoPlayer = "VideoPlayerViewController"
