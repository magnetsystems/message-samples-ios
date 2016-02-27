//
//  LoadingCell.swift
//  
//
//  Created by Lorenzo Stanton on 2/25/16.
//
//

import UIKit

class LoadingCell: UITableViewCell {
    
    
    @IBOutlet weak var indicator : UIActivityIndicatorView?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
