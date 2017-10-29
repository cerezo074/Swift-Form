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
    case invalidRange(lowLimit: Float, upLimit: Float , type: InvalidNumber)
    
    var localizedDescription: String {
        switch self {
        case .invalid(let type):
            return type == .note ? "Nota invalida" : "Porcentaje invalido"
        case .invalidRange(let lowLimit, let upLimit, let type):
            let typeText = type == .note ? "en nota" : "en porcentaje"
            return "Rango invalido \(typeText), debe estar comprendido entre \(lowLimit) - \(upLimit)"
        }
    }
}

protocol NotesInteractorInterface {
    func desiredNoteIsValid(_ note: String) -> ScoreError?
    func notesAreValid(_ rawScores: [RawScore]) -> [ScoreErrorResult]
    func calculeNote(_ rawScores: [RawScore], desiredNote: Float) -> Float
    func remainingPercentage(with rawScores: [RawScore], desiredNote: Float) -> Float
}
