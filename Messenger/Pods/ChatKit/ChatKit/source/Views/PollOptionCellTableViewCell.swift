//
//  PollOptionCellTableViewCell.swift
//
//
//  Created by Lorenzo Stanton on 4/22/16.
//
//

import UIKit

protocol PollOptionCellDelegate {
    func optionShouldDelete(cell : PollOptionCellTableViewCell)
    func optionDidUpdate(cell : PollOptionCellTableViewCell)
}

class PollOptionCellTableViewCell: UITableViewCell, UITextFieldDelegate {
    
    @IBOutlet var textField : UITextField?
    var delegate: PollOptionCellDelegate?
    @IBOutlet var deleteButton : UIButton?
    var indexPath: NSIndexPath?
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        textField.text = (textField.text as NSString?)?.stringByReplacingCharactersInRange(range, withString: string)
        self.delegate?.optionDidUpdate(self)
        return false
    }
    
    @IBAction func action(button: UIButton) {
        self.delegate?.optionShouldDelete(self)
    }
}
