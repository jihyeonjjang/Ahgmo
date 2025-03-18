//
//  DetailInfoViewController.swift
//  Ahgmo
//
//  Created by 지현 on 12/26/24.
//

import UIKit
import Combine
import Kingfisher
import SafariServices

class DetailInfoViewController: UIViewController {
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var subscriptions = Set<AnyCancellable>()
    var viewModel: DetailInfoViewModel!
    
    var dataSource: UICollectionViewDiffableDataSource<DetailInfoViewModel.Section, DetailInfoViewModel.Item>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
        configureNavigationItem()
        configureCollectionView()
        updateUI()
        navigationController?.setToolbarHidden(true, animated: true)
    }
    
    private func bind() {
        viewModel.infoItems
            .receive(on: RunLoop.main)
            .sink { [weak self] data in
                self?.applySnapshot(data)
            }.store(in: &subscriptions)
        
        viewModel.selectedItem
            .compactMap { $0 }
            .receive(on: RunLoop.main)
            .sink { [weak self] url in
                let safari = SFSafariViewController(url: url)
                self?.present(safari, animated: true)
            }.store(in: &subscriptions)
    }
    
    private func configureNavigationItem() {
        self.navigationItem.largeTitleDisplayMode = .never
        let deleteItem = UIBarButtonItem(
            image: UIImage(systemName: "trash"),
            style: .plain,
            target: self,
            action: #selector(deleteItem)
        )
        
        let editItem = UIBarButtonItem(
            title: "편집",
            style: .plain,
            target: self,
            action: #selector(navigateToPage(_:))
        )
        
        navigationItem.rightBarButtonItems = [deleteItem, editItem]
    }
    
    @objc private func navigateToPage(_ sender: UIBarButtonItem) {
        let storyboard = UIStoryboard(name: "EditInfo", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "EditInfoViewController") as! EditInfoViewController
        vc.viewModel = EditInfoViewModel(infoItems: self.viewModel.infoItems.value)
        let navigationController = UINavigationController(rootViewController: vc)
        self.navigationController?.present(navigationController, animated: true)
    }
    
    @objc private func deleteItem() {
        let actionSheet = UIAlertController(title: nil, message: "선택한 항목이 영구적으로 삭제됩니다.", preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        let deleteAction = UIAlertAction(title: "삭제", style: .destructive) { [weak self] _ in
            self?.viewModel.deleteItem()
            // UI 업데이트
        }
        
        actionSheet.addAction(deleteAction)
        actionSheet.addAction(cancelAction)
        
        present(actionSheet, animated: true, completion: nil)
    }
    
    private func configureCollectionView() {
        let headerRegistration = UICollectionView.SupplementaryRegistration<UICollectionViewListCell>(elementKind: UICollectionView.elementKindSectionHeader) { cell, _, indexPath in
            let section = DetailInfoViewModel.Section.allCases[indexPath.section]
            var content = UIListContentConfiguration.plainHeader()
            content.text = section.title
            cell.contentConfiguration = content
        }
        
        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, DetailInfoViewModel.Item> { cell, indexPath, item in
            var content = UIListContentConfiguration.cell()
            let section = DetailInfoViewModel.Section(rawValue: indexPath.section)
            if section == .url {
                content.text = item.urlString
            } else {
                content.text = item.details
            }
            cell.contentConfiguration = content
        }
        
        dataSource = UICollectionViewDiffableDataSource<DetailInfoViewModel.Section, DetailInfoViewModel.Item>(collectionView: collectionView) { collectionView, indexPath, item in
            collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: item)
        }
        
        dataSource.supplementaryViewProvider = { (collectionView, elementKind, indexPath) in
            if elementKind == UICollectionView.elementKindSectionHeader {
                return collectionView.dequeueConfiguredReusableSupplementary(using: headerRegistration, for: indexPath)
            }
            return nil
        }
        
        collectionView.collectionViewLayout = layout()
        collectionView.delegate = self
    }
    
    private func applySnapshot(_ items: InfoData) {
        var snapshot = NSDiffableDataSourceSnapshot<DetailInfoViewModel.Section, DetailInfoViewModel.Item>()
        snapshot.appendSections(DetailInfoViewModel.Section.allCases)
        snapshot.appendItems([InfoData(title: items.title, details: "", urlString: items.urlString, imageURL: "", category: CategoryData(title: ""))], toSection: .url)
        snapshot.appendItems([InfoData(title: items.title, details: items.details, urlString: "", imageURL: "", category: CategoryData(title: ""))], toSection: .details)
        dataSource.apply(snapshot)
    }
    
    private func updateUI() {
        thumbnailImageView.kf.setImage(
            with: URL(string: self.viewModel.infoItems.value.imageURL)!,
            placeholder: UIImage(systemName: "hands.sparkles.fill"))
        thumbnailImageView.layer.cornerRadius = 20
        
        titleLabel.text = self.viewModel.infoItems.value.title
        categoryLabel.text = self.viewModel.infoItems.value.category.title
    }
    
    private func layout() -> UICollectionViewCompositionalLayout {
        var configuration = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        configuration.headerMode = .supplementary
        
        return UICollectionViewCompositionalLayout.list(using: configuration)
    }
}

extension DetailInfoViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return DetailInfoViewModel.Section(rawValue: indexPath.section) == .url
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.didSelect()
        collectionView.deselectItem(at: indexPath, animated: true)
    }
}
