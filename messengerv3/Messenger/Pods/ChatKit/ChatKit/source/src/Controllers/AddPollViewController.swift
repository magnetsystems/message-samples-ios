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

class AddPollViewController: MMViewController {
    
    var delegate: AddPollViewControllerDelegate?
    @IBOutlet var swMultipleSelections : UISwitch?
    @IBOutlet var textQuestion: UITextField?
    @IBOutlet var textOptions: UITextField?
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
        let right = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: #selector(AddPollViewController.save))
        self.navigationItem.leftBarButtonItem = left
        self.navigationItem.rightBarButtonItem = right
    }
    
    func save() {
        self.textStatus?.text = ""
        if self.textQuestion?.text?.characters.count <= 3 {
            textStatus?.text = "Please enter a question."
            return
        } else if self.textOptions?.text?.characters.count <= 3 {
            textStatus?.text = "Please enter some options."
            return
        }
        
        delegate?.shouldAddPoll(self)
        close()
    }
    
    func close() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
