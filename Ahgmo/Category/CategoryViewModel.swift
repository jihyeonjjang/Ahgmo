//
//  CategoryViewModel.swift
//  Ahgmo
//
//  Created by 지현 on 3/5/25.
//

import Foundation
import Combine
import CoreData

final class CategoryViewModel: NSObject, NSFetchedResultsControllerDelegate {
    let categoryItems: CurrentValueSubject<[CategoryEntity], Never>
    let selectedItem: CurrentValueSubject<UUID?, Never>
    
    private var categoryController: NSFetchedResultsController<CategoryEntity>!
    
    init(selectedItem: UUID? = nil) {
        self.categoryItems = CurrentValueSubject([])
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
        selectedItem.send(id)
    }
    
    func deleteItem(id: UUID) {
        // 삭제
    }
}
