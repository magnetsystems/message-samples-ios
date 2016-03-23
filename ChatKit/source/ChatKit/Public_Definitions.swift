import UIKit

import CocoaLumberjack
import MagnetMax


//Mark: MMXChatListViewController


public protocol DEF_MMXChatListViewController : class {
    
    //MARK: Variables
    
    var chooseContacts : Bool{get set}
    var datasource : ChatListControllerDatasource?{get set}
    var delegate : ChatListControllerDelegate?{get set}
    var tableView : UITableView!{get set}
    
    //These can be overridden to inject datasources, delegates and other customizations into the variable on didSet
    
    weak var currentChatViewController : MMXChatViewController?{get set}
    weak var currentContactsViewController : MMXContactsPickerController?{get set}
    
    //MARK: Methods
    
    func append(mmxChannels: [MMXChannel])
    func loadingContext() -> Int
    func presentChatViewController(chatViewController : MMXChatViewController, users : [MMUser])
    func reloadData()
    
    //MARK: - ContactsViewControllerDelegate
    
    func mmxContactsControllerDidFinish(with selectedUsers: [MMUser])
}


//MARK: MMXContactsPickerController


public protocol DEF_MMXContactsPickerController : class {
    
    //MARK: Public Variables
    
    var barButtonCancel : UIBarButtonItem?{get set}
    var barButtonNext : UIBarButtonItem?{get set}
    weak var delegate : ContactsControllerDelegate?{get set}
    var datasource : ContactsControllerDatasource?{get set}
    
    //MARK: Initialization
    
    func setupViewController()
    
    //MARK: Public Methods
    
    func contacts() -> [[String : [MMUser]?]]
    func loadingContext() -> Int
    func reloadData()
    func append(unfilteredUsers: [MMUser])
}

