//
//  Message.swift
//  MMChat
//
//  Created by Pritesh Shah on 9/9/15.
//  Copyright (c) 2015 Magnet Systems, Inc. All rights reserved.
//

import UIKit
import JSQMessagesViewController
import MMX

class Message : NSObject, JSQMessageData {
    
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
    
    private(set) var isDownloaded : Bool = false
    
    lazy var type: MessageType = {
        return MessageType(rawValue: self.underlyingMessage.messageContent["type"]!)
        }()!
    
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
    
    init(message: MMXMessage) {
        self.underlyingMessage = message
    }
    
    func senderId() -> String! {
        return underlyingMessage.sender!.userID
    }
    
    func senderDisplayName() -> String! {
        return (underlyingMessage.sender!.firstName != nil && underlyingMessage.sender!.lastName != nil) ? "\(underlyingMessage.sender!.firstName) \(underlyingMessage.sender!.lastName)" : underlyingMessage.sender!.userName
    }
    
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
    
    func text() -> String! {
        return underlyingMessage.messageContent[Constants.ContentKey.Message]! as String
    }
    
    func media() -> JSQMessageMediaData! {
        return mediaContent
    }
    
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
