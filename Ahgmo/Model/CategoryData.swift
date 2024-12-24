//
//  CategoryData.swift
//  Ahgmo
//
//  Created by 지현 on 12/23/24.
//

import Foundation

struct CategoryData: Codable, Hashable {
    
    let title: String
    let emoji: String
}

extension CategoryData {
    static let list = [
        CategoryData(title: "요리", emoji: "👩‍🍳"),
        CategoryData(title: "신발", emoji: "👟"),
        CategoryData(title: "화장품", emoji: "💄")
    ]
}
