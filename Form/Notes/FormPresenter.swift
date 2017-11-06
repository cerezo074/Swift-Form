//
//  FormPresenter.swift
//  Form
//
//  Created by Eli Pacheco Hoyos on 10/22/17.
//  Copyright © 2017 Eli Pacheco Hoyos. All rights reserved.
//

import Foundation
import UIKit

class FormPresenter: FormPresenterInterface {
    
    var sections: UInt {
        return FormSection.sections
    }
    
    var sectionTypes: [FormSection] {
        return [
            FormSection.information,
            FormSection.doubleInput,
            FormSection.addOrRemove,
            FormSection.simpleInput,
            FormSection.result,
            FormSection.action,
        ]
    }
    
    var cleanText: String {
        return "Limpiar"
    }
    
    var formViewStateAction: FormViewStateAction?
    
    private var formViewState: FormViewState = .idle {
        didSet{
            formViewStateAction?(formViewState)
        }
    }
    
    private var result: FieldType?
    private var simpleInput: FieldType = .simpleInput(title: "Nota Deseada",
                                                      input: "",
                                                      validationError: "")
    private var doubleInputFields: [FieldType] = [FormPresenter.defaultDoubleInput]
    private var doubleInputIntructionsMessage: String {
        return "adoedmwed ewod wedwiopemdw edopqiwed qwoepdqwmed qwoedinqwe diqwed#"
    }
    
    private let interactor: NotesInteractorInterface
    
    required init(interactor: NotesInteractorInterface) {
        self.interactor = interactor
    }
    
    func fields(for section: UInt) -> [FieldType] {
        guard let formSections = FormSection(rawValue: Int(section)) else {
            return []
        }
        
        switch formSections {
        case .information:
            return [
                .simpleMessage(description: doubleInputIntructionsMessage)
            ]
        case .doubleInput:
            return doubleInputFields
        case .addOrRemove:
            return [.addOrRemoveInput(addTitle: "", removeTitle: "")]
        case .simpleInput:
            return [simpleInput]
        case .result:
            guard let result = result else {
                return []
            }
            
            return [result]
        case .action:
            return [.simpleAction(title: "Calcula tu Nota")]
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
            formViewState = .deletedInputs(indexPaths: [createIndexPath(for: .doubleInput, row: index)])
            return
        }
        
        let lastIndex = UInt(doubleInputFields.count - 1)
        doubleInputFields.removeLast()
        formViewState = .deletedInputs(indexPaths: [createIndexPath(for: .doubleInput, row: lastIndex)])
    }
    
    func addDoubleInput(at index: UInt?) {
        let inputToInsert = FormPresenter.defaultDoubleInput
        
        if let index = index,
           index < doubleInputFields.count - 1 {
            doubleInputFields.insert(inputToInsert, at: Int(index))
            formViewState = .addedInputs(indexPaths: [createIndexPath(for: .doubleInput, row: index)])
            return
        }
        
        doubleInputFields.append(inputToInsert)
        let lastIndex = UInt(doubleInputFields.count - 1)
        formViewState = .addedInputs(indexPaths: [createIndexPath(for: .doubleInput, row: lastIndex)])
    }
    
    func setSimpleInput(_ newValue: String, at index: IndexPath) {
        guard isValidSection(of: .simpleInput, at: index)  else {
            print("Invalid section to be updated \(index.section), it should be of Simple Input type")
            return
        }
        
        guard let simpleInputUpdated = simpleInput.updateSimpleInput(newValue) else {
            print("Can't update simple input")
            return
        }
        
        simpleInput = simpleInputUpdated
    }
    
    func setDoubleInput(firstInput: String, secondInput: String, at index: IndexPath) {
        guard let newDoubleInput = updateDoubleInput(firtsInput: firstInput,
                                                     secondInput: secondInput,
                                                     errorDescription: nil,
                                                     at: index) else { return }
        
        doubleInputFields[index.row] = newDoubleInput
    }
    
    func calculateNote() {
        guard fieldsWereFilled else {
            notifyCompleteAllFieldsFirst()
            return
        }
        
        if let inputValidationErrors = inputValidationErrors {
            processValidationErrors(inputValidationErrors)
            return
        }
        
        guard let desiredNote = desiredNote,
            let desiredNoteValue = Float(desiredNote) else {
            return
        }
        
        let calculatedNote = interactor.calculeNote(rawNotes,
                                        desiredNote: desiredNoteValue)
        let result = FieldType.result(title: "Necesitas...", message: "\(calculatedNote.note) en el \(calculatedNote.remainingPercentage)%")
        updateViewForResult(result)
    }
    
    func updateViewForResult(_ result: FieldType) {
        let resultIndexPath = [createIndexPath(for: .result, row: 0)]
        let errorIndexes = removeInvalidErrorsOnDoubleInputFields(with: nil) + removeInvalidErrorsOnSimpleInputFields(with: nil)

        self.result = result
        formViewState = .showResults(indexPaths: resultIndexPath, errors: errorIndexes)
    }
    
