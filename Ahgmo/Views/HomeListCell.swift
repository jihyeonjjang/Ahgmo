//
//  HomeListCell.swift
//  Ahgmo
//
//  Created by 지현 on 12/23/24.
//

import UIKit

class HomeListCell: UICollectionViewCell {
    
    @IBOutlet weak var infoTitleLabel: UILabel!
    @IBOutlet weak var infoEmojiLabel: UILabel!

    func configure(item: InfoData) {
        infoTitleLabel.text = item.title
        infoEmojiLabel.text = item.category.emoji
    }
}
