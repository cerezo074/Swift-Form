//
//  DoubleInputCell.swift
//  Form
//
//  Created by Eli Pacheco Hoyos on 10/22/17.
//  Copyright © 2017 Eli Pacheco Hoyos. All rights reserved.
//

import UIKit

class DoubleInputCell: UICollectionViewCell, DequeueAbleCell, DynamicHeightCell {
    
    @IBOutlet weak var firstInputTitleLabel: UILabel!
    @IBOutlet weak var secondInputTitleLabel: UILabel!
    @IBOutlet weak var firtInputTextView: UITextField!
    @IBOutlet weak var secondInputTextView: UITextField!
    @IBOutlet weak var InvalidMessageLabel: UILabel!
    
    static var dequeueCell: FieldCellType {
        let doubleInputCellIdentifier = String(describing: DoubleInputCell.self)
        let doubleInputNib = UINib(nibName: String(describing: DoubleInputCell.self), bundle: nil)
        
        return FieldCellType(cellIdentifier: doubleInputCellIdentifier,
                             nib: doubleInputNib)
    }
    
    private var isHeightCalculated = false
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        guard !isHeightCalculated else {
            return layoutAttributes
        }
        
        return calculateDynamicHeight(with: layoutAttributes)
    }
    
    func update(with field: FieldType) {
        guard case let .doubleInput(firstTitleInput, secondTitleInput, error) = field  else {
            return
        }
        
        firstInputTitleLabel.text = firstTitleInput
        secondInputTitleLabel.text = secondTitleInput
        InvalidMessageLabel.text = error
    }
    
    func updateWithInvalidMessage(_ invalidText: String) {
        InvalidMessageLabel.text = invalidText
    }

}
