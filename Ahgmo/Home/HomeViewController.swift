//
//  HomeViewController.swift
//  Ahgmo
//
//  Created by 지현 on 12/23/24.
//

import UIKit

class HomeViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var tableView: UITableView!

    typealias CollectionItem = CategoryData
    typealias TableItem = InfoData
    
    enum Section: Int {
        case main
    }
    var categoryItems: [CategoryData] = CategoryData.list
    var infoItems: [InfoData] = InfoData.list
    
    var numberOfInfoList = 3
    
    var collectionViewDataSource: UICollectionViewDiffableDataSource<Section, CollectionItem>!
    var tableViewDataSource: UITableViewDiffableDataSource<Section, TableItem>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationItem()
        embedSearchControl()
        
        collectionViewDataSource = UICollectionViewDiffableDataSource<Section, CollectionItem>(collectionView: collectionView) { collectionView, indexPath, item in
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeCategoryCell", for: indexPath) as? HomeCategoryCell else { return nil }
            cell.configure(item: item)
            return cell
        }
        
        tableViewDataSource = UITableViewDiffableDataSource<Section, TableItem>(tableView: tableView) { tableView, indexPath, item in
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "HomeListCell", for: indexPath) as? HomeListCell else { return UITableViewCell() }
            cell.configure(item: item)
            return cell
        }
        
        var collectionViewSnapshot = NSDiffableDataSourceSnapshot<Section, CollectionItem>()
        collectionViewSnapshot.appendSections([.main])
        collectionViewSnapshot.appendItems(categoryItems, toSection: .main)
        collectionViewDataSource.apply(collectionViewSnapshot)
        
        var tableViewSnapshot = NSDiffableDataSourceSnapshot<Section, TableItem>()
        tableViewSnapshot.appendSections([.main])
        tableViewSnapshot.appendItems(infoItems, toSection: .main)
        tableViewDataSource.apply(tableViewSnapshot)
        
        collectionView.collectionViewLayout = layout()
    }
    
    private func labelBarButtonItem(text: String) -> UIBarButtonItem {
        let label = UILabel()
        label.text = "\(text)"
        return UIBarButtonItem(customView: label)
    }
    
    private func configureNavigationItem() {
        self.navigationItem.title = "아그모"
    
        let selectItem = UIBarButtonItem(image: UIImage(systemName: "checklist"), style: .plain, target: self, action: #selector(toggleEditing))
        let doneItem = UIBarButtonItem(title: "완료", style: .plain, target: self, action: #selector(toggleEditing))
        let settingItem = UIBarButtonItem(image: UIImage(systemName: "gearshape"), style: .plain, target: self, action: nil)
        
        navigationItem.leftBarButtonItem = tableView.isEditing ? doneItem : selectItem
        navigationItem.rightBarButtonItem = settingItem
        
        self.navigationController?.isToolbarHidden = false
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        
        let categoryButton = UIBarButtonItem(image: UIImage(systemName: "folder"), style: .plain, target: self, action: nil)
        let numberInfoLabel = labelBarButtonItem(text: "\(numberOfInfoList)개의 항목")
        let plusButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: nil)
        let defaultToolBarItems = [categoryButton, flexibleSpace, numberInfoLabel, flexibleSpace, plusButton]
        
        let numberSelectLabel = labelBarButtonItem(text: "0개 선택")
        let deleteButton = UIBarButtonItem(title: "삭제", style: .plain, target: self, action: nil)
        let editToolBarItems = [flexibleSpace, numberSelectLabel, flexibleSpace, deleteButton]
        
        let items: [UIBarButtonItem] = tableView.isEditing ? editToolBarItems : defaultToolBarItems
        
        self.toolbarItems = items
    }
    
    @objc private func toggleEditing() {
        tableView.setEditing(!tableView.isEditing, animated: true)
        configureNavigationItem()
    }
    
    private func embedSearchControl() {
        let searchController = UISearchController(searchResultsController: nil)
//        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.placeholder = "Search"
        searchController.searchBar.delegate = self
        self.navigationItem.searchController = searchController
    }
    
    private func layout() -> UICollectionViewCompositionalLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .estimated(100), heightDimension: .absolute(40))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(widthDimension: .estimated(100), heightDimension: .absolute(40))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
//        group.interItemSpacing = NSCollectionLayoutSpacing.fixed(7)
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 15, bottom: 0, trailing: 15)
        section.interGroupSpacing = 10
        section.orthogonalScrollingBehavior = .continuousGroupLeadingBoundary

        return UICollectionViewCompositionalLayout(section: section)
    }
}

extension HomeViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let keyword = searchBar.text, !keyword.isEmpty else { return }
        
    }
}
