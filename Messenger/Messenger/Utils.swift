//
//  Utils.swift
//  Messenger
//
//  Created by Vladimir Yevdokimov on 2/9/16.
//  Copyright © 2016 Magnet Systems, Inc. All rights reserved.
//

import UIKit
import MagnetMax

class Utils: NSObject {
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
    
    static func loadUserAvatarWithUrl(url : NSURL, toImageView: UIImageView, placeholderImage:UIImage) {
        
        if url.absoluteString.characters.count > 0 {
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                let data = NSData(contentsOfURL:url)
                dispatch_async(dispatch_get_main_queue()) {
                    if data!.length > 0 {
                        print("data \(data!.length)")
                        toImageView.image = UIImage(data: data!)
                    } else {
                        print("no url content data")
                        toImageView.image = placeholderImage
                    }
                }
            }
        } else {
            print("no url")
            toImageView.image = placeholderImage
        }
    }
    
    static func loadUserAvatar(user : MMUser, toImageView: UIImageView, placeholderImage:UIImage) {
       
        if let url = user.avatarURL() {
            print("user avatar url \(url)")
        
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                let data = NSData(contentsOfURL:url)
                dispatch_async(dispatch_get_main_queue()) {
                    if data?.length > 0 {
                        print("data \(data?.length)")
                        toImageView.image = UIImage(data: data!)
                    } else {
                        print("no url content data")
                        toImageView.image = placeholderImage
                    }
                }
            }
        } else {
            print("no url")
            toImageView.image = placeholderImage
        }
    }
    
    static func noAvatarImageForUser(user : MMUser) -> UIImage {
        
        let view : UIView = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        
        let lbl : UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        lbl.backgroundColor = UIColor(red: 71/255.0, green: 161/255.0, blue: 1, alpha: 1)
        lbl.text = "\(user.firstName.uppercaseString.characters.first!)\(user.lastName.uppercaseString.characters.first!)"
        lbl.textAlignment = NSTextAlignment.Center
        lbl.textColor = UIColor.whiteColor()
        
        view.addSubview(lbl)
        view.layer.cornerRadius = view.frame.size.width/2
        view.layer.masksToBounds = true
        
        
        let image:UIImage = UIImage.init(view: view)
        return image
    }
}
