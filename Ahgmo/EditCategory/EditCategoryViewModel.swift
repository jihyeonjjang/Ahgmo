//
//  EditCategoryViewModel.swift
//  Ahgmo
//
//  Created by 지현 on 3/10/25.
//

import Foundation
import Combine
import CoreData

final class EditCategoryViewModel {
    let categoryID: CurrentValueSubject<UUID, Never>
    let categoryItem: CurrentValueSubject<CategoryEntity?, Never>
    let userInput: CurrentValueSubject<String, Never>
    
    init(categoryID: UUID, categoryItem: CategoryEntity? = nil) {
        self.categoryID = CurrentValueSubject(categoryID)
        self.categoryItem = CurrentValueSubject(categoryItem)
        self.userInput = CurrentValueSubject("")
        fetchCategory(id: categoryID)
    }

    private func fetchCategory(id: UUID) {
        let predicate = NSPredicate(format: "id == %@", id as CVarArg)
        guard let category = CoreDataManager.shared.fetchSingleEntity(ofType: CategoryEntity.self, withPredicate: predicate) else { return }
        categoryItem.value = category
    }

    enum Section {
        case main
    }
    
    typealias Item = CategoryEntity
}
