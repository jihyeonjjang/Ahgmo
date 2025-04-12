//
//  AddCategoryViewController.swift
//  Ahgmo
//
//  Created by 지현 on 12/26/24.
//

import UIKit
import Combine

class AddCategoryViewController: UIViewController {
    var originView: String?
    var subscriptions = Set<AnyCancellable>()
    let keyboardWillHide = PassthroughSubject<Void, Never>()
    var viewModel: AddCategoryViewModel!
    
    var collectionView: UICollectionView!
    var dataSource: UICollectionViewDiffableDataSource<AddCategoryViewModel.Section, AddCategoryViewModel.Item>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = AddCategoryViewModel()
        bind()
        configureNavigationItem()
        configureColelctionView()
        hideKeyBoardWhenTappedScreen()
    }
    
    private func bind() {
        keyboardWillHide
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.view.endEditing(true)
            }
            .store(in: &subscriptions)
    }
    
    private func configureNavigationItem() {
        self.navigationItem.title = "새로운 카테고리"
        self.navigationItem.largeTitleDisplayMode = .never
        
        let cancelItem = UIBarButtonItem(
            title: "취소",
            style: .plain,
            target: self,
            action: #selector(navigateToPage(_:))
        )
        cancelItem.tag = 0
        
        let doneItem = UIBarButtonItem(
            title: "완료",
            style: .plain,
            target: self,
            action: #selector(navigateToPage(_:))
        )
        doneItem.tag = 1
        
        if originView == "Category" {
            navigationItem.leftBarButtonItem = cancelItem
        }
        navigationItem.rightBarButtonItem = doneItem
    }
    
    @objc private func navigateToPage(_ sender: UIBarButtonItem) {
        switch sender.tag {
        case 0:
            self.dismiss(animated: true, completion: nil)
        case 1:
            viewModel.saveCategory()
            self.dismiss(animated: true, completion: nil)
        default:
            return
        }
    }
    
    private func configureColelctionView() {
        let config = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        let layout = UICollectionViewCompositionalLayout.list(using: config)
        
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(collectionView)
        collectionView.keyboardDismissMode = .interactive
        collectionView.delegate = self
        
        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, AddCategoryViewModel.Item> { cell, indexPath, item in
            let textField = UITextField()
            textField.placeholder = item
            textField.clearButtonMode = .whileEditing
            textField.frame = CGRect(x: 0, y: 0, width: cell.bounds.width, height: cell.bounds.height)
            textField.delegate = self
            
            cell.contentView.addSubview(textField)
            
            textField.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                textField.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 20),
                textField.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -10),
                textField.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor),
            ])
        }
        
        dataSource = UICollectionViewDiffableDataSource<AddCategoryViewModel.Section, AddCategoryViewModel.Item>(collectionView: collectionView) { collectionView, indexPath, item in
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: item)
        }
        
        var snapshot = NSDiffableDataSourceSnapshot<AddCategoryViewModel.Section, AddCategoryViewModel.Item>()
        snapshot.appendSections([.main])
        snapshot.appendItems(["카테고리 이름"])
        dataSource.apply(snapshot, animatingDifferences: false)
    }
    
    private func hideKeyBoardWhenTappedScreen() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapHandler))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc func tapHandler() {
        keyboardWillHide.send()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        keyboardWillHide.send()
        return true
    }
}

extension AddCategoryViewController: UICollectionViewDelegate, UITextFieldDelegate, UIGestureRecognizerDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        viewModel.userInput.send(textField.text ?? "")
    }
}
