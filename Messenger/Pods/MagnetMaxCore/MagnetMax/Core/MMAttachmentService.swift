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
import AFNetworking

public class MMAttachmentProgress : NSObject {
    dynamic private(set) public var uploadProgress : NSProgress?
    dynamic private(set) public var downloadProgress : NSProgress?
    
    override init() {
        super.init()
        
        uploadProgress = NSProgress.init()
        downloadProgress = NSProgress.init()
    }
}

@objc public class MMAttachmentService: NSObject {
    
    static public func attachmentURL(attachmentID: String, userId : String?) -> NSURL? {
     return attachmentURL(attachmentID, userId: userId, parameters: nil)
    }
    
    static public func attachmentURL(attachmentID: String, userId : String?, parameters : NSDictionary?) -> NSURL? {
        var userIDQueryParam : String = ""
        if let userID = userId {
            userIDQueryParam = "?user_id=\(userID)"
        }
        if let params = parameters {
            for (key, value) in params {
                if userIDQueryParam.characters.count == 0 {
                    userIDQueryParam = "?"
                } else {
                    userIDQueryParam += "&"
                }
                userIDQueryParam += "\(key)=\(value)"
            }
        }
        
        guard let downloadURL = NSURL(string: "com.magnet.server/file/download/\(attachmentID)\(userIDQueryParam)", relativeToURL: MMCoreConfiguration.serviceAdapter.endPoint.URL) else {
            return nil
        }
        
        return downloadURL
    }

    static public func upload(attachments: [MMAttachment], metaData:[String: String]?, success: (() -> ())?, failure: ((error: NSError) -> Void)?) {
        upload(attachments, metaData: metaData, progress: nil, success: success, failure: failure)
    }
    
    static public func upload(attachments: [MMAttachment], metaData:[String: String]?, progress : MMAttachmentProgress?, success: (() -> ())?, failure: ((error: NSError) -> Void)?) {
        guard let uploadURL = NSURL(string: "com.magnet.server/file/save/multiple", relativeToURL: MMCoreConfiguration.serviceAdapter.endPoint.URL)?.absoluteString else {
            fatalError("uploadURL should not be nil")
        }
        let request = AFHTTPRequestSerializer().multipartFormRequestWithMethod(MMStringFromRequestMethod(MMRequestMethod.POST), URLString: uploadURL, parameters: nil, constructingBodyWithBlock: { formData in
            for i in 0..<attachments.count {
                let attachment = attachments[i]
                if let fileURL = attachment.fileURL {
                    let _ = try? formData.appendPartWithFileURL(fileURL, name: attachment.name ?? "file", fileName: "attachment\(i)", mimeType: attachment.mimeType)
                } else if let data = attachment.data {
                    formData.appendPartWithFileData(data, name: attachment.name ?? "file", fileName: "attachment\(i)", mimeType: attachment.mimeType)
                } else if let inputStream = attachment.inputStream {
                    formData.appendPartWithInputStream(inputStream, name: attachment.name ?? "file", fileName: "attachment\(i)", length: attachment.length ?? 0, mimeType: attachment.mimeType)
                } else if let content = attachment.content {
                    if let data = content.dataUsingEncoding(NSUTF8StringEncoding) {
                        formData.appendPartWithFileData(data, name: attachment.name ?? "file", fileName: "attachment\(i)", mimeType: attachment.mimeType)
                    }
                }
            }
            }, error: nil)
        
        // Add metaData
        if let metaDataToAdd = metaData {
            for (key, value) in metaDataToAdd {
                request.setValue(value, forHTTPHeaderField: "metadata_\(key)")
            }
        }
        request.timeoutInterval = 60 * 5
        request.setValue("Bearer \(MMCoreConfiguration.serviceAdapter.HATToken)", forHTTPHeaderField: "Authorization")
        
        var progressObject : MMAttachmentProgress = MMAttachmentProgress.init()
        if let prog = progress {
            progressObject = prog
        }
        
        let uploadTask = MMCoreConfiguration.serviceAdapter.backgroundSessionManager.uploadTaskWithStreamedRequest(request, progress:&progressObject.uploadProgress) { response, responseObject, error in
            if let e = error {
                failure?(error: e)
            } else {
                do {
                    let res = try AFJSONResponseSerializer().responseObjectForResponse(response, data: responseObject as? NSData)
                    if let dictionary = res as? [String: String]  {
                        for i in 0..<attachments.count {
                            let attachment = attachments[i]
                            let attachmentID = dictionary["attachment\(i)"]
                            attachment.attachmentID = attachmentID
                        }
                        success?()
                    }
                } catch let error as NSError {
                    failure?(error: error)
                }
            }
        }
        uploadTask.resume()
    }
    
    static public func download(attachmentID: String, userID userIdentifier: String?, success: ((NSURL) -> ())?, failure: ((error: NSError) -> Void)?) {
        download(attachmentID, userID: userIdentifier, progress: nil, success: success, failure: failure)
    }
    
    static public func download(attachmentID: String, userID userIdentifier: String?, progress : MMAttachmentProgress?, success: ((NSURL) -> ())?, failure: ((error: NSError) -> Void)?) {
        
        guard let downloadURL = attachmentURL(attachmentID, userId: userIdentifier) else {
            fatalError("downloadURL should not be nil")
        }
        let request = NSMutableURLRequest(URL: downloadURL, cachePolicy: .UseProtocolCachePolicy, timeoutInterval: 60 * 5)
        request.setValue("Bearer \(MMCoreConfiguration.serviceAdapter.HATToken)", forHTTPHeaderField: "Authorization")
//        let request = NSMutableURLRequest(URL: NSURL(string: "https://cdn.sstatic.net/stackoverflow/img/sprites.png?v=3c6263c3453b")!, cachePolicy: .UseProtocolCachePolicy, timeoutInterval: 300)
        
        //        let request = NSMutableURLRequest(URL: NSURL(string: "http://media.licdn.com/mpr/mpr/shrinknp_400_400/p/3/000/202/3a4/2d8ca5f.jpg")!, cachePolicy: .UseProtocolCachePolicy, timeoutInterval: 300)
        
        //        let request = NSURLRequest(URL: downloadURL)
        
        
        //        var prog = progress?.downloadProgress
        let _ = progress?.downloadProgress
        
        let dataTask = MMCoreConfiguration.serviceAdapter.sessionManager.dataTaskWithRequest(request) { response, data, error in
            if let e = error {
                failure?(error: e)
            } else {
                let destination  = NSURL(fileURLWithPath: NSTemporaryDirectory()).URLByAppendingPathComponent("\(attachmentID)_\(response.suggestedFilename!)")
                (data as? NSData)?.writeToURL(destination, atomically: true)
                success?(destination)
            }
        }
        
        dataTask.resume()
    }
    
}