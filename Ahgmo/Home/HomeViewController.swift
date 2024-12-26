//
//  HomeViewController.swift
//  Ahgmo
//
//  Created by 지현 on 12/23/24.
//

import UIKit

class HomeViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    enum Item: Hashable {
        case categoryData(CategoryData)
        case infoData(InfoData)
    }
    enum Section: Int {
        case category
        case main
    }
    
    var categorySectionItems = CategoryData.list.map { Item.categoryData($0) }
    var mainSectionItems = InfoData.list.map { Item.infoData($0) }
    
//    struct MySendableStruct: Sendable, Hashable {
//        let infoData: InfoData
//        let categoryData: CategoryData
//    }
//
//    typealias Item = MySendableStruct
    
    var dataSource: UICollectionViewDiffableDataSource<Section, Item>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateNavigationItem()
        embedSearchControl()
        
        dataSource = UICollectionViewDiffableDataSource<Section, Item>(collectionView: collectionView) { collectionView, indexPath, item in
            guard let section = Section(rawValue: indexPath.section) else { return nil }
            let cell = self.configureCell(for: section, item: item, collectionView: collectionView, indexPath: indexPath)
            return cell
        }
        
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        snapshot.appendSections([.category, .main])
        snapshot.appendItems(categorySectionItems, toSection: .category)
        snapshot.appendItems(mainSectionItems, toSection: .main)
        dataSource.apply(snapshot)
        
        collectionView.collectionViewLayout = layout()
    }
    
    private func updateNavigationItem() {
        let checekConfig = CustomBarItemConfiguration(
            image: UIImage(systemName: "checkmark.circle"),
            handler: { }
        )
        let checekItem = UIBarButtonItem.generate(with: checekConfig, width: 30)
        
        let folderConfig = CustomBarItemConfiguration(
            image: UIImage(systemName: "folder"),
            handler: { }
        )
        let folderItem = UIBarButtonItem.generate(with: folderConfig, width: 30)
        
        let settingConfig = CustomBarItemConfiguration(
            image: UIImage(systemName: "gearshape"),
            handler: { }
        )
        let settingItem = UIBarButtonItem.generate(with: settingConfig, width: 30)
        
        navigationItem.leftBarButtonItem = checekItem
        navigationItem.rightBarButtonItems = [settingItem, folderItem]
    }
    
    private func embedSearchControl() {
        self.navigationItem.title = "아그모"
        
        let searchController = UISearchController(searchResultsController: nil)
//        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.placeholder = "Search"
        searchController.searchBar.delegate = self
        self.navigationItem.searchController = searchController
    }
    
    private func configureCell(for section: Section, item: Item, collectionView: UICollectionView, indexPath: IndexPath) -> UICollectionViewCell? {
        switch section {
        case .category:
            if case .categoryData(let category) = item {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeCategoryCell", for: indexPath) as! HomeCategoryCell
                cell.configure(item: category)
                return cell
            } else { return nil }
        case .main:
            if case .infoData(let info) = item {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeListCell", for: indexPath) as! HomeListCell
                cell.configure(item: info)
                return cell
            } else { return nil }
        }
    }
    
    private func layout() -> UICollectionViewCompositionalLayout {
        let layout = UICollectionViewCompositionalLayout{ sectionIndex, layoutEnvironment in
            switch sectionIndex {
            case 0:
                return self.createCategorySection()
            case 1:
                return self.createInfoSection()
            default:
                return self.createInfoSection()
            }
        }
        return layout
    }
    
    private func createCategorySection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .estimated(50), heightDimension: .absolute(30))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(widthDimension: .estimated(50), heightDimension: .absolute(30))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
//        group.interItemSpacing = NSCollectionLayoutSpacing.fixed(7)
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 15, bottom: 0, trailing: 15)
        section.interGroupSpacing = 10
        section.orthogonalScrollingBehavior = .continuousGroupLeadingBoundary
        
        return section
    }
    
    private func createInfoSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(80))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(80))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
//        section.orthogonalScrollingBehavior = .continuousGroupLeadingBoundary

        return section
    }
}

extension HomeViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let keyword = searchBar.text, !keyword.isEmpty else { return }
        
    }
}
