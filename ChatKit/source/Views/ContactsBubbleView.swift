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

protocol ContactsBubbleViewDelegate : class {
    func didSelectBubbleViewAvatar(view : ContactsBubbleView)
}

public class ContactsBubbleView : UIView, UIGestureRecognizerDelegate {
    
    
    //MARK: Public Variables
    
    
    weak var delegate : ContactsBubbleViewDelegate?
    var imageView : UIImageView?
    var title : UILabel?
    weak var user : MMUser?
    
    
    //MARK: Creation
    
    
    static func newBubbleView() -> ContactsBubbleView {
        let view = ContactsBubbleView(frame: CGRect(x: 0, y: 0, width: 50, height: 0))
        view.translatesAutoresizingMaskIntoConstraints = false
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        imageView.layer.cornerRadius = imageView.frame.size.width / 2.0
        imageView.clipsToBounds = true
        imageView.contentMode = .ScaleAspectFill
        imageView.autoresizingMask = [.FlexibleHeight, .FlexibleWidth]
        let imageContainer = UIView(frame: CGRect(x: 0, y: 5, width: imageView.frame.size.width, height: imageView.frame.size.height))
        imageContainer.addSubview(imageView)
        imageContainer.translatesAutoresizingMaskIntoConstraints = false
        
        let label = UILabel(frame: CGRect(x: 0, y: CGRectGetMaxY(imageContainer.frame), width: 0, height: 16))
        label.textAlignment = .Center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFontOfSize(10)
        label.textColor = UIColor.grayColor()
        
        let centerX = NSLayoutConstraint(item: imageContainer, attribute: .CenterX, relatedBy: .Equal, toItem: view, attribute: .CenterX, multiplier: 1, constant: 0)
        let imageYSpace = NSLayoutConstraint(item: imageContainer, attribute: .Top, relatedBy: .Equal, toItem: view, attribute: .Top, multiplier: 1, constant: 0)
        let imageWidth = NSLayoutConstraint(item: imageContainer, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: imageContainer.frame.size.width)
        let imageHeight = NSLayoutConstraint(item: imageContainer, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: imageContainer.frame.size.height)
        
        let labelYSpace = NSLayoutConstraint(item: label, attribute: .Top, relatedBy: .Equal, toItem: imageContainer, attribute: .Bottom, multiplier: 1, constant: 0)
        let labelBottom = NSLayoutConstraint(item: label, attribute: .Bottom, relatedBy: .Equal, toItem: view, attribute: .Bottom, multiplier: 1, constant: 0)
        let labelLeading = NSLayoutConstraint(item: label, attribute: .Leading, relatedBy: .Equal, toItem: view, attribute: .Leading, multiplier: 1, constant: 0)
        let labelTrailing = NSLayoutConstraint(item: label, attribute: .Trailing, relatedBy: .Equal, toItem: view, attribute: .Trailing, multiplier: 1, constant: 0)
        let labelHeight =  NSLayoutConstraint(item: label, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: label.frame.size.height)
        //label constraints
        view.addSubview(imageContainer)
        view.addSubview(label)
        view.addConstraints([centerX, imageYSpace, imageWidth, imageHeight, labelYSpace, labelBottom, labelLeading, labelTrailing,labelHeight])
        view.title = label
        view.imageView = imageView
        
        let tap = UITapGestureRecognizer(target: view, action: "didTapAvatar:")
        tap.cancelsTouchesInView = true
        tap.delaysTouchesBegan = true
        view.imageView?.userInteractionEnabled = true
        view.imageView?.addGestureRecognizer(tap)
        
        return view
    }
    
    
    func didTapAvatar(gesture : UITapGestureRecognizer) {
        self.delegate?.didSelectBubbleViewAvatar(self)
    }
    
    //MARK: Action
    
    
    public func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}