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
    
    enum Section: Int, CaseIterable {
        case url
        case description
        
        var title: String {
            switch self {
            case .url: return "URL"
            case .description: return "설명"
            }
        }
    }
    typealias Item = InfoData
    @Published var information: InfoData = InfoData(title: "Unknown", description: "", urlString: "", imageURL: "", category: CategoryData(title: ""))
    
    var subscriptions = Set<AnyCancellable>()
    let didSelect = PassthroughSubject<URL, Never>()
    
    var dataSource: UICollectionViewDiffableDataSource<Section, Item>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bind()
        configureNavigationItem()
        configureCollectionView()
        updateUI()
        navigationController?.setToolbarHidden(true, animated: true)
    }
    
    private func bind() {
        didSelect
            .receive(on: RunLoop.main)
            .sink { [weak self] url in
                let safari = SFSafariViewController(url: url)
                self?.present(safari, animated: true)
            }.store(in: &subscriptions)
        
        $information
            .receive(on: RunLoop.main)
            .sink { [weak self] data in
                self?.applySnapshot(data)
            }.store(in: &subscriptions)
    }
    
    private func configureNavigationItem() {
        self.navigationItem.largeTitleDisplayMode = .never
        let deleteItem = UIBarButtonItem(
            image: UIImage(systemName: "trash"),
            style: .plain,
            target: self,
            action: nil
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
        vc.information = information
        let navigationController = UINavigationController(rootViewController: vc)
        self.navigationController?.present(navigationController, animated: true)
    }
    
    private func configureCollectionView() {
        let headerRegistration = UICollectionView.SupplementaryRegistration<UICollectionViewListCell>(elementKind: UICollectionView.elementKindSectionHeader) { cell, _, indexPath in
            let section = Section.allCases[indexPath.section]
            var content = UIListContentConfiguration.plainHeader()
            content.text = section.title
            //            content.textProperties.font = .boldSystemFont(ofSize: 16)
            cell.contentConfiguration = content
        }
        
        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, Item> { cell, indexPath, item in
            var content = UIListContentConfiguration.cell()
            let section = Section(rawValue: indexPath.section)
            if section == .url {
                content.text = item.urlString
            } else {
                content.text = item.description
            }
            cell.contentConfiguration = content
        }
        
        dataSource = UICollectionViewDiffableDataSource<Section, Item>(collectionView: collectionView) { collectionView, indexPath, item in
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
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        snapshot.appendSections(Section.allCases)
        snapshot.appendItems([InfoData(title: items.title, description: "", urlString: items.urlString, imageURL: "", category: CategoryData(title: ""))], toSection: .url)
        snapshot.appendItems([InfoData(title: items.title, description: items.description, urlString: "", imageURL: "", category: CategoryData(title: ""))], toSection: .description)
        dataSource.apply(snapshot)
    }
    
    private func updateUI() {
        thumbnailImageView.kf.setImage(
            with: URL(string: information.imageURL)!,
            placeholder: UIImage(systemName: "hands.sparkles.fill"))
        thumbnailImageView.layer.cornerRadius = 20
        
        titleLabel.text = information.title
        categoryLabel.text = information.category.title
    }
    
    private func layout() -> UICollectionViewCompositionalLayout {
        var configuration = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        configuration.headerMode = .supplementary
        
        return UICollectionViewCompositionalLayout.list(using: configuration)
    }
}

extension DetailInfoViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if Section(rawValue: indexPath.section) == .url {
            guard let url = URL(string: information.urlString) else {
                return
            }
            didSelect.send(url)
        }
        collectionView.deselectItem(at: indexPath, animated: true)
    }
}
