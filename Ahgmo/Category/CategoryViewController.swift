//
//  CategoryViewController.swift
//  Ahgmo
//
//  Created by 지현 on 12/26/24.
//

import UIKit
import Combine

class CategoryViewController: UIViewController {
    var subscriptions = Set<AnyCancellable>()
    var viewModel: CategoryViewModel!
    
    var filteredItems: [CategoryData] = []
    let searchManager = SearchManager()
    
    var collectionView: UICollectionView!
    var dataSource: UICollectionViewDiffableDataSource<CategoryViewModel.Section, CategoryViewModel.Item>!
    var searchController: UISearchController!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setToolbarHidden(true, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = CategoryViewModel(categoryItems: CategoryData.list)
        bind()
        configureNavigationItem()
        embedSearchControl()
        configureCollectionView()
    }
    
    private func bind() {
        viewModel.categoryItems
            .receive(on: RunLoop.main)
            .sink { [weak self] data in
                self?.applySnapshot(data)
            }.store(in: &subscriptions)
        
        viewModel.selectedItem
            .compactMap { $0 }
            .receive(on: RunLoop.main)
            .sink { [weak self] selectedItem in
                self?.presentViewController(item: selectedItem)
            }.store(in: &subscriptions)
    }
    
    private func configureNavigationItem() {
        self.navigationItem.title = "카테고리"
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationItem.largeTitleDisplayMode = .always
        
        let plusItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(navigateToPage(_:))
        )
        
        navigationItem.rightBarButtonItems = [plusItem, editButtonItem]
        if let editButton = navigationItem.rightBarButtonItems?.first(where: { $0 == editButtonItem }) {
            editButton.title = isEditing ? "완료" : "편집"
        }
    }
    
    @objc private func navigateToPage(_ sender: UIBarButtonItem) {
        let storyboard = UIStoryboard(name: "AddCategory", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "AddCategoryViewController") as! AddCategoryViewController
        vc.originView = "Category"
        let navigationController = UINavigationController(rootViewController: vc)
        self.navigationController?.present(navigationController, animated: true)
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        
        if let editButton = navigationItem.rightBarButtonItems?.first(where: { $0 == editButtonItem }) {
            editButton.title = isEditing ? "완료" : "편집"
        }
        collectionView.isEditing = editing
    }
    
    private func embedSearchControl() {
        searchController = UISearchController(searchResultsController: nil)
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.placeholder = "Search"
        searchController.searchBar.delegate = self
        self.navigationItem.searchController = searchController
        self.navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    private func configureCollectionView() {
        let config = UICollectionLayoutListConfiguration(appearance: .plain)
        let layout = UICollectionViewCompositionalLayout.list(using: config)
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.autoresizingMask = []
        collectionView?.contentInsetAdjustmentBehavior = .never
        collectionView.delegate = self
        collectionView.keyboardDismissMode = .onDrag
        
        view.addSubview(collectionView)
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, CategoryViewModel.Item> { cell, indexPath, item in
            var content = UIListContentConfiguration.cell()
            content.text = item.title
            cell.contentConfiguration = content
            
            let accessories: [UICellAccessory] = [
                .delete(displayed: .whenEditing, actionHandler: { [weak self] in
                    self?.deleteItem(item)
                })
            ]
            
            cell.accessories = accessories
        }
        
        dataSource = UICollectionViewDiffableDataSource<CategoryViewModel.Section, CategoryViewModel.Item>(collectionView: collectionView) { collectionView, indexPath, item in
            collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: item)
        }
    }
    
    private func deleteItem(_ item: CategoryViewModel.Item) {
        let actionSheet = UIAlertController(title: nil, message: "선택한 항목이 영구적으로 삭제됩니다.", preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        let deleteAction = UIAlertAction(title: "삭제", style: .destructive) { [weak self] _ in
            if let indexPath = self?.dataSource.indexPath(for: item),
               let item = self?.dataSource.itemIdentifier(for: indexPath) {
                self?.viewModel.deleteItem(id: item.id)
            }
            self?.isEditing = false
            // UI 업데이트
        }
        
        actionSheet.addAction(deleteAction)
        actionSheet.addAction(cancelAction)
        
        present(actionSheet, animated: true, completion: nil)
        
//        var snapshot = dataSource.snapshot()
//        snapshot.deleteItems([item])
//        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    private func applySnapshot(_ items: [CategoryViewModel.Item]) {
        var snapshot = NSDiffableDataSourceSnapshot<CategoryViewModel.Section, CategoryViewModel.Item>()
        snapshot.appendSections([.main])
        snapshot.appendItems(items, toSection: .main)
        dataSource.apply(snapshot)
    }
    
    private func updateSnapshot(item: CategoryViewModel.Item) {
        var snapshot = dataSource.snapshot()
        snapshot.reloadItems([item])
        dataSource.apply(snapshot)
    }
    
    private func applySearchSnapshot(searchItems: [CategoryViewModel.Item]) {
        var snapshot = dataSource.snapshot()
        let existingItems = snapshot.itemIdentifiers(inSection: .main)
        snapshot.deleteItems(existingItems)
        snapshot.appendItems(searchItems, toSection: .main)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    private func presentViewController(item: CategoryViewModel.Item) {
        let storyboard = UIStoryboard(name: "EditCategory", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "EditCategoryViewController") as! EditCategoryViewController
        vc.viewModel = EditCategoryViewModel(categoryItems: item)
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension CategoryViewController: UICollectionViewDelegate, UISearchBarDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let item = dataSource.itemIdentifier(for: indexPath) {
            viewModel.didSelect(id: item.id)
        }
        collectionView.deselectItem(at: indexPath, animated: true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filteredItems = searchManager.filterItems(viewModel.categoryItems.value, with: searchText)
        applySearchSnapshot(searchItems: filteredItems)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        filteredItems = viewModel.categoryItems.value
        applySnapshot(viewModel.categoryItems.value)
    }
}
