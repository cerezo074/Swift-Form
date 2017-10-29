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
    case doubleInput
    case addOrRemove
    case simpleInput
    case action
    
    static var sections: UInt {
        return 5
    }
}

class FormPresenter: FormPresenterInterface {
    
    var sections: UInt {
        return FormSections.sections
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
    private var doubleInputFields: [FieldType] = [FormPresenter.defaultInput]
    private var doubleInputIntructionsMessage: String {
        return "adoedmwed ewod wedwiopemdw edopqiwed qwoepdqwmed qwoedinqwe diqwed#"
    }
    
    private let interactor: NotesInteractorInterface
    
    required init(interactor: NotesInteractorInterface) {
        self.interactor = interactor
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
            formViewState = .deletedInput(indexPath: createIndexPath(for: .doubleInput, item: index))
            return
        }
        
        let lastIndex = UInt(doubleInputFields.count - 1)
        doubleInputFields.removeLast()
        formViewState = .deletedInput(indexPath: createIndexPath(for: .doubleInput, item: lastIndex))
    }
    
    func addDoubleInput(at index: UInt?) {
        let inputToInsert = FormPresenter.defaultInput
        
        if let index = index,
           index < doubleInputFields.count - 1 {
            doubleInputFields.insert(inputToInsert, at: Int(index))
            formViewState = .addedInput(indexPath: createIndexPath(for: .doubleInput, item: index))
            return
        }
        
        doubleInputFields.append(inputToInsert)
        let lastIndex = UInt(doubleInputFields.count - 1)
        formViewState = .addedInput(indexPath: createIndexPath(for: .doubleInput, item: lastIndex))
    }
    
    func setSimpleInput(_ newValue: String, at index: IndexPath) {
        guard let section = FormSections(rawValue: index.section),
            section == .simpleInput else {
            print("Invalid section to be updated \(index.section), it should be of simpleInput type")
            return
        }
        
        guard case let .simpleInput(title, _) = simpleInput else {
            return
        }
        
        simpleInput = .simpleInput(title: title, input: newValue)
    }
    
    func setDoubleInput(firstInput: String, secondInput: String, at index: IndexPath) {
        guard let newDoubleInput = createDoubleInput(firtsInput: firstInput,
                                                  secondInput: secondInput,
                                                  at: index) else {
            return
        }
        
        doubleInputFields[index.row] = newDoubleInput
    }
    
    func calculateNote() {
        
        //Fill double input fields
        //Set the state if notes are not valid(calculate each indexpath) return invalid state if needed
        //Calculate desirednote
    }
    
    func cleanNotes() {
        let doubleInputsFieldWithoutValues = doubleInputFields.flatMap { field -> FieldType? in
            guard case let .doubleInput(firstTitle, _, secondTitle, _, _) = field else {
                return nil
            }
            
            return .doubleInput(firtsTitleInput: firstTitle,
                                firstInput: "",
                                secondTitleInput: secondTitle,
                                secondInput: "",
                                validationError: "")
        }
        
        guard !doubleInputsFieldWithoutValues.isEmpty else {
            print("Error can't remove erorrs on double inputs")
            return
        }
        
        doubleInputFields = doubleInputsFieldWithoutValues
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
    
    var notes: [Score] {
        return doubleInputFields.flatMap { (field) -> Score? in
            guard case let .doubleInput(_ ,noteText, _, percentageText, _) = field else {
                return nil
            }
            
            guard let note = Float(noteText), let percetage = Float(percentageText) else {
                return nil
            }
            
            return Score(note: note, percentage: percetage)
        }
    }
    
    static var defaultInput: FieldType {
        return .doubleInput(firtsTitleInput: "Nota",
                            firstInput: "",
                            secondTitleInput: "Porcentaje",
                            secondInput: "",
                            validationError: "")
    }
    
    func createDoubleInput(firtsInput: String, secondInput: String, at index: IndexPath) -> FieldType? {
        guard let section = FormSections(rawValue: index.section),
            section == .doubleInput else {
                print("Invalid section to be updated \(index.section), it should be of doubleInput type")
                return nil
        }
        
        guard doubleInputFields[safe: index.row] != nil else {
            print("Invalid row to be updated on double input section \(index.row)")
            return nil
        }
        
        return .doubleInput(firtsTitleInput: "Nota",
                            firstInput: firtsInput,
                            secondTitleInput: "Porcentaje",
                            secondInput: secondInput,
                            validationError: "")
    }
    
    func createIndexPath(for section: FormSections, item: UInt) -> IndexPath {
        return IndexPath(item: Int(item), section: section.rawValue)
    }
    
    func cleanErrors() {
        let doubleInputsFieldWithoutError = doubleInputFields.flatMap { field -> FieldType? in
            guard case let .doubleInput(firstTitle, firstInput, secondTitle, secondInput, _) = field else {
                return nil
            }
            
            return .doubleInput(firtsTitleInput: firstTitle,
                                firstInput: firstInput,
                                secondTitleInput: secondTitle,
                                secondInput: secondInput,
                                validationError: "")
        }
        
        guard !doubleInputsFieldWithoutError.isEmpty else {
            print("Error can't remove erorrs on double inputs")
            return
        }
        
        doubleInputFields = doubleInputsFieldWithoutError
    }
    
}
