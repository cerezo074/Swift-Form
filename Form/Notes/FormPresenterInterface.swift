//
//  NotesPresenterInterface.swift
//  Form
//
//  Created by Eli Pacheco Hoyos on 10/22/17.
//  Copyright © 2017 Eli Pacheco Hoyos. All rights reserved.
//

import Foundation

enum FieldType {
    case simpleMessage(description: String)
    case doubleInput(firtsTitleInput: String, secondTitleInput: String, validationError: String)
    case addOrRemoveInput(addTitle: String, removeTitle: String)
    case simpleAction(title: String)
    
    var cellType: FieldCellType {
        switch self {
        case .simpleMessage(_):
            return DoubleInputHeaderCell.dequeueCell
        case .doubleInput(_, _, _):
            return DoubleInputCell.dequeueCell
        case .addOrRemoveInput(_, _):
            return AddOrRemoveDoubleInputCell.dequeueCell
        case .simpleAction(_):
            return SimpleActionCell.dequeueCell
        }
    }
}

extension FieldType: Equatable {
    
    static func ==(left: FieldType, right: FieldType) -> Bool {
        switch (left, right) {
        case (.simpleMessage(let leftDescription), .simpleMessage(let rightDescription)):
            return leftDescription == rightDescription
            
        case (.doubleInput(let leftFirtsTitleInput, let leftSecondTitleInput, let leftValidationError),
              .doubleInput(let rightFirtsTitleInput, let rightSecondTitleInput, let rightValidationError)):
            return leftFirtsTitleInput == rightFirtsTitleInput
                && leftSecondTitleInput == rightSecondTitleInput
                && leftValidationError == rightValidationError
            
        case (.addOrRemoveInput(let leftAddTitle, let leftRemoveTitle),
              .addOrRemoveInput(let rightAddTitle, let rightRemoveTitle)):
            return leftAddTitle == rightAddTitle && leftRemoveTitle == rightRemoveTitle
        
        case (.simpleAction(let leftTitle), .simpleAction(let rightTitle)):
            return leftTitle == rightTitle
            
        default:
            return false
        }
    }
    
}

enum RemoveOrAddType {
    case add
    case remove
}

enum FormViewState {
    case idle
    case addedInput(indexPath: IndexPath)
    case deletedInput(indexPath: IndexPath)
    case showValidationError(indexPath: IndexPath)
    case showResult(indexPath: IndexPath)
}

typealias RemoveOrAddTypeAction = (RemoveOrAddType) -> Void
typealias FormViewStateAction = (FormViewState) -> Void

protocol FormPresenterInterface: class {
    var sections: UInt { get }
    var formViewStateAction: FormViewStateAction? { get set }
    
    func fields(for section: UInt) -> [FieldType]
    func removeDoubleInput(at index: UInt?)
    func addDoubleInput(at index: UInt?)
    func calculateNote()
    func createRemoveOrAddAction(for indexPath: IndexPath) -> RemoveOrAddTypeAction
}
