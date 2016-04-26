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
