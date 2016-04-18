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

public class CKStrings {
    
public class func localizedString(string : String) ->String {
    return NSLocalizedString(string, comment: "")
}

public static let kStr_AttachmentFile = CKStrings.localizedString("Attachment file")
public static let kStr_AttachmentLocation = CKStrings.localizedString("Attachment location")
public static let kStr_AddContact = CKStrings.localizedString("Add a contact")

public static let kStr_Cancel = CKStrings.localizedString("Cancel")
public static let kStr_Close = CKStrings.localizedString("Close")
public static let kStr_CouldntLogin = CKStrings.localizedString("Couldn't log in")
public static let kStr_CouldntRegisterTitle = CKStrings.localizedString("Couldn't register")

public static let kStr_Delete = CKStrings.localizedString("Delete")

public static let kStr_EmailPassNotFound = CKStrings.localizedString("Username and password not found.\n Please try again.")
public static let kStr_EnterEmail = CKStrings.localizedString("Please enter your email")
public static let kStr_EnterFirstLastName = CKStrings.localizedString("Please enter your first and last name")
public static let kStr_EnterPasswordAndVerify = CKStrings.localizedString("Please enter your password and verify your password again")
public static let kStr_EnterPasswordLength = CKStrings.localizedString("Please enter at least 6 characters")
public static let kStr_Events = CKStrings.localizedString("Events")

public static let kStr_Group = CKStrings.localizedString("Group")

public static let kStr_Subscribers = CKStrings.localizedString("In Group")

public static let kStr_Leave = CKStrings.localizedString("Leave")

public static let kStr_MediaMessages = CKStrings.localizedString("Media Messages")

public static let kStr_No = CKStrings.localizedString("No")
public static let kStr_NoInternetError = CKStrings.localizedString("Please check your internet connection and try again")
public static let kStr_NoInternetErrorTitle = CKStrings.localizedString("No internet")

public static let kStr_PhotoLib = CKStrings.localizedString("Photo Library")

public static let kStr_SendLoc = CKStrings.localizedString("Send Location")
public static let kStr_TakePhotoOrVideo = CKStrings.localizedString("Take Photo")
public static let kStr_CreatePoll = CKStrings.localizedString("Create a Poll")
    
public static let kStr_Yes = CKStrings.localizedString("Yes")
}


