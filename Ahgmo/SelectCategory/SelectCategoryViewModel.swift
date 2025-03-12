//
//  SelectCategoryViewModel.swift
//  Ahgmo
//
//  Created by 지현 on 3/10/25.
//

import Foundation
import Combine

final class SelectCategoryViewModel {
    let categoryItems: CurrentValueSubject<[CategoryData], Never>
    let selectedItem: CurrentValueSubject<CategoryData?, Never>
    
    init(categoryItems: [CategoryData], selectedItem: CategoryData? = nil) {
        self.categoryItems = CurrentValueSubject(categoryItems)
        self.selectedItem = CurrentValueSubject(selectedItem)
    }
    
    enum Section {
        case main
    }
    typealias Item = CategoryData
    
    func didSelect(at indexPath: IndexPath) {
        selectedItem.send(categoryItems.value[indexPath.item])
    }
    
    func didSelect(id: UUID) {
        if let category = categoryItems.value.first(where: { $0.id == id }) {
            selectedItem.send(category)
        }
    }
}
