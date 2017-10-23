//
//  AddOrRemoveDoubleInputCell.swift
//  Form
//
//  Created by Eli Pacheco Hoyos on 10/22/17.
//  Copyright © 2017 Eli Pacheco Hoyos. All rights reserved.
//

import UIKit

class AddOrRemoveDoubleInputCell: UICollectionViewCell, DequeueAbleCell, DynamicHeightCell {

    @IBOutlet private weak var minusButton: UIButton!
    @IBOutlet private weak var plusButton: UIButton!
    
    var action: RemoveOrAddTypeAction?
    
    static var dequeueCell: FieldCellType {
        let addOrRemoveDoubleInputHeaderCellIdentifier = String(describing: AddOrRemoveDoubleInputCell.self)
        let addOrRemoveDoubleInputHeaderNib = UINib(nibName: String(describing: AddOrRemoveDoubleInputCell.self), bundle: nil)
        
        return FieldCellType(cellIdentifier: addOrRemoveDoubleInputHeaderCellIdentifier,
                             nib: addOrRemoveDoubleInputHeaderNib)
    }
    
    private var isHeightCalculated = false
    
    func update(with field: FieldType) {
        
    }
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        guard !isHeightCalculated else {
            return layoutAttributes
        }
        
        return calculateDynamicHeight(with: layoutAttributes)
    }
    
    @IBAction func plusButtonWasPressed(_ sender: Any) {
        action?(.add)
    }
    
    @IBAction func minusButtonWasPressed(_ sender: Any) {
        action?(.remove)
    }
    
}
