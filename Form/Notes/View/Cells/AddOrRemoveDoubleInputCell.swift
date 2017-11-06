//
//  AddOrRemoveDoubleInputCell.swift
//  Form
//
//  Created by Eli Pacheco Hoyos on 10/22/17.
//  Copyright © 2017 Eli Pacheco Hoyos. All rights reserved.
//

import UIKit

class AddOrRemoveDoubleInputCell: UITableViewCell, DequeueAbleCell {

    @IBOutlet private weak var minusButton: UIButton!
    @IBOutlet private weak var plusButton: UIButton!
    
    var action: RemoveOrAddTypeAction?
    
    static var dequeueCell: FieldCellType {
        let addOrRemoveDoubleInputHeaderCellIdentifier = String(describing: AddOrRemoveDoubleInputCell.self)
        let addOrRemoveDoubleInputHeaderNib = UINib(nibName: String(describing: AddOrRemoveDoubleInputCell.self), bundle: nil)
        
        return FieldCellType(cellIdentifier: addOrRemoveDoubleInputHeaderCellIdentifier,
                             nib: addOrRemoveDoubleInputHeaderNib)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        action = nil
    }
    
    func update(with field: FieldType) {
        
    }
    
    @IBAction func plusButtonWasPressed(_ sender: Any) {
        action?(.add)
    }
    
    @IBAction func minusButtonWasPressed(_ sender: Any) {
        action?(.remove)
    }
    
}
