//
//  NotesInteractorInterface.swift
//  Form
//
//  Created by Eli Pacheco Hoyos on 10/28/17.
//  Copyright © 2017 Eli Pacheco Hoyos. All rights reserved.
//

import Foundation

typealias RawScore = (note: String, percentage: String)
typealias ScoreErrorResult = (errors: [ScoreError], index: UInt)

enum InvalidNumber {
    case note
    case percentage
}

enum ScoreError: LocalizedError {
    case invalid(type: InvalidNumber)
    case negative
    case invalidRange(lowLimit: Int, upLimit: Int)
    
    var localizedDescription: String {
        switch self {
        case .invalid(let type):
            return type == .note ? "Nota invalida" : "Porcentaje invalido"
        case .negative:
            return "Numeros negativos no son permitidos"
        case .invalidRange(let lowLimit, let upLimit):
            return "Rango invalido, debe estar comprendido entre \(lowLimit) - \(upLimit)"
        }
    }
}

protocol NotesInteractorInterface {
    func notesAreValid(_ rawScores: [RawScore]) -> [ScoreErrorResult]
    func calculeNote(_ rawScores: [RawScore], desiredNote: Float) -> Float
    func remainingPercentage(with rawScores: [RawScore], desiredNote: Float) -> Float
}
