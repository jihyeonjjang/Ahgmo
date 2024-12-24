//
//  HomeButtonCell.swift
//  Ahgmo
//
//  Created by 지현 on 12/23/24.
//

import UIKit

class HomeCategoryCell: UICollectionViewCell {
    
    @IBOutlet weak var categoryButton: UIButton!
    
    func configure(item: CategoryData) {
        categoryButton.setTitle(item.title, for: .normal)
    }
}
