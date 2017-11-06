//
//  ResultWithTitleCell.swift
//  Form
//
//  Created by Eli Pacheco Hoyos on 11/5/17.
//  Copyright © 2017 Eli Pacheco Hoyos. All rights reserved.
//

import UIKit

class ResultWithTitleCell: UITableViewCell, DequeueAbleCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    
    static var dequeueCell: FieldCellType {
        let simpleResultWithTitleCellIdentifier = String(describing: ResultWithTitleCell.self)
        let simpleResultWithHeaderNib = UINib(nibName: String(describing: ResultWithTitleCell.self), bundle: nil)
        
        return FieldCellType(cellIdentifier: simpleResultWithTitleCellIdentifier,
                             nib: simpleResultWithHeaderNib)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func update(with field: FieldType) {
        guard case .result(let title, let message) = field else {
            return
        }
        
        titleLabel.text = title
        messageLabel.text = message
    }
    
}
