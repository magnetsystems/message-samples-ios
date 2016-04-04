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

import UIKit

import MMX

public class Message : NSObject, JSQMessageData {
    
    
    //MARK: Public properties
    
    
    public private(set) var isDownloaded : Bool = false
    public var mediaCompletionBlock: JSQLocationMediaItemCompletionBlock?
    public private(set) var underlyingMessage: MMXMessage {
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
            case .Unknown:
                break
            }
        }
    }
    
    public var fullsizedImage : UIImage?
    public lazy var mediaContent: JSQMessageMediaData? = {
        
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
            
            if let url = self.underlyingMessage.attachments?.first?.downloadURL {
                
                Utils.loadImageWithUrl(url, completion: { image in
                    photoMediaItem.image = image
                    Utils.loadImageWithUrl(url, completion: { image in
                        self.fullsizedImage = image
                    })
                    if self.mediaCompletionBlock != nil {
                        self.mediaCompletionBlock!()
                        self.mediaCompletionBlock = nil
                    }
                    self.isDownloaded  = true
                    },aspectSize: CGSize(width: 100, height: CGFloat.max))
            }
            
            return photoMediaItem
            
        case .Video:
            let videoMediaItem = JSQVideoMediaItem()
            videoMediaItem.appliesMediaViewMaskAsOutgoing = self.senderId() == MMUser.currentUser()?.userID
            videoMediaItem.isReadyToPlay = true
            
            let attachment = self.underlyingMessage.attachments?.first
            videoMediaItem.fileURL = attachment!.downloadURL
            self.isDownloaded  = true
            
            return videoMediaItem
            
        case .Unknown :
            return nil
        }
    }()
    
    public lazy var type: MessageType = {
        if let type = self.underlyingMessage.messageContent["type"] {
            return MessageType(rawValue: type) ?? .Text
        }
        return .Unknown
    }()
    
    
    //MARK: init
    
    
    public init(message: MMXMessage) {
        self.underlyingMessage = message
    }
    
    
    //MARK: - Public implementation
    
    public func date() -> NSDate! {
        if let date = underlyingMessage.timestamp {
            return date
        }
        
        return NSDate()
    }
    
    public func isMediaMessage() -> Bool {
        return (type != .Text && type != .Unknown)
    }
    
    public func messageHash() -> UInt {
        return UInt(abs(underlyingMessage.messageID!.hash))
    }
    
    public func senderId() -> String! {
        return underlyingMessage.sender?.userID ?? ""
    }
    
    public func senderDisplayName() -> String! {
        if let sender = underlyingMessage.sender {
            return (sender.firstName != nil && sender.lastName != nil) ? "\(sender.firstName) \(sender.lastName)" : sender.userName
        }
        return ""
    }
    
    public func text() -> String {
        if let content = underlyingMessage.messageContent[Constants.ContentKey.Message] {
            return content as String
        }
        return ""
    }
    
    public func media() -> JSQMessageMediaData? {
        return mediaContent
    }
    
    
    //MARK: Overrides
    
    
    public override var description: String {
        return "senderId is \(senderId()), messageContent is \(underlyingMessage.messageContent)"
    }
    
}

public enum MessageType: String, CustomStringConvertible {
    case Text = "text"
    case Location = "location"
    case Photo = "photo"
    case Video = "video"
    case Unknown = "Unknown"
    
    public var description: String {
        
        switch self {
        case .Text:
            return "text"
        case .Location:
            return "location"
        case .Photo:
            return "photo"
        case .Video:
            return "video"
        case .Unknown :
            return "Unknown"
        }
    }
}