    func updateViewForErrors(errorIndexes: [IndexPath]) {
        var resultIndexPath: [IndexPath] = []
        
        if result != nil {
            result = nil
            resultIndexPath = [createIndexPath(for: .result, row: 0)]
        }
        
        formViewState = .deleteResults(indexPath: resultIndexPath, errors: errorIndexes)
    }
    
    func cleanNotes() {
        var inputIndexes: [IndexPath] = []
        var resultIndexes: [IndexPath] = []
        
        if let simpleInputCleaned = simpleInput.updateSimpleInput("", error: ""), !simpleInput.isEmpty {
            simpleInput = simpleInputCleaned
            inputIndexes.append(createIndexPath(for: .simpleInput, row: 0))
        }
        
        if result != nil {
            result = nil
            resultIndexes.append(createIndexPath(for: .result, row: 0))
        }
        
        for (doubleInputIndex, doubleInputField) in doubleInputFields.enumerated() {
            guard let doubleInputCleaned = doubleInputField.updateDoubleInput(firstInput: "", secondInput: "", errorDescription: ""),
                !doubleInputField.isEmpty else {
                continue
            }
            
            doubleInputFields[doubleInputIndex] = doubleInputCleaned
            inputIndexes.append(createIndexPath(for: .doubleInput, row: UInt(doubleInputIndex)))
        }
        
        formViewState = .cleanInputs(indexPaths: inputIndexes, results: resultIndexes)
    }
    
    func removeOrAddAction(for index: IndexPath) -> RemoveOrAddTypeAction {
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
    
    func simpleAction(for index: IndexPath) -> SimpleAction {
        return { [weak self] in
            guard let `self` = self else {
                return
            }
            
            self.calculateNote()
        }
    }

    func simpleInputAction(for index: IndexPath) -> SimpleInputAction {
        return { [weak self] (input, index) in
            guard let `self` = self else {
                return
            }
            
            self.setSimpleInput(input, at: index)
        }
    }
    
    func doubleInputAction(for index: IndexPath) -> DoubleInputAction {
        return { [weak self] (firstInput, secondInput, index) in
            guard let `self` = self else {
                return
            }
            
            self.setDoubleInput(firstInput: firstInput,
                                secondInput: secondInput,
                                at: index)
        }
    }
    
}

private extension FormPresenter {
    
    var rawNotes: [RawScore] {
        return doubleInputFields.flatMap { (field) -> RawScore? in
            guard case let .doubleInput(_ ,noteText, _, percentageText, _) = field else {
                return nil
            }
            
            return RawScore(note: noteText, percentage: percentageText)
        }
    }
    
    var desiredNote: String? {
        guard case let .simpleInput(_ ,input, _) = simpleInput else {
            return nil
        }
        
        return input
    }
    
    var fieldsWereFilled: Bool {
        guard case let .simpleInput(_, input, _) = simpleInput,
            !input.isEmpty else {
            return false
        }
        
        for doubleInput in doubleInputFields {
            guard case let .doubleInput(_, firstInput, _, secondInput, _) = doubleInput,
                !firstInput.isEmpty, !secondInput.isEmpty else {
                return false
            }
        }
        
        return true
    }
    
    var inputValidationErrors: [String : Any]? {
        var allErrors: [String : Any] = [:]
        let doubleInputErrors = interactor.notesAreValid(rawNotes)
        
        if !doubleInputErrors.isEmpty {
            allErrors[ValidationErrorType.doubleInput.rawValue] = doubleInputErrors
        }
        
        if let desiredNote = desiredNote,
            let desiredNoteError = interactor.desiredNoteIsValid(desiredNote) {
            allErrors[ValidationErrorType.simpleInput.rawValue] = desiredNoteError
        }
        
        return allErrors.isEmpty ? nil : allErrors
    }
    
    func isValidSection(of type: FormSection, at index: IndexPath) -> Bool {
        return FormSection(rawValue: index.section) == type
    }
    
    func createIndexPath(for section: FormSection, row index: UInt) -> IndexPath {
        return IndexPath(row: Int(index), section: section.rawValue)
    }
    
    func notifyCompleteAllFieldsFirst() {
        formViewState = .showMessageToUser(title: "Calculadora", message: "Debes llenar los todos campos primero")
    }
    
