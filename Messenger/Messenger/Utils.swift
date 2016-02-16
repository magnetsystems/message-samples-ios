//
//  Utils.swift
//  Messenger
//
//  Created by Vladimir Yevdokimov on 2/9/16.
//  Copyright © 2016 Magnet Systems, Inc. All rights reserved.
//

import UIKit
import MagnetMax
import AFNetworking

class UtilsSet {
    var set : Set<UIImageView> = Set()
    var completionBlocks : [(()->Void)] = []
    
    func addCompletionBlock(completion : (()->Void)?) {
        if let completion = completion {
            completionBlocks.append(completion)
        }
    }
}

class Utils: NSObject {
    private static var downloadObjects : [String : String] = [:]
    private static var loadingURLs : [String : UtilsSet] = [:]
    
    class func name(name: AnyClass) -> String {
        let ident:String = NSStringFromClass(name).componentsSeparatedByString(".").last!
        return ident
    }
    
    class func resizeImage(image:UIImage, toSize:CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(toSize, false, 0.0);
        image.drawInRect(CGRect(x: 0, y: 0, width: toSize.width, height: toSize.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return newImage;
    }
    
    static func loadImageWithUrl(url : NSURL?, toImageView: UIImageView, placeholderImage:UIImage?) {
       loadImageWithUrl(url, toImageView: toImageView, placeholderImage: placeholderImage, completion: nil)
    }
    
    static func loadImageWithUrl(url : NSURL?, toImageView: UIImageView, placeholderImage:UIImage?, completion : (()->Void)?) {
        
        if placeholderImage != nil {
        toImageView.image = placeholderImage
        }
        
        guard let imageUrl = url else {
            print("no url content data")
            objc_sync_enter(self.downloadObjects)
            self.downloadObjects.removeValueForKey("\(toImageView.hashValue)")
            objc_sync_exit(self.downloadObjects)
            completion?()
            return
        }
        
        //TODO: ADD API
        
        //track image View
        
        objc_sync_enter(self.downloadObjects)
        self.downloadObjects["\(toImageView.hashValue)"] = url?.path
        objc_sync_exit(self.downloadObjects)
        
        if let urlPath = url?.path {
            objc_sync_enter(self.loadingURLs)
            
            if self.loadingURLs[urlPath] == nil {
                self.loadingURLs[urlPath] = UtilsSet()
            }
            self.loadingURLs[urlPath]?.set.insert(toImageView)
            self.loadingURLs[urlPath]?.addCompletionBlock(completion)
            if self.loadingURLs[urlPath]?.set.count > 1 {
                objc_sync_exit(self.loadingURLs)
                return
            } else {
                objc_sync_exit(self.loadingURLs)
            }
        }
        
        let requestOperation = AFHTTPRequestOperation(request: NSURLRequest(URL: imageUrl))
        requestOperation.responseSerializer = AFImageResponseSerializer();
        requestOperation.setCompletionBlockWithSuccess({ (operation, response) -> Void in
            if let img = response as? UIImage {
                //if last request on image view
                pushImageToImageView(img, url: url)
            } else {
                pushImageToImageView(placeholderImage, url: url)
            }
            }) { (operation, error) -> Void in
                pushImageToImageView(placeholderImage, url: url)
                print("No Image")
        }
        requestOperation.start()
    }
    
    private static func pushImageToImageView(image : UIImage?, url : NSURL?) {
        objc_sync_enter(self.loadingURLs)
        if let urlPath = url?.path, let loadingURLObject = self.loadingURLs[urlPath] {
            let imageViews = loadingURLObject.set
            for imageView in imageViews {
                if self.downloadObjects["\(imageView.hashValue)"]  == url?.path {
                    objc_sync_enter(self.downloadObjects)
                    self.downloadObjects.removeValueForKey("\(imageView.hashValue)")
                    if image != nil {
                    imageView.image = image
                    }
                    objc_sync_exit(self.downloadObjects)
                }
            }
            let completionBlocks = loadingURLObject.completionBlocks
            for block in completionBlocks {
                block()
            }
            self.loadingURLs.removeValueForKey(urlPath)
            objc_sync_exit(self.loadingURLs)
        }
    }
    
    static func loadUserAvatar(user : MMUser, toImageView: UIImageView, placeholderImage:UIImage?) {
        
        loadImageWithUrl(user.avatarURL(), toImageView: toImageView, placeholderImage: placeholderImage)
    }
    
    static func loadUserAvatarByUserID(userID : String, toImageView: UIImageView, placeholderImage:UIImage?) {
        
        toImageView.image = placeholderImage
        
        MMUser.usersWithUserIDs([userID], success: { (users) -> Void in
            let user = users.first
            if (user != nil) {
                Utils.loadUserAvatar(user!, toImageView: toImageView, placeholderImage: placeholderImage)
            }
            }) { (error) -> Void in
                print("error getting users \(error)")
        }
    }
    
    
    static func noAvatarImageForUser(user : MMUser) -> UIImage {
        return Utils.noAvatarImageForUser(user.firstName, lastName: user.lastName ?? "")
    }
    
    static func firstCharacterInString(s: String) -> String {
        if s == "" {
            return ""
        }
        return s.substringWithRange(Range<String.Index>(start: s.startIndex, end: s.endIndex.advancedBy(-(s.characters.count - 1))))
    }
    
    static func noAvatarImageForUser(firstName : String, lastName:String) -> UIImage {
        
        let view : UIView = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        
        let lbl : UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        lbl.backgroundColor = UIColor.jsq_messageBubbleBlueColor()
        let f = firstCharacterInString(firstName).uppercaseString
        let l = firstCharacterInString(lastName).uppercaseString
        
        lbl.text = "\(f)\(l)"
        lbl.textAlignment = NSTextAlignment.Center
        lbl.textColor = UIColor.whiteColor()
        
        view.addSubview(lbl)
        
        let image:UIImage = UIImage.init(view: view)
        return image
    }
}
