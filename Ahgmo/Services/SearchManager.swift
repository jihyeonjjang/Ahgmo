//
//  SearchManager.swift
//  Ahgmo
//
//  Created by 지현 on 3/11/25.
//

import Foundation

class SearchManager {
    func filterItems<T: Searchable>(_ items: [T], with query: String) -> [T] {
        guard !query.isEmpty else { return items }
        return items.filter { $0.title.lowercased().contains(query.lowercased()) }
    }
}
