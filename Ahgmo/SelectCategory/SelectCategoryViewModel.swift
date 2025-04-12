//
//  SelectCategoryViewModel.swift
//  Ahgmo
//
//  Created by 지현 on 3/10/25.
//

import Foundation
import Combine
import CoreData

final class SelectCategoryViewModel: NSObject, NSFetchedResultsControllerDelegate {
    let categoryItems: CurrentValueSubject<[CategoryEntity], Never>
    let initialCategory: CurrentValueSubject<CategoryEntity?, Never>
    let selectedItem: CurrentValueSubject<CategoryEntity?, Never>
    
    private var categoryController: NSFetchedResultsController<CategoryEntity>!
    
    init(initialCategory: CategoryEntity? = nil, selectedItem: CategoryEntity? = nil) {
        self.categoryItems = CurrentValueSubject([])
        self.initialCategory = CurrentValueSubject(initialCategory)
        self.selectedItem = CurrentValueSubject(selectedItem)
        super.init()
        fetchCategories()
    }
    
    private func fetchCategories() {
        guard let fetchedResultsController = CoreDataManager.shared.fetch(for: CategoryEntity.self) else { return }
        self.categoryController = fetchedResultsController
        self.categoryController.delegate = self
        categoryItems.value = self.categoryController.fetchedObjects ?? []
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        if let updatedCategories = controller.fetchedObjects as? [CategoryEntity] {
            categoryItems.send(updatedCategories)
        }
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
