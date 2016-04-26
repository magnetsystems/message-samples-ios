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
import MMX

public class PollMediaButton : UIButton {
    public var pollOption: MMXPollOption?
    
    public var rightLabel: UILabel? {
        didSet {
            oldValue?.removeFromSuperview()
            if let label = rightLabel {
                label.translatesAutoresizingMaskIntoConstraints = false
                let trailing = NSLayoutConstraint(item: label, attribute: .Trailing, relatedBy: .Equal, toItem: self, attribute: .Trailing, multiplier: 1, constant: -8)
                
                let width = NSLayoutConstraint(item: label, attribute: .Width , relatedBy: .Equal, toItem: label, attribute: .Height, multiplier: 1, constant: 0)
                
                let top = NSLayoutConstraint(item: label, attribute: .Top , relatedBy: .Equal, toItem: self, attribute: .Top, multiplier: 1, constant: 8)
                
                let bottom = NSLayoutConstraint(item: label, attribute: .Bottom, relatedBy: .Equal, toItem: self, attribute: .Bottom, multiplier: 1, constant: -8)
                
                self.addSubview(label)
                self.addConstraints([trailing, top, bottom, width])
            }
        }
    }
}

public class PollUpdateItem: JSQMediaItem {
    var text : String?
    override public func mediaView() -> UIView! {
        let label = UILabel()
        label.textColor = UIColor.darkGrayColor()
        label.text = text
        label.textAlignment = .Center
        label.font = UIFont.systemFontOfSize(12)
        return label
    }
    
    override public func mediaViewDisplaySize() -> CGSize {
        return CGSize(width: super.mediaViewDisplaySize().width, height: 40.0)
    }
}

