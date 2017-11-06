//
//  FormViewController.swift
//  Form
//
//  Created by Eli Pacheco Hoyos on 10/22/17.
//  Copyright © 2017 Eli Pacheco Hoyos. All rights reserved.
//

import UIKit

class FormViewController: UIViewController {
    
    @IBOutlet private weak var formTableView: UITableView!
    private var presenter: FormPresenterInterface
    private var dataSource: FormDataSource
    
    init(presenter: FormPresenterInterface, dataSource: FormDataSource) {
        self.presenter = presenter
        self.dataSource = dataSource
        super.init(nibName: String(describing: FormViewController.self), bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Calculadora"
        configureFormCollectionView()
        bindFormViewState()
        configureCleanAction()
    }

}

private extension FormViewController {
    
    func configureCleanAction() {
        let cleanButton = UIBarButtonItem(title: presenter.cleanText,
                                          style: .plain,
                                          target: self,
                                          action: #selector(cleanAction))
        
        navigationItem.rightBarButtonItem = cleanButton
    }
    
    @objc func cleanAction() {
        presenter.cleanNotes()
    }
    
    func configureFormCollectionView() {
        dataSource.registerCells(on: formTableView, for: presenter.sectionTypes)
        formTableView.tableFooterView = UIView(frame: .zero)
        formTableView.rowHeight = UITableViewAutomaticDimension
        formTableView.estimatedRowHeight = 100
        formTableView.dataSource = dataSource
        formTableView.delegate = self
    }
    
    func bindFormViewState() {
        presenter.formViewStateAction = { [weak self] state in
            guard let `self` = self else {
                return
            }
            
            switch state {
            case .addedInputs(let indexPaths):
                self.addCells(at: indexPaths)
            case .deletedInputs(let indexPaths):
                self.removeCells(at: indexPaths)
            case .showValidationErrors(let indexPaths):
                self.showValidationErrors(at: indexPaths)
            case .showMessageToUser(let title, let message):
                self.showMessageToUser(title: title, message: message)
            case .showResults(let indexPaths, let errorIndexes):
                self.updateResults(at: indexPaths, errors: errorIndexes)
            case .deleteResults(let indexPaths, let errorIndexes):
                self.updateResults(at: indexPaths, errors: errorIndexes)
            case .cleanInputs(let indexPaths, let resultIndexes):
                self.reloadInputs(at: indexPaths, results: resultIndexes)
            default:
                return
            }
        }
    }
    
    func addCells(at indexes: [IndexPath]) {
        formTableView.insertRows(at: indexes, with: .automatic)
    }
    
    func removeCells(at indexes: [IndexPath]) {
        formTableView.deleteRows(at: indexes, with: .automatic)
    }
    
    func showValidationErrors(at indexes: [IndexPath]) {
        formTableView.reloadRows(at: indexes, with: .automatic)
    }
    
    func showMessageToUser(title: String, message: String) {
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func updateResults(at indexes: [IndexPath], errors: [IndexPath]) {
        formTableView.performBatchUpdates({ [weak self] in
            guard let section = indexes.first?.section else { return}
            let sectionIndexSet = IndexSet(integer: section)
            self?.formTableView.reloadSections(sectionIndexSet, with: .automatic)
        }) { [weak self] (completed) in
            guard !errors.isEmpty else { return }
            self?.showValidationErrors(at: errors)
        }
    }
    
    func reloadInputs(at indexes: [IndexPath], results: [IndexPath]) {
        formTableView.performBatchUpdates({ [weak self] in
            guard let section = results.first?.section else { return}
            let sectionIndexSet = IndexSet(integer: section)
            self?.formTableView.reloadSections(sectionIndexSet, with: .automatic)
        }) { [weak self] (completed) in
            self?.formTableView.reloadRows(at: indexes, with: .automatic)
        }
    }
    
}

extension FormViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}
