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

@objc public class MMAttachment: NSObject {
    /**
        The file URL for the attachment.
     
        While sending attachments, this is automatically populated by init(fileURL:mimeType:) and init(fileURL:mimeType:name:description:).
        On received attachments, this is automatically populated by downloadFileWithSuccess(_:failure:).
    */
    public private(set) var fileURL: NSURL?
    /**
        The data for the attachment.
     
        While sending attachments, this is automatically populated by init(data:mimeType:) and init(data:mimeType:name:description:).
        On received attachments, this is automatically populated by downloadDataWithSuccess(_:failure:).
    */
    public private(set) var data: NSData?
    /**
        The input stream for the attachment.
     
        While sending attachments, this is automatically populated by init(inputStream:length:mimeType:) and init(inputStream:length:mimeType:name:description:).
        On received attachments, this is automatically populated by downloadInputStreamWithSuccess(_:failure:).
    */
    public private(set) var inputStream: NSInputStream?
    /**
        The length for the attachment.
     
        On received attachments, this is automatically populated by downloadInputStreamWithSuccess(_:failure:).
    */
    public private(set) var length: Int64?
    /**
        The string content for the attachment.
     
        While sending attachments, this is automatically populated by init(content:mimeType:) and init(content:mimeType:).
        On received attachments, this is automatically populated by downloadStringWithSuccess(_:failure:).
    */
    public private(set) var content: String?
    /// The unique identifer for the attachment.
    public internal(set) var attachmentID: String?
    /// The name for the attachment.
    public private(set) var name: String?
    /// The summary for the attachment.
    public private(set) var summary: String?
    /// The mime type for the attachment.
    public private(set) var mimeType: String
    /// The download URL for the attachment.
    public lazy var downloadURL: NSURL? = {
        [unowned self] in
        if let attachmentID = self.attachmentID, let accessToken = MMCoreConfiguration.serviceAdapter.HATToken {
            let downloadURL = NSURL(string: "com.magnet.server/file/download/\(attachmentID)?access_token=\(accessToken)", relativeToURL: MMCoreConfiguration.serviceAdapter.endPoint.URL)
            return downloadURL
        }
        return nil
        }()
    
    /**
        Initialize attachment.
     
        - Parameters:
            - fileURL: The file URL.
            - mimeType: The mime type.
    */
    public convenience init(fileURL: NSURL, mimeType: String) {
        self.init(fileURL: fileURL, mimeType: mimeType, name: nil, description: nil)
    }
    
    /**
        Initialize attachment.
     
        - Parameters:
            - fileURL: The file URL.
            - mimeType: The mime type.
            - name: The name.
            - description: The description.
    */
    public convenience init(fileURL: NSURL, mimeType: String, name: String?, description: String?) {
        self.init(mimeType: mimeType, name: name, description: description)
        self.fileURL = fileURL
    }
    
    /**
        Initialize attachment.
     
        - Parameters:
            - data: The data.
            - mimeType: The mime type.
    */
    public convenience init(data: NSData, mimeType: String) {
        self.init(data: data, mimeType: mimeType, name: nil, description: nil)
    }
    
    /**
        Initialize attachment.
     
        - Parameters:
            - data: The data.
            - mimeType: The mime type.
            - name: The name.
            - description: The description.
    */
    public convenience init(data: NSData, mimeType: String, name: String?, description: String?) {
        self.init(mimeType: mimeType, name: name, description: description)
        self.data = data
    }
    
    /**
        Initialize attachment.
     
        - Parameters:
            - inputStream: The input stream.
            - length: The length.
            - mimeType: The mime type.
     */
    public convenience init(inputStream: NSInputStream, length: Int64, mimeType: String) {
        self.init(inputStream: inputStream, length: length, mimeType: mimeType, name: nil, description: nil)
    }
    
