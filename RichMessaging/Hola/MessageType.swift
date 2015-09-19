//
//  MessageType.swift
//  Hola
//
//  Created by Pritesh Shah on 9/10/15.
//  Copyright (c) 2015 Magnet Systems, Inc. All rights reserved.
//

import Foundation

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
