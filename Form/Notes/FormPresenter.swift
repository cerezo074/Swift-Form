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
            formViewState = .deletedInput(indexPaths: [createIndexPath(for: .doubleInput, item: index)])
            return
        }
        
        let lastIndex = UInt(doubleInputFields.count - 1)
        doubleInputFields.removeLast()
        formViewState = .deletedInput(indexPaths: [createIndexPath(for: .doubleInput, item: lastIndex)])
    }
    
    func addDoubleInput(at index: UInt?) {
        let inputToInsert = FormPresenter.defaultDoubleInput
        
        if let index = index,
           index < doubleInputFields.count - 1 {
            doubleInputFields.insert(inputToInsert, at: Int(index))
            formViewState = .addedInput(indexPaths: [createIndexPath(for: .doubleInput, item: index)])
            return
        }
        
        doubleInputFields.append(inputToInsert)
        let lastIndex = UInt(doubleInputFields.count - 1)
        formViewState = .addedInput(indexPaths: [createIndexPath(for: .doubleInput, item: lastIndex)])
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
        let resultIndexPath = [IndexPath(row: 0, section: FormSection.result.rawValue)]
        let errorIndexes = removeInvalidErrorsOnDoubleInputFields(with: nil) + removeInvalidErrorsOnSimpleInputFields(with: nil)
        
        if self.result != nil {
            self.result = result
            formViewState = .showResult(indexPaths: errorIndexes + resultIndexPath, add: false)
            
            return
        }
        
        self.result = result
        if errorIndexes.isEmpty {
//            formViewState = .showResult(indexPaths: resultIndexPath, add: true)
            return
        }

        formViewState = .showValidationErrors(indexPaths: errorIndexes)
        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
//            self?.formViewState = .addedInput(indexPaths: resultIndexPath)
//        }
    }
    
    func updateViewForErrors(errorIndexes: [IndexPath]) {
        guard !errorIndexes.isEmpty else {
            return
        }
        
        let resultIndexPath = [IndexPath(row: 0, section: FormSection.result.rawValue)]
        
        guard result != nil else {
            formViewState = .showValidationErrors(indexPaths: errorIndexes)
            return
        }
        
        result = nil
        formViewState = .deleteResults(indexPath: resultIndexPath)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            self?.formViewState = .showValidationErrors(indexPaths: errorIndexes)
        }
    }
    
    func cleanNotes() {
        cleanSimpleErrors()
        let doubleInputsFieldWithoutValues = doubleInputFields.flatMap { $0.updateDoubleInput(firstInput: "",
                                                                                              secondInput: "",
                                                                                              errorDescription: "")}
        
        guard !doubleInputsFieldWithoutValues.isEmpty else {
            print("Error can't remove errors on double inputs")
            return
        }
        
        doubleInputFields = doubleInputsFieldWithoutValues
        //TODO: clean all(simple and double inputs) on view
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
    
    func createIndexPath(for section: FormSection, item: UInt) -> IndexPath {
        return IndexPath(item: Int(item), section: section.rawValue)
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
            
            let errorIndexPath = IndexPath(row: index, section: FormSection.doubleInput.rawValue)
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
        let validIndexes = validErrors?.map { Int($0.index) } ?? []
        var invalidIndexes: [IndexPath] = []
        
        for (possibleInvalidIndex, field) in doubleInputFields.enumerated() {
            let possibleInvalidIndexPath = IndexPath(row: possibleInvalidIndex, section: FormSection.doubleInput.rawValue)
            
            guard case let .doubleInput(_, _, _, _, validationError) = field else {
                continue
            }
            
            if let updatedFieldWithoutErrors = field.cleanDoubleInputError(),
                validIndexes.isEmpty,
                !validationError.isEmpty {
                doubleInputFields[possibleInvalidIndex] = updatedFieldWithoutErrors
                invalidIndexes.append(possibleInvalidIndexPath)
                continue
            }
            
            guard let updatedFieldWithoutErrors = field.cleanDoubleInputError(),
                !validationError.isEmpty else {
                    continue
            }
            
            guard !validIndexes.contains(possibleInvalidIndex) || validErrors != nil else {
                continue
            }
            
            doubleInputFields[possibleInvalidIndex] = updatedFieldWithoutErrors
            invalidIndexes.append(possibleInvalidIndexPath)
        }
        
        return invalidIndexes
    }
    
    func processSimpleInputError(_ error: ScoreError) -> [IndexPath] {
        let errorDescriptions = errorText(for: [error])
        guard updateSimpleInputError(error: errorDescriptions) else {
            return removeInvalidErrorsOnSimpleInputFields(with: error)
        }
        
        return [IndexPath(row: 0, section: FormSection.simpleInput.rawValue)]
    }
    
    func removeInvalidErrorsOnSimpleInputFields(with validErrors: ScoreError?) -> [IndexPath] {
        guard case let .simpleInput(_ ,_ , validationError) = simpleInput,
            !validationError.isEmpty else {
                return []
        }
        
        cleanSimpleErrors()
        
        return [IndexPath(row: 0, section: FormSection.simpleInput.rawValue)]
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
    
    func cleanDoubleInputErrors() {
        let doubleInputsFieldWithoutError = doubleInputFields.flatMap { $0.cleanDoubleInputError() }
        
        guard !doubleInputsFieldWithoutError.isEmpty else {
            print("Error can't remove erorrs on double inputs")
            return
        }
        
        doubleInputFields = doubleInputsFieldWithoutError
    }
    
    func cleanSimpleErrors() {
        guard let simpleInputWithoutError = simpleInput.updateSimpleInput(nil, error: "") else {
            print("Error can't remove erorr on simple input")
            return
        }
        
        simpleInput = simpleInputWithoutError
    }
    
}
