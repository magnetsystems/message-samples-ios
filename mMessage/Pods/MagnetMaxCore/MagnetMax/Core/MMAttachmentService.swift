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

@objc public class MMAttachmentService: NSObject {
    
    static public func upload(attachments: [MMAttachment], metaData:[String: String]?, success: (() -> ())?, failure: ((error: NSError) -> Void)?) {
        var progress : NSProgress? = nil
        upload(attachments, metaData: metaData, progress: &progress, success: success, failure: failure)
    }
    
    static public func upload(attachments: [MMAttachment], metaData:[String: String]?, inout progress : NSProgress?, success: (() -> ())?, failure: ((error: NSError) -> Void)?) {
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
        
        let uploadTask = MMCoreConfiguration.serviceAdapter.backgroundSessionManager.uploadTaskWithStreamedRequest(request, progress:&progress) { response, responseObject, error in
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
        var progress : NSProgress? = nil
        download(attachmentID, userID: userIdentifier, progress: &progress, success: success, failure: failure)
    }
    
    static public func download(attachmentID: String, userID userIdentifier: String?, inout progress : NSProgress?, success: ((NSURL) -> ())?, failure: ((error: NSError) -> Void)?) {
        var userIDQueryParam = ""
        if let userID = userIdentifier {
            userIDQueryParam = "?user_id=\(userID)"
        }
        guard let downloadURL = NSURL(string: "com.magnet.server/file/download/\(attachmentID)\(userIDQueryParam)", relativeToURL: MMCoreConfiguration.serviceAdapter.endPoint.URL) else {
            fatalError("downloadURL should not be nil")
        }
        let request = NSMutableURLRequest(URL: downloadURL)
        request.setValue("Bearer \(MMCoreConfiguration.serviceAdapter.HATToken)", forHTTPHeaderField: "Authorization")
        request.timeoutInterval = 60 * 5
        let downloadTask = MMCoreConfiguration.serviceAdapter.backgroundSessionManager.downloadTaskWithRequest(request, progress: &progress, destination: { targetPath, response in
            let documentsDirectoryURL = try! NSFileManager.defaultManager().URLForDirectory(.DocumentDirectory, inDomain: .UserDomainMask, appropriateForURL: nil, create: false)
            let destination  = documentsDirectoryURL.URLByAppendingPathComponent("\(attachmentID)_\(response.suggestedFilename!)")
            //            let _ = try? NSFileManager.defaultManager().removeItemAtURL(destination)
            return destination
            
            }) { response, filePath, error in
                if let e = error {
                    failure?(error: e)
                } else {
                    //                guard let httpResponse = response as? NSHTTPURLResponse else {
                    //                    fatalError("response should be of type NSHTTPURLResponse")
                    //                }
                    //                let headers = httpResponse.allHeaderFields["Content-Type"] as! [String: AnyObject]
                    //                var contentType = "application/octet-stream"
                    //                if let contentTypeHeader = headers["Content-Type"] as? String {
                    //                    contentType = contentTypeHeader
                    //                }
                    success?(filePath!)
                }
        }
        
        downloadTask.resume()
    }
    
}