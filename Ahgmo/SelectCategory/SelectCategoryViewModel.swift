//
//  SelectCategoryViewModel.swift
//  Ahgmo
//
//  Created by 지현 on 3/10/25.
//

import Foundation
import Combine
import CoreData

final class SelectCategoryViewModel {
    let categoryItems: CurrentValueSubject<[CategoryEntity], Never>
    let initialCategory: CurrentValueSubject<CategoryEntity?, Never>
    let selectedItem: CurrentValueSubject<CategoryEntity?, Never>
    
    init(initialCategory: CategoryEntity? = nil, selectedItem: CategoryEntity? = nil) {
        self.categoryItems = CurrentValueSubject([])
        self.initialCategory = CurrentValueSubject(initialCategory)
        self.selectedItem = CurrentValueSubject(selectedItem)
        fetchCategories()
    }
    
    private func fetchCategories() {
        let categoryFetchRequest = NSFetchRequest<CategoryEntity>(entityName: "CategoryEntity")
        self.categoryItems.value = CoreDataManager.shared.fetchContext(request: categoryFetchRequest)
    }
    
    enum Section {
        case main
    }
    typealias Item = CategoryEntity
    
    func didSelect(id: UUID) {
        if let category = categoryItems.value.first(where: { $0.id == id }) {
            selectedItem.send(category)
        }
    }
}
