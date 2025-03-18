//
//  SortType.swift
//  Ahgmo
//
//  Created by 지현 on 3/13/25.
//

import Foundation

struct SortType: Codable, Hashable, Identifiable {
    let id: UUID
    let title: String
    var isSortedAscending: Bool
    
    init(id: UUID = UUID(), title: String, isSortedAscending: Bool = true) {
        self.id = id
        self.title = title
        self.isSortedAscending = isSortedAscending
    }
}

extension SortType {
    static let list = [
        SortType(title: "정보"),
        SortType(title: "카테고리")
    ]
}
