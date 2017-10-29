//
//  NotesInteractorInterface.swift
//  Form
//
//  Created by Eli Pacheco Hoyos on 10/28/17.
//  Copyright © 2017 Eli Pacheco Hoyos. All rights reserved.
//

import Foundation

protocol NotesInteractorInterface {
    func notesAreValid(_ notes: [Score]) -> Bool
    func calculeNote(_ notes: [Score], desiredNote: Float) -> Float
    func remainingPercentage(with notes: [Score], desiredNote: Float) -> Float
}
