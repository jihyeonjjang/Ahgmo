//
//  SettingViewController.swift
//  Ahgmo
//
//  Created by 지현 on 12/26/24.
//

import UIKit
import Combine
import MessageUI

class SettingViewController: UIViewController {
    enum Section: Int, CaseIterable {
        case sort
        case service
    }
    
    struct Item: Hashable {
        enum ItemType {
            case info
            case category
            case appInfo
            case contact
        }
        
        let title: String
        let type: ItemType
    }
    
    var subscriptions = Set<AnyCancellable>()
    let didSelect = PassthroughSubject<Item, Never>()
    @Published var setData: [Section: [Item]] = [
        .sort: [
            Item(title: "정보", type: .info),
            Item(title: "카테고리", type: .category)
        ],
        .service: [
            Item(title: "앱정보", type: .appInfo),
            Item(title: "문의하기", type: .contact)
        ]
    ]
    var isSortedAscending: Bool = true
    
    var collectionView: UICollectionView!
    var dataSource: UICollectionViewDiffableDataSource<Section, Item>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bind()
        configureNavigationItem()
        configureCollectionView()
    }
    
    private func bind() {
        didSelect
            .receive(on: RunLoop.main)
            .sink { [weak self] selectedItem in
                switch selectedItem.type {
                case .appInfo:
                    self?.presentViewController()
                case .contact:
                    self?.presentMailComposer()
                case .info, .category:
                    break
                }
            }.store(in: &subscriptions)
        
        $setData
            .receive(on: RunLoop.main)
            .sink { [weak self] data in
                self?.applySnapshot(data)
            }.store(in: &subscriptions)
    }
    
    private func configureNavigationItem() {
        self.navigationItem.title = "설정"
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationItem.largeTitleDisplayMode = .always
    }
    
    private func configureCollectionView() {
        let config = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        let layout = UICollectionViewCompositionalLayout.list(using: config)
        
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(collectionView)
        collectionView.delegate = self
        
        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, Item> { cell, indexPath, item in
            let section = Section(rawValue: indexPath.section)
            if section == .sort {
                self.configureSortCell(cell: cell, item: item)
            } else {
                self.configureServiceCell(cell: cell, item: item)
            }
        }
        
        dataSource = UICollectionViewDiffableDataSource<Section, Item>(collectionView: collectionView) { collectionView, indexPath, item in
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: item)
        }
    }
    
    private func configureSortCell(cell: UICollectionViewListCell, item: Item) {
        let titleLabel = UILabel()
        let sortTypeButton = UIButton()
        
        titleLabel.text = item.title
        updateSortButtonTitle(sortTypeButton)
        sortTypeButton.setTitleColor(.systemBlue, for: .normal)
        sortTypeButton.contentHorizontalAlignment = .right
        
        cell.contentView.addSubview(titleLabel)
        cell.contentView.addSubview(sortTypeButton)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        sortTypeButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 20),
            titleLabel.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor),
            
            sortTypeButton.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -25),
            sortTypeButton.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor)
        ])
        
        updateMenuItems(sortTypeButton)
        sortTypeButton.showsMenuAsPrimaryAction = true
    }
    
    private func updateSortButtonTitle(_ button: UIButton) {
        button.setTitle(self.isSortedAscending ? "오름차순" : "내림차순", for: .normal)
    }
    
    private func updateMenuItems(_ button: UIButton) {
        let ascendingAction = UIAction(title: "오름차순", state: isSortedAscending ? .on : .off) { [weak self] _ in
            self?.isSortedAscending = true
            self?.updateSortButtonTitle(button)
            self?.updateMenuItems(button)
        }
        
        let descendingAction = UIAction(title: "내림차순", state: isSortedAscending ? .off : .on) { [weak self] _ in
            self?.isSortedAscending = false
            self?.updateSortButtonTitle(button)
            self?.updateMenuItems(button)
        }
        
        button.menu = UIMenu(title: "", children: [ascendingAction, descendingAction])
    }
    
    private func configureServiceCell(cell: UICollectionViewListCell, item: Item) {
        var content = cell.defaultContentConfiguration()
        content.text = item.title
        cell.contentConfiguration = content
    }
    
    private func applySnapshot(_ items: [Section: [Item]]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        snapshot.appendSections(Section.allCases)
        for (section, item) in items {
            snapshot.appendItems(item, toSection: section)
        }
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    private func presentViewController() {
        let storyboard = UIStoryboard(name: "AppInfo", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "AppInfoViewController") as! AppInfoViewController
        let navigationController = UINavigationController(rootViewController: vc)
        self.navigationController?.present(navigationController, animated: true)
    }
    
    private func presentMailComposer() {
        if MFMailComposeViewController.canSendMail() {
            let mailComposeVC = MFMailComposeViewController()
            mailComposeVC.mailComposeDelegate = self
            mailComposeVC.setToRecipients(["jihyeon9975@icloud.com"])
            self.present(mailComposeVC, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "메일 전송 불가", message: "이 기기에서는 메일을 보낼 수 없습니다.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
}

extension SettingViewController: UICollectionViewDelegate, MFMailComposeViewControllerDelegate {
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        guard let section = Section(rawValue: indexPath.section) else { return false }
        if section == .sort {
            return false
        }
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let section = Section(rawValue: indexPath.section), let items = setData[section] {
            let selectedItem = items[indexPath.row]
            didSelect.send(selectedItem)
        }
        collectionView.deselectItem(at: indexPath, animated: true)
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
        
        switch result {
        case .sent:
            print("메일이 성공적으로 전송되었습니다.")
        case .saved:
            print("메일이 저장되었습니다.")
        case .cancelled:
            print("메일이 취소되었습니다.")
        case .failed:
            print("메일 전송에 실패했습니다.")
        @unknown default:
            break
        }
    }
}
