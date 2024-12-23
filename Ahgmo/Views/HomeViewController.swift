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
        
        navigationItem.title = "아그모"
        
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

