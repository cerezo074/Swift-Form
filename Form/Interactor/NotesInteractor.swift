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
        self.calculatorService = calculatorService ?? NotesCalculator()
    }
    
    func notesAreValid(_ notes: [Score]) -> Bool {
        for note in notes {
            guard note.note > 0 else {
                return false
            }
            
            guard note.percentage > 0,
            note.percentage < 100 else {
                return false
            }
        }
        
        return true
    }
    
    func calculeNote(_ notes: [Score], desiredNote: Float) -> Float {
        return calculatorService.caculateNotes(with: notes, diseredNote: desiredNote)
    }
    
}

class NotesCalculator: NotesCalculatorProtocol {
    
    func caculateNotes(with notes: [Score], diseredNote: Float) -> Float {
        return 0.0
    }
    
}
