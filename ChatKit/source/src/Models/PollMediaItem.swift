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

public class PollMediaItem: JSQMediaItem {
    
    
    //MARK: Public Variables
    
    
    public var buttonBackgroundColor = UIColor(red: 0, green: 122/255.0, blue: 255/255.0, alpha: 1.0)
    public var buttonBorderColor = UIColor.whiteColor()
    public var buttonBorderWidth: CGFloat = 2.0
    public var bottomConstraint: NSLayoutConstraint?
    public let buttonHeight: CGFloat = 44.0
    public var buttonTextColor = UIColor.whiteColor()
    public internal(set) var channel : MMXChannel? {
        didSet {
            ChannelManager.sharedInstance.removeChannelMessageObserver(self)
            if let channel = self.channel {
                ChannelManager.sharedInstance.addChannelMessageObserver(self, channel: channel, selector: #selector(PollMediaItem.didReceiveMessage(_:)))
            }
        }
    }
    public var cornerRadius: CGFloat = 3.0
    public let padding: CGFloat = 10.0
    public var viewBackgroundColor = UIColor.lightGrayColor()
    public var onUpdate: (() -> Void)?
    public var poll : MMXPoll?
    
    
    //Private Variables
    
    
    private var cachedView: UIView?
    private var count = 1
    internal var message: MMXMessage?
    private var isRetrievingPoll = false
    
    
    //MARK: Nofication
    
    
    func didReceiveMessage(message : MMXMessage) {
        if message.contentType == MMXPollAnswer.contentType {
            clearCachedMediaViews()
            onUpdate?()
        }
    }
    
    
    //MARK: Poll Loading
    
    
    func retrievePoll() {
        guard let message = self.message where isRetrievingPoll else {
            return
        }
        isRetrievingPoll = true
        MMXPoll.pollFromMessage(message, success: { poll in
            self.poll = poll
            self.clearCachedMediaViews()
            self.onUpdate?()
            }, failure: { error in
                print("error retrieving poll - \(error.localizedDescription)")
        })
    }
    
    
    //MARK: JSQMediaItem View Generation
    
    
    func addButton(view : UIView, label : String) {
        var leftView = view
        if let left = view.viewWithTag(count - 1) where count > 1 {
            leftView = left
        }
        if let constraint = bottomConstraint {
            view.removeConstraint(constraint)
        }
        let button = UIButton(type: .Custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(button)
        button.tag = count
        button.setTitle(label, forState: .Normal)
        button.layer.cornerRadius = cornerRadius
        button.backgroundColor = buttonBackgroundColor
        button.titleLabel?.textColor = buttonTextColor
        button.layer.borderColor = buttonBorderColor.CGColor
        button.layer.borderWidth = buttonBorderWidth
        
        var top = NSLayoutConstraint(item: button, attribute: .Top, relatedBy: .Equal, toItem: view, attribute: .Top, multiplier: 1, constant: padding)
        
        var height = NSLayoutConstraint(item: button, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: buttonHeight)
        
        if leftView != view {
            top = NSLayoutConstraint(item: button, attribute: .Top, relatedBy: .Equal, toItem: leftView, attribute: .Bottom, multiplier: 1, constant: padding)
            height = NSLayoutConstraint(item: button, attribute: .Height, relatedBy: .Equal, toItem: leftView, attribute: .Height, multiplier: 1, constant: 0)
        }
        height.priority = 900
        view.addConstraint(height)
        
        let leading = NSLayoutConstraint(item: button, attribute: .Leading, relatedBy: .Equal, toItem: view, attribute: .Leading, multiplier: 1, constant: padding)
        let trailing = NSLayoutConstraint(item: button, attribute: .Trailing, relatedBy: .Equal, toItem: view, attribute: .Trailing, multiplier: 1, constant: -padding)
        
        let bottom = NSLayoutConstraint(item: button, attribute: .Bottom, relatedBy: .Equal, toItem: view, attribute: .Bottom, multiplier: 1, constant: -padding)
        bottomConstraint = bottom
        view.addConstraints([top, bottom, leading, trailing])
        count += 1
    }
    
    func buttonsForDisplay() -> [String] {
        var buttons = [String]()
        if let poll = self.poll {
            for option in poll.options {
                let value = "\(option.text) (\(option.count))"
                buttons.append(value)
            }
        }
        return buttons
    }
    
    override public func clearCachedMediaViews() {
        super.clearCachedMediaViews()
        self.cachedView = nil
    }
    
    override public func mediaView() -> UIView! {
        guard self.cachedView == nil else {
            return self.cachedView!
        }
        
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = viewBackgroundColor
        view.layer.cornerRadius = cornerRadius
        
        guard poll != nil else {
            return view
        }
        
        count = 1
        
        let buttons = buttonsForDisplay()
        
        for button in buttons {
            addButton(view, label: button)
        }
        self.cachedView = view
        
        return view
    }
    
    override public func mediaViewDisplaySize() -> CGSize {
        let size = super.mediaViewDisplaySize()
        let totalPadding : CGFloat = (CGFloat(buttonsForDisplay().count) + 1) * padding
        let totalHeight : CGFloat = buttonHeight * CGFloat(buttonsForDisplay().count) + totalPadding
        let mediaSize = CGSize(width: size.width, height: buttonsForDisplay().count > 0 ? totalHeight : 100)
        
        return mediaSize
    }
}