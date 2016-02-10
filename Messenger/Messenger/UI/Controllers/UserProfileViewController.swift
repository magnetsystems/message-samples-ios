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
        if let user = MMUser.currentUser() {
            firstNameTF?.text = "\(user.firstName ?? "")"
            lastNameTF?.text = "\(user.lastName ?? "")"

            if ((user.avatarURL()?.absoluteString) == nil) {
                userAvatarIV?.image = UIImage(data: NSData(contentsOfURL:user.avatarURL()!)!)
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
        let profileUpdateReq = MMUpdateProfileRequest()
        profileUpdateReq.firstName = firstNameTF.text
        profileUpdateReq.lastName = lastNameTF.text
        
        MMUser.updateProfile(profileUpdateReq, success: { (user) -> Void in
            
            }) { (error) -> Void in
                
        }
        
    }
    
    
}

extension UserProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
        if let user = MMUser.currentUser() {
            
            user.setAvatarWithData(UIImageJPEGRepresentation(pickedImage, 0.1), success: { (url) -> Void in
                self.userAvatarIV.image = UIImage(data: NSData(contentsOfURL:url!)!)
                }, failure: { (error) -> Void in
                    
            })
        }
        }
        
//        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        
//        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
        
//            let messageContent = [Constants.ContentKey.Type: MessageType.Photo.rawValue]
//            let mmxMessage = MMXMessage(toChannel: chat!, messageContent: messageContent)
//            
//            if let data = UIImagePNGRepresentation(pickedImage) {
//                
//                let attachment = MMAttachment(data: data, mimeType: "image/PNG")
//                mmxMessage.addAttachment(attachment)
//                self.showSpinner()
//                mmxMessage.sendWithSuccess({ [weak self] _ in
//                    self?.hideSpinner()
//                    self?.finishSendingMessageAnimated(true)
//                    }) { error in
//                        self.hideSpinner()
//                        print(error)
//                }
//            }
//        } else if let urlOfVideo = info[UIImagePickerControllerMediaURL] as? NSURL {
//            let messageContent = [Constants.ContentKey.Type: MessageType.Video.rawValue]
//            let name = urlOfVideo.lastPathComponent
//            let mmxMessage = MMXMessage(toChannel: chat!, messageContent: messageContent)
//            let attachment = MMAttachment(fileURL: urlOfVideo, mimeType: "video/quicktime", name: name, description: "Video file")
//            self.showSpinner()
//            mmxMessage.addAttachment(attachment)
//            mmxMessage.sendWithSuccess({ [weak self] _ in
//                self?.hideSpinner()
//                self?.finishSendingMessageAnimated(true)
//                }) { error in
//                    self.hideSpinner()
//                    print(error)
//            }
//        }
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}