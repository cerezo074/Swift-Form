//
//  SimpleInputCell.swift
//  Form
//
//  Created by Eli Pacheco Hoyos on 10/29/17.
//  Copyright © 2017 Eli Pacheco Hoyos. All rights reserved.
//

import UIKit

class SimpleInputCell: UITableViewCell, DequeueAbleCell {

    @IBOutlet weak var inputTitleLabel: UILabel!
    @IBOutlet weak var inputTextField: UITextField!
    
    static var dequeueCell: FieldCellType {
        let simpleActionCellIdentifier = String(describing: SimpleInputCell.self)
        let simpleActionNib = UINib(nibName: String(describing: SimpleInputCell.self), bundle: nil)
        
        return FieldCellType(cellIdentifier: simpleActionCellIdentifier,
                             nib: simpleActionNib)
    }
    
    func update(with field: FieldType) {
        guard case let .simpleInput(title, input) = field else {
            return
        }
        
        inputTitleLabel.text = title
        inputTextField.text = input
    }
    
}
