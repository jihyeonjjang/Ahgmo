//
//  EditCategoryViewController.swift
//  Ahgmo
//
//  Created by 지현 on 2/12/25.
//

import UIKit

class EditCategoryViewController: UIViewController {
    enum Section {
        case main
    }
    
    typealias Item = CategoryData
    
    var collectionView: UICollectionView!
    var dataSource: UICollectionViewDiffableDataSource<Section, Item>!
    
    var category: CategoryData = CategoryData(title: "Unknown")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationItem()
        hideKeyBoardWhenTappedScreen()
        
        let config = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        let layout = UICollectionViewCompositionalLayout.list(using: config)
        
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(collectionView)
        collectionView.keyboardDismissMode = .onDrag
        collectionView.delegate = self
        
        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, Item> { cell, indexPath, item in
            let textField = UITextField()
            textField.placeholder = "카테고리 이름"
            textField.clearButtonMode = .always
            textField.text = self.category.title
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
        
        dataSource = UICollectionViewDiffableDataSource<Section, Item>(collectionView: collectionView) { collectionView, indexPath, item in
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: item)
        }
        
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        snapshot.appendSections([.main])
        snapshot.appendItems([CategoryData(title: category.title)], toSection: .main)
        dataSource.apply(snapshot, animatingDifferences: false)
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

}

extension EditCategoryViewController: UICollectionViewDelegate, UITextFieldDelegate, UIGestureRecognizerDelegate {
    func hideKeyBoardWhenTappedScreen() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapHandler))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }

    @objc func tapHandler() {
        print("터치")
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        print("return!")
        self.view.endEditing(true)
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
    }
}
