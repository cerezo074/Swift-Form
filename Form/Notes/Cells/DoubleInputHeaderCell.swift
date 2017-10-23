//
//  DoubleInputHeaderCell.swift
//  Form
//
//  Created by Eli Pacheco Hoyos on 10/22/17.
//  Copyright © 2017 Eli Pacheco Hoyos. All rights reserved.
//

import UIKit

class DoubleInputHeaderCell: UICollectionViewCell, DequeueAbleCell, DynamicHeightCell {

    @IBOutlet weak var descriptionLabel: UILabel!
    
    static var dequeueCell: FieldCellType {
        let doubleInputHeaderCellIdentifier = String(describing: DoubleInputHeaderCell.self)
        let doubleInputHeaderNib = UINib(nibName: String(describing: DoubleInputHeaderCell.self), bundle: nil)
        
        return FieldCellType(cellIdentifier: doubleInputHeaderCellIdentifier,
                             nib: doubleInputHeaderNib)
    }
    
    private var isHeightCalculated = false
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        guard !isHeightCalculated else {
            return layoutAttributes
        }
        
        return calculateDynamicHeight(with: layoutAttributes)
    }
    
    func update(with field: FieldType) {
        guard case let .simpleMessage(description) = field  else {
            return
        }
        
        descriptionLabel.text = description
    }

}
