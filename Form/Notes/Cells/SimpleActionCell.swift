//
//  SimpleActionCell.swift
//  Form
//
//  Created by Eli Pacheco Hoyos on 10/22/17.
//  Copyright © 2017 Eli Pacheco Hoyos. All rights reserved.
//

import UIKit

class SimpleActionCell: UITableViewCell, DequeueAbleCell {
    
    @IBOutlet weak var actionButton: UIButton!
    var action: SimpleAction?
    var indexPath: IndexPath?
    
    static var dequeueCell: FieldCellType {
        let simpleActionCellIdentifier = String(describing: SimpleActionCell.self)
        let simpleActionNib = UINib(nibName: String(describing: SimpleActionCell.self), bundle: nil)
        
        return FieldCellType(cellIdentifier: simpleActionCellIdentifier,
                             nib: simpleActionNib)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        action = nil
        indexPath = nil
    }
    
    func update(with field: FieldType) {
        guard case let .simpleAction(title) = field  else {
            return
        }
        
       actionButton.setTitle(title, for: .normal)
    }
    
    
    @IBAction func actionButtonWasPressed(_ sender: Any) {
        action?()
    }
    
}
