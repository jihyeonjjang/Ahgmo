//
//  HomeViewController.swift
//  Ahgmo
//
//  Created by 지현 on 12/23/24.
//

import UIKit
import Combine

class HomeViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    var subscriptions = Set<AnyCancellable>()
    var viewModel: HomeViewModel!
    let searchManager = SearchManager()
    var searchController: UISearchController!
    var dataSource: UICollectionViewDiffableDataSource<HomeViewModel.Section, HomeViewModel.Item>!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setToolbarHidden(false, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = HomeViewModel()
        bind()
        configureNavigationItem()
        embedSearchControl()
        configureCollectionView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setToolbarHidden(true, animated: true)
    }
    
    private func bind() {
        Publishers.CombineLatest(viewModel.categoryItems, viewModel.infoItems)
            .receive(on: RunLoop.main)
            .sink { [weak self] (categories, infos) in
                guard let self = self else { return }
                var items: [HomeViewModel.Section: [HomeViewModel.Item]] = [:]
                items[.category] = categories.map { HomeViewModel.Item.categoryItem($0) }
                items[.information] = infos.map { HomeViewModel.Item.informationItem($0) }
                self.applySnapshot(items)
            }.store(in: &subscriptions)
        
        viewModel.selectedInfo
            .compactMap { $0 }
            .receive(on: RunLoop.main)
            .sink { [weak self] selectedItem in
                guard let self = self else { return }
                if self.isEditing {
                    self.viewModel.toggleItemSelection(selectedItem)
                } else {
                    self.presentViewController(item: .informationItem(selectedItem))
                }
            }.store(in: &subscriptions)
        
        viewModel.selectedItems
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.reconfigureSnapshot(section: .information)
                self.toolbarItems = self.isEditing ? self.editToolBarItem() : self.defaultToolBarItem()
            }.store(in: &subscriptions)
        
        viewModel.filteredItems
            .receive(on: RunLoop.main)
            .sink { [weak self] items in
                guard let self = self else { return }
                let filteredHomeItems = items.map { HomeViewModel.Item.informationItem($0) }
                self.applyFilteredSnapshot(searchItems: filteredHomeItems)
                reconfigureSnapshot(section: .category)
            }.store(in: &subscriptions)
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
        
        let items: [UIBarButtonItem] = defaultToolBarItem()
        self.toolbarItems = items
    }
    
    private func defaultToolBarItem() -> [UIBarButtonItem] {
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        
        let numberInfoLabel = UIBarButtonItem(customView: {
            let label = UILabel()
            label.text = "\(viewModel.infoItems.value.count)개의 항목"
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
            label.text = "\(viewModel.selectedItemsCount)개 선택"
            return label
        }())
        
        let selectAllButton = UIBarButtonItem(
            title: viewModel.isSelectAll.value ? "전체 선택 해제" : "전체 선택",
            style: .plain,
            target: self,
            action: #selector(selectAllItems)
        )
        
        let deleteItem = UIBarButtonItem(
            title: "삭제",
            style: .plain,
            target: self,
            action: #selector(deleteSelectedItems)
        )
        if viewModel.selectedItemsCount > 0 {
            deleteItem.isEnabled = true
        } else {
            deleteItem.isEnabled = false
        }
        
        let editToolBarItems = [selectAllButton, flexibleSpace, numberSelectLabel, flexibleSpace, deleteItem]
        return editToolBarItems
    }
    
    @objc private func navigateToPage(_ sender: UIBarButtonItem) {
        let viewControllers: [Int: (storyboard: String, viewControllerID: String)] = [
            1: ("Setting", "SettingViewController"),
            2: ("Category", "CategoryViewController"),
            3: ("AddInfo", "AddInfoViewController")
        ]
        guard let viewControllerInfo = viewControllers[sender.tag] else { return }
        let storyboard = UIStoryboard(name: viewControllerInfo.storyboard, bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: viewControllerInfo.viewControllerID)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        
        let leftBarButtonCustom = isEditing ? "완료" : "편집"
        navigationItem.leftBarButtonItem?.title = leftBarButtonCustom
        let items: [UIBarButtonItem] = isEditing ? editToolBarItem() : defaultToolBarItem()
        self.toolbarItems = items
        
        if !isEditing {
            viewModel.clearSelection()
//            reconfigureSnapshot(section: .information)
        }
        collectionView.isEditing = editing
    }
    
    @objc private func selectAllItems() {
        viewModel.toggleSelectAll()
    }
    
    @objc private func deleteSelectedItems() {
        let actionSheet = UIAlertController(title: nil, message: "선택한 항목이 영구적으로 삭제됩니다.", preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        let deleteAction = UIAlertAction(title: "삭제", style: .destructive) { [weak self] _ in
            guard let self = self else { return }
            self.viewModel.deleteItems()
            self.isEditing = false
            
            // UI 업데이트
        }
        
        actionSheet.addAction(deleteAction)
        actionSheet.addAction(cancelAction)
        
        present(actionSheet, animated: true, completion: nil)
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
        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, HomeViewModel.Item> { cell, indexPath, item in
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
            
            if case let .informationItem(info) = item, self.viewModel.selectedItems.value.contains(info) {
                accessories = [.customView(configuration: checkAccessory)]
            }
            cell.accessories = accessories
        }
        
        dataSource = UICollectionViewDiffableDataSource<HomeViewModel.Section, HomeViewModel.Item>(collectionView: collectionView) { collectionView, indexPath, item in
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
        
        collectionView.collectionViewLayout = layout()
        collectionView?.contentInsetAdjustmentBehavior = .never
        collectionView.delegate = self
        collectionView.allowsSelectionDuringEditing = true
        collectionView.keyboardDismissMode = .onDrag
    }
    
    private func applySnapshot(_ items: [HomeViewModel.Section: [HomeViewModel.Item]]) {
        var snapshot = NSDiffableDataSourceSnapshot<HomeViewModel.Section, HomeViewModel.Item>()
        snapshot.appendSections(HomeViewModel.Section.allCases)
        for (section, item) in items {
            snapshot.appendItems(item, toSection: section)
        }
        dataSource.apply(snapshot, animatingDifferences: false)
    }
    
    private func reconfigureSnapshot(section: HomeViewModel.Section) {
        var snapshot = dataSource.snapshot()
        let sectionItems = snapshot.itemIdentifiers(inSection: section)
        snapshot.reconfigureItems(sectionItems)
        dataSource.apply(snapshot, animatingDifferences: false)
    }
    
    private func applyFilteredSnapshot(searchItems: [HomeViewModel.Item]) {
        var snapshot = dataSource.snapshot()
        let existingItems = snapshot.itemIdentifiers(inSection: .information)
        snapshot.deleteItems(existingItems)
        snapshot.appendItems(searchItems, toSection: .information)
        dataSource.apply(snapshot, animatingDifferences: false)
    }
    
    private func layout() -> UICollectionViewCompositionalLayout {
        return UICollectionViewCompositionalLayout { (section, env) -> NSCollectionLayoutSection? in
            if section == 0  {
                let itemSize = NSCollectionLayoutSize(widthDimension: .estimated(50), heightDimension: .absolute(35))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .estimated(50), heightDimension: .absolute(35))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                
                let section = NSCollectionLayoutSection(group: group)
                section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 15, bottom: 0, trailing: 15)
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
    
    private func presentViewController(item: HomeViewModel.Item) {
        let storyboard = UIStoryboard(name: "DetailInfo", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "DetailInfoViewController") as! DetailInfoViewController
        if case .informationItem(let infoData) = item {
            vc.viewModel = DetailInfoViewModel(infoItem: infoData)
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension HomeViewController: UICollectionViewDelegate, UISearchBarDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch HomeViewModel.Section(rawValue: indexPath.section) {
        case .category:
            if let item = dataSource.itemIdentifier(for: indexPath) {
                viewModel.didCategorySelect(id: item.id)
            }
        case .information:
            if let item = dataSource.itemIdentifier(for: indexPath) {
                viewModel.didInfoSelect(id: item.id)
            }
        case .none:
            break
        }
        collectionView.deselectItem(at: indexPath, animated: true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        viewModel.filteredItems.value = searchManager.filterItems(viewModel.infoItems.value, with: searchText)
        let filteredHomeItems = viewModel.filteredItems.value.map { HomeViewModel.Item.informationItem($0) }
        applyFilteredSnapshot(searchItems: filteredHomeItems)
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        viewModel.filteredItems.value = viewModel.infoItems.value
        viewModel.categoryItems.value.indices
            .forEach { viewModel.categoryItems.value[$0].isSelected = false }
        var items: [HomeViewModel.Section: [HomeViewModel.Item]] = [:]
        items[.category] = viewModel.categoryItems.value.map { HomeViewModel.Item.categoryItem($0) }
        items[.information] = viewModel.infoItems.value.map { HomeViewModel.Item.informationItem($0) }
        applySnapshot(items)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        viewModel.filteredItems.value = viewModel.infoItems.value
        var items: [HomeViewModel.Section: [HomeViewModel.Item]] = [:]
        items[.category] = viewModel.categoryItems.value.map { HomeViewModel.Item.categoryItem($0) }
        items[.information] = viewModel.infoItems.value.map { HomeViewModel.Item.informationItem($0) }
        applySnapshot(items)
    }
}
