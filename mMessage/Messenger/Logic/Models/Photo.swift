//
//  Photo.swift
//  MMChat
//
//  Created by Kostya Grishchenko on 1/22/16.
//  Copyright © 2016 Kostya Grishchenko. All rights reserved.
//

import NYTPhotoViewer

class Photo: NSObject, NYTPhoto {
    
    private let photo: UIImage
    
    init(photo: UIImage) {
        self.photo = photo
    }
    
    var image: UIImage? { return photo }

    var imageData: NSData? { return nil }
    
    var placeholderImage: UIImage? { return nil }

    var attributedCaptionTitle: NSAttributedString? { return nil }

    var attributedCaptionSummary: NSAttributedString? { return nil }    

    var attributedCaptionCredit: NSAttributedString? { return nil }
}
