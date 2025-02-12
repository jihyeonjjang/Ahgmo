//
//  SelectCategoryCell.swift
//  Ahgmo
//
//  Created by 지현 on 1/14/25.
//

import UIKit

class SelectCategoryCell: UICollectionViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    
    func configure(item: CategoryData) {
        titleLabel.text = item.title
    }
}
