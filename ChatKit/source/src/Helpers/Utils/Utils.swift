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

import MagnetMax

extension UIImage {
    convenience init(view: UIView) {
        UIGraphicsBeginImageContext(view.frame.size)
        view.layer.renderInContext(UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.init(CGImage: image.CGImage!)
    }
}

class UtilsImageOperation : MMAsyncBlockOperation {
    
    
    //Mark: Public variables
    
    
    var url : NSURL?
    weak var imageView : UIImageView?
    var image : UIImage?
}


public class UtilsImageCache : UtilsCache {
    
    
    //Mark: Public variables
    
    
    public var maxImageCacheSize : Int = 4194304 //2^22 = 4mb
    
    
    public static var sharedCache : UtilsImageCache = {
        let cache = UtilsImageCache()
        return cache
    }()
    
    
    public func setImage(image : UIImage, forURL : NSURL) {
        
        let data = UIImagePNGRepresentation(image)
        var size = 0
        if let len = data?.length {
            size = len / 8
        }
        
        self.setObject(image, forURL: forURL, cost:size)
    }
    
    public func imageForUrl(url : NSURL) -> UIImage? {
        return self.objectForURL(url) as? UIImage
    }
}

public class Utils: NSObject {
    
    
    //MARK: Private Properties
    
    
    private static var queue : NSOperationQueue = {
        let queue = NSOperationQueue()
        queue.underlyingQueue = dispatch_queue_create("operation - images", nil)
        queue.maxConcurrentOperationCount = 100
        return queue
    }()
    
    
    //MARK: Image Loading
    
    
    public static func loadImageWithUrl(url : NSURL, toImageView : UIImageView, placeholderImage:UIImage?) {
        loadImageWithUrl(url, toImageView: toImageView, placeholderImage: placeholderImage, defaultImage: placeholderImage)
    }
    
    public static func loadImageWithUrl(url : NSURL, toImageView: UIImageView, placeholderImage :UIImage?,  defaultImage : UIImage?) {
        loadImageWithUrl(url, toImageView: toImageView, placeholderImage: placeholderImage,defaultImage: defaultImage, aspectSize : nil)
    }
    
    public static func loadImageWithUrl(url : NSURL, completion : ((image : UIImage?)->Void)) {
        loadImageWithUrl(url, completion: completion, aspectSize: nil)
    }
    
    public static func loadUserAvatar(user : MMUser, toImageView: UIImageView, placeholderImage : UIImage?) {
        loadUserAvatar(user, toImageView: toImageView, placeholderImage: placeholderImage, aspectSize: nil)
    }
    
    
    //MARK: Image loading with size in view
    
    
    public static func loadImageWithUrl(url : NSURL, toImageView : UIImageView, placeholderImage:UIImage?, aspectSize : CGSize?) {
        loadImageWithUrl(url, toImageView: toImageView, placeholderImage: placeholderImage, defaultImage: placeholderImage)
    }
    
    public static func loadImageWithUrl(url : NSURL, toImageView: UIImageView, placeholderImage :UIImage?,  defaultImage : UIImage?, aspectSize : CGSize?) {
        imageWithUrl(url, toImageView: toImageView, placeholderImage : placeholderImage, defaultImage : defaultImage, completion : nil, aspectSize : aspectSize)
    }
    
    public static func loadImageWithUrl(url : NSURL, completion : ((image : UIImage?)->Void), aspectSize : CGSize?) {
        imageWithUrl(url, toImageView: nil, placeholderImage : nil, defaultImage : nil, completion : completion, aspectSize : aspectSize)
    }
    
    public static func loadUserAvatar(user : MMUser, toImageView: UIImageView, placeholderImage : UIImage?, aspectSize : CGSize?) {
        if let url = user.avatarURL() {
            loadImageWithUrl(url, toImageView: toImageView, placeholderImage: placeholderImage, aspectSize : aspectSize)
        } else {
            imageWithUrl(nil, toImageView: toImageView, placeholderImage: placeholderImage, defaultImage: placeholderImage, completion: nil, aspectSize: nil)
        }
    }
    
    
    //MARK: User Avatar Generation
    
    
    public static func firstCharacterInString(s: String) -> String {
        if s == "" {
            return ""
        }
        return s.substringWithRange(Range<String.Index>(start: s.startIndex, end: s.endIndex.advancedBy(-(s.characters.count - 1))))
    }
    
    public class func name(name: AnyClass) -> String {
        let ident:String = NSStringFromClass(name).componentsSeparatedByString(".").last!
        return ident
    }
    
    public static func noAvatarImageForUser(user : MMUser) -> UIImage {
        return Utils.noAvatarImageForUser(user.firstName, lastName: user.lastName ?? "")
    }
    
