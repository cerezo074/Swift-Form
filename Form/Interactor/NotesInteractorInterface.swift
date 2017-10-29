//
//  NotesInteractorInterface.swift
//  Form
//
//  Created by Eli Pacheco Hoyos on 10/28/17.
//  Copyright © 2017 Eli Pacheco Hoyos. All rights reserved.
//

import Foundation

enum ScoreError: LocalizedError {
    case negative
    case invalidRange(lowLimit: Int, upLimit: Int)
    
    var localizedDescription: String {
        switch self {
        case .negative:
            return "Numeros negativos no son permitidos"
        case .invalidRange(let lowLimit, let upLimit):
            return "Numero Invalido, debe estar comprendido entre \(lowLimit) - \(upLimit)"
        }
    }
}

protocol NotesInteractorInterface {
    func notesAreValid(_ notes: [Score]) -> ScoreError?
    func calculeNote(_ notes: [Score], desiredNote: Float) -> Float
    func remainingPercentage(with notes: [Score], desiredNote: Float) -> Float
}
