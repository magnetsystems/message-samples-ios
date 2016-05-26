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

/**
 The MessageData object for `MMXChatViewController`/`JSQMessagesViewController`
 */
public class Message : NSObject, JSQMessageData {
    
    
    //MARK: Private properties
    
    
    private var dataChangeHash = 0
    
    
    //MARK: Public properties
    
    
    /// has data been downloaded for this data object (i.e images, videos... etc)
    public private(set) var isDownloaded : Bool = false
    /// completion block to be called when media has been downloaded
    public var mediaCompletionBlock: JSQLocationMediaItemCompletionBlock?
    /// the actual MMXMessage the Message object is using
    public private(set) var underlyingMessage: MMXMessage {
        didSet {
            switch self.type {
            case .Text:
                self.isDownloaded  = true
            default:
                break
            }
        }
    }
    /// higher resolution image
    public var fullsizedImage : UIImage?
    /// Media content based on `underlyingMessage`
    public lazy var mediaContent: JSQMessageMediaData? = {
        
        switch self.type {
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
                    self.fullsizedImage = image
                    if self.mediaCompletionBlock != nil {
                        self.mediaCompletionBlock!()
                        self.mediaCompletionBlock = nil
                    }
                    self.isDownloaded  = true
                })
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
            
        case .PollIdentifier:
            let mediaItem = PollMediaItem()
            mediaItem.message = self.underlyingMessage
            mediaItem.onUpdate = {
                self.mediaCompletionBlock?()
                self.isDownloaded  = true
            }
            
            return mediaItem
        case .PollUpdate:
            let mediaItem = PollUpdateItem()
            if let user = self.underlyingMessage.sender {
                let sender = Utils.displayNameForUser(user)
                let text = "\(sender) voted!"
                mediaItem.text = text
            }
            self.isDownloaded  = true
            return mediaItem
        default:
            return nil
        }
    }()
    /**
     Message Type based on `underlyingMessage`
     - see: MessageType
     */
    public lazy var type: MessageType = {
        if self.underlyingMessage.contentType == MMXPollIdentifier.contentType {
            return .PollIdentifier
        } else if self.underlyingMessage.contentType == MMXPollAnswer.contentType {
            return .PollUpdate
        } else {
            if let type = self.underlyingMessage.messageContent["type"] {
                return MessageType(rawValue: type) ?? .Text
            }
        }
        return .Unknown
    }()
    
    
    //MARK: init
    
    
    /// Init
    required public init(message: MMXMessage) {
        self.underlyingMessage = message
    }
    
    
    //MARK: - Public implementation
    
    
    /// changes the Message object hash for caching purposes
    public func setDataChanged() {
        dataChangeHash += 1
    }
    
    /// Data of `underlyingMessage` if available if not Data right now
    public func date() -> NSDate! {
        if let date = underlyingMessage.timestamp {
            return date
        }
        
        return NSDate()
    }
    
    /// Is the message object a media message
    public func isMediaMessage() -> Bool {
        return (type == .Location || type == .Video || type == .Photo || type == .PollIdentifier || type == .PollUpdate )
    }
    
    /// current hash of the Message object
    public func messageHash() -> UInt {
        return UInt(abs((underlyingMessage.messageID! + "\(dataChangeHash)").hash))
    }
    
    /// MMUser Id based on `underlyingMessage`
    public func senderId() -> String! {
        return underlyingMessage.sender?.userID ?? ""
    }
    
    /// MMUser display name based on `underlyingMessage`
    public func senderDisplayName() -> String! {
        if let sender = underlyingMessage.sender {
            return (sender.firstName != nil && sender.lastName != nil) ? "\(sender.firstName) \(sender.lastName)" : sender.userName
        }
        return ""
    }
    
    /// Text based on `underlyingMessage` if available if not returns empty string ""
    public func text() -> String {
        if let content = underlyingMessage.messageContent[Constants.ContentKey.Message] {
            return content as String
        }
        return ""
    }
    
    /// media content for message if available
    public func media() -> JSQMessageMediaData? {
        return mediaContent
    }
    
    
    //MARK: Overrides
    
    
    /// Description
    public override var description: String {
        return "senderId is \(senderId()), messageContent is \(underlyingMessage.messageContent)"
    }
    
}

/**
 MessageType for `Message` object
 - see: `Message`
 */
public enum MessageType: String, CustomStringConvertible {
    /// Text
    case Text = "text"
    /// Location
    case Location = "location"
    /// Image
    case Photo = "photo"
    /// Video
    case Video = "video"
    /// Poll ID
    case PollIdentifier = "pollIdentifier"
    /// Poll Answer Update
    case PollUpdate = "pollUpdate"
    /// Default
    case Unknown = "Unknown"
    
    /// String description of `MessageType`
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
        case .PollIdentifier:
            return "pollIdentifier"
        case .PollUpdate:
            return "pollUpdate"
        case .Unknown :
            return "Unknown"
        }
    }
}
