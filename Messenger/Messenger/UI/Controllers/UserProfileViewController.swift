//
//  UserProfileViewController.swift
//  Messenger
//
//  Created by Vladimir Yevdokimov on 2/10/16.
//  Copyright © 2016 Magnet Systems, Inc. All rights reserved.
//

import UIKit
import MobileCoreServices
import MagnetMax

class UserProfileViewController: BaseViewController {

    @IBOutlet weak var userAvatarIV: UIImageView!
    @IBOutlet weak var userEmailL: UILabel!
    @IBOutlet weak var firstNameTF: UITextField!
    @IBOutlet weak var lastNameTF: UITextField!

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        userAvatarIV.layer.cornerRadius = userAvatarIV.frame.size.width/2
        userAvatarIV.layer.masksToBounds = true
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if let user = MMUser.currentUser() {
            firstNameTF?.text = "\(user.firstName ?? "")"
            lastNameTF?.text = "\(user.lastName ?? "")"
            userEmailL.text = user.userName
            
                
            self.loadUserAvatar(user)
        }
    }

    func loadUserAvatar(user:MMUser) {
        let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
        dispatch_async(dispatch_get_global_queue(priority, 0)) {
            // do some task
            if let data = NSData(contentsOfURL:user.avatarURL()!) {
                dispatch_async(dispatch_get_main_queue()) {
                    // update some UI
                    self.userAvatarIV?.image = UIImage(data: data)
                }
            }
        }
    }
    
    //MARK: - Actions

    @IBAction func close(sender: UIBarButtonItem) {
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func selectAvatar(sender: UIButton) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .PhotoLibrary
        imagePicker.mediaTypes = [kUTTypeImage as String]
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func saveChanges(sender: UIButton) {
        firstNameTF.resignFirstResponder()
        lastNameTF.resignFirstResponder()
        
        let profileUpdateReq = MMUpdateProfileRequest(user: MMUser.currentUser())
        profileUpdateReq.firstName = firstNameTF.text
        profileUpdateReq.lastName = lastNameTF.text
        
        MMUser.updateProfile(profileUpdateReq, success: { (user) -> Void in
            print("updated \(MMUser.currentUser())")
            }) { (error) -> Void in
                
        }
        
    }
    
    
}

extension UserProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
        if let user = MMUser.currentUser() {
            
            user.setAvatarWithData(UIImageJPEGRepresentation(pickedImage, 0.1), success: { (url) -> Void in
                self.loadUserAvatar(user)
                }, failure: { (error) -> Void in
                    
            })
        }
        }
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}