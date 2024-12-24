//
//  CategoryData.swift
//  Ahgmo
//
//  Created by 지현 on 12/23/24.
//

import Foundation

struct CategoryData: Codable, Hashable {

    let title: String
//    let emoji: String
}

extension CategoryData {
    static let list = [
        CategoryData(title: "모두보기"),
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
