//
//  SelectCategoryViewController.swift
//  Ahgmo
//
//  Created by 지현 on 12/26/24.
//

import UIKit
import Combine

class SelectCategoryViewController: UIViewController {
    var subscriptions = Set<AnyCancellable>()
    var viewModel: SelectCategoryViewModel!
    
    var filteredItems: [CategoryEntity] = []
    let searchManager = SearchManager()
    
    var collectionView: UICollectionView!
    var dataSource: UICollectionViewDiffableDataSource<SelectCategoryViewModel.Section, SelectCategoryViewModel.Item>!
    
    var completion: ((CategoryEntity) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
        configureNavigationItem()
        embedSearchControl()
        configureCollectionView()
    }
    
    private func bind() {
        viewModel.categoryItems
            .receive(on: RunLoop.main)
            .sink { [weak self] list in
                self?.applySnapshot(list)
            }.store(in: &subscriptions)
        
        viewModel.selectedItem
            .compactMap { $0 }
            .receive(on: RunLoop.main)
            .sink { [weak self] item in
                self?.completion?(item)
                self?.dismiss(animated: true, completion: nil)
            }.store(in: &subscriptions)
    }
    
    private func configureNavigationItem() {
        self.navigationItem.title = "카테고리 선택"
        self.navigationItem.largeTitleDisplayMode = .never
        
        let cancelItem = UIBarButtonItem(
            title: "취소",
            style: .plain,
            target: self,
            action: #selector(navigateToPage(_:))
        )
        cancelItem.tag = 1
        
        let plusItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(navigateToPage(_:))
        )
        plusItem.tag = 2
        
        navigationItem.leftBarButtonItem = cancelItem
        navigationItem.rightBarButtonItem = plusItem
    }
    
    @objc private func navigateToPage(_ sender: UIBarButtonItem) {
        switch sender.tag {
        case 1:
            self.dismiss(animated: true, completion: nil)
        case 2:
            let storyboard = UIStoryboard(name: "AddCategory", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "AddCategoryViewController") as! AddCategoryViewController
            self.navigationController?.pushViewController(vc, animated: true)
        default:
            return
        }
    }
    
    private func embedSearchControl() {
        let searchController = UISearchController(searchResultsController: nil)
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
        view.addSubview(collectionView)
        collectionView.delegate = self
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, SelectCategoryViewModel.Item> { [weak self] cell, indexPath, item in
            guard let self = self else { return }
            
            var content = UIListContentConfiguration.cell()
            content.text = item.title
            cell.contentConfiguration = content
            
            if let selected = viewModel.initialCategory.value, selected.title == item.title {
                cell.accessories = [.checkmark()]
            } else {
                cell.accessories = []
            }
        }
        
        dataSource = UICollectionViewDiffableDataSource<SelectCategoryViewModel.Section, SelectCategoryViewModel.Item>(collectionView: collectionView) { collectionView, indexPath, item in
            collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: item)
        }
    }
    
    private func applySnapshot(_ items: [CategoryEntity]) {
        var snapshot = NSDiffableDataSourceSnapshot<SelectCategoryViewModel.Section, SelectCategoryViewModel.Item>()
        snapshot.appendSections([.main])
        snapshot.appendItems(items, toSection: .main)
        dataSource.apply(snapshot)
    }
    
    private func applySearchSnapshot(searchItems: [SelectCategoryViewModel.Item]) {
        var snapshot = dataSource.snapshot()
        let existingItems = snapshot.itemIdentifiers(inSection: .main)
        snapshot.deleteItems(existingItems)
        snapshot.appendItems(searchItems, toSection: .main)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
}

extension SelectCategoryViewController: UICollectionViewDelegate, UISearchBarDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        if let item = dataSource.itemIdentifier(for: indexPath) {
            viewModel.didSelect(id: item.id!)
        }
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
