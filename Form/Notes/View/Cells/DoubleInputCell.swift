//
//  DoubleInputCell.swift
//  Form
//
//  Created by Eli Pacheco Hoyos on 10/22/17.
//  Copyright © 2017 Eli Pacheco Hoyos. All rights reserved.
//

import UIKit

class DoubleInputCell: UITableViewCell, DequeueAbleCell {
    
    @IBOutlet weak var firstInputTitleLabel: UILabel!
    @IBOutlet weak var secondInputTitleLabel: UILabel!
    @IBOutlet weak var InvalidMessageLabel: UILabel!
    
    @IBOutlet weak var firstInputTextField: UITextField! {
        didSet {
            firstInputTextField.addTarget(self,
                                     action: #selector(textFieldDidChange),
                                     for: .editingChanged)
        }
    }
    
    @IBOutlet weak var secondInputTextField: UITextField! {
        didSet {
            secondInputTextField.addTarget(self,
                                     action: #selector(textFieldDidChange),
                                     for: .editingChanged)
        }
    }
    
    static var dequeueCell: FieldCellType {
        let doubleInputCellIdentifier = String(describing: DoubleInputCell.self)
        let doubleInputNib = UINib(nibName: String(describing: DoubleInputCell.self), bundle: nil)
        
        return FieldCellType(cellIdentifier: doubleInputCellIdentifier,
                             nib: doubleInputNib)
    }
    
    var action: DoubleInputAction?
    var indexPath: IndexPath?
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        action = nil
        indexPath = nil
        firstInputTextField.text = ""
        secondInputTextField.text = ""
    }

    func update(with field: FieldType) {
        guard case let .doubleInput(firstTitleInput, firstInput, secondTitleInput, secondInput, error) = field  else {
            return
        }
        
        firstInputTitleLabel.text = firstTitleInput
        firstInputTextField.text = firstInput
        secondInputTitleLabel.text = secondTitleInput
        secondInputTextField.text = secondInput
        InvalidMessageLabel.text = error
    }
    
    func updateWithInvalidMessage(_ invalidText: String) {
        InvalidMessageLabel.text = invalidText
    }
    
    
    @objc func textFieldDidChange(textField: UITextField) {
        guard let index = indexPath else {
            return
        }
        
        action?(firstInputTextField.text ?? "" , secondInputTextField.text ?? "", index)
    }

}
