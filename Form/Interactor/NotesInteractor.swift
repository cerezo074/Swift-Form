//
//  NotesInteractor.swift
//  Form
//
//  Created by Eli Pacheco Hoyos on 10/28/17.
//  Copyright © 2017 Eli Pacheco Hoyos. All rights reserved.
//

import Foundation

class NotesInteractor: NotesInteractorInterface {
    
    private let calculatorService: NotesCalculatorProtocol
    
    init(calculatorService: NotesCalculatorProtocol?) {
        self.calculatorService = calculatorService ?? NoteCalculator()
    }
    
    func notesAreValid(_ rawScores: [RawScore]) -> [ScoreErrorResult] {
        var errors: [ScoreErrorResult] = []
        
        for (index, rawScore) in rawScores.enumerated() {
            var errorsAtIndex: [ScoreError] = []
            let note = Float(rawScore.note)
            let percentage = Float(rawScore.percentage)
            
            if note == nil {
                errorsAtIndex.append(.invalid(type: .note))
            }
            
            if percentage == nil {
                errorsAtIndex.append(.invalid(type: .percentage))
            }
            
            guard let noteValue = note,
                let percentageValue = percentage else {
                continue
            }
            
            if noteValue <= 0 {
                errorsAtIndex.append(.negative)
            }
            
            if percentageValue < 1,
                percentageValue > 100 {
                errorsAtIndex.append(.invalidRange(lowLimit: 1, upLimit: 100))
            }
            
            errors.append(ScoreErrorResult(errors: errorsAtIndex, index: UInt(index)))
        }
        
        return errors
    }
    
    func calculeNote(_ rawScores: [RawScore], desiredNote: Float) -> Float {
        let scores = getScores(from: rawScores)
        
        guard !scores.isEmpty else {
            return 0.0
        }
        
        return calculatorService.caculateNotes(with: scores, desiredNote: desiredNote)
    }
    
    func remainingPercentage(with rawScores: [RawScore], desiredNote: Float) -> Float {
        let scores = getScores(from: rawScores)
        
        guard !scores.isEmpty else {
            return 0.0
        }
        
        return calculatorService.getRemainingPercentage(with: scores, desiredNote: desiredNote)
    }
    
    private func getScores(from rawScores: [RawScore]) -> [Score] {
        return rawScores.flatMap { (rawScore) -> Score? in
            guard let note = Float(rawScore.note), let percetage = Float(rawScore.percentage) else {
                return nil
            }
            
            return Score(note: note, percentage: percetage)
        }
    }
    
}
