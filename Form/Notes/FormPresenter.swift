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
    
    private var simpleInput: FieldType = .simpleInput(title: "Nota Deseada",
                                                      input: "")
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
        guard isValidSection(of: .doubleInput, at: index) else {
            print("Invalid section to be updated \(index.section), it should be of Double Input type")
            return
        }
        
        guard let newDoubleInput = updateDoubleInput(firtsInput: firstInput,
                                                     secondInput: secondInput,
                                                     errorDescription: "",
                                                     at: index) else { return }
        
        doubleInputFields[index.row] = newDoubleInput
    }
    
    func calculateNote() {
        cleanDoubleInputErrors()
        let errors = interactor.notesAreValid(rawNotes)
        
        guard errors.isEmpty else {
            processValidationErrors(errors)
            return
        }
        //Set the state if notes are not valid(calculate each indexpath) return invalid state if needed
        //Calculate desirednote
    }
    
    func cleanNotes() {
        let doubleInputsFieldWithoutValues = doubleInputFields.flatMap { $0.updateDoubleInput(firstInput: "",
                                                                                              secondInput: "",
                                                                                              errorDescription: "") }
        
        guard !doubleInputsFieldWithoutValues.isEmpty else {
            print("Error can't remove erorrs on double inputs")
            return
        }
        
        doubleInputFields = doubleInputsFieldWithoutValues
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
    
    func isValidSection(of type: FormSection, at index: IndexPath) -> Bool {
        return FormSection(rawValue: index.section) == type
    }
    
    func createIndexPath(for section: FormSection, item: UInt) -> IndexPath {
        return IndexPath(item: Int(item), section: section.rawValue)
    }
    
    func processValidationErrors(_ errors: [ScoreErrorResult]) {
        var errorIndexPaths: [IndexPath] = []
        
        for (index, doubleInput) in doubleInputFields.enumerated() {
            guard case .doubleInput(_, _, _, _, _) = doubleInput,
                let scoreErrors = errors[safe: index] else {
                continue
            }
            
            let errorDescriptions = errorText(for: scoreErrors.errors)
            guard updateDoubleInputError(error: errorDescriptions, at: index) else {
                continue
            }
            
            let errorIndexPath = IndexPath(row: index, section: FormSection.doubleInput.rawValue)
            errorIndexPaths.append(errorIndexPath)
        }
        
        formViewState = .showValidationError(indexPaths: errorIndexPaths)
    }
    
    func errorText(for scoreErrors: [ScoreError]) -> String {
        return scoreErrors
            .map { $0.localizedDescription }
            .joined(separator: ", ")
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
    
    static var defaultDoubleInput: FieldType {
        return .doubleInput(firtsTitleInput: "Nota",
                            firstInput: "",
                            secondTitleInput: "Porcentaje",
                            secondInput: "",
                            validationError: "")
    }
    
    func updateDoubleInput(firtsInput: String, secondInput: String, errorDescription: String, at index: IndexPath) -> FieldType? {
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
    
}
