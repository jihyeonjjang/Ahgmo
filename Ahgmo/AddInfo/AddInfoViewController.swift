//
//  AddInfoViewController.swift
//  Ahgmo
//
//  Created by 지현 on 12/26/24.
//

import UIKit
import Combine

class AddInfoViewController: UIViewController {
    //    private let ogpFetcher = OGPFetcher()
    
    enum Section: Int {
        case textField
        case button
    }
    
    struct Item: Hashable {
        let title: String
    }
    
    var subscriptions = Set<AnyCancellable>()
    let didSelect = PassthroughSubject<Void, Never>()
    let keyboardWillHide = PassthroughSubject<Void, Never>()
    var selectedCategory: CategoryEntity?
    
    var collectionView: UICollectionView!
    var dataSource: UICollectionViewDiffableDataSource<Section, Item>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
        configureNavigationItem()
        setupCollectionView()
        applySnapshot()
        hideKeyBoardWhenTappedScreen()
    }
    
    private func bind() {
        didSelect
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.presentViewController()
            }.store(in: &subscriptions)
        
        keyboardWillHide
            .receive(on: RunLoop.main)
            .sink { [unowned self] _ in
                self.view.endEditing(true)
            }
            .store(in: &subscriptions)
    }
    
    private func configureNavigationItem() {
        self.navigationItem.title = "새로운 정보"
        self.navigationItem.largeTitleDisplayMode = .never
        
        let cancelItem = UIBarButtonItem(
            title: "취소",
            style: .plain,
            target: self,
            action: #selector(navigateToPage(_:))
        )
        cancelItem.tag = 0
        
        let doneItem = UIBarButtonItem(
            title: "완료",
            style: .plain,
            target: self,
            action: #selector(navigateToPage(_:))
        )
        cancelItem.tag = 1
        
        navigationItem.leftBarButtonItem = cancelItem
        navigationItem.rightBarButtonItem = doneItem
    }
    
    @objc private func navigateToPage(_ sender: UIBarButtonItem) {
        switch sender.tag {
        case 0:
            self.navigationController?.popViewController(animated: true)
        case 1:
            // 완료
            self.navigationController?.popViewController(animated: true)
        default:
            return
        }
    }
    
    private func setupCollectionView() {
        let layoutConfig = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        let layout = UICollectionViewCompositionalLayout.list(using: layoutConfig)
        
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(collectionView)
        collectionView.keyboardDismissMode = .onDrag
        
        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, Item> { cell, indexPath, item in
            let section = Section(rawValue: indexPath.section)
            if section == .textField {
                let textField = UITextField()
                textField.placeholder = item.title
                textField.clearButtonMode = .whileEditing
                textField.frame = CGRect(x: 0, y: 0, width: cell.bounds.width, height: cell.bounds.height)
                textField.delegate = self
                
                cell.contentView.addSubview(textField)
                
                textField.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    textField.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 20),
                    textField.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -10),
                    textField.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor)
                ])
            } else {
                var content = UIListContentConfiguration.valueCell()
                content.text = item.title
                content.secondaryText = self.selectedCategory?.title
                cell.contentConfiguration = content
                cell.accessories = [.disclosureIndicator()]
            }
        }
        
        dataSource = UICollectionViewDiffableDataSource<Section, Item>(collectionView: collectionView) { collectionView, indexPath, item in
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: item)
        }
        
        collectionView.delegate = self
    }
    
    private func updateSnapshot(section: Section) {
        var snapshot = dataSource.snapshot()
        snapshot.reloadSections([section])
        dataSource.apply(snapshot, animatingDifferences: false)
    }
    
    private func applySnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        snapshot.appendSections([.textField, .button])
        snapshot.appendItems([Item(title: "제목"), Item(title: "설명"), Item(title: "URL")], toSection: .textField)
        snapshot.appendItems([Item(title: "카테고리")], toSection: .button)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    private func presentViewController() {
        let storyboard = UIStoryboard(name: "SelectCategory", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "SelectCategoryViewController") as! SelectCategoryViewController
        vc.viewModel = SelectCategoryViewModel(initialCategory: selectedCategory)
        vc.completion = { [weak self] category in
            self?.selectedCategory = category
            self?.updateSnapshot(section: .button)
        }
        let navigationController = UINavigationController(rootViewController: vc)
        
        self.navigationController?.present(navigationController, animated: true)
    }
    
    private func hideKeyBoardWhenTappedScreen() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapHandler))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc func tapHandler() {
        keyboardWillHide.send()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        keyboardWillHide.send()
        return true
    }
    
    //        // viewdidload
    //        let url = "https://example.com" // 가져올 웹페이지 URL
    //        ogpFetcher.fetchOGPData(from: url) { [weak self] ogpData in
    //            DispatchQueue.main.async {
    //                self?.updateUI(with: ogpData)
    //            }
    //        }
    
    
    //    private func updateUI(with ogpData: OGPData?) {
    //        guard let ogpData = ogpData else { return }
    //
    ////        titleLabel.text = ogpData.title
    ////        descriptionLabel.text = ogpData.description
    //
    //        if let imageUrl = ogpData.imageUrl, let url = URL(string: imageUrl) {
    //            downloadImage(from: url) { image in
    //                DispatchQueue.main.async {
    ////                    self.imageView.image = image
    //                }
    //            }
    //        }
    //    }
    //
    //    private func downloadImage(from url: URL, completion: @escaping (UIImage?) -> Void) {
    //        URLSession.shared.dataTask(with: url) { data, _, _ in
    //            if let data = data {
    //                completion(UIImage(data: data))
    //            } else {
    //                completion(nil)
    //            }
    //        }.resume()
    //    }
    
    //    @IBAction func categoryButtonTapped(_ sender: Any) {
    //        let storyboard = UIStoryboard(name: "SelectCategory", bundle: nil)
    //        let vc = storyboard.instantiateViewController(withIdentifier: "SelectCategoryViewController") as! SelectCategoryViewController
    //        let navigationController = UINavigationController(rootViewController: vc)
    //
    //        self.navigationController?.present(navigationController, animated: true)
    //    }
}

extension AddInfoViewController: UICollectionViewDelegate, UITextFieldDelegate, UIGestureRecognizerDelegate {
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return Section(rawValue: indexPath.section) == .button
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        didSelect.send()
        collectionView.deselectItem(at: indexPath, animated: true)
    }
}




