//
//  CategoryCell.swift
//  Ahgmo
//
//  Created by 지현 on 1/17/25.
//

import UIKit

class CategoryCell: UICollectionViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    
    func configure(item: CategoryData) {
        titleLabel.text = item.title
    }
}
