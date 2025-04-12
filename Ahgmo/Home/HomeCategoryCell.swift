//
//  HomeButtonCell.swift
//  Ahgmo
//
//  Created by 지현 on 12/23/24.
//

import UIKit

class HomeCategoryCell: UICollectionViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    
    func configure(item: HomeViewModel.CategoryItemModel) {
        titleLabel.text = item.entity.title
        titleLabel.textColor = item.isSelected ? .systemBackground : .label
    }
}