    /**
        Initialize attachment.
     
        - Parameters:
            - inputStream: The input stream.
            - length: The length.
            - mimeType: The mime type.
            - name: The name.
            - description: The description.
    */
    public convenience init(inputStream: NSInputStream, length: Int64, mimeType: String, name: String?, description: String?) {
        self.init(mimeType: mimeType, name: name, description: description)
        self.inputStream = inputStream
        self.length = length
    }
    
    /**
        Initialize attachment.
     
        - Parameters:
            - content: The string content.
            - mimeType: The mime type.
    */
    public convenience init(content: String, mimeType: String) {
        self.init(content: content, mimeType: mimeType, name: nil, description: nil)
    }
    
    /**
        Initialize attachment.
     
        - Parameters:
            - content: The string content.
            - mimeType: The mime type.
            - name: The name.
            - description: The description.
    */
    public convenience init(content: String, mimeType: String, name: String?, description: String?) {
        self.init(mimeType: mimeType, name: name, description: description)
        self.content = content
    }
    
    /**
        Initialize attachment.
     
        - Parameters:
            - content: The string content.
            - mimeType: The mime type.
            - name: The name.
            - description: The description.
    */
    public required init(mimeType: String, name: String?, description: String?) {
        self.mimeType = mimeType
        self.name = name
        self.summary = description
    }
    
    /**
        Get dictionary representation of the attachment.
     
        - Returns: The dictionary representation of the attachment.
    */
    func toDictionary() -> [String: AnyObject] {
        var dictionary = ["mimeType": mimeType]
        if let attachmentID = self.attachmentID {
            dictionary["attachmentID"] = attachmentID
        }
        if let name = self.name {
            dictionary["name"] = name
        }
        if let summary = self.summary {
            dictionary["summary"] = summary
        }
        
        return dictionary
    }
    
    /**
        Get JSON representation of the attachment.
     
        - Returns: The JSON representation of the attachment or nil.
    */
    func toJSON() -> NSData? {
        let dictionary = toDictionary()
        if NSJSONSerialization.isValidJSONObject(dictionary) {
            do {
                let data = try NSJSONSerialization.dataWithJSONObject(dictionary, options: NSJSONWritingOptions(rawValue: 0))
                return data
            } catch {
                return nil
            }
        }
        return nil
    }
    
    /**
        Get JSON string representation of the attachment.
     
        - Returns: The JSON string representation of the attachment.
    */
    public func toJSONString() -> String {
        var jsonString = ""
        if let jsonData = toJSON() {
            jsonString = NSString(data: jsonData, encoding: NSUTF8StringEncoding) as! String
        }
        
        return jsonString
    }
    
    /**
        Create an attachment instance given a JSON string.

        - Parameters:
            - jsonString: The JSON string representation.

        - Returns: An attachment instance.
    */
    static public func fromJSONString(jsonString: String) -> Self? {
        do {
            let object = try NSJSONSerialization.JSONObjectWithData(jsonString.dataUsingEncoding(NSUTF8StringEncoding)!, options: NSJSONReadingOptions(rawValue: 0))
            if let dictionary = object as? [String: AnyObject] {
                return fromDictionary(dictionary)
            }
        } catch {
            return nil
        }
        
        return nil
    }
    
    /**
        Create an attachment instance given a dictionary.
     
        - Parameters:
            - dictionary: The dictionary representation.
     
        - Returns: An attachment instance.
    */
    class func fromDictionary(dictionary: [String: AnyObject]) -> Self? {
        let attachment = self.init(mimeType: dictionary["mimeType"] as! String, name: dictionary["name"] as? String, description: dictionary["summary"] as? String)
        attachment.attachmentID = dictionary["attachmentID"] as? String
        
        return attachment
    }
    
    override public func isEqual(object: AnyObject?) -> Bool {
        if let rhs = object as? MMAttachment {
            return attachmentID != nil && attachmentID == rhs.attachmentID
        }
        return false
    }
    
    override public var hash: Int {
        return attachmentID?.hashValue ?? ObjectIdentifier(self).hashValue
    }
    
