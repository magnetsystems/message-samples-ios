//
//  RearMenuViewController.swift
//  MMChat
//
//  Created by Kostya Grishchenko on 1/5/16.
//  Copyright © 2016 Kostya Grishchenko. All rights reserved.
//

import UIKit
import MagnetMax

class RearMenuViewController: UITableViewController {
    
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var userAvatar: UIImageView!
    @IBOutlet weak var version: UILabel!
    
    var notifier : SupportNotifier?
    
    enum IndexPathRowAction: Int {
        case UserInfo = 0
        case Home
        case Support
//        case Events
        case SignOut
        case Version
    }
    
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
                //        case IndexPathRowAction.Events.rawValue:
                //            let storyboard = UIStoryboard(name: sb_id_Main, bundle: nil)
                //            let vc = storyboard.instantiateViewControllerWithIdentifier(vc_id_Events);
                //            self.revealViewController().pushFrontViewController(vc, animated: true);
            case IndexPathRowAction.Support.rawValue :
                SupportNotifier.hideAllSupportNotifiers()
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
            notifier = SupportNotifier(cell: cell)
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

    private func didDisconnect(notification: NSNotification) {
        // Indicate that you are not ready to receive messages now!
        MMX.stop()
        
        // Redirect to the login screen
        if let revealVC = self.revealViewController() {
            revealVC.rearViewController.navigationController?.popToRootViewControllerAnimated(true)
        }
    }
}
