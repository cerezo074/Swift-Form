//
//  NotesInteractorInterface.swift
//  Form
//
//  Created by Eli Pacheco Hoyos on 10/28/17.
//  Copyright © 2017 Eli Pacheco Hoyos. All rights reserved.
//

import Foundation

typealias Score = (note: Float, percentage: Float)

protocol NotesCalculatorProtocol {
    func caculateNotes(with notes: [Score], diseredNote: Float) -> Float
}

protocol NotesInteractorInterface {
    func notesAreValid(_ notes: [Score]) -> Bool
    func calculeNote(_ notes: [Score], desiredNote: Float) -> Float
}
