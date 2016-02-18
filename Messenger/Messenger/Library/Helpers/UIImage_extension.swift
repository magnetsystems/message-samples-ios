//
//  UIImage_extension.swift
//  Messenger
//
//  Created by Vladimir Yevdokimov on 2/11/16.
//  Copyright © 2016 Magnet Systems, Inc. All rights reserved.
//

import UIKit

class UIImage_extension: NSObject {

}

extension UIImage {
    convenience init(view: UIView) {
        UIGraphicsBeginImageContext(view.frame.size)
        view.layer.renderInContext(UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.init(CGImage: image.CGImage!)
    }
}