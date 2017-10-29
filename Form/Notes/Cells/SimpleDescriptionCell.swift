//
//  SimpleDescriptionCell.swift
//  Form
//
//  Created by Eli Pacheco Hoyos on 10/22/17.
//  Copyright © 2017 Eli Pacheco Hoyos. All rights reserved.
//

import UIKit

class SimpleDescriptionCell: UITableViewCell, DequeueAbleCell {

    @IBOutlet weak var descriptionLabel: UILabel!
    
    static var dequeueCell: FieldCellType {
        let doubleInputHeaderCellIdentifier = String(describing: SimpleDescriptionCell.self)
        let doubleInputHeaderNib = UINib(nibName: String(describing: SimpleDescriptionCell.self), bundle: nil)
        
        return FieldCellType(cellIdentifier: doubleInputHeaderCellIdentifier,
                             nib: doubleInputHeaderNib)
    }
    
    func update(with field: FieldType) {
        guard case let .simpleMessage(description) = field  else {
            return
        }
        
        descriptionLabel.text = description
    }

}
