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
    
    class DataSource: UITableViewDiffableDataSource<Section, TableItem> {
        override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
            return true
        }
        
        override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
            if editingStyle == .delete {
                if let identifierToDelete = itemIdentifier(for: indexPath) {
                    var snapshot = self.snapshot()
                    snapshot.deleteItems([identifierToDelete])
                    apply(snapshot)
                }
            }
        }
    }
    
    var categoryItems: [CategoryData] = CategoryData.list
    var infoItems: [InfoData] = InfoData.list
    
    var numberOfInfoList = 3
    
    var collectionViewDataSource: UICollectionViewDiffableDataSource<Section, CollectionItem>!
    var tableViewDataSource: DataSource!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setToolbarHidden(false, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationItem()
        embedSearchControl()
        configureCollectionView()
        configureTableView()
        
        collectionView.collectionViewLayout = layout()
        tableView.delegate = self
        collectionView.delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setToolbarHidden(true, animated: true)
    }
    
    private func configureCollectionView() {
        collectionViewDataSource = UICollectionViewDiffableDataSource<Section, CollectionItem>(collectionView: collectionView) { collectionView, indexPath, item in
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeCategoryCell", for: indexPath) as? HomeCategoryCell else { return nil }
            cell.configure(item: item)
            return cell
        }
        
        var collectionViewSnapshot = NSDiffableDataSourceSnapshot<Section, CollectionItem>()
        collectionViewSnapshot.appendSections([.main])
        collectionViewSnapshot.appendItems([CategoryData(title: "모두보기")], toSection: .main)
        collectionViewSnapshot.appendItems(categoryItems, toSection: .main)
        collectionViewDataSource.apply(collectionViewSnapshot)
    }
    
    private func configureTableView() {
        tableViewDataSource = DataSource(tableView: tableView) { tableView, indexPath, item in
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "HomeListCell", for: indexPath) as? HomeListCell else { return UITableViewCell() }
            cell.configure(item: item)
            return cell
        }
        
        var tableViewSnapshot = NSDiffableDataSourceSnapshot<Section, TableItem>()
        tableViewSnapshot.appendSections([.main])
        tableViewSnapshot.appendItems(infoItems, toSection: .main)
        tableViewDataSource.apply(tableViewSnapshot)
    }
    
    private func configureNavigationItem() {
        self.navigationItem.title = "아그모"
        
        let numberInfoLabel = labelBarButtonItem(text: "\(numberOfInfoList)개의 항목")
        let numberSelectLabel = labelBarButtonItem(text: "0개 선택")
        
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        
        let selectItem = UIBarButtonItem(
            image: UIImage(systemName: "checklist"),
            style: .plain,
            target: self,
            action: #selector(toggleEditing)
        )
        
        let doneItem = UIBarButtonItem(
            title: "완료",
            style: .plain,
            target: self,
            action: #selector(toggleEditing)
        )
        
        let settingItem = UIBarButtonItem(
            image: UIImage(systemName: "gearshape"),
            style: .plain,
            target: self,
            action: #selector(navigateToPage(_:))
        )
        settingItem.tag = 1
        
        let categoryItem = UIBarButtonItem(
            image: UIImage(systemName: "folder"),
            style: .plain,
            target: self,
            action: #selector(navigateToPage(_:))
        )
        categoryItem.tag = 2
        
        let plusItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(navigateToPage(_:))
        )
        plusItem.tag = 3
        
        let deleteItem = UIBarButtonItem(
            title: "삭제",
            style: .plain,
            target: self,
            action: #selector(deleteSelectedItems)
        )
        
        navigationItem.leftBarButtonItem = tableView.isEditing ? doneItem : selectItem
        navigationItem.rightBarButtonItem = settingItem
        
        let defaultToolBarItems = [categoryItem, flexibleSpace, numberInfoLabel, flexibleSpace, plusItem]
        let editToolBarItems = [flexibleSpace, numberSelectLabel, flexibleSpace, deleteItem]
        let items: [UIBarButtonItem] = tableView.isEditing ? editToolBarItems : defaultToolBarItems
        self.toolbarItems = items
    }
    
    private func labelBarButtonItem(text: String) -> UIBarButtonItem {
        let label = UILabel()
        label.text = "\(text)"
        return UIBarButtonItem(customView: label)
    }
    
    @objc private func navigateToPage(_ sender: UIBarButtonItem) {
        switch sender.tag {
        case 1:
            let storyboard = UIStoryboard(name: "Setting", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "SettingViewController") as! SettingViewController
            self.navigationController?.pushViewController(vc, animated: true)
        case 2:
            let storyboard = UIStoryboard(name: "Category", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "CategoryViewController") as! CategoryViewController
            self.navigationController?.pushViewController(vc, animated: true)
        case 3:
            let storyboard = UIStoryboard(name: "AddInfo", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "AddInfoViewController") as! AddInfoViewController
            self.navigationController?.pushViewController(vc, animated: true)
        default:
            return
        }
    }
    
    @objc private func toggleEditing() {
        tableView.setEditing(!tableView.isEditing, animated: true)
        configureNavigationItem()
    }
    
    @objc private func deleteSelectedItems() {
        // 선택된 항목 삭제
    }
    
    private func embedSearchControl() {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.placeholder = "Search"
        searchController.searchBar.delegate = self
        self.navigationItem.searchController = searchController
        self.navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    private func layout() -> UICollectionViewCompositionalLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .estimated(100), heightDimension: .absolute(40))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .estimated(100), heightDimension: .absolute(40))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        //        group.interItemSpacing = NSCollectionLayoutSpacing.fixed(7)
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 15, bottom: 0, trailing: 0)
        section.interGroupSpacing = 10
        section.orthogonalScrollingBehavior = .continuousGroupLeadingBoundary
        
        return UICollectionViewCompositionalLayout(section: section)
    }
}

extension HomeViewController: UISearchBarDelegate, UICollectionViewDelegate, UITableViewDelegate {
    // 동작안함
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = categoryItems[indexPath.item]
        print(">>> selected: \(item.title)")
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = infoItems[indexPath.item]
        print(">>> selected: \(item.title)")
        
        if tableView.isEditing {
            return
        }
        
        let storyboard = UIStoryboard(name: "DetailInfo", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "DetailInfoViewController") as! DetailInfoViewController
        vc.information = item
        self.navigationController?.pushViewController(vc, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let keyword = searchBar.text, !keyword.isEmpty else { return }
        
    }
}
