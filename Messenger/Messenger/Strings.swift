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

func localizedString(string : String) ->String {
    return NSLocalizedString(string, comment: "")
}

let kStr_AttachmentFile = localizedString("Attachment file")
let kStr_CouldntLogin = localizedString("Couldn't log in")
let kStr_EmailPassNotFound = localizedString("Username and password not found.\n Please try again.")
let kStr_FillEmailPass = localizedString("Please fill in email and password")
let kStr_EnterFirstLastName = localizedString("Please enter your first and last name")
let kStr_EnterEmail = localizedString("Please enter your email")
let kStr_EnterPasswordAndVerify = localizedString("Please enter your password and verify your password again")
let kStr_EnterPasswordLength = localizedString("Please enter at least 6 characters")

let kStr_NoInternetError = localizedString("Please check your internet connection and try again")
let kStr_NoInternetErrorTitle = localizedString("No internet")
let kStr_PleaseTryAgain = localizedString("Please try agian")
let kStr_UsernameTaken = localizedString("Sorry, that username is already taken. Please select a new username and try again.")
let kStr_UsernameTitle = localizedString("Username taken")

let kStr_CouldntRegisterTitle = localizedString("Couldn't register")

let kStr_FieldRequired = localizedString("Field required")
let kStr_PasssNotMatch = localizedString("Passwords do not match")
let kStr_PasswordShort = localizedString("Password too short")

let kStr_MediaMessages = localizedString("Media Messages")
let kStr_TakePhotoOrVideo = localizedString("Take Photo")
let kStr_PhotoLib = localizedString("Photo Library")
let kStr_SendLoc = localizedString("Send Location")

let kStr_Cancel = localizedString("Cancel")
let kStr_Close = localizedString("Close")
let kStr_Leave = localizedString("Leave")
let kStr_Delete = localizedString("Delete")
let kStr_No = localizedString("No")
let kStr_Yes = localizedString("Yes")

let kStr_NewMessage = localizedString("New message")
let kStr_AddContact = localizedString("Add a contact")
let kStr_Group = localizedString("Group")
let kStr_Events = localizedString("Events")
let kStr_Support = localizedString("Support")
let kStr_SignOut = localizedString("Sign out")
let kStr_SignOutAsk = localizedString("Do you want sign out?")