//
//  SortData.swift
//  Ahgmo
//
//  Created by 지현 on 2/1/25.
//

import Foundation

struct SortData: Codable, Hashable {
    let title: String
//    let sortType: String
}

extension SortData {
    static let list = [
        SortData(title: "리스트"),
        SortData(title: "카테고리")
    ]
}
