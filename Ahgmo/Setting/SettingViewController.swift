//
//  SettingViewController.swift
//  Ahgmo
//
//  Created by 지현 on 12/26/24.
//

import UIKit
import Combine
import MessageUI
import SafariServices

class SettingViewController: UIViewController {
    var subscriptions = Set<AnyCancellable>()
    var viewModel: SettingViewModel!
    var collectionView: UICollectionView!
    var dataSource: UICollectionViewDiffableDataSource<SettingViewModel.Section, SettingViewModel.Item>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = SettingViewModel(serviceItems: ["버전 정보", "사용자 가이드", "문의하기"])
        bind()
        configureNavigationItem()
        configureCollectionView()
    }
    
    private func bind() {
        viewModel.sortingItems
            .receive(on: RunLoop.main)
            .sink { [weak self] data in
                guard let self = self else { return }
                self.applySnapshot(data.map { SettingViewModel.Item.sortingItem($0) })
            }.store(in: &subscriptions)
        
        viewModel.selectedItem
            .compactMap { $0 }
            .receive(on: RunLoop.main)
            .sink { [weak self] selectedItem in
                guard let self = self else { return }
                if selectedItem == "사용자 가이드" {
                    // 노션 링크 연결
                    let safari = SFSafariViewController(url: URL(string: "https://grey-backbone-80f.notion.site/Ahgmo-1bf890ca890480be8443d6a1289a4a94?pvs=4")!)
                    self.present(safari, animated: true)
                } else if selectedItem == "문의하기" {
                    self.presentMailComposer()
                }
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
        
        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, SettingViewModel.Item> { cell, indexPath, item in
            let section = SettingViewModel.Section(rawValue: indexPath.section)
            if section == .sort {
                self.configureSortCell(cell: cell, item: item)
            } else {
                self.configureServiceCell(cell: cell, item: item)
            }
        }
        
        dataSource = UICollectionViewDiffableDataSource<SettingViewModel.Section, SettingViewModel.Item>(collectionView: collectionView) { collectionView, indexPath, item in
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: item)
        }
    }
    
    private func configureSortCell(cell: UICollectionViewListCell, item: SettingViewModel.Item) {
        let titleLabel = UILabel()
        let sortTypeButton = UIButton(primaryAction: nil)
        let titleClosure = { (action: UIAction) in
            self.viewModel.updateSortOption()
            sortTypeButton.setTitle(action.title, for: .normal)
        }
        
        titleLabel.text = item.title
        sortTypeButton.menu = UIMenu(title: "정렬방식", children: [
            UIAction(title: "오름차순", state: item.isSortedAscending ?? true ? .on : .off, handler: titleClosure),
            UIAction(title: "내림차순", state: item.isSortedAscending ?? true ? .off : .on, handler: titleClosure)
        ])
        sortTypeButton.setTitleColor(.systemBlue, for: .normal)
        sortTypeButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .regular)
        sortTypeButton.contentHorizontalAlignment = .right
        
        cell.contentView.addSubview(titleLabel)
        cell.contentView.addSubview(sortTypeButton)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        sortTypeButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 20),
            titleLabel.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor),
            
            sortTypeButton.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -25),
            sortTypeButton.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor),
        ])
        
        sortTypeButton.showsMenuAsPrimaryAction = true
        sortTypeButton.changesSelectionAsPrimaryAction = true
    }
    
    private func configureServiceCell(cell: UICollectionViewListCell, item: SettingViewModel.Item) {
        var content = UIListContentConfiguration.valueCell()
        content.text = item.title
        if item.title == "버전 정보" {
            content.secondaryText = "1.0.0"
        }
        cell.contentConfiguration = content
    }
    
    private func applySnapshot(_ items: [SettingViewModel.Item]) {
        var snapshot = NSDiffableDataSourceSnapshot<SettingViewModel.Section, SettingViewModel.Item>()
        snapshot.appendSections(SettingViewModel.Section.allCases)
        snapshot.appendItems(items, toSection: .sort)
        snapshot.appendItems(viewModel.serviceItems.value.map(SettingViewModel.Item.serviceItem), toSection: .service)
        dataSource.apply(snapshot, animatingDifferences: true)
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
        return SettingViewModel.Section(rawValue: indexPath.section) == .service
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.didSelect(at: indexPath)
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
