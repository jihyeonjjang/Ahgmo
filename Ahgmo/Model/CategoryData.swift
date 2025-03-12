//
//  CategoryData.swift
//  Ahgmo
//
//  Created by 지현 on 12/23/24.
//

import Foundation

struct CategoryData: Codable, Hashable, Identifiable, Searchable {
    let id: UUID
    let title: String
    var isSelected: Bool = false
//    let emoji: String
    
    init(id: UUID = UUID(), title: String, isSelected: Bool = false) {
        self.id = id
        self.title = title
        self.isSelected = isSelected
    }
}

extension CategoryData {
    static let list = [
        CategoryData(title: "요리"),
        CategoryData(title: "신발"),
        CategoryData(title: "화장품"),
        CategoryData(title: "코스트코"),
        CategoryData(title: "악세서리"),
        CategoryData(title: "아우터"),
        CategoryData(title: "상의"),
        CategoryData(title: "하의"),
        CategoryData(title: "원피스"),
        CategoryData(title: "꿀팁"),
        CategoryData(title: "편의점"),
        CategoryData(title: "음식점"),
    ]
}
