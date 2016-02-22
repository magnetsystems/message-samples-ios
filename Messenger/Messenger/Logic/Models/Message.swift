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

import JSQMessagesViewController
import MMX
import UIKit

class Message : NSObject, JSQMessageData {
    
    
    //MARK: Public properties
    
    
    private(set) var isDownloaded : Bool = false
    var mediaCompletionBlock: JSQLocationMediaItemCompletionBlock?
    private(set) var underlyingMessage: MMXMessage {
        didSet {
            switch self.type {
            case .Text:
                self.isDownloaded  = true
            case .Location:
                break
            case .Photo:
                break
            case .Video:
                break
            }
        }
    }
    
    lazy var mediaContent: JSQMessageMediaData! = {
        
        switch self.type {
        case .Text:
            return nil
        case .Location:
            let messageContent = self.underlyingMessage.messageContent
            let locationMediaItem = JSQLocationMediaItem()
            locationMediaItem.appliesMediaViewMaskAsOutgoing = self.senderId() == MMUser.currentUser()?.userID
            
            if let latitude = Double(messageContent["latitude"]!), let longitude = Double(messageContent["longitude"]!) {
                let location = CLLocation(latitude: latitude, longitude: longitude)
                locationMediaItem.setLocation(location, withCompletionHandler: self.mediaCompletionBlock ?? nil)
            }
            self.isDownloaded  = true
            self.mediaCompletionBlock = nil
            return locationMediaItem
            
        case .Photo:
            let photoMediaItem = JSQPhotoMediaItem()
            photoMediaItem.appliesMediaViewMaskAsOutgoing = self.senderId() == MMUser.currentUser()?.userID
            photoMediaItem.image = nil
            
            let attachment = self.underlyingMessage.attachments?.first
            attachment?.downloadFileWithSuccess({ [weak self] fileURL in
                photoMediaItem.image = UIImage(contentsOfFile: fileURL.path!)
                if self?.mediaCompletionBlock != nil {
                    self?.mediaCompletionBlock!()
                    self?.mediaCompletionBlock = nil
                }
                self?.isDownloaded  = true
                }, failure: nil)
            
            return photoMediaItem
            
        case .Video:
            let videoMediaItem = JSQVideoMediaItem()
            videoMediaItem.appliesMediaViewMaskAsOutgoing = self.senderId() == MMUser.currentUser()?.userID
            videoMediaItem.isReadyToPlay = true
            
            let attachment = self.underlyingMessage.attachments?.first
            videoMediaItem.fileURL = attachment!.downloadURL
            self.isDownloaded  = true
            
            return videoMediaItem
        }
    }()
    
    lazy var type: MessageType = {
        return MessageType(rawValue: self.underlyingMessage.messageContent["type"]!)
        }()!
    
    
    //MARK: init
    
    
    init(message: MMXMessage) {
        self.underlyingMessage = message
    }
    
    
    //MARK: - Public implementation
    
    func date() -> NSDate! {
        if let date = underlyingMessage.timestamp {
            return date
        }
        
        return NSDate()
    }
    
    func isMediaMessage() -> Bool {
        return (type != MessageType.Text)
    }
    
    func messageHash() -> UInt {
        return UInt(abs(underlyingMessage.messageID!.hash))
    }
    
    func senderId() -> String! {
        return underlyingMessage.sender!.userID
    }
    
    func senderDisplayName() -> String! {
        return (underlyingMessage.sender!.firstName != nil && underlyingMessage.sender!.lastName != nil) ? "\(underlyingMessage.sender!.firstName) \(underlyingMessage.sender!.lastName)" : underlyingMessage.sender!.userName
    }
    
    func text() -> String! {
        return underlyingMessage.messageContent[Constants.ContentKey.Message]! as String
    }
    
    func media() -> JSQMessageMediaData! {
        return mediaContent
    }
    
    
    //MARK: Overrides
    
    
    override var description: String {
        return "senderId is \(senderId()), messageContent is \(underlyingMessage.messageContent)"
    }
    
}

enum MessageType: String, CustomStringConvertible {
    case Text = "text"
    case Location = "location"
    case Photo = "photo"
    case Video = "video"
    
    var description: String {
        
        switch self {
            
        case .Text:
            return "text"
        case .Location:
            return "location"
        case .Photo:
            return "photo"
        case .Video:
            return "video"
        }
    }
}
