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
    let categoryItems: CurrentValueSubject<[CategoryEntity], Never>
    let selectedItem: CurrentValueSubject<CategoryEntity?, Never>
    
    init(selectedItem: CategoryEntity? = nil) {
        self.categoryItems = CurrentValueSubject([])
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
    
    func deleteItem(id: UUID) {
        // 삭제
    }
}
