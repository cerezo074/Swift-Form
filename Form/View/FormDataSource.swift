//
//  FormDataSource.swift
//  Form
//
//  Created by Eli Pacheco Hoyos on 10/22/17.
//  Copyright © 2017 Eli Pacheco Hoyos. All rights reserved.
//

import Foundation
import UIKit

typealias FieldCellType = (cellIdentifier: String, nib: UINib)

protocol DequeueAbleCell {
    static var dequeueCell: FieldCellType { get }
    func update(with field: FieldType)
}

class FormDataSource: NSObject {

    weak var presenter: FormPresenterInterface?
    
    init(presenter: FormPresenterInterface) {
        self.presenter = presenter
    }
    
}

extension FormDataSource: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return Int(presenter?.sections ?? 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fields(at: section).count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let field = fields(at: indexPath.section)[safe: indexPath.item],
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: field.cellType.cellIdentifier, for: indexPath) as? UICollectionViewCell & DequeueAbleCell else {
                return UICollectionViewCell()
        }
        
        cell.update(with: field)
        shouldBindRemoveOrAddAction(with: field, on: cell, at: indexPath)
        
        return cell
    }
    
}

private extension FormDataSource {
    
    private func fields(at section: Int) -> [FieldType] {
        guard let presenter = presenter else {
            return []
        }
        
        return presenter.fields(for: UInt(section))
    }
    
    func shouldBindRemoveOrAddAction(with field: FieldType, on cell: UICollectionViewCell, at index: IndexPath) {
        guard let cell = cell as? AddOrRemoveDoubleInputCell else {
            return
        }
        
        cell.action = presenter?.createRemoveOrAddAction(for: index)
    }
    
}
