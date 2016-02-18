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
//import AFNetworking

class DownloadManager {
    
    static let sharedInstance: DownloadManager = {
        return DownloadManager()
    }()
    
    func downloadImage(url: NSURL!, completionHandler: ((UIImage?, NSError?) -> Void)) {
        
        let imageDownloadTask = NSURLSession.sharedSession().downloadTaskWithURL(url, completionHandler: { (location, _, error) -> Void in
            
            var image: UIImage? = nil
            if error == nil {
                let avatarData = NSData(contentsOfURL: location!)
                if let _ = avatarData {
                    image = UIImage(data: avatarData!)
                }
            }
            dispatch_async(dispatch_get_main_queue()) {
                completionHandler(image, error)
            }
        })
        imageDownloadTask.resume()

//        let requestOperation = AFHTTPRequestOperation(request: NSURLRequest(URL: url))
//        let responseSerializer = AFImageResponseSerializer()
//        // FIXME: We should set the correct Content-Type header during upload, but can't seem to figure it out.
//        // https://github.com/AFNetworking/AFAmazonS3Manager/issues/91
//        responseSerializer.acceptableContentTypes?.insert("binary/octet-stream")
//        requestOperation.responseSerializer = responseSerializer
//        requestOperation.setCompletionBlockWithSuccess({ (operation, responseObject) -> Void in
//            completionHandler(responseObject as? UIImage, nil)
//        }, failure: { (operation, error) -> Void in
//            print("error = \(error)")
//            completionHandler(nil, error)
//        })
//        requestOperation.start()
    }
    
    func downloadVideo(url: NSURL!, completionHandler: ((NSURL?, NSError?) -> Void)) {
        
        let videoDownloadTask = NSURLSession.sharedSession().downloadTaskWithURL(url, completionHandler: { (location, _, error) -> Void in
            
            if error == nil {
                dispatch_async(dispatch_get_main_queue()) {
                    completionHandler(location, error)
                }
            }
            
        })
        videoDownloadTask.resume()
    }
}
