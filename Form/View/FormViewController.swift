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
        for section in 0 ..< presenter.sections {
            presenter.fields(for: section).forEach {
                formTableView.register($0.cellType.nib,
                                       forCellReuseIdentifier: $0.cellType.cellIdentifier)
            }
        }
        
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
            case .addedInput(let indexPath):
                self.addCell(at: indexPath)
            case .deletedInput(let indexPath):
                self.removeCell(at: indexPath)
            case .showResult(let indexPath):
                self.showResult(at: indexPath)
            case .showValidationError(let indexPath):
                self.showValidationError(at: indexPath)
            default:
                return
            }
        }
    }
    
    func addCell(at index: IndexPath) {
        formTableView.insertRows(at: [index], with: .automatic)
    }
    
    func removeCell(at index: IndexPath) {
        formTableView.deleteRows(at: [index], with: .automatic)
    }
    
    func showResult(at index: IndexPath) {
        formTableView.reloadRows(at: [index], with: .automatic)
    }
    
    func showValidationError(at index: IndexPath) {
        formTableView.reloadRows(at: [index], with: .automatic)
    }
    
}

extension FormViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}
