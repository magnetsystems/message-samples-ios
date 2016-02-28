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

import AFNetworking
import MagnetMax
import UIKit

extension UIImage {
    convenience init(view: UIView) {
        UIGraphicsBeginImageContext(view.frame.size)
        view.layer.renderInContext(UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.init(CGImage: image.CGImage!)
    }
}

class UtilsSet {
    
    var completionBlocks : [((image : UIImage?)->Void)] = []
    var set : Set<UIImageView> = Set()
    
    func addCompletionBlock(completion : ((image : UIImage?)->Void)?) {
        if let completion = completion {
            completionBlocks.append(completion)
        }
    }
}

class Utils: NSObject {
    
    
    //MARK: Private Properties
    
    
    private static var downloadObjects : [String : String] = [:]
    private static var loadingURLs : [String : UtilsSet] = [:]
    
    //MARK: Image Loading
    
    
    static func loadImageWithUrl(url : NSURL?, toImageView: UIImageView, placeholderImage:UIImage?) {
        loadImageWithUrl(url, toImageView: toImageView, placeholderImage: placeholderImage, completion: nil)
    }
    
    static func loadImageWithUrl(url : NSURL?, toImageView: UIImageView, placeholderImage:UIImage?,  onlyShowAfterDownload:Bool) {
        loadImageWithUrl(url, toImageView: toImageView, placeholderImage: placeholderImage, onlyShowAfterDownload:onlyShowAfterDownload, completion: nil)
    }
    
    static func loadImageWithUrl(url : NSURL?, toImageView: UIImageView, placeholderImage:UIImage?, completion : ((image : UIImage?)->Void)?) {
        loadImageWithUrl(url, toImageView: toImageView, placeholderImage: placeholderImage,  onlyShowAfterDownload: placeholderImage == nil, completion: completion)
    }
    
    static func loadImageWithUrl(url : NSURL?, toImageView: UIImageView, placeholderImage:UIImage?,  onlyShowAfterDownload:Bool, completion : ((image : UIImage?)->Void)?) {
        imageWithUrl(url, toImageView: toImageView, placeholderImage: placeholderImage,  onlyShowAfterDownload: onlyShowAfterDownload, completion: completion)
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
                //print("error getting users \(error)")
        }
    }
    
    
    //MARK: User Avatar Generation
    
    
    static func firstCharacterInString(s: String) -> String {
        if s == "" {
            return ""
        }
        return s.substringWithRange(Range<String.Index>(start: s.startIndex, end: s.endIndex.advancedBy(-(s.characters.count - 1))))
    }
    
    class func name(name: AnyClass) -> String {
        let ident:String = NSStringFromClass(name).componentsSeparatedByString(".").last!
        return ident
    }
    
    static func noAvatarImageForUser(user : MMUser) -> UIImage {
        return Utils.noAvatarImageForUser(user.firstName, lastName: user.lastName ?? "")
    }
    
    static func noAvatarImageForUser(firstName : String?, lastName:String?) -> UIImage {
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
    
    class func resizeImage(image:UIImage, toSize:CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(toSize, false, 0.0);
        image.drawInRect(CGRect(x: 0, y: 0, width: toSize.width, height: toSize.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return newImage;
    }
    
    
    //MARK: Private Methods
    
    
    private static func imageWithUrl(url : NSURL?, toImageView: UIImageView, placeholderImage:UIImage?, onlyShowAfterDownload:Bool, completion : ((image : UIImage?)->Void)?) {
        
        if  !onlyShowAfterDownload {
            toImageView.image = placeholderImage
        }
        
        guard let imageUrl = url else {
            //print("no url content data")
            objc_sync_enter(self.downloadObjects)
            self.downloadObjects.removeValueForKey("\(toImageView.hashValue)")
            objc_sync_exit(self.downloadObjects)
            completion?(image: nil)
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
                //print("No Image")
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
                block(image:image)
            }
            self.loadingURLs.removeValueForKey(urlPath)
            objc_sync_exit(self.loadingURLs)
        }
    }
    
}


extension Array where Element : Comparable {
    
    func findInsertionIndexForSortedArray(obj : Generator.Element) -> Int {
        return Array.findInsertionIndex(self) { (haystack) -> Bool in
            return haystack > obj
        }
    }
    
    func searchrSortedArray(obj : Generator.Element) -> Int? {
        return Array.find(self) { (haystack) -> Bool? in
            if haystack == obj {
                return nil
            }
            return haystack > obj
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
