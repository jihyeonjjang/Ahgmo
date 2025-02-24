//
//  HomeViewController.swift
//  Ahgmo
//
//  Created by 지현 on 12/23/24.
//

import UIKit

class HomeViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    
    enum Section: Int, CaseIterable {
        case category
        case information
    }
    
    enum Item: Hashable {
        case categoryItem(CategoryData)
        case informationItem(InfoData)
        
        var title: String {
            switch self {
            case .categoryItem(let data):
                return data.title
            case .informationItem(let data):
                return data.title
            }
        }
    }
    
    var categoryItems: [CategoryData] = CategoryData.list
    var infoItems: [InfoData] = InfoData.list
    var selectedItems: Set<Item> = []
    var isSelectAll: Bool = false
    
    var searchController: UISearchController!
    var dataSource: UICollectionViewDiffableDataSource<Section, Item>!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setToolbarHidden(false, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationItem()
        embedSearchControl()
        configureCollectionView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setToolbarHidden(true, animated: true)
    }
    
    private func configureNavigationItem() {
        self.navigationItem.title = "아그모"
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationItem.largeTitleDisplayMode = .always
        
        let settingItem = UIBarButtonItem(
            image: UIImage(systemName: "gearshape"),
            style: .plain,
            target: self,
            action: #selector(navigateToPage(_:))
        )
        settingItem.tag = 1
        
        navigationItem.leftBarButtonItem = editButtonItem
        let leftBarButtonCustom = isEditing ? "완료" : "편집"
        navigationItem.leftBarButtonItem?.title = leftBarButtonCustom
        navigationItem.rightBarButtonItem = settingItem
        
//        let items: [UIBarButtonItem] = isEditing ? editToolBarItem() : defaultToolBarItem()
        let items: [UIBarButtonItem] = defaultToolBarItem()
        self.toolbarItems = items
    }
    
    private func defaultToolBarItem() -> [UIBarButtonItem] {
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        
        let numberInfoLabel = UIBarButtonItem(customView: {
            let label = UILabel()
            label.text = "\(infoItems.count)개의 항목"
            return label
        }())
        
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
        
        let defaultToolBarItems = [categoryItem, flexibleSpace, numberInfoLabel, flexibleSpace, plusItem]
        return defaultToolBarItems
    }
    
    private func editToolBarItem() -> [UIBarButtonItem] {
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let numberSelectLabel = UIBarButtonItem(customView: {
            let label = UILabel()
            label.text = "\(selectedItems.count)개 선택"
            return label
        }())
        
        let selectAllButton = UIBarButtonItem(
            title: isSelectAll ? "전체 선택 해제" : "전체 선택",
            style: .plain,
            target: self,
            action: #selector(selectAllItems)
        )
        selectAllButton.tag = 11
        
        let deleteItem = UIBarButtonItem(
            title: "삭제",
            style: .plain,
            target: self,
            action: #selector(deleteSelectedItems)
        )
        
        let editToolBarItems = [selectAllButton, flexibleSpace, numberSelectLabel, flexibleSpace, deleteItem]
        return editToolBarItems
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
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        
        let leftBarButtonCustom = isEditing ? "완료" : "편집"
        navigationItem.leftBarButtonItem?.title = leftBarButtonCustom
        let items: [UIBarButtonItem] = isEditing ? editToolBarItem() : defaultToolBarItem()
        self.toolbarItems = items
        if !isEditing {
            if !selectedItems.isEmpty {
                selectedItems.removeAll()
                collectionView.reloadData()
            }
        }
        collectionView.isEditing = editing
    }

    @objc private func selectAllItems() {
        isSelectAll.toggle()
        if isSelectAll {
//            selectedItems.insert()
//            updateSnapshot(section: .information)
        } else {
            selectedItems.removeAll()
        }
        if let selectAllButton = self.toolbarItems?.first(where: { $0.tag == 11 }) {
            selectAllButton.title = isSelectAll ? "전체 선택 해제" : "전체 선택"
        }
    }
    
    @objc private func deleteSelectedItems() {
        
    }
    
    private func embedSearchControl() {
        searchController = UISearchController(searchResultsController: nil)
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.placeholder = "Search"
        searchController.searchBar.delegate = self
        self.navigationItem.searchController = searchController
        self.navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    private func accessoryCustomView(imageName: String) -> UIImageView {
        let accessoryimageView = UIImageView(image: UIImage(systemName: "\(imageName)")?.withRenderingMode(.alwaysTemplate))
        accessoryimageView.tintColor = .systemGray3
        
        return accessoryimageView
    }
    
    private func configureCollectionView() {
        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, Item> { cell, indexPath, item in
            var content = UIListContentConfiguration.cell()
            content.text = item.title
            cell.contentConfiguration = content
            
            let circleAccessory = UICellAccessory.CustomViewConfiguration(
                customView: self.accessoryCustomView(imageName: "circle"),
                placement: .leading(displayed: .whenEditing)
            )
            
            let checkAccessory = UICellAccessory.CustomViewConfiguration(
                customView: UIImageView(image: UIImage(systemName: "checkmark.circle.fill")?.withRenderingMode(.alwaysOriginal)),
                placement: .leading(displayed: .whenEditing)
            )
            
            var accessories: [UICellAccessory] = [.customView(configuration: circleAccessory)]
            
            if self.selectedItems.contains(item) {
                accessories = [.customView(configuration: checkAccessory)]
            }
            cell.accessories = accessories
        }
        
        dataSource = UICollectionViewDiffableDataSource<Section, Item>(collectionView: collectionView) { collectionView, indexPath, item in
            switch item {
            case .categoryItem(let item):
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeCategoryCell", for: indexPath) as? HomeCategoryCell else {
                    fatalError("error")
                }
                cell.backgroundColor = item.isSelected ? .systemBlue : .secondarySystemBackground
                cell.layer.masksToBounds = true
                cell.layer.cornerRadius = 17
                cell.configure(item: item)
                return cell
            case .informationItem:
                return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: item)
            }
        }
        
        applySnapshot()
        
        collectionView.collectionViewLayout = layout()
        collectionView?.contentInsetAdjustmentBehavior = .never
        collectionView.delegate = self
        collectionView.allowsSelectionDuringEditing = true
        collectionView.keyboardDismissMode = .onDrag
    }
    
    private func applySnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        snapshot.appendSections(Section.allCases)
        snapshot.appendItems([CategoryData(title: "모두보기", isSelected: true)].map { Item.categoryItem($0) }, toSection: .category)
        snapshot.appendItems(categoryItems.map { Item.categoryItem($0) }, toSection: .category)
        snapshot.appendItems(infoItems.map{ Item.informationItem($0) }, toSection: .information)
        dataSource.apply(snapshot)
    }
    
    private func updateSnapshot(item: Item) {
        var snapshot = dataSource.snapshot()
        snapshot.reloadItems([item])
        dataSource.apply(snapshot)
    }
    
    private func layout() -> UICollectionViewCompositionalLayout {
        return UICollectionViewCompositionalLayout { (section, env) -> NSCollectionLayoutSection? in
            if section == 0  {
                let itemSize = NSCollectionLayoutSize(widthDimension: .estimated(50), heightDimension: .absolute(35))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .estimated(50), heightDimension: .absolute(35))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                
                let section = NSCollectionLayoutSection(group: group)
                section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 15, bottom: 0, trailing: 0)
                section.interGroupSpacing = 10
                section.orthogonalScrollingBehavior = .continuousGroupLeadingBoundary
                
                return section
            } else {
                let config = UICollectionLayoutListConfiguration(appearance: .plain)
                let section = NSCollectionLayoutSection.list(using: config, layoutEnvironment: env)
                section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 0, bottom: 0, trailing: 0)
                
                return section
            }
        }
    }
}

extension HomeViewController: UICollectionViewDelegate, UISearchBarDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch Section(rawValue: indexPath.section) {
        case .category:
            if indexPath.item == 0 {
                print(">>> selected: 모두보기")
                
            } else {
                var item = categoryItems[indexPath.item - 1]
                print(">>> selected: \(item.title)")
                
                // toggle이 안되는데?
                item.isSelected.toggle()
                print(">>> selected: \(item.isSelected)")
            }
        default:
            if isEditing {
                guard let item = dataSource.itemIdentifier(for: indexPath) else { return }
                
                if selectedItems.contains(item) {
                    selectedItems.remove(item)
                } else {
                    selectedItems.insert(item)
                }
                updateSnapshot(item: item)
            } else {
                let item = infoItems[indexPath.item]
                print(">>> selected: \(item.title)")
                
                let storyboard = UIStoryboard(name: "DetailInfo", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "DetailInfoViewController") as! DetailInfoViewController
                vc.information = item
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
        collectionView.deselectItem(at: indexPath, animated: true)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
        guard let keyword = searchBar.text, !keyword.isEmpty else { return }
        print("\(keyword)")
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        collectionView.reloadData()
    }
}
