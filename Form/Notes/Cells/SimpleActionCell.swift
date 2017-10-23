//
//  SimpleActionCell.swift
//  Form
//
//  Created by Eli Pacheco Hoyos on 10/22/17.
//  Copyright © 2017 Eli Pacheco Hoyos. All rights reserved.
//

import UIKit

class SimpleActionCell: UICollectionViewCell, DequeueAbleCell, DynamicHeightCell {
    
    @IBOutlet weak var actionButton: UIButton!
    
    static var dequeueCell: FieldCellType {
        let simpleActionCellIdentifier = String(describing: SimpleActionCell.self)
        let simpleActionNib = UINib(nibName: String(describing: SimpleActionCell.self), bundle: nil)
        
        return FieldCellType(cellIdentifier: simpleActionCellIdentifier,
                             nib: simpleActionNib)
    }
    
    private var isHeightCalculated = false
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        guard !isHeightCalculated else {
            return layoutAttributes
        }
        
        return calculateDynamicHeight(with: layoutAttributes)
    }
    
    func update(with field: FieldType) {
        guard case let .simpleAction(title) = field  else {
            return
        }
        
       actionButton.setTitle(title, for: .normal)
    }
    
    
    @IBAction func actionButtonWasPressed(_ sender: Any) {
        
    }
    
}
