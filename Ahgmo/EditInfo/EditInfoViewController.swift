//
//  EditInfoViewController.swift
//  Ahgmo
//
//  Created by 지현 on 12/26/24.
//

import UIKit
import Combine
import CoreData

class EditInfoViewController: UIViewController {
    //    private let ogpFetcher = OGPFetcher()
    var subscriptions = Set<AnyCancellable>()
    let keyboardWillHide = PassthroughSubject<Void, Never>()
    var viewModel: EditInfoViewModel!
    var isInitialState = true
    
    var collectionView: UICollectionView!
    var dataSource: UICollectionViewDiffableDataSource<EditInfoViewModel.Section, EditInfoViewModel.Item>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
        configureNavigationItem()
        setupCollectionView()
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
        
        viewModel.infoItem
            .receive(on: RunLoop.main)
            .sink { [weak self] data in
                guard let self = self else { return }
                if self.isInitialState {
                    self.isInitialState = false
                    self.applySnapshot(data)
                } else {
                    self.changeCategorySnapshot(data)
                }
            }.store(in: &subscriptions)
        
        viewModel.selectedItem
            .compactMap { $0 }
            .receive(on: RunLoop.main)
            .sink { [weak self] selectedcategory in
                guard let self = self else { return }
                self.presentViewController(selectedcategory)
            }.store(in: &subscriptions)
    }
    
    private func configureNavigationItem() {
        self.navigationItem.title = "정보 편집"
        
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
        cancelItem.tag = 1
        
        navigationItem.leftBarButtonItem = cancelItem
        navigationItem.rightBarButtonItem = doneItem
    }
    
    @objc private func navigateToPage(_ sender: UIBarButtonItem) {
        switch sender.tag {
        case 0:
            self.dismiss(animated: true, completion: nil)
        case 1:
            // 완료
            self.dismiss(animated: true, completion: nil)
        default:
            return
        }
    }
    
    private func setupCollectionView() {
        let config = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        let layout = UICollectionViewCompositionalLayout.list(using: config)
        
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(collectionView)
        collectionView.keyboardDismissMode = .onDrag
        
        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, EditInfoViewModel.Item> { cell, indexPath, item in
            let section = EditInfoViewModel.Section(rawValue: indexPath.section)
            if section == .textField {
                let textField = UITextField()
                textField.text = item.contentText
                textField.placeholder = item.placeholder
                textField.clearButtonMode = .whileEditing
                textField.frame = CGRect(x: 20, y: 0, width: cell.bounds.width, height: cell.bounds.height)
                textField.delegate = self
                
                cell.contentView.addSubview(textField)
                
                textField.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    textField.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 20),
                    textField.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -10),
                    textField.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor)
                ])
            }  else {
                var content = UIListContentConfiguration.valueCell()
                content.text = item.placeholder
                content.secondaryText = item.contentText
                cell.contentConfiguration = content
                cell.accessories = [.disclosureIndicator()]
            }
        }
        
        dataSource = UICollectionViewDiffableDataSource<EditInfoViewModel.Section, EditInfoViewModel.Item>(collectionView: collectionView) { collectionView, indexPath, item in
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: item)
        }
        
        collectionView.delegate = self
    }
    
    private func applySnapshot(_ items: Information) {
        var snapshot = NSDiffableDataSourceSnapshot<EditInfoViewModel.Section, EditInfoViewModel.Item>()
        snapshot.appendSections(EditInfoViewModel.Section.allCases)
        
        let textItems = [
            EditInfoViewModel.Item(contentText: items.title ?? "error", placeholder: "제목"),
            EditInfoViewModel.Item(contentText: items.details ?? "error", placeholder: "설명"),
            EditInfoViewModel.Item(contentText: items.urlString ?? "error", placeholder: "URL")
        ]
        
        let buttonItem = EditInfoViewModel.Item(contentText: items.categoryItem?.title ?? "error", placeholder: "카테고리")
        
        snapshot.appendItems(textItems, toSection: .textField)
        snapshot.appendItems([buttonItem], toSection: .button)
        
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    private func changeCategorySnapshot(_ item: Information) {
        var snapshot = dataSource.snapshot()
        let existingItems = snapshot.itemIdentifiers(inSection: .button)
        snapshot.deleteItems(existingItems)
        let buttonItem = EditInfoViewModel.Item(contentText: item.categoryItem?.title ?? "error", placeholder: "카테고리")
        snapshot.appendItems([buttonItem], toSection: .button)
        dataSource.apply(snapshot, animatingDifferences: false)
    }
    
    private func presentViewController(_ selectedCategory: Category) {
        let storyboard = UIStoryboard(name: "SelectCategory", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "SelectCategoryViewController") as! SelectCategoryViewController
        vc.viewModel = SelectCategoryViewModel(initialCategory: selectedCategory)
        vc.completion = { [weak self] category in
            guard let self = self else { return }
            let updatedInfo = self.viewModel.infoItem.value
            updatedInfo.categoryItem = category
            self.viewModel.infoItem.value = updatedInfo
        }
        let navigationController = UINavigationController(rootViewController: vc)
        
        self.navigationController?.present(navigationController, animated: true)
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

extension EditInfoViewController: UICollectionViewDelegate, UITextFieldDelegate, UIGestureRecognizerDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.didSelect()
        collectionView.deselectItem(at: indexPath, animated: true)
    }
}
