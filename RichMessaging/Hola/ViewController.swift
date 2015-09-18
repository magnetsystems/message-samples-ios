//
//  ViewController.swift
//  Hola
//
//  Created by Pritesh Shah on 9/8/15.
//  Copyright (c) 2015 Magnet Systems, Inc. All rights reserved.
//

import UIKit
import MMX
import FBSDKCoreKit
import FBSDKLoginKit

class ViewController: UIViewController, FBSDKLoginButtonDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
		
		//Setup Facebook button
		setupFacebook()
		
		//If have valid facebook session token just login to MMX
		if (FBSDKAccessToken.currentAccessToken() != nil) {
			fetchUserFacebookDataAndLogin()
		}
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
		
    }
	
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
	
	// MARK: - Facebook
	
	func setupFacebook() {
		//Enable Facebook token status updates
		FBSDKProfile.enableUpdatesOnAccessTokenChange(true)
				
		// Setup Facebook login button.
		let loginButton = FBSDKLoginButton()
		loginButton.delegate = self
		let buttonWidth = 150.0
		let buttonXPos: Float = Float(self.view.frame.size.width)/2.0 - Float(buttonWidth/2.0)
		loginButton.frame = CGRectMake(CGFloat(buttonXPos), CGFloat(buttonWidth), 150, 40)
		loginButton.readPermissions = ["email","user_friends"]
		self.view.addSubview(loginButton)
		
	}

	func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
		fetchUserFacebookDataAndLogin()
	}
	
	func fetchUserFacebookDataAndLogin() {
		if let _ = FBSDKAccessToken.currentAccessToken() {
			let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath:  "me", parameters: ["fields":"id,name,email"])
			graphRequest.startWithCompletionHandler({ (connection: FBSDKGraphRequestConnection!, requestResult: AnyObject!, requestError: NSError!) -> Void in
				let name: AnyObject? = requestResult.valueForKey("name")
				let email: AnyObject? = requestResult.valueForKey("email")
				let userID: AnyObject? = requestResult.valueForKey("id")
				
				self.registerAndLoginToMMX(name as! String, email: email as! String, userID: userID as! String)
			})
		}
	}
	
	func registerAndLoginToMMX(name: String, email: String, userID: String) {
		let user = MMXUser()
		user.username = userID
		user.displayName = name
		let credential = NSURLCredential(user: user.username, password: userID, persistence: .None)
		user.registerWithCredential(credential, success: { () -> Void in
			MMXUser.logInWithCredential(credential, success: { (user) -> Void in
					self.performSegueWithIdentifier("showRecipientsSegue", sender: self)
				}, failure: { (error) -> Void in
					print("logInWithCredential error = \(error)")
			})
			}) { (error) -> Void in
				//If error is for user already exists login
				if error.code == 409 {
					MMXUser.logInWithCredential(credential, success: { (user) -> Void in
						self.performSegueWithIdentifier("showRecipientsSegue", sender: self)
						}, failure: { (error) -> Void in
							print("logInWithCredential error = \(error)")
					})
				} else {
					print("logInWithCredential error = \(error)")
				}
		}
	}
	
	func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
		
	}
	
}