public class PollMediaItem: JSQMediaItem {
    
    
    //MARK: Public Variables
    
    
    public var buttonBorderColor = UIColor.whiteColor()
    public var buttonBorderWidth: CGFloat = 2.0
    public var bottomConstraint: NSLayoutConstraint?
    public let buttonHeight: CGFloat = 44.0
    public var darkColor = UIColor(red: 62/255.0, green: 154/255.0, blue: 252/255.0, alpha: 1.0)
    public let labelHeight: CGFloat = 25.0
    public var lightColor = UIColor(red: 196/255.0, green: 217/255.0, blue: 248/255.0, alpha: 1.0)
    public var hightLightColor = UIColor.whiteColor()
    public private(set) var channel : MMXChannel? {
        didSet {
            ChannelManager.sharedInstance.removeChannelMessageObserver(self)
            if let channel = self.channel {
                ChannelManager.sharedInstance.addChannelMessageObserver(self, channel: channel, selector: #selector(PollMediaItem.didReceiveMessage(_:)))
            }
        }
    }
    public var cornerRadius: CGFloat = 10.0
    public let padding: CGFloat = 10.0
    public var viewBackgroundColor = UIColor(red: 3/255.0, green: 125/255.0, blue: 255/255.0, alpha: 1.0)
    public var onUpdate: (() -> Void)?
    public var poll : MMXPoll?
    
    
    //Private Variables
    
    
    private var buttons = [PollMediaButton]()
    private var cachedView: UIView?
    private var count = 1
    private var viewHeight:CGFloat = 0.0
    private var lastPadding: CGFloat?
    internal var message: MMXMessage? {
        didSet {
            channel = message?.channel
            retrievePoll()
        }
    }
    
    private var isRetrievingPoll = false
    
    
    //MARK: Nofication
    
    
    func didReceiveMessage(message : MMXMessage) {
        if message.contentType == MMXPollAnswer.contentType {
            if let answer = message.payload as? MMXPollAnswer where answer.pollID == poll?.pollID && poll?.pollID != nil {
                self.poll?.refreshResults(answer: answer)
                updatePoll()
            }
        }
    }
    
    //MARK: Poll Loading
    
    func updatePoll() {
        for button in buttons {
            if let count = button.pollOption?.count {
                button.rightLabel?.text = "\(count.integerValue)"
            }
        }
        updateButtons()
    }
    
    func updateButtons() {
        for button in self.buttons {
            if let myOptions = self.poll?.myVotes?.filter({$0 == button.pollOption}) where myOptions.count > 0 {
                button.rightLabel?.backgroundColor = darkColor
                button.rightLabel?.textColor = hightLightColor
                
                button.backgroundColor = lightColor
                button.setTitleColor(hightLightColor, forState: .Normal)
            } else {
                button.rightLabel?.backgroundColor = lightColor
                button.rightLabel?.textColor = hightLightColor
                
                button.backgroundColor = darkColor
                button.setTitleColor(hightLightColor, forState: .Normal)
            }
        }
    }
    
    func retrievePoll() {
        guard let message = self.message where !isRetrievingPoll else {
            return
        }
        isRetrievingPoll = true
        MMXPoll.pollFromMessage(message, success: { poll in
            self.poll = poll
            self.clearCachedMediaViews()
            self.onUpdate?()
            self.isRetrievingPoll = false
            }, failure: { error in
                self.isRetrievingPoll = false
                print("error retrieving poll - \(error.localizedDescription)")
        })
    }
    
    func refreshPoll(button: PollMediaButton) {
       self.poll?.refreshResults(completion: { (poll) in
        self.updatePoll()
       })
    }
    
    func didSelectButton(button: PollMediaButton) {
        if let option = button.pollOption, var options = self.poll?.myVotes, let poll = self.poll {
            if options.count == options.filter({$0 != option}).count {
                if poll.allowMultiChoice {
                    options.append(option)
                } else {
                    options.removeAll()
                    options.append(option)
                }
            } else {
                options = options.filter({$0 != option})
            }
            button.enabled = false
            self.cachedView?.userInteractionEnabled = false
            poll.choose(options: options, success: { (message) in
                button.enabled = true
                self.updateButtons()
                if poll.ownerID != nil && poll.ownerID == MMUser.currentUser()?.userID && poll.hideResultsFromOthers {
                    poll.refreshResults(completion: { poll in
                        self.updatePoll()
                        self.cachedView?.userInteractionEnabled = true
                    })
                } else {
                    self.cachedView?.userInteractionEnabled = true
                }
                }, failure: { (error) in
                    button.enabled = true
                    self.cachedView?.userInteractionEnabled = true
                    self.updateButtons()
            })
        }
    }
    
    
    //MARK: JSQMediaItem View Generation
    
    
    func addButton(view : UIView, label : String) -> PollMediaButton {
        let button = PollMediaButton(type: .System)
        button.setTitle(label, forState: .Normal)
        button.layer.cornerRadius = cornerRadius
        button.layer.borderColor = buttonBorderColor.CGColor
        button.layer.borderWidth = buttonBorderWidth
        button.titleLabel?.minimumScaleFactor = 0.5
        addView(view, subview: button, height: buttonHeight, padding: padding)
        return button
    }
    
    func addLabel(view : UIView, text : String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.textAlignment = .Left
        label.minimumScaleFactor = 0.5
        label.lineBreakMode = .ByTruncatingMiddle
        label.textColor = hightLightColor
        addView(view, subview: label, height: labelHeight, padding: padding)
        
        return label
    }

    func addView(superview : UIView, subview : UIView, height : CGFloat, padding: CGFloat) {
        subview.tag = count
        var leftView = superview
        if let left = superview.viewWithTag(count - 1) where count > 1 {
            leftView = left
        }
        if let lastPadding = self.lastPadding {
            viewHeight -= lastPadding
        }
        if let constraint = bottomConstraint {
            superview.removeConstraint(constraint)
        }
        superview.translatesAutoresizingMaskIntoConstraints = false
        subview.translatesAutoresizingMaskIntoConstraints = false
        superview.addSubview(subview)
        var top = NSLayoutConstraint(item: subview, attribute: .Top, relatedBy: .Equal, toItem: superview, attribute: .Top, multiplier: 1, constant: padding)
        
        let heightConstraint = NSLayoutConstraint(item: subview, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: height)
        
        if leftView != superview {
            top = NSLayoutConstraint(item: subview, attribute: .Top, relatedBy: .Equal, toItem: leftView, attribute: .Bottom, multiplier: 1, constant: padding)
        }
        superview.addConstraint(heightConstraint)
        
        let leading = NSLayoutConstraint(item: subview, attribute: .Leading, relatedBy: .Equal, toItem: superview, attribute: .Leading, multiplier: 1, constant: padding)
        let trailing = NSLayoutConstraint(item: subview, attribute: .Trailing, relatedBy: .Equal, toItem: superview, attribute: .Trailing, multiplier: 1, constant: -padding)
        
        let bottom = NSLayoutConstraint(item: subview, attribute: .Bottom, relatedBy: .Equal, toItem: superview, attribute: .Bottom, multiplier: 1, constant: -padding)
        bottomConstraint = bottom
        bottom.priority = 900
        superview.addConstraints([top, bottom, leading, trailing])
        viewHeight += padding + height + padding
        lastPadding = padding
        count += 1
    }
    
    func optionsForDisplay() -> [MMXPollOption] {
        return self.poll?.options ?? []
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
        view.backgroundColor = viewBackgroundColor
        view.layer.cornerRadius = cornerRadius
        
        guard let poll = self.poll else {
            return view
        }
        count = 1
        viewHeight = 0.0
        lastPadding = 0.0
        self.buttons.removeAll()
        let topView = UIView()
        let questionLabel = UILabel()
        questionLabel.text = poll.question
        questionLabel.textAlignment = .Left
        questionLabel.minimumScaleFactor = 0.5
        questionLabel.adjustsFontSizeToFitWidth = true
        questionLabel.lineBreakMode = .ByTruncatingTail
        questionLabel.textColor = hightLightColor
        questionLabel.translatesAutoresizingMaskIntoConstraints = false
        questionLabel.setContentCompressionResistancePriority(999, forAxis: .Horizontal)
        
        let nameLabel = UILabel()
        nameLabel.text = "\(poll.name):"
        nameLabel.textAlignment = .Left
        nameLabel.font = UIFont.boldSystemFontOfSize(14.0)
        nameLabel.minimumScaleFactor = 0.5
        nameLabel.lineBreakMode = .ByTruncatingTail
        nameLabel.textColor = hightLightColor
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.adjustsFontSizeToFitWidth = true
        nameLabel.setContentHuggingPriority(999, forAxis: .Horizontal)
        
        topView.addSubview(questionLabel)
        topView.addSubview(nameLabel)
        
        let constraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|[name]-[question]|", options: [.AlignAllBaseline, .AlignAllTop], metrics: nil, views: ["question": questionLabel,"name": nameLabel])
        let vConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:|[name]|", options: .AlignAllBaseline, metrics: nil, views: ["name": nameLabel])
        
        topView.addConstraints(constraints)
        topView.addConstraints(vConstraints)
        addView(view, subview: topView, height: 30, padding: 8)
        
        let border = UIView()
        border .backgroundColor = UIColor.whiteColor()
        addView(view, subview: border, height: 1, padding: 0)
        let options = optionsForDisplay()
        
        for option in options {
            let button = addButton(view, label: option.text)
            let label = MMRoundedLabel()
            label.textAlignment = .Center
            if self.poll?.hideResultsFromOthers == false || (self.poll?.ownerID == MMUser.currentUser()?.userID && self.poll?.ownerID != nil) {
                button.rightLabel = label
            }
            button.pollOption = option
            button.addTarget(self, action: #selector(PollMediaItem.didSelectButton(_:)), forControlEvents: .TouchUpInside)
            self.buttons.append(button)
        }
        
        if poll.hideResultsFromOthers && self.poll?.ownerID == MMUser.currentUser()?.userID && self.poll?.ownerID != nil {
        let refreshButton = addButton(view, label: "↻")
        refreshButton.layer.borderWidth = 0
        refreshButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        refreshButton.titleLabel?.font = UIFont.boldSystemFontOfSize(25.0)
        refreshButton.addTarget(self, action: #selector(PollMediaItem.refreshPoll(_:)), forControlEvents: .TouchUpInside)
        }
        updatePoll()
        self.cachedView = view
        
        return view
    }
    
    override public func mediaViewDisplaySize() -> CGSize {
        let _ = mediaView()
        let height = max(viewHeight, 100.0)
        return CGSize(width: super.mediaViewDisplaySize().width, height: height)
    }
}