//
//  EditInfoViewController.swift
//  Ahgmo
//
//  Created by 지현 on 12/26/24.
//

import UIKit

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
    
    var collectionView: UICollectionView!
    var dataSource: UICollectionViewDiffableDataSource<Section, Item>!
    
    var information: InfoData = InfoData(title: "Unknown", description: "", urlString: "", imageURL: "", category: CategoryData(title: ""))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationItem()
        setupCollectionView()
        applySnapshot()
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
        let layoutConfig = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        let layout = UICollectionViewCompositionalLayout.list(using: layoutConfig)
        
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(collectionView)
        
        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, Item> { cell, indexPath, item in
            let section = Section(rawValue: indexPath.section)
            if section == .title {
                let textField = UITextField()
                textField.text = self.information.title
                //                textField.placeholder = item.title
                textField.clearButtonMode = .whileEditing
                textField.frame = CGRect(x: 20, y: 0, width: cell.bounds.width, height: cell.bounds.height)
                cell.contentView.addSubview(textField)
            } else if section == .description {
                let textField = UITextField()
                textField.text = self.information.description
                //                textField.placeholder = item.title
                textField.clearButtonMode = .whileEditing
                textField.frame = CGRect(x: 20, y: 0, width: cell.bounds.width, height: cell.bounds.height)
                cell.contentView.addSubview(textField)
            } else if section == .url {
                let textField = UITextField()
                textField.text = self.information.urlString
                //                textField.placeholder = item.title
                textField.clearButtonMode = .whileEditing
                textField.frame = CGRect(x: 20, y: 0, width: cell.bounds.width, height: cell.bounds.height)
                cell.contentView.addSubview(textField)
            } else {
                var content = cell.defaultContentConfiguration()
                content.text = "카테고리"
                content.secondaryText = self.information.category.title // 왜 오른쪽으로 안들어가고 아래로 들어가지?
                cell.contentConfiguration = content
                cell.accessories = [.disclosureIndicator()]
            }
        }
        
        dataSource = UICollectionViewDiffableDataSource<Section, Item>(collectionView: collectionView) { collectionView, indexPath, item in
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: item)
        }
        
        collectionView.delegate = self
    }
    
    private func applySnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        snapshot.appendSections(Section.allCases)
        snapshot.appendItems([InfoData(title: information.title, description: "", urlString: "", imageURL: "", category: CategoryData(title: ""))], toSection: .title)
        snapshot.appendItems([InfoData(title: "", description: information.description, urlString: "", imageURL: "", category: CategoryData(title: ""))], toSection: .description)
        snapshot.appendItems([InfoData(title: "", description: "", urlString: information.urlString, imageURL: "", category: CategoryData(title: ""))], toSection: .url)
        snapshot.appendItems([InfoData(title: "", description: "", urlString: "", imageURL: "", category: CategoryData(title: information.category.title))], toSection: .button)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
}

extension EditInfoViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let section = Section(rawValue: indexPath.section)
        if section == .button {
            let storyboard = UIStoryboard(name: "SelectCategory", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "SelectCategoryViewController") as! SelectCategoryViewController
            let navigationController = UINavigationController(rootViewController: vc)
            
            self.navigationController?.present(navigationController, animated: true)
            collectionView.deselectItem(at: indexPath, animated: true)
        }
    }
}
