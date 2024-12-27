//
//  HomeListCell.swift
//  Ahgmo
//
//  Created by 지현 on 12/27/24.
//

import UIKit

class HomeListCell: UITableViewCell {

    @IBOutlet weak var infoTitleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(item: InfoData) {
        infoTitleLabel.text = item.title
    }

}
