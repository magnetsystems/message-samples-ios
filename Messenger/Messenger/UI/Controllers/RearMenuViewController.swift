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

class RearMenuViewController: UITableViewController {
    
    
    //MARK: Public properties
    
    
    var notifier : SupportNotifier?
    @IBOutlet weak var userAvatar: UIImageView!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var version: UILabel!
    
    
    //MARK: Type Def
    
    
    enum IndexPathRowAction: Int {
        case UserInfo = 0
        case Home
        case Support
        case SignOut
        case Version
    }
    
    
    //MARK: Overrides
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        MMX.start()
        // Handling disconnection
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didDisconnect:", name: MMUserDidReceiveAuthenticationChallengeNotification, object: nil)
        
        userAvatar.layer.cornerRadius = userAvatar.frame.size.width/2
        userAvatar.layer.masksToBounds = true
        self.version.text = ""
        if let version = NSBundle.mainBundle().infoDictionary?["CFBundleVersion"] as? String {
            self.version.text = "v\(version)"
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        if let user = MMUser.currentUser() {
            username.text = "\(user.firstName ?? "") \(user.lastName ?? "")"

            Utils.loadUserAvatar(user, toImageView: self.userAvatar, placeholderImage: UIImage(named: "user_default")!)
        }
    }

    
    // MARK: - Table view delegate
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 {
            switch indexPath.row {
            case IndexPathRowAction.UserInfo.rawValue:
                self.revealViewController().revealToggleAnimated(true)
                self.revealViewController().presentViewController((self.storyboard?.instantiateViewControllerWithIdentifier(vc_id_UserProfile))!, animated: true, completion: nil)
            case IndexPathRowAction.SignOut.rawValue :
                
                let confirmationAlert = Popup(message: kStr_SignOutAsk, title: kStr_SignOut, closeTitle: kStr_No)
                let okAction = UIAlertAction(title: kStr_Yes, style: .Default) { action in
                    MMUser.logout({() -> Void in
                        print("[SESSION]: SESSION ENDED BY USER")
                        }, failure: { (error) -> Void in
                            print("[ERROR]: \(error)")
                    })
                }
                confirmationAlert.addAction(okAction)
                confirmationAlert.presentForController(self)
                
            case IndexPathRowAction.Home.rawValue :
                notifier?.stopped = false
                let storyboard = UIStoryboard(name: sb_id_Main, bundle: nil)
                let vc = storyboard.instantiateViewControllerWithIdentifier(vc_id_Home);
                self.revealViewController().pushFrontViewController(vc, animated: true);
            case IndexPathRowAction.Support.rawValue :
                SupportNotifier.hideSupportNotifiers()
                notifier?.stopped = true
                
                let storyboard = UIStoryboard(name: sb_id_Main, bundle: nil)
                let vc = storyboard.instantiateViewControllerWithIdentifier(vc_id_Support);
                self.revealViewController().pushFrontViewController(vc, animated: true);
            default:break;
            }
        }
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAtIndexPath: indexPath)
        if indexPath.row == IndexPathRowAction.Support.rawValue && Utils.isMagnetEmployee() {
            notifier = SupportNotifier(view: cell.contentView)
            notifier?.count = NewSupportMessages.count
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.row == IndexPathRowAction.Support.rawValue {
            if !Utils.isMagnetEmployee() {
                return 0
            }
        }
        
        return super.tableView(tableView, heightForRowAtIndexPath: indexPath)
    }

    
    //Mark Notifications
    
    
    private func didDisconnect(notification: NSNotification) {
        // Indicate that you are not ready to receive messages now!
        MMX.stop()
        
        // Redirect to the login screen
        if let revealVC = self.revealViewController() {
            revealVC.rearViewController.navigationController?.popToRootViewControllerAnimated(true)
        }
    }
}
