//
//  DynamicHeighCell.swift
//  Form
//
//  Created by Eli Pacheco Hoyos on 10/22/17.
//  Copyright © 2017 Eli Pacheco Hoyos. All rights reserved.
//

import Foundation
import UIKit

protocol DynamicHeightCell {}

extension DynamicHeightCell where Self: UICollectionViewCell {
    
     func calculateDynamicHeight(with layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {        
        setNeedsLayout()
        layoutIfNeeded()
        let size = contentView.systemLayoutSizeFitting(layoutAttributes.size)
        var newFrame = layoutAttributes.frame
        newFrame.size.height = CGFloat(ceilf(Float(size.height)))
        layoutAttributes.frame = newFrame
        
        return layoutAttributes
    }
    
}
