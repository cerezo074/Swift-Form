//
//  NoteCalculator.swift
//  Form
//
//  Created by Eli Pacheco Hoyos on 10/28/17.
//  Copyright © 2017 Eli Pacheco Hoyos. All rights reserved.
//

import Foundation

typealias Score = (note: Float, percentage: Float)

protocol NotesCalculatorProtocol {
    func caculateNotes(with notes: [Score], desiredNote: Float) -> Float
    func getRemainingPercentage(with notes: [Score], desiredNote: Float) -> Float
}

class NoteCalculator: NotesCalculatorProtocol {
    
    func caculateNotes(with notes: [Score], desiredNote: Float) -> Float {
        let acumulatedNotes = notes.reduce(0.0) { $0 + ($1.note * ($1.percentage / 100.0)) }
        let remainingPercentage = getRemainingPercentage(with: notes, desiredNote: desiredNote)
        
        return acumulatedNotes > desiredNote ? 0 :
            (desiredNote - acumulatedNotes) / (remainingPercentage / 100.0)
    }
    
    func getRemainingPercentage(with notes: [Score], desiredNote: Float) -> Float {
        let acumulatedPercentages = notes.reduce(0.0) { $0 + ($1.percentage) }
        let remainingPercentage = 100 - acumulatedPercentages
        
        return remainingPercentage
    }
    
}
