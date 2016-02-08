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
        case ChangePassword = 0
        case SignOut = 1
    }

    override func viewDidLoad() {
        super.viewDidLoad()

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
        if indexPath.row == IndexPathRowAction.SignOut.rawValue {
            MMUser.logout({ () -> Void in
                self.navigationController?.popToRootViewControllerAnimated(true)
            }, failure: { (error) -> Void in
                print("[ERROR]: \(error)")
            })
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
