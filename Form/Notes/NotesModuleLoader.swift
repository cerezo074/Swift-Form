//
//  NotesModuleLoader.swift
//  Form
//
//  Created by Eli Pacheco Hoyos on 10/22/17.
//  Copyright © 2017 Eli Pacheco Hoyos. All rights reserved.
//

import Foundation
import UIKit

struct NotesModuleLoader {
    
    var view: UIViewController {
        let calculatorServices = NoteCalculator()
        let interactor = NotesInteractor(calculatorService: calculatorServices)
        let presenter = FormPresenter(interactor: interactor)
        let dataSource = FormDataSource(presenter: presenter)
        let view = FormViewController(presenter: presenter, dataSource: dataSource)
        
        return view
    }
    
}
