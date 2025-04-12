//
//  EditCategoryViewController.swift
//  Ahgmo
//
//  Created by 지현 on 2/12/25.
//

import UIKit
import Combine

class EditCategoryViewController: UIViewController {
    var subscriptions = Set<AnyCancellable>()
    let keyboardWillHide = PassthroughSubject<Void, Never>()
    var viewModel: EditCategoryViewModel!
    
    var collectionView: UICollectionView!
    var dataSource: UICollectionViewDiffableDataSource<EditCategoryViewModel.Section, EditCategoryViewModel.Item>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
        configureNavigationItem()
        configureCollectionView()
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
        
        viewModel.categoryItem
            .receive(on: RunLoop.main)
            .sink { [weak self] data in
                guard let self = self else { return }
                self.applySnapshot(data)
            }.store(in: &subscriptions)
    }
    
    private func configureNavigationItem() {
        self.navigationItem.title = "카테고리 수정"
        self.navigationItem.largeTitleDisplayMode = .never
        
        let doneItem = UIBarButtonItem(
            title: "완료",
            style: .plain,
            target: self,
            action: #selector(navigateToPage(_:))
        )
        
        navigationItem.rightBarButtonItem = doneItem
    }
    
    @objc private func navigateToPage(_ sender: UIBarButtonItem) {
        // 임시
        self.dismiss(animated: true, completion: nil)
    }
    
    private func configureCollectionView() {
        let config = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        let layout = UICollectionViewCompositionalLayout.list(using: config)
        
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(collectionView)
        collectionView.keyboardDismissMode = .onDrag
        collectionView.delegate = self
        
        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, EditCategoryViewModel.Item> { cell, indexPath, item in
            let textField = UITextField()
            textField.placeholder = "카테고리 이름"
            textField.clearButtonMode = .always
            textField.text = self.viewModel.categoryItem.value?.title
            textField.frame = CGRect(x: 0, y: 0, width: cell.bounds.width, height: cell.bounds.height)
            textField.delegate = self
            
            cell.contentView.addSubview(textField)
            
            textField.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                textField.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 20),
                textField.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -10),
                textField.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor)
            ])
        }
        
        dataSource = UICollectionViewDiffableDataSource<EditCategoryViewModel.Section, EditCategoryViewModel.Item>(collectionView: collectionView) { collectionView, indexPath, item in
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: item)
        }
    }
    
    private func applySnapshot(_ items: EditCategoryViewModel.Item) {
        var snapshot = NSDiffableDataSourceSnapshot<EditCategoryViewModel.Section, EditCategoryViewModel.Item>()
        snapshot.appendSections([.main])
        snapshot.appendItems([items], toSection: .main)
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

extension EditCategoryViewController: UICollectionViewDelegate, UITextFieldDelegate, UIGestureRecognizerDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
    }
}
