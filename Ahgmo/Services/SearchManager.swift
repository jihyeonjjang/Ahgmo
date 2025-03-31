//
//  SearchManager.swift
//  Ahgmo
//
//  Created by 지현 on 3/11/25.
//

import Foundation
import CoreData

class SearchManager {
    func filterItems<T: NSManagedObject & TitleRepresentable>(_ items: [T], with query: String) -> [T] {
        guard !query.isEmpty else { return items }
        return items.filter { $0.contextTitle.lowercased().contains(query.lowercased()) }
    }
}
