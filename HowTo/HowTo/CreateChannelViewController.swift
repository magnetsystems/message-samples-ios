/*
* Copyright (c) 2015 Magnet Systems, Inc.
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

class CreateChannelViewController: UIViewController {
    
    
    // MARK: Outlets
    
    
    @IBOutlet weak var segCtrlPermissions: UISegmentedControl!
    @IBOutlet weak var switchIsPublic: UISwitch!
    @IBOutlet weak var txtfName: UITextField!
    @IBOutlet weak var txtfSummary: UITextField!
    @IBOutlet weak var txtfTag: UITextField!
    
    
    // MARK: Overrides
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    // MARK: Actions
    
    
    @IBAction func saveAction() {
        guard let name = txtfName.text where (name.isEmpty == false),
            let summary = txtfSummary.text where (summary.isEmpty == false) else {
                return
        }
        
        var permisssions : MMXPublishPermissions!
        switch segCtrlPermissions.selectedSegmentIndex {
        case 0: permisssions = .OwnerOnly
        case 1: permisssions = .Subscribers
        case 2: permisssions = .Anyone
        default : break
        }
        let isPublic = switchIsPublic.on
        
        // Create channel
        MMXChannel.createWithName(name, summary: summary, isPublic: isPublic, publishPermissions: permisssions, success: { [weak self] (channel)  in
            // Add tags
            
            let tagsString = self?.txtfTag.text?.stringByReplacingOccurrencesOfString(" ", withString: "")
            if var tags = tagsString?.componentsSeparatedByString(",") {
                tags = tags.filter(){
                    return $0.characters.count > 0
                }
                print("Will set \(tags.count) tag(s) for channel: \(name)")
                channel.setTags(NSSet.init(array: tags) as! Set<String>, success: nil, failure: { error in
                    print("[ERROR]: \(error)")
                })
            }
            
            let alert = UIAlertController(title: nil, message: "Channel \(channel.name) is created", preferredStyle: .Alert)
            let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
            alert.addAction(defaultAction)
            self?.presentViewController(alert, animated: true, completion: nil)
            
            }) { (error) -> Void in
                print("[ERROR]: \(error)")
        }
    }
    
    
    //MARK: UITextField delegate
    
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
    
}
