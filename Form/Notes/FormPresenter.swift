//
//  FormPresenter.swift
//  Form
//
//  Created by Eli Pacheco Hoyos on 10/22/17.
//  Copyright © 2017 Eli Pacheco Hoyos. All rights reserved.
//

import Foundation
import UIKit

fileprivate enum FormSections: Int {
    case information
    case input
    case action
    
    static var sections: UInt {
        return 3
    }
}

class FormPresenter: FormPresenterInterface {
    
    var sections: UInt {
        return FormSections.sections
    }
    
    var formViewStateAction: FormViewStateAction?
    
    private var formViewState: FormViewState = .idle {
        didSet{
            formViewStateAction?(formViewState)
        }
    }
    
    private var doubleInputFields: [FieldType] = [FormPresenter.defaultInput]
    private var doubleInputIntructionsMessage: String {
        return "adoedmwed ewod wedwiopemdw edopqiwed qwoepdqwmed qwoedinqwe diqwed#"
    }
    
    func fields(for section: UInt) -> [FieldType] {
        guard let formSections = FormSections(rawValue: Int(section)) else {
            return []
        }
        
        switch formSections {
        case .information:
            return [
                .simpleMessage(description: doubleInputIntructionsMessage)
            ]
        case .input:
            return doubleInputFields
        case .action:
            return [
                .addOrRemoveInput(addTitle: "", removeTitle: ""),
                .simpleAction(title: "Calcula tu Nota")
            ]
        }
    }
    
    func removeDoubleInput(at index: UInt?) {
        guard doubleInputFields.count > 1 else {
            print("Can't remove input at index: \(index ?? 1)")
            return
        }
        
        if let index = index,
            index < doubleInputFields.count - 1 {
            doubleInputFields.remove(at: Int(index))
            formViewState = .deletedInput(indexPath: createIndexPath(for: .input, item: index))
            return
        }
        
        let lastIndex = UInt(doubleInputFields.count - 1)
        doubleInputFields.removeLast()
        formViewState = .deletedInput(indexPath: createIndexPath(for: .input, item: lastIndex))
    }
    
    func addDoubleInput(at index: UInt?) {
        let inputToInsert = FormPresenter.defaultInput
        
        if let index = index,
           index < doubleInputFields.count - 1 {
            doubleInputFields.insert(inputToInsert, at: Int(index))
            formViewState = .addedInput(indexPath: createIndexPath(for: .input, item: index))
            return
        }
        
        doubleInputFields.append(inputToInsert)
        let lastIndex = UInt(doubleInputFields.count - 1)
        formViewState = .addedInput(indexPath: createIndexPath(for: .input, item: lastIndex))
    }
    
    func calculateNote() {
        
    }
    
    func createRemoveOrAddAction(for indexPath: IndexPath) -> RemoveOrAddTypeAction {
        return { [weak self] (action) in
            guard let `self` = self else {
                return
            }
            
            switch action {
            case .add:
                self.addDoubleInput(at: nil)
            case .remove:
                self.removeDoubleInput(at: nil)
            }
        }
    }
    
}

private extension FormPresenter {
    
    static var defaultInput: FieldType {
        return .doubleInput(firtsTitleInput: "Nota", secondTitleInput: "Porcentaje", validationError: "")
    }
    
    func createIndexPath(for section: FormSections, item: UInt) -> IndexPath {
        return IndexPath(item: Int(item), section: section.rawValue)
    }
    
}
