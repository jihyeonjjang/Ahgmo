//
//  HomeButtonCell.swift
//  Ahgmo
//
//  Created by 지현 on 12/23/24.
//

import UIKit

class HomeCategoryCell: UICollectionViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    
    func configure(item: CategoryEntity) {
        titleLabel.text = item.title
        titleLabel.textColor = item.isSelected ? .systemBackground : .label
    }
}
