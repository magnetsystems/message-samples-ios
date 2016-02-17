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
        
        let activityIndicator = UIActivityIndicatorView.init(activityIndicatorStyle: .Gray)
        activityIndicator.hidesWhenStopped = true
        let indicator = UIBarButtonItem(customView: activityIndicator)
        navigationItem.leftBarButtonItems = [indicator]
        self.activityIndicator = activityIndicator
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if let user = MMUser.currentUser() {
            firstNameTF?.text = "\(user.firstName ?? "")"
            lastNameTF?.text = "\(user.lastName ?? "")"
            userEmailL.text = user.userName
            
                
            Utils.loadUserAvatar(user, toImageView: self.userAvatarIV, placeholderImage: UIImage(named: "user_default")!)
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
        profileUpdateReq.password = nil
        
        self.showLoadingIndicator()
        MMUser.updateProfile(profileUpdateReq, success: { [weak self] user in
            print("updated \(MMUser.currentUser())")
            self?.hideLoadingIndicator()
            self?.showAlert("Changes are saved", title: "Saved", closeTitle: kStr_Close)
            }) { [weak self] error in
            print("update err \(error)")
            self?.hideLoadingIndicator()
        }
        
    }
    
    
}

extension UserProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
        if let user = MMUser.currentUser() {
            
            user.setAvatarWithData(UIImageJPEGRepresentation(pickedImage, 0.1), success: { (url) -> Void in
                print("avatar updated, new url \(url)")
                if let url = url where url.absoluteString.characters.count > 0 {
                    Utils.loadImageWithUrl(url, toImageView: self.userAvatarIV, placeholderImage: nil)
                }
                }, failure: { (error) -> Void in
                    print("avatar update error \(error)")
            })
        }
        }
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}