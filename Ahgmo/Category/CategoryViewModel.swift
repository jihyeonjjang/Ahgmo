//
//  CategoryViewModel.swift
//  Ahgmo
//
//  Created by 지현 on 3/5/25.
//

import Foundation
import Combine

final class CategoryViewModel {
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

    func didSelect(id: UUID) {
        if let category = categoryItems.value.first(where: { $0.id == id }) {
            selectedItem.send(category)
        }
    }
    
    func deleteItem(id: UUID) {
        // 삭제
        //        viewModel.categoryItems.remove(at: indexPath.item)
    }
}
