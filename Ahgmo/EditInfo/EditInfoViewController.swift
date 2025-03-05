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
    
    enum Section: Int, CaseIterable {
        case title
        case description
        case url
        case button
        
        var title: String {
            switch self {
            case .title: return "제목"
            case .description: return "설명"
            case .url: return "URL"
            case .button: return "카테고리"
            }
        }
    }
    typealias Item = InfoData

    var subscriptions = Set<AnyCancellable>()
    let didSelect = PassthroughSubject<CategoryData, Never>()
    let keyboardWillHide = PassthroughSubject<Void, Never>()
    @Published var information: InfoData = InfoData(title: "Unknown", description: "", urlString: "", imageURL: "", category: CategoryData(title: ""))
    var selectedCategory: CategoryData = CategoryData(title: "")
    
    var collectionView: UICollectionView!
    var dataSource: UICollectionViewDiffableDataSource<Section, Item>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bind()
        configureNavigationItem()
        setupCollectionView()
        hideKeyBoardWhenTappedScreen()
    }
    
    private func bind() {
        didSelect
            .receive(on: RunLoop.main)
            .sink { [weak self] selectedcategory in
                self?.presentViewController(selectedcategory)
            }.store(in: &subscriptions)
        
        
        keyboardWillHide
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.view.endEditing(true)
            }
            .store(in: &subscriptions)
        
        $information
            .receive(on: RunLoop.main)
            .sink { [weak self] data in
                self?.applySnapshot(data)
            }.store(in: &subscriptions)

        NotificationCenter.default
            .publisher(for: .didSelectCategory)
            .compactMap { $0.object as? CategoryData }
            .receive(on: RunLoop.main)
            .sink { [weak self] category in
                self?.selectedCategory = category
                self?.information.category = category
            }
            .store(in: &subscriptions)
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
        
        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, Item> { cell, indexPath, item in
            let section = Section(rawValue: indexPath.section)
            if section == .title {
                let textField = UITextField()
                textField.text = self.information.title
                //                textField.placeholder = item.title
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
                textField.text = self.information.description
                //                textField.placeholder = item.title
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
                textField.text = self.information.urlString
                //                textField.placeholder = item.title
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
                content.secondaryText = self.information.category.title
                cell.contentConfiguration = content
                cell.accessories = [.disclosureIndicator()]
            }
        }
        
        dataSource = UICollectionViewDiffableDataSource<Section, Item>(collectionView: collectionView) { collectionView, indexPath, item in
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: item)
        }
        
        collectionView.delegate = self
    }
    
    private func applySnapshot(_ items: InfoData) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        snapshot.appendSections(Section.allCases)
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
        if let section = Section(rawValue: indexPath.section) {
            if section == .button {
                let selectedCategory = information.category
                didSelect.send(selectedCategory)
            }
        }
        collectionView.deselectItem(at: indexPath, animated: true)
    }
}
