//
//  CreateChannelViewController.swift
//  KitchenSink
//
//  Created by Kostya Grishchenko on 12/24/15.
//  Copyright © 2015 Magnet Systems, Inc. All rights reserved.
//

import UIKit
import MagnetMax

class CreateChannelViewController: UIViewController {
    
    
    // MARK: Outlets
    
    
    @IBOutlet weak var lblTags: UILabel!
    @IBOutlet weak var segCtrlPermissions: UISegmentedControl!
    @IBOutlet weak var switchIsPublic: UISwitch!
    @IBOutlet weak var txtfName: UITextField!
    @IBOutlet weak var txtfSummary: UITextField!
    @IBOutlet weak var txtfTag: UITextField!
    
    
    // MARK: public properties
    
    
    var tags = Set<String> ()


    // MARK: Overrides
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    // MARK: Actions
    
    
    @IBAction func addTagAction() {
        if let tag = txtfTag.text where (tag.isEmpty == false) {
            tags.insert(tag)
            txtfTag.text = ""
            lblTags.text = "\(lblTags.text!) \(tag)"
        }
    }
    
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
            channel.setTags(self!.tags, success: nil, failure: { error in
                print("[ERROR]: \(error)")
            })
            
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
