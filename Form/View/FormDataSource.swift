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

extension FormDataSource: UITableViewDataSource {
    
    func registerCells(on tableView: UITableView, for fieldSections: [FormSection]) {
        fieldSections.forEach {
            tableView.register($0.cellType.nib, forCellReuseIdentifier: $0.cellType.cellIdentifier)
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return Int(presenter?.sections ?? 0)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fields(at: section).count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let field = fields(at: indexPath.section)[safe: indexPath.item],
            let cell = tableView.dequeueReusableCell(withIdentifier: field.cellType.cellIdentifier) else {
                return UITableViewCell()
        }
        
        if let cell = cell as? DequeueAbleCell {
            cell.update(with: field)
        }
        
        shouldConfigureRemoveOrAddAction(on: cell, at: indexPath)
        shouldConfigureInputs(on: cell, at: indexPath)
        shouldConfigureSimpleAction(on: cell, at: indexPath)
        
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
    
    func shouldConfigureRemoveOrAddAction(on cell: UITableViewCell, at index: IndexPath) {
        guard let cell = cell as? AddOrRemoveDoubleInputCell else {
            return
        }
        
        cell.action = presenter?.removeOrAddAction(for: index)
    }
    
    func shouldConfigureInputs(on cell: UITableViewCell, at index: IndexPath) {
        if let cell = cell as? SimpleInputCell {
            cell.indexPath = index
            cell.action = presenter?.simpleInputAction(for: index)
        }
        
        if let cell = cell as? DoubleInputCell {
            cell.indexPath = index
            cell.action = presenter?.doubleInputAction(for: index)
        }
    }
    
    func shouldConfigureSimpleAction(on cell: UITableViewCell, at index: IndexPath) {
        guard let cell = cell as? SimpleActionCell else {
            return
        }
        
        cell.indexPath = index
        cell.action = presenter?.simpleAction(for: index)
    }
    
}
