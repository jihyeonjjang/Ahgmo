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
    let categoryItems: CurrentValueSubject<[Category], Never>
    let initialCategory: CurrentValueSubject<Category?, Never>
    let selectedItem: CurrentValueSubject<Category?, Never>
    
    init(initialCategory: Category? = nil, selectedItem: Category? = nil) {
        self.categoryItems = CurrentValueSubject([])
        self.initialCategory = CurrentValueSubject(initialCategory)
        self.selectedItem = CurrentValueSubject(selectedItem)
        fetchCategories()
    }
    
    private func fetchCategories() {
        let categoryFetchRequest = NSFetchRequest<Category>(entityName: "Category")
        self.categoryItems.value = CoreDataManager.shared.fetchContext(request: categoryFetchRequest)
    }
    
    enum Section {
        case main
    }
    typealias Item = Category
    
    func didSelect(id: UUID) {
        if let category = categoryItems.value.first(where: { $0.id == id }) {
            selectedItem.send(category)
        }
    }
}
