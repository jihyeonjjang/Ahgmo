//
//  SettingViewController.swift
//  Ahgmo
//
//  Created by 지현 on 12/26/24.
//

import UIKit
import MessageUI

class SettingViewController: UIViewController {
    enum Section: Int {
        case sort
        case service
    }
    
    //    struct Item: Hashable {
    //        let title: String
    //    }
    typealias Item = String
    
    var collectionView: UICollectionView!
    var dataSource: UICollectionViewDiffableDataSource<Section, Item>!
    
    let sortData = ["정보", "카테고리"]
    let serviceData = ["앱정보", "문의하기"]
    var sortType: Bool = true // true: 오름차순, false: 내림차순
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "설정"
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationItem.largeTitleDisplayMode = .always
        
        let config = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        let layout = UICollectionViewCompositionalLayout.list(using: config)
        
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(collectionView)
        
        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, Item> { cell, indexPath, item in
            let section = Section(rawValue: indexPath.section)
            if section == .sort {
                let titleLabel = UILabel()
                let sortTypeButton = UIButton()
                let menu = UIMenu(title: "", children: [
                    UIAction(title: "오름차순", state: .on, handler: { _ in print("오름차순") }),
                    UIAction(title: "내림차순", handler: { _ in print("내림차순") })
                ])
                titleLabel.text = item
                sortTypeButton.setTitle(self.sortType ? "오름차순" : "내림차순", for: .normal)
                sortTypeButton.setTitleColor(.systemBlue, for: .normal)
                sortTypeButton.contentHorizontalAlignment = .right
                sortTypeButton.menu = menu
                sortTypeButton.showsMenuAsPrimaryAction = true
                titleLabel.frame = CGRect(x: 0, y: 0, width: cell.bounds.width/2, height: cell.bounds.height)
                titleLabel.textAlignment = .left
                sortTypeButton.frame = CGRect(x: cell.bounds.width/2, y: 0, width: cell.bounds.width/2, height: cell.bounds.height)
                
                cell.contentView.addSubview(titleLabel)
                cell.contentView.addSubview(sortTypeButton)
                
                titleLabel.translatesAutoresizingMaskIntoConstraints = false
                sortTypeButton.translatesAutoresizingMaskIntoConstraints = false
                
                NSLayoutConstraint.activate([
                    // titleLabel 왼쪽 정렬 (leading)
                    titleLabel.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 20),
                    titleLabel.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor),
                    
                    // sortTypeButton 오른쪽 정렬 (trailing)
                    sortTypeButton.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -25),
                    sortTypeButton.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor)
                ])
            } else {
                var content = cell.defaultContentConfiguration()
                content.text = item
                cell.contentConfiguration = content
            }
        }
        
        dataSource = UICollectionViewDiffableDataSource<Section, Item>(collectionView: collectionView) { collectionView, indexPath, item in
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: item)
        }
        
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        snapshot.appendSections([.sort, .service])
        snapshot.appendItems(sortData, toSection: .sort)
        snapshot.appendItems(serviceData, toSection: .service)
        dataSource.apply(snapshot, animatingDifferences: true)
        
        collectionView.delegate = self
    }
    
    private func layout() -> UICollectionViewCompositionalLayout {
        let config = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        return UICollectionViewCompositionalLayout.list(using: config)
    }
}

extension SettingViewController: UICollectionViewDelegate, MFMailComposeViewControllerDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let section = Section(rawValue: indexPath.section)
        if section == .sort {
            let selectedItem = sortData[indexPath.row]
            print("선택된 아이템: \(selectedItem)")
        } else {
            let selectedItem = serviceData[indexPath.row]
            print("선택된 아이템: \(selectedItem)")
            if selectedItem == "앱정보" {
                let storyboard = UIStoryboard(name: "AppInfo", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "AppInfoViewController") as! AppInfoViewController
                let navigationController = UINavigationController(rootViewController: vc)
                
                self.navigationController?.present(navigationController, animated: true)
            } else {
                if MFMailComposeViewController.canSendMail() {
                    let mailComposeVC = MFMailComposeViewController()
                    mailComposeVC.mailComposeDelegate = self
                    mailComposeVC.setToRecipients(["jihyeon9975@icloud.com"])
                    present(mailComposeVC, animated: true, completion: nil)
                } else {
                    let alert = UIAlertController(title: "메일 전송 불가", message: "이 기기에서는 메일을 보낼 수 없습니다.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
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
        }
        collectionView.deselectItem(at: indexPath, animated: true)
    }
}
