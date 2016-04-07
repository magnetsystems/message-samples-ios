import UIKit

import CocoaLumberjack
import MagnetMax


//Mark: MMXChatListViewController


public protocol Define_MMXChatListViewController : class {
    
    //MARK: Variables
    
    var canSearch : Bool?{get set}
    var channelDetailsMessagesLimit : Int{get set}
    var channelDetailsSubscribersLimit : Int{get set}
    var chooseContacts : Bool{get set}
    var datasource : ChatListControllerDatasource?{get set}
    var delegate : ChatListControllerDelegate?{get set}
    //@IBOutlet - searchBar will be auto generated and inserted into the tableview header if not connected to an outlet
    //to hide set canSearch = false
    var searchBar : UISearchBar?{get set}
    var tableView : UITableView!{get set}
    
    //These can be overridden to inject datasources, delegates and other customizations into the variable on didSet
    
    weak var currentChatViewController : MMXChatViewController?{get set}
    weak var currentContactsViewController : MMXContactsPickerController?{get set}
    
    //MARK: Initialization
    
    func setupViewController()
    
    //MARK: Public Methods
    
    func append(mmxChannels: [MMXChannel])
    func loadingContext() -> Int
    func presentChatViewController(chatViewController : MMXChatViewController, users : [MMUser])
    func refreshDataForChannel(channel : MMXChannel)
    func reloadData()
    func resetData()
    
    //MARK: - ContactsViewControllerDelegate
    
    func mmxContactsControllerDidFinish(with selectedUsers: [MMUser])
}


//MARK: MMXContactsPickerController


public protocol Define_MMXContactsPickerController : class {
    
    //MARK: Public Variables
    
    var barButtonCancel : UIBarButtonItem?{get set}
    var barButtonNext : UIBarButtonItem?{get set}
    var canSearch : Bool?{get set}
    weak var delegate : ContactsControllerDelegate?{get set}
    var datasource : ContactsControllerDatasource?{get set}
    //@IBOutlet - searchBar will be auto generated and inserted into the tableview header if not connected to an outlet
    //to hide set canSearch = false
    var searchBar : UISearchBar?{get set}
    
    //MARK: Initialization
    
    func setupViewController()
    
    //MARK: Public Methods
    
    func append(unfilteredUsers: [MMUser])
    func contacts() -> [[String : [MMUser]?]]
    func loadingContext() -> Int
    func reloadData()
    func resetData()
}


//MARK: MMXChatViewController


public protocol Define_MMXChatViewController : class {
    
    //MARK: Public Variables
    
    var channel : MMXChannel?{get}
    var currentMessageCount : Int{get set}
    var delegate : ChatViewControllerDelegate?{get set}
    var datasource : ChatViewControllerDatasource?{get set}
    var incomingBubbleImageView : JSQMessagesBubbleImage!{get set}
    var mmxMessages : [MMXMessage]{get}
    var outgoingBubbleImageView : JSQMessagesBubbleImage!{get set}
    var recipients : [MMUser]?{get}
    var showDetails : Bool{get set}
    var useNavigationBarNotifier : Bool?{get set}
    weak var collectionView : JSQMessagesCollectionView!{get}
    
    //Delegate and Datasource
    
    weak var chatDetailsViewController : MMXContactsPickerController?{get set}
    weak var chatDetailsDataSource : SubscribersDatasource?{get set}
    
    //MARK: Initialization
    
    func setupViewController()
    
    //MARK: Public Methods
    
    func loadingContext() -> Int
    func reloadData()
}
