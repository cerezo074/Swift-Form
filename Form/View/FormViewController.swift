//
//  FormViewController.swift
//  Form
//
//  Created by Eli Pacheco Hoyos on 10/22/17.
//  Copyright © 2017 Eli Pacheco Hoyos. All rights reserved.
//

import UIKit

class FormViewController: UIViewController {
    
    @IBOutlet private weak var formCollectionView: UICollectionView!
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
        configureFormCollectionView()
        bindFormViewState()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

private extension FormViewController {
    
    func configureFormCollectionView() {
        for section in 0 ..< presenter.sections {
            presenter.fields(for: section).forEach {
                formCollectionView.register($0.cellType.nib,
                                            forCellWithReuseIdentifier: $0.cellType.cellIdentifier)
            }
        }
        
        if let flowLayout = formCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.estimatedItemSize = CGSize(width: UIScreen.main.bounds.size.width, height: 100)
        }
        
        formCollectionView.dataSource = dataSource
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
        formCollectionView.insertItems(at: [index])
    }
    
    func removeCell(at index: IndexPath) {
        formCollectionView.deleteItems(at: [index])
    }
    
    func showResult(at index: IndexPath) {
        formCollectionView.reloadItems(at: [index])
    }
    
    func showValidationError(at index: IndexPath) {
        formCollectionView.reloadItems(at: [index])
    }
    
}

extension FormViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
    }
    
}
