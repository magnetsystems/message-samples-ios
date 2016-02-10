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
    
    enum IndexPathRowAction: Int {
        case Home = 0
        case Events
        case SignOut
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        MMX.start()
        // Handling disconnection
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didDisconnect:", name: MMUserDidReceiveAuthenticationChallengeNotification, object: nil)
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var title = String()
        if let user = MMUser.currentUser() {
            title = "\(user.firstName ?? "") \(user.lastName ?? "")"
        }
        return title
    }
    
    // MARK: - Table view delegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch indexPath.row {
        case IndexPathRowAction.SignOut.rawValue :
            MMUser.logout({ () -> Void in
                self.navigationController?.popToRootViewControllerAnimated(true)
                }, failure: { (error) -> Void in
                    print("[ERROR]: \(error)")
            })
            break;
        case IndexPathRowAction.Home.rawValue :
            let storyboard = UIStoryboard(name: sb_id_Main, bundle: nil)
            let vc = storyboard.instantiateViewControllerWithIdentifier(vc_id_Home);
            self.revealViewController().pushFrontViewController(vc, animated: true);
            break;
        case IndexPathRowAction.Events.rawValue:
            let storyboard = UIStoryboard(name: sb_id_Main, bundle: nil)
            let vc = storyboard.instantiateViewControllerWithIdentifier(vc_id_Events);
            self.revealViewController().pushFrontViewController(vc, animated: true);
            break;
        default:break;
        }

        tableView.deselectRowAtIndexPath(indexPath, animated: true)
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
