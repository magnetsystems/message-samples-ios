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
import ChatKit

protocol AskMagnetCounterDelegate : class {
    func didUpdateAskMagnetCounter(counter : AskMagnetCounter)
}

class AskMagnetCounter : NSObject {
    
    static var sharedCounter = AskMagnetCounter()
    
    var newAskMagnetMessageCount : Int = 0
    var notifyForNewAskMessages = true
    weak var delegate : AskMagnetCounterDelegate?
    
    override init() {
        super.init()
        
        ChannelManager.sharedInstance.addChannelMessageObserver(self, channel: nil, selector: #selector(AskMagnetCounter.didRecieveMessage(_:)))
    }
    
    func isAskMagnet(channel : MMXChannel) -> Bool {
        return notifyForNewAskMessages && channel.name.hasPrefix(kAskMagnetChannel)
    }
    
    func increment() {
        newAskMagnetMessageCount += 1
        self.delegate?.didUpdateAskMagnetCounter(self)
    }
    
    func reset() {
        newAskMagnetMessageCount = 0
        self.delegate?.didUpdateAskMagnetCounter(self)
    }
    
    func didRecieveMessage(message : MMXMessage) {
        if let channel = message.channel where isAskMagnet(channel) {
            increment()
        }
    }
}

class RearMenuViewController: UITableViewController, AskMagnetCounterDelegate {
    
    
    //MARK: Public properties
    
    
    @IBOutlet weak var newAskMagnetMessageLabel: UILabel!
    @IBOutlet weak var userAvatar: UIImageView!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var version: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userAvatar.layer.cornerRadius = userAvatar.frame.size.width / 2.0
        userAvatar.layer.masksToBounds = true
        self.version.text = ""
        if let version = NSBundle.mainBundle().infoDictionary?["CFBundleVersion"] as? String {
            self.version.text = "v\(version)"
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        AskMagnetCounter.sharedCounter.delegate = self
        updateAskMagnetCount()
        
        if let user = MMUser.currentUser() {
            self.username.text = ChatKit.Utils.displayNameForUser(user)
        }
        
        if let url = MMUser.currentUser()?.avatarURL() {
            ChatKit.Utils.loadImageWithUrl(url, toImageView: self.userAvatar, placeholderImage: nil, defaultImage: UIImage(named: "user_default.png"))
        }
    }
    
    //MARK: Ask Magnet Notification management
    
    func didUpdateAskMagnetCounter(counter : AskMagnetCounter) {
        updateAskMagnetCount()
    }
    
    func updateAskMagnetCount() {
        if AskMagnetCounter.sharedCounter.newAskMagnetMessageCount > 0 {
            newAskMagnetMessageLabel.text = "\(AskMagnetCounter.sharedCounter.newAskMagnetMessageCount)"
        } else {
            newAskMagnetMessageLabel.text = ""
        }
    }
    
    func resetAskMagnetCount() {
        AskMagnetCounter.sharedCounter.reset()
    }
    
    //MARK: Tableview overrides
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if indexPath.row == 1 {
            if let nav = self.revealViewController().frontViewController as? UINavigationController {
                nav.popToRootViewControllerAnimated(true)
            }
            self.revealViewController().setFrontViewPosition(.Left, animated: true)
        } else if indexPath.row == 2 {
            showAskMagnet()
        } else if indexPath.row == 3 {
            signOut()
        } else {
            let controller = self.storyboard?.instantiateViewControllerWithIdentifier(vc_id_UserProfile)
            if let vC = controller, let nav = self.revealViewController().frontViewController as? UINavigationController {
                nav.pushViewController(vC, animated: true)
                self.revealViewController().setFrontViewPosition(.Left, animated: true)
            }
        }
    }
    
    func showAskMagnet() {
        AskMagnetCounter.sharedCounter.notifyForNewAskMessages = false
        resetAskMagnetCount()
        
        let listController = MMXChatListViewController()
        listController.chooseContacts = false
        let datasource = AskMagnetDatasource()
        datasource.controller = listController
        datasource.limit = 10
        let delegate = AskMagnetDelegate()
        delegate.controller = listController
        
        listController.datasource = datasource
        listController.delegate = delegate
        listController.title = "Ask Magnet"
        if let nav = self.revealViewController().frontViewController as? UINavigationController {
            nav.pushViewController(listController, animated: true)
            self.revealViewController().setFrontViewPosition(.Left, animated: true)
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.row == 2 {
            if !Utils.isMagnetEmployee() {
                return 0
            }
        }
        
        return super.tableView(tableView, heightForRowAtIndexPath: indexPath)
    }
    
    @IBAction func signOut() {
        MMUser.logout({
            self.revealViewController().dismissViewControllerAnimated(true, completion: nil)
            }, failure: nil)
    }
}