    func processValidationErrors(_ errors: [String : Any]) {
        var errorIndexPaths: [IndexPath] = []
        
        if let simpleInputErrors = errors[ValidationErrorType.simpleInput.rawValue] as? ScoreError {
            errorIndexPaths += processSimpleInputError(simpleInputErrors)
        } else {
            errorIndexPaths += removeInvalidErrorsOnSimpleInputFields(with: nil)
        }
        
        if let doubleInputErrors = errors[ValidationErrorType.doubleInput.rawValue] as? [ScoreErrorResult] {
            errorIndexPaths += processDoubleInputErrors(doubleInputErrors)
        } else {
            errorIndexPaths += removeInvalidErrorsOnDoubleInputFields(with: nil)
        }
        
        updateViewForErrors(errorIndexes: errorIndexPaths)
    }
    
    func processDoubleInputErrors(_ errors: [ScoreErrorResult]) -> [IndexPath] {
        var errorIndexPaths: [IndexPath] = removeInvalidErrorsOnDoubleInputFields(with: errors)
        
        for error in errors {
            let index = Int(error.index)
            
            let errorDescriptions = errorText(for: error.errors)
            guard updateDoubleInputError(error: errorDescriptions, at: index) else {
                continue
            }
            
            let errorIndexPath = createIndexPath(for: .doubleInput, row: UInt(index))
            errorIndexPaths.append(errorIndexPath)
        }
        
        return errorIndexPaths
    }
    
    func updateDoubleInputError(error: String, at index: Int) -> Bool {
        guard let doubleInputToUpdate = doubleInputFields[safe: index] else {
            return false
        }
        
        guard let doubleInputUpdated = doubleInputToUpdate.updateDoubleInput(firstInput: nil,
                                                                             secondInput: nil,
                                                                             errorDescription: error) else {
                                                                                return false
        }
        
        doubleInputFields[index] = doubleInputUpdated
        return true
    }
    
    func removeInvalidErrorsOnDoubleInputFields(with validErrors: [ScoreErrorResult]?) -> [IndexPath] {
        let validErrorIndexes = validErrors?.map { Int($0.index) } ?? []
        var invalidErrorIndexes: [IndexPath] = []
        
        for (possibleInvalidIndex, field) in doubleInputFields.enumerated() {
            let possibleInvalidIndexPath = createIndexPath(for: .doubleInput, row: UInt(possibleInvalidIndex))
            
            guard case let .doubleInput(_, _, _, _, fieldError) = field,
                let updatedFieldWithoutErrors = field.cleanDoubleInputError() else {
                continue
            }
            
            if validErrorIndexes.isEmpty, !fieldError.isEmpty {
                doubleInputFields[possibleInvalidIndex] = updatedFieldWithoutErrors
                invalidErrorIndexes.append(possibleInvalidIndexPath)
                continue
            }
            
            guard !validErrorIndexes.contains(possibleInvalidIndex), !fieldError.isEmpty else {
                continue
            }
            
            doubleInputFields[possibleInvalidIndex] = updatedFieldWithoutErrors
            invalidErrorIndexes.append(possibleInvalidIndexPath)
        }
        
        return invalidErrorIndexes
    }
    
    func processSimpleInputError(_ error: ScoreError) -> [IndexPath] {
        let errorDescriptions = errorText(for: [error])
        guard updateSimpleInputError(error: errorDescriptions) else {
            return removeInvalidErrorsOnSimpleInputFields(with: error)
        }
        
        return [createIndexPath(for: .simpleInput, row: 0)]
    }
    
    func removeInvalidErrorsOnSimpleInputFields(with validErrors: ScoreError?) -> [IndexPath] {
        guard case let .simpleInput(_ ,_ , validationError) = simpleInput,
            !validationError.isEmpty,
            updateSimpleInputError(error: "") else {
                return []
        }
        
        return [createIndexPath(for: .simpleInput, row: 0)]
    }
    
    func updateSimpleInputError(error: String) -> Bool {
        guard let simpleInputUpdated = simpleInput.updateSimpleInput(nil, error: error) else {
            return false
        }
        
        simpleInput = simpleInputUpdated
        return true
    }
    
    func errorText(for scoreErrors: [ScoreError]) -> String {
        return scoreErrors
            .map { $0.localizedDescription }
            .joined(separator: ", ")
    }
    
    static var defaultDoubleInput: FieldType {
        return .doubleInput(firtsTitleInput: "Nota",
                            firstInput: "",
                            secondTitleInput: "Porcentaje",
                            secondInput: "",
                            validationError: "")
    }
    
    func updateDoubleInput(firtsInput: String, secondInput: String, errorDescription: String? = nil, at index: IndexPath) -> FieldType? {
        guard let section = FormSection(rawValue: index.section),
            section == .doubleInput else {
                print("Invalid section to be updated \(index.section), it should be of doubleInput type")
                return nil
        }
        
        guard let doubleInputToUpdated = doubleInputFields[safe: index.row] else {
            print("Invalid row to be updated on double input section \(index.row)")
            return nil
        }
        
        return doubleInputToUpdated.updateDoubleInput(firstInput: firtsInput,
                                                      secondInput: secondInput,
                                                      errorDescription: errorDescription)
    }
    
}