    /**
        Download the attachment to a specified file.
     
        - Parameters:
            - fileURL: The file URL where the attachment should be downloaded to.
            - success: A block object to be executed when the download finishes successfully. This block has no return value and takes no arguments.
            - failure: A block object to be executed when the logout finishes with an error. This block has no return value and takes one argument: the error object.
    */
    public func downloadToFile(fileURL: NSURL, success: (Void -> Void)?, failure: ((error: NSError) -> Void)?) {
        if let attachmentID = self.attachmentID {
            MMAttachmentService.download(attachmentID, success: { URL in
                do {
                    try NSFileManager.defaultManager().moveItemAtURL(URL, toURL: fileURL)
                } catch let error as NSError {
                    failure?(error: error)
                }
                success?()
                }) { error in
                    failure?(error: error)
            }
        }
    }
    
    /**
        Download the attachment to a file.
     
        - Parameters:
            - success: A block object to be executed when the download finishes successfully. This block has no return value and takes one argument: the downloaded file URL.
            - failure: A block object to be executed when the logout finishes with an error. This block has no return value and takes one argument: the error object.
    */
    public func downloadFileWithSuccess(success: ((fileURL: NSURL) -> Void)?, failure: ((error: NSError) -> Void)?) {
        if let attachmentID = self.attachmentID {
            MMAttachmentService.download(attachmentID, success: { URL in
                self.fileURL = URL
                success?(fileURL: URL)
                }) { error in
                    failure?(error: error)
            }
        }
    }
    
    /**
        Download the attachment as data.
     
        - Parameters:
            - success: A block object to be executed when the download finishes successfully. This block has no return value and takes one argument: the downloaded data.
            - failure: A block object to be executed when the logout finishes with an error. This block has no return value and takes one argument: the error object.
    */
    public func downloadDataWithSuccess(success: ((data: NSData) -> Void)?, failure: ((error: NSError) -> Void)?) {
        if let attachmentID = self.attachmentID {
            MMAttachmentService.download(attachmentID, success: { URL in
                self.data = NSData(contentsOfURL: URL)
                success?(data: self.data!)
                }) { error in
                    failure?(error: error)
            }
        }
    }
    
    /**
        Download the attachment as an input stream.
     
        - Parameters:
            - success: A block object to be executed when the download finishes successfully. This block has no return value and takes one argument: the input stream for the downloaded data.
            - failure: A block object to be executed when the logout finishes with an error. This block has no return value and takes one argument: the error object.
    */
    public func downloadInputStreamWithSuccess(success: ((inputStream: NSInputStream, length: Int64) -> Void)?, failure: ((error: NSError) -> Void)?) {
        if let attachmentID = self.attachmentID {
            MMAttachmentService.download(attachmentID, success: { URL in
                self.inputStream = NSInputStream(URL: URL)
                let fileAttributes = try? NSFileManager.defaultManager().attributesOfItemAtPath(URL.path!)
                self.length = (fileAttributes?[NSFileSize] as? NSNumber)?.longLongValue
                success?(inputStream: self.inputStream!, length: self.length ?? 0)
                }) { error in
                    failure?(error: error)
            }
        }
    }
    
    /**
        Download the attachment as a string.
     
        - Parameters:
            - success: A block object to be executed when the download finishes successfully. This block has no return value and takes one argument: the string representation of the downloaded data.
            - failure: A block object to be executed when the logout finishes with an error. This block has no return value and takes one argument: the error object.
    */
    public func downloadStringWithSuccess(success: ((content: String) -> Void)?, failure: ((error: NSError) -> Void)?) {
        if let attachmentID = self.attachmentID {
            MMAttachmentService.download(attachmentID, success: { URL in
                if let data = NSData(contentsOfURL: URL), content = NSString(data: data, encoding: NSUTF8StringEncoding) as? String {
                    success?(content: content)
                }
                }) { error in
                    failure?(error: error)
            }
        }
    }
}