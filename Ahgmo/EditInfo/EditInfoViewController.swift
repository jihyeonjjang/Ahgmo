//
//  EditInfoViewController.swift
//  Ahgmo
//
//  Created by 지현 on 12/26/24.
//

import UIKit
import Combine

class EditInfoViewController: UIViewController {
    //    private let ogpFetcher = OGPFetcher()
    var subscriptions = Set<AnyCancellable>()
    let keyboardWillHide = PassthroughSubject<Void, Never>()
    var viewModel: EditInfoViewModel!
    var selectedCategory: CategoryData = CategoryData(title: "")
    
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
                self?.view.endEditing(true)
            }
            .store(in: &subscriptions)
        
        viewModel.infoItems
            .receive(on: RunLoop.main)
            .sink { [weak self] data in
                self?.applySnapshot(data)
            }.store(in: &subscriptions)
        
        viewModel.selectedItem
            .compactMap { $0 }
            .receive(on: RunLoop.main)
            .sink { [weak self] selectedcategory in
                self?.presentViewController(selectedcategory)
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
            if section == .title {
                let textField = UITextField()
                textField.text = self.viewModel.infoItems.value.title
                textField.placeholder = "제목"
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
            } else if section == .description {
                let textField = UITextField()
                textField.text = self.viewModel.infoItems.value.description
                textField.placeholder = "설명"
                textField.clearButtonMode = .whileEditing
                textField.frame = CGRect(x: 20, y: 0, width: cell.bounds.width, height: cell.bounds.height)
                cell.contentView.addSubview(textField)
                
                textField.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    textField.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 20),
                    textField.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -10),
                    textField.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor)
                ])
            } else if section == .url {
                let textField = UITextField()
                textField.text = self.viewModel.infoItems.value.urlString
                textField.placeholder = "URL"
                textField.clearButtonMode = .whileEditing
                textField.frame = CGRect(x: 20, y: 0, width: cell.bounds.width, height: cell.bounds.height)
                cell.contentView.addSubview(textField)
                
                textField.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    textField.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 20),
                    textField.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -10),
                    textField.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor)
                ])
            } else {
                var content = UIListContentConfiguration.valueCell()
                content.text = "카테고리"
                content.secondaryText = self.viewModel.infoItems.value.category.title
                cell.contentConfiguration = content
                cell.accessories = [.disclosureIndicator()]
            }
        }
        
        dataSource = UICollectionViewDiffableDataSource<EditInfoViewModel.Section, EditInfoViewModel.Item>(collectionView: collectionView) { collectionView, indexPath, item in
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: item)
        }
        
        collectionView.delegate = self
    }
    
    private func applySnapshot(_ items: InfoData) {
        var snapshot = NSDiffableDataSourceSnapshot<EditInfoViewModel.Section, EditInfoViewModel.Item>()
        snapshot.appendSections(EditInfoViewModel.Section.allCases)
        snapshot.appendItems([InfoData(title: items.title, description: "", urlString: "", imageURL: "", category: CategoryData(title: ""))], toSection: .title)
        snapshot.appendItems([InfoData(title: "", description: items.description, urlString: "", imageURL: "", category: CategoryData(title: ""))], toSection: .description)
        snapshot.appendItems([InfoData(title: "", description: "", urlString: items.urlString, imageURL: "", category: CategoryData(title: ""))], toSection: .url)
        snapshot.appendItems([InfoData(title: "", description: "", urlString: "", imageURL: "", category: CategoryData(title: items.category.title))], toSection: .button)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    private func presentViewController(_ selectedCategory: CategoryData) {
        let storyboard = UIStoryboard(name: "SelectCategory", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "SelectCategoryViewController") as! SelectCategoryViewController
        vc.viewSource = .editInfo(selectedCategory: selectedCategory)
        vc.completion = { [weak self] category in
            self?.selectedCategory = category
            self?.viewModel.infoItems.value.category = category
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
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return EditInfoViewModel.Section(rawValue: indexPath.section) == .button
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.didSelect()
        collectionView.deselectItem(at: indexPath, animated: true)
    }
}
