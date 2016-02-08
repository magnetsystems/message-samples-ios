//
//  DownloadManager.swift
//  Hola
//
//  Created by Pritesh Shah on 9/14/15.
//  Copyright © 2015 Magnet Systems, Inc. All rights reserved.
//

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
