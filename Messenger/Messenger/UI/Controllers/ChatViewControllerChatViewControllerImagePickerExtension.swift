// ChatViewControllerChatViewControllerImagePickerExtension.swift
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

import JSQMessagesViewController
import MagnetMax

extension ChatViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    //MARK: UIImagePickerControllerDelegate
    
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            
            let messageContent = [Constants.ContentKey.Type: MessageType.Photo.rawValue]
            let mmxMessage = MMXMessage(toChannel: chat!, messageContent: messageContent)
            
            if let data = UIImageJPEGRepresentation(pickedImage, 0.8) {
                
                let attachment = MMAttachment(data: data, mimeType: "image/jpg")
                mmxMessage.addAttachment(attachment)
                self.showSpinner()
                mmxMessage.sendWithSuccess({ [weak self] _ in
                    self?.hideSpinner()
                    }) { error in
                        self.hideSpinner()
                        print(error)
                }
                finishSendingMessageAnimated(true)
            }
        } else if let urlOfVideo = info[UIImagePickerControllerMediaURL] as? NSURL {
            let messageContent = [Constants.ContentKey.Type: MessageType.Video.rawValue]
            let name = urlOfVideo.lastPathComponent
            let mmxMessage = MMXMessage(toChannel: chat!, messageContent: messageContent)
            let attachment = MMAttachment(fileURL: urlOfVideo, mimeType: "video/quicktime", name: name, description: "Video file")
            self.showSpinner()
            mmxMessage.addAttachment(attachment)
            mmxMessage.sendWithSuccess({ [weak self] _ in
                self?.hideSpinner()
                }) { error in
                    self.hideSpinner()
                    print(error)
            }
            finishSendingMessageAnimated(true)
        }
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}