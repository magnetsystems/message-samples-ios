//
//  MagnetChatViewController.swift
//  
//
//  Created by Lorenzo Stanton on 2/29/16.
//
//

import Cocoa

class MagnetChatViewController: MagnetViewController {
private var underlyingChatViewController = ChatViewController.init()
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        underlyingHomeViewController.datasource = self
        underlyingHomeViewController.delegate = self
    }
    
    override public func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        generateNavBars()
    }
    
    override public func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.title = nil
    }
    
    override internal func underlyingViewController() -> UIViewController? {
        return underlyingChatViewController
    }
    
    private func generateNavBars() { }
    
    override func setupViewController() {
        if let user = MMUser.currentUser() {
            self.title = "\(user.firstName ?? "") \(user.lastName ?? "")"
        }
        
        if self.title?.characters.count == 1 {
            self.title = MMUser.currentUser()?.userName
        }
        
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    public override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
