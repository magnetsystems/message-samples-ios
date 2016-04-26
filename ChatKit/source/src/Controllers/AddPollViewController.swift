//
//  AddPollViewController.swift
//
//
//  Created by Lorenzo Stanton on 4/19/16.
//
//

import UIKit

protocol AddPollViewControllerDelegate {
    func shouldAddPoll(viewController : AddPollViewController)
}

class OptionString  {
    var value: String = ""
}

class AddPollViewController: MMTableViewController, PollOptionCellDelegate {
    
    var delegate: AddPollViewControllerDelegate?
    var options = [OptionString]()
    
    @IBOutlet var swMultipleSelections : UISwitch?
    @IBOutlet var swShowResults : UISwitch?
    @IBOutlet var textQuestion: UITextField?
    @IBOutlet var textName: UITextField?
    @IBOutlet var textStatus: UILabel?
    
    override init() {
        super.init(nibName: String(AddPollViewController.self), bundle: NSBundle(forClass: AddPollViewController.self))
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.textStatus?.text = ""
        let left = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: #selector(AddPollViewController.close))
        let right = UIBarButtonItem(title: "Add", style: .Plain, target: self, action: #selector(AddPollViewController.save))
        self.navigationItem.leftBarButtonItem = left
        self.navigationItem.rightBarButtonItem = right
        
        var nib = UINib.init(nibName: "PollOptionCellTableViewCell", bundle: NSBundle(forClass: PollOptionCellTableViewCell.self))
        self.tableView.registerNib(nib, forCellReuseIdentifier: "OptionCell")
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(AddPollViewController.keyboardDidShow(_:)), name:UIKeyboardDidShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(AddPollViewController.keyboardWillHide(_:)), name:UIKeyboardWillHideNotification, object: nil)
        self.tableView.bounces = false
    }
    
    func save() {
        self.textStatus?.text = ""
        if (textName?.text?.characters.count ?? 0) == 0 {
            textStatus?.text = "Please enter a poll name."
            return
        } else if (self.textQuestion?.text?.characters.count ?? 0) == 0 {
            textStatus?.text = "Please enter a poll question."
            return
        } else if self.options.count == 0 || self.options.first?.value.characters.count == 0 {
            textStatus?.text = "Please add options."
            return
        }
        
        for var i = options.count - 1; i >= 0; i-- {
            if options[i].value.characters.count == 0 {
                options.removeAtIndex(i)
            }
        }
        
        delegate?.shouldAddPoll(self)
        close()
    }
    
    func close() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    
    //MARK: TableView Datasource
    
    
   @IBAction func actionAddOption(button: UIButton) {
        if let last = self.options.last {
            guard last.value.characters.count > 0 else {
                return
            }
        }
        let option = OptionString()
        self.options.append(option)
        self.tableView.reloadData()
    }
    
    func optionDidUpdate(cell: PollOptionCellTableViewCell) {
        if let index = cell.indexPath?.row {
            options[index].value = cell.textField?.text ?? ""
        }
    }
    
    func optionShouldDelete(cell: PollOptionCellTableViewCell) {
        if let index = cell.indexPath?.row {
            options.removeAtIndex(index)
            self.tableView.reloadData()
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView .dequeueReusableCellWithIdentifier("OptionCell") as! PollOptionCellTableViewCell
        cell.delegate = self
        cell.textField?.text = self.options[indexPath.row].value
        cell.indexPath = NSIndexPath(forRow: indexPath.row, inSection: 0)
        
        return cell
    }
    
    
    //MARK: Notifications
    
    
    func keyboardDidShow(notification : NSNotification) {
        var info = notification.userInfo!
        var keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        
        self.tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardFrame.size.height, right: 0)
    }
    
    
    func keyboardWillHide(notification : NSNotification) {
        self.tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
}
