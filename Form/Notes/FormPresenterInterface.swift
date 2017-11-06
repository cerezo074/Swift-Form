//
//  NotesPresenterInterface.swift
//  Form
//
//  Created by Eli Pacheco Hoyos on 10/22/17.
//  Copyright © 2017 Eli Pacheco Hoyos. All rights reserved.
//

import Foundation

enum FormSection: Int {
    case information
    case doubleInput
    case addOrRemove
    case simpleInput
    case result
    case action
    
    static var sections: UInt {
        return 6
    }
}

enum FieldType {
    case simpleMessage(description: String)
    case addOrRemoveInput(addTitle: String, removeTitle: String)
    case simpleAction(title: String)
    case simpleInput(title: String, input: String, validationError: String)
    case doubleInput(
        firtsTitleInput: String,
        firstInput: String,
        secondTitleInput: String,
        secondInput: String,
        validationError: String
    )
    case result(title: String, message: String)
}

extension FieldType {
    
    var cellType: FieldCellType {
        switch self {
        case .simpleMessage(_):
            return SimpleDescriptionCell.dequeueCell
        case .simpleInput(_, _, _):
            return SimpleInputCell.dequeueCell
        case .doubleInput(_, _, _, _, _):
            return DoubleInputCell.dequeueCell
        case .addOrRemoveInput(_, _):
            return AddOrRemoveDoubleInputCell.dequeueCell
        case .simpleAction(_):
            return SimpleActionCell.dequeueCell
        case .result(_, _):
            return ResultWithTitleCell.dequeueCell
        }
    }
    
    func updateSimpleInput(_ input: String? = nil, error: String? = nil) -> FieldType? {
        guard case let .simpleInput(title, oldInput, oldError) = self else {
            return nil
        }
        
        return .simpleInput(title: title,
                            input: input ?? oldInput,
                            validationError: error ?? oldError)
    }
    
    func updateDoubleInput(firstInput: String? = nil, secondInput: String? = nil, errorDescription: String? = nil) -> FieldType? {
        guard case let .doubleInput(firstTitle, oldFirstInput, secondTitle, oldSecondInput, oldError) = self else {
            return nil
        }
        
        return .doubleInput(firtsTitleInput: firstTitle,
                            firstInput: firstInput ?? oldFirstInput,
                            secondTitleInput: secondTitle,
                            secondInput: secondInput ?? oldSecondInput,
                            validationError: errorDescription ?? oldError)
    }
    
    func cleanDoubleInputError() -> FieldType? {
        guard case let .doubleInput(firstTitle, firstInput, secondTitle, secondInput, _) = self else {
            return nil
        }
        
        return .doubleInput(firtsTitleInput: firstTitle,
                            firstInput: firstInput,
                            secondTitleInput: secondTitle,
                            secondInput: secondInput,
                            validationError: "")
    }
    
}

extension FieldType: Equatable {
    
    static func ==(left: FieldType, right: FieldType) -> Bool {
        switch (left, right) {
        case (.simpleMessage(let leftDescription), .simpleMessage(let rightDescription)):
            return leftDescription == rightDescription
            
        case (.doubleInput(
                let leftFirtsTitleInput,
                let leftFirstInput,
                let leftSecondTitleInput,
                let leftSecondInput,
                let leftValidationError),
              .doubleInput(
                let rightFirtsTitleInput,
                let rightFirstInput,
                let rightSecondTitleInput,
                let rightSecondInput,
                let rightValidationError)):
            return leftFirtsTitleInput == rightFirtsTitleInput
                && leftFirstInput == rightFirstInput
                && leftSecondTitleInput == rightSecondTitleInput
                && leftSecondInput == rightSecondInput
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
    case addedInput(indexPaths: [IndexPath])
    case deletedInput(indexPaths: [IndexPath])
    case showValidationErrors(indexPaths: [IndexPath])
    case showResult(indexPaths: [IndexPath], add: Bool)
    case deleteResults(indexPath: [IndexPath])
    case showMessageToUser(title: String, message: String)
}

typealias RemoveOrAddTypeAction = (RemoveOrAddType) -> Void
typealias FormViewStateAction = (FormViewState) -> Void
typealias SimpleAction = () -> Void
typealias SimpleInputAction = (_ input: String, _ index: IndexPath) -> Void
typealias DoubleInputAction = (_ firstInput: String, _ secondInput: String, _ index: IndexPath) -> Void

enum ValidationErrorType: String {
    case simpleInput
    case doubleInput
}

protocol FormPresenterInterface: class {
    var sections: UInt { get }
    var cleanText: String { get }
    var formViewStateAction: FormViewStateAction? { get set }
    
    func setSimpleInput(_ newValue: String, at index: IndexPath)
    func setDoubleInput(firstInput: String, secondInput: String, at index: IndexPath)
    func fields(for section: UInt) -> [FieldType]
    func removeDoubleInput(at index: UInt?)
    func addDoubleInput(at index: UInt?)
    func calculateNote()
    func cleanNotes()
    
    func removeOrAddAction(for index: IndexPath) -> RemoveOrAddTypeAction
    func simpleAction(for index: IndexPath) -> SimpleAction
    func simpleInputAction(for index: IndexPath) -> SimpleInputAction
    func doubleInputAction(for index: IndexPath) -> DoubleInputAction
    
    init(interactor: NotesInteractorInterface)
}
