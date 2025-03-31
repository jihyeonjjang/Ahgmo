//
//  CategoryViewModel.swift
//  Ahgmo
//
//  Created by 지현 on 3/5/25.
//

import Foundation
import Combine
import CoreData

final class CategoryViewModel {
    let categoryItems: CurrentValueSubject<[Category], Never>
    let selectedItem: CurrentValueSubject<Category?, Never>
    
    init(selectedItem: Category? = nil) {
        self.categoryItems = CurrentValueSubject([])
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
    
    func deleteItem(id: UUID) {
        // 삭제
    }
}
