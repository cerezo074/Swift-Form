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
    
    func notesAreValid(_ notes: [Score]) -> ScoreError? {
        for note in notes {
            guard note.note > 0 else {
                return ScoreError.negative
            }
            
            guard note.percentage > 0,
            note.percentage < 100 else {
                return ScoreError.invalidRange(lowLimit: 1, upLimit: 100)
            }
        }
        
        return true
    }
    
    func calculeNote(_ notes: [Score], desiredNote: Float) -> Float {
        return calculatorService.caculateNotes(with: notes, desiredNote: desiredNote)
    }
    
    func remainingPercentage(with notes: [Score], desiredNote: Float) -> Float {
        return calculatorService.getRemainingPercentage(with: notes, desiredNote: desiredNote)
    }

    
}