    public static func noAvatarImageForUser(firstName : String?, lastName:String?) -> UIImage {
        var fName = ""
        var lName = ""
        
        if let firstName = firstName{
            fName = firstName
        }
        
        if let lastName = lastName {
            lName = lastName
        }
        
        let diameter : CGFloat = 30.0 * 3
        
        let view : UIView = UIView(frame: CGRect(x: 0, y: 0, width: diameter, height: diameter))
        let lbl : UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: diameter, height: diameter))
        lbl.backgroundColor = MagnetControllerAppearance.tintColor
        let f = firstCharacterInString(fName).uppercaseString
        let l = firstCharacterInString(lName).uppercaseString
        lbl.font = UIFont.systemFontOfSize(diameter * 0.5)
        lbl.text = "\(f)\(l)"
        lbl.textAlignment = NSTextAlignment.Center
        lbl.textColor = UIColor.whiteColor()
        
        view.addSubview(lbl)
        
        let image:UIImage = UIImage.init(view: view)
        return image
    }
    
    public class func resizeImage(image:UIImage, toSize:CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(toSize, false, 0.0);
        image.drawInRect(CGRect(x: 0, y: 0, width: toSize.width, height: toSize.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return newImage;
    }
    
    
    //MARK: User Naming
    
    
    public class func displayNameForUser(user : MMUser) -> String {
        //create username
        var name : String = ""
        if user.firstName != nil {
            name = "\(user.firstName)"
        }
        if user.lastName != nil {
            name += (name.characters.count > 0 ? " " : "") + user.lastName
        }
        
        if name.characters.count == 0 {
            name = user.userName
        }
        
        return name
    }
    
    public class func nameForUser(user : MMUser) -> String {
        //create username
        var name = user.userName
        if user.lastName != nil {
            name = user.lastName
        } else if user.firstName != nil {
            name = user.firstName
        }
        return name
    }
    
    
    //MARK: Private Methods
    
    
    private static func aspectResizeImage(image : UIImage, size : CGSize) -> UIImage {
        var resizedImage = image
        let maxSize = CGSize(width: 50.0, height: 50.0)
        let newSize = CGSize.aspectFit(image.size, boundingSize: maxSize)
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        CGContextSetInterpolationQuality(UIGraphicsGetCurrentContext(), .High);
        image.drawInRect(CGRect(origin: CGPointZero, size: newSize))
        resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return resizedImage
    }
    
    private static func imageWithUrl(url : NSURL?, toImageView: UIImageView?, placeholderImage : UIImage?, defaultImage : UIImage?, completion : ((image : UIImage?)->Void)?, aspectSize : CGSize?) {
        
        var dependencies : [UtilsImageOperation] = []
        for operation in queue.operations {
            if let imageOperation = operation as? UtilsImageOperation {
                if imageOperation.url?.path != url?.path && imageOperation.imageView != nil && imageOperation.imageView == toImageView {
                    imageOperation.imageView = nil
                    imageOperation.cancel()
                } else if imageOperation.url?.path == url?.path {
                    dependencies.append(imageOperation)
                }
            }
        }
        
        if let imageUrl = url {
            if let image = UtilsImageCache.sharedCache.imageForUrl(imageUrl) {
                var resizedImage = image
                if let size = aspectSize {
                    resizedImage = aspectResizeImage(image, size: size)
                }
                //loading image from cache
                toImageView?.image = resizedImage
                completion?(image: image)
                return
            }
            
            if let placeHolder = placeholderImage, let imageView = toImageView {
                //adding placeholder
                imageView.image = placeHolder
            }
            
            let imageOperation = UtilsImageOperation(with: { operation in
                
                if let imageOperation = operation as? UtilsImageOperation {
                    
                    if let operations = imageOperation.dependencies as? [UtilsImageOperation] {
                        for imOp in operations {
                            if let image = imOp.image {
                                var resizedImage = image
                                if let size = aspectSize {
                                    resizedImage = aspectResizeImage(image, size: size)
                                }
                                dispatch_sync(dispatch_get_main_queue(), {
                                    imageOperation.imageView?.image = resizedImage
                                    completion?(image: resizedImage)
                                })
                                imageOperation.finish()
                                return
                            }
                        }
                    }
                    
                    if let image = UtilsImageCache.sharedCache.imageForUrl(imageUrl) {
                        var resizedImage = image
                        if let size = aspectSize {
                            resizedImage = aspectResizeImage(image, size: size)
                        }
                        //loading image from cache in operation
                        dispatch_sync(dispatch_get_main_queue(), {
                            imageOperation.imageView?.image = resizedImage
                            completion?(image: resizedImage)
                        })
                        imageOperation.finish()
                        return
                    }
                    
                    var image  : UIImage?
                    //download image
                    if  let imageData = NSData(contentsOfURL: imageUrl) {
                        image = UIImage(data: imageData)
                    }
                    
                    imageOperation.image = image
                    let newImg = imageFromOperation(imageOperation, defaultImage: defaultImage, aspectSize: aspectSize)
                    dispatch_sync(dispatch_get_main_queue(), {
                        completion?(image: newImg)
                    })
                    
                    //image loading complete
                    imageOperation.finish()
                }
            })
            
            imageOperation.imageView = toImageView
            imageOperation.url = imageUrl
            for operation in dependencies {
                imageOperation.addDependency(operation)
            }
            self.queue.addOperation(imageOperation)
        } else {
            if let placeHolder = placeholderImage, let imageView = toImageView {
                //adding placeholder
                imageView.image = placeHolder
            }
        }
    }
    
    private static func imageFromOperation(operation : UtilsImageOperation, defaultImage : UIImage?, aspectSize : CGSize?) -> UIImage? {
        
        var downloadedImage : UIImage?
        if let img = operation.image {
            //using downloaded image
            downloadedImage = img
            if let url = operation.url {
                //set image in cache
                UtilsImageCache.sharedCache.setImage(img, forURL: url)
            }
            if let size = aspectSize, let resizeImage = downloadedImage {
                downloadedImage = aspectResizeImage(resizeImage, size: size)
            }
        } else {
            //using default image
            downloadedImage = defaultImage
        }
        
        if let imageView = operation.imageView {
            dispatch_sync(dispatch_get_main_queue(), {
                imageView.image = downloadedImage
            })
        }
        
        return downloadedImage
    }
}

extension CGSize {
    static func aspectFit(aspectRatio : CGSize, boundingSize: CGSize) -> CGSize {
        var size = boundingSize
        let mW = size.width / aspectRatio.width;
        let mH = size.height / aspectRatio.height;
        
        if( mH < mW ) {
            size.width = size.height / aspectRatio.height * aspectRatio.width;
        }
        else if( mW < mH ) {
            size.height = size.width / aspectRatio.width * aspectRatio.height;
        }
        
        return size;
    }
    
    static func aspectFill(aspectRatio :CGSize, minimumSize: CGSize) -> CGSize {
        var size = minimumSize
        let mW = size.width / aspectRatio.width;
        let mH = size.height / aspectRatio.height;
        
        if( mH > mW ) {
            size.width = size.height / aspectRatio.height * aspectRatio.width;
        }
        else if( mW > mH ) {
            size.height = size.width / aspectRatio.width * aspectRatio.height;
        }
        
        return size;
    }
}

extension Array {
    
    func findInsertionIndexForSortedArray<T : Comparable>(mappedObject : ((obj : Generator.Element) -> T), object :  T) -> Int {
        return  self.findInsertionIndexForSortedArrayWithBlock() { (haystack) -> Bool in
            return mappedObject(obj: haystack) > object
        }
    }
    
    func findInsertionIndexForSortedArrayWithBlock(greaterThan GR_TH : (Generator.Element) -> Bool) -> Int {
        return Array.findInsertionIndex(self) { (haystack) -> Bool in
            return GR_TH(haystack)
        }
    }
    
    func searchrSortedArrayWithBlock(greaterThan GR_TH : (Generator.Element) -> Bool?) -> Int? {
        return Array.find(self) { (haystack) -> Bool? in
            return GR_TH(haystack)
        }
    }
    
    func searchrSortedArray<T : Comparable>(mappedObject : ((obj : Generator.Element) -> T), object :  T) -> Int? {
        return self.searchrSortedArrayWithBlock() { (haystack) -> Bool? in
            let mapped = mappedObject(obj: haystack)
            if mapped == object {
                return nil
            }
            return mapped > object
        }
    }
    
    static private func find(haystack : Array<Element>, greaterThan : (haystack : Generator.Element) -> Bool?) -> Int? {
        //search for index of user group based on letter
        if haystack.count == 0 {
            return nil
        }
        
        let index = haystack.count >> 0x1
        let compare = haystack[index]
        
        let isGreater = greaterThan(haystack: compare)
        if isGreater == nil {//if equal
            return index
        } else if let greater = isGreater where greater == true { //if greater
            return find(Array(haystack[0..<index]), greaterThan : greaterThan)
        }
        
        if let rightIndex = find(Array(haystack[index + 1..<haystack.count]), greaterThan : greaterThan) {
            return rightIndex + index + 1
        }
        
        return nil
    }
    
    static private func findInsertionIndex(haystack : Array<Element>, greaterThan : ((haystack : Generator.Element) -> Bool)) -> Int {
        if haystack.count == 0 {
            return 0
        }
        let index = haystack.count >> 0x1
        let compare = haystack[index]
        
        if greaterThan(haystack: compare) {
            return findInsertionIndex(Array(haystack[0..<index]), greaterThan : greaterThan)
        }
        
        return findInsertionIndex(Array(haystack[index + 1..<haystack.count]), greaterThan : greaterThan) + 1 + index
    }
}

extension Array where Element : Comparable {
    
    func findInsertionIndexForSortedArray(obj : Generator.Element) -> Int {
        return  self.findInsertionIndexForSortedArrayWithBlock() { (haystack) -> Bool in
            return haystack > obj
        }
    }
    
    func searchrSortedArray(obj : Generator.Element) -> Int? {
        return self.searchrSortedArrayWithBlock() { (haystack) -> Bool? in
            if haystack == obj {
                return nil
            }
            return haystack > obj
        }
    }
}

public class MagnetControllerAppearance {
    public static var tintColor : UIColor = UIColor(hue: 210.0 / 360.0, saturation: 0.94, brightness: 1.0, alpha: 1.0)
    public var tintColor : UIColor {
        set {
            self.dynamicType.tintColor = newValue
        }
        get {
            return self.dynamicType.tintColor
        }
    }
}
