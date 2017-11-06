//
//  NotesInteractor.swift
//  Form
//
//  Created by Eli Pacheco Hoyos on 10/28/17.
//  Copyright © 2017 Eli Pacheco Hoyos. All rights reserved.
//

import Foundation

typealias NoteCalculated = (note: Float, acumulatedPercentage: Float, remainingPercentage: Float)

class NotesInteractor: NotesInteractorInterface {
    
    struct ValidationRanges {
        static let noteLowLimitValue: Float = 0.1
        static let noteUpLimitValue: Float = 5
        static let percentageLowLimitValue: Float = 1
        static let percentageUpLimitValue: Float = 100
    }
    
    private let calculatorService: NotesCalculatorProtocol
    
    init(calculatorService: NotesCalculatorProtocol) {
        self.calculatorService = calculatorService
    }
    
    func desiredNoteIsValid(_ note: String) -> ScoreError? {
        return validateNote(note)
    }
    
    func notesAreValid(_ rawScores: [RawScore]) -> [ScoreErrorResult] {
        var errors: [ScoreErrorResult] = []
        
        for (index, rawScore) in rawScores.enumerated() {
            var errorsAtIndex: [ScoreError] = []
            
            if let noteError = validateNote(rawScore.note) {
                errorsAtIndex.append(noteError)
            }
            
            if let percentageError = validatePercentage(rawScore.percentage) {
                errorsAtIndex.append(percentageError)
            }
            
            guard !errorsAtIndex.isEmpty else {
                continue
            }
            
            errors.append(ScoreErrorResult(errors: errorsAtIndex, index: UInt(index)))
        }
        
        return errors
    }
    
    func calculeNote(_ rawScores: [RawScore], desiredNote: Float) -> NoteCalculated {
        let scores = getScores(from: rawScores)
        
        guard !scores.isEmpty else {
            return NoteCalculated(note: 0,
                                  acumulatedPercentage: 0,
                                  remainingPercentage: 0)
        }
        
        let note = calculatorService.caculateNotes(with: scores, desiredNote: desiredNote)
        let remainingPercentage = calculatorService.getRemainingPercentage(with: scores, desiredNote: desiredNote)
        let acumulatedPercentage: Float = abs(100 - remainingPercentage)
        
        return NoteCalculated(note: note,
                              acumulatedPercentage: acumulatedPercentage,
                              remainingPercentage: remainingPercentage)
    }
    
    private func getScores(from rawScores: [RawScore]) -> [Score] {
        return rawScores.flatMap { (rawScore) -> Score? in
            guard let note = Float(rawScore.note), let percetage = Float(rawScore.percentage) else {
                return nil
            }
            
            return Score(note: note, percentage: percetage)
        }
    }
    
    private func validateNote(_ note: String?) -> ScoreError? {
        guard let note = note,
            let noteValue = Float(note) else {
            return.invalid(type: .note)
        }
        
        guard noteValue >= ValidationRanges.noteLowLimitValue,
            noteValue <= ValidationRanges.noteUpLimitValue else {
                return .invalidRange(lowLimit: ValidationRanges.noteLowLimitValue,
                                     upLimit: ValidationRanges.noteUpLimitValue,
                                     type: .note)
        }
        
        return nil
    }
    
    private func validatePercentage(_ percentage: String?) -> ScoreError? {
        guard let percentage = percentage,
            let percentageValue = Float(percentage) else {
                return.invalid(type: .percentage)
        }
        
        guard percentageValue >= ValidationRanges.percentageLowLimitValue,
            percentageValue <= ValidationRanges.percentageUpLimitValue else {
                return .invalidRange(lowLimit: ValidationRanges.percentageLowLimitValue,
                                     upLimit: ValidationRanges.percentageUpLimitValue,
                                     type: .percentage)
        }
        
        return nil
    }
    
}
