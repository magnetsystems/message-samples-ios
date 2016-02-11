//
//  ContactsPickerController.swift
//
//
//  Created by Lorenzo Stanton on 2/11/16.
//
//

import UIKit
import MagnetMax

public protocol ContactsPickerControllerDelegate: class {
    func contactsControllerDidFinish(with selectedUsers: [MMUser])
}

public class ContactsPickerController: UINavigationController {
    private var underlyingContactsViewController = ContactsViewController.init()
    public weak var pickerDelegate : ContactsPickerControllerDelegate?
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        underlyingContactsViewController.delegate = pickerDelegate
        setViewControllers([underlyingContactsViewController], animated: false)
    }
    
    public func reloadData() {
      underlyingContactsViewController.tableView.reloadData()
    }
    
   convenience public init(disabledUsers: [MMUser]) {
        self.init()
        self.underlyingContactsViewController = ContactsViewController.init(disabledUsers: disabledUsers)
    }
}
