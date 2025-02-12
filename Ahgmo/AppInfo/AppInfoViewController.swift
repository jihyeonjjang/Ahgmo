//
//  AppInfoViewController.swift
//  Ahgmo
//
//  Created by 지현 on 12/26/24.
//

import UIKit

class AppInfoViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationItem()
    }
    
    private func configureNavigationItem() {
        let cancelItem = UIBarButtonItem(
            title: "닫기",
            style: .plain,
            target: self,
            action: #selector(navigateToPage(_:))
        )
        
        navigationItem.rightBarButtonItem = cancelItem
    }
    
    @objc private func navigateToPage(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
}
