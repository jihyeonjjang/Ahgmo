//
//  HomeViewModel.swift
//  Ahgmo
//
//  Created by 지현 on 3/10/25.
//

import Foundation
import Combine
import CoreData

final class HomeViewModel: NSObject, NSFetchedResultsControllerDelegate  {
    var categoryItems: CurrentValueSubject<[CategoryItemModel], Never>
    var infoItems: CurrentValueSubject<[InfoEntity], Never>
    var filteredItems: CurrentValueSubject<[InfoEntity], Never>
    var selectedInfo: CurrentValueSubject<InfoEntity?, Never>
    var selectedItems: CurrentValueSubject<Set<InfoEntity>, Never>
    var isSelectAll: CurrentValueSubject<Bool, Never>
    
    private var categoryController: NSFetchedResultsController<CategoryEntity>!
    private var infoController: NSFetchedResultsController<InfoEntity>!
    
    init(selectedInfo: InfoEntity? = nil) {
        self.categoryItems = CurrentValueSubject([])
        self.infoItems = CurrentValueSubject([])
        self.filteredItems = CurrentValueSubject([])
        self.selectedInfo = CurrentValueSubject(selectedInfo)
        self.selectedItems = CurrentValueSubject([])
        self.isSelectAll = CurrentValueSubject(false)
        super.init()
        fetchCategories()
        fetchInfos()
    }
    
    private func fetchCategories() {
        guard let fetchedResultsController = CoreDataManager.shared.fetch(for: CategoryEntity.self) else { return }
        self.categoryController = fetchedResultsController
        self.categoryController.delegate = self
        let entities: [CategoryEntity] = self.categoryController.fetchedObjects ?? []
        categoryItems.value = entities.map { CategoryItemModel(entity: $0, isSelected: false) }
    }
    
    private func fetchInfos() {
        guard let fetchedResultsController = CoreDataManager.shared.fetch(for: InfoEntity.self) else { return }
        self.infoController = fetchedResultsController
        self.infoController.delegate = self
        infoItems.value = self.infoController.fetchedObjects ?? []
        filteredItems.value = infoItems.value
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        if let updatedCategories = controller.fetchedObjects as? [CategoryEntity] {
            let entities: [CategoryEntity] = updatedCategories
            categoryItems.value = entities.map { CategoryItemModel(entity: $0, isSelected: false) }
//            categoryItems.send(updatedCategories)
        }
        
        if let updatedInfos = controller.fetchedObjects as? [InfoEntity] {
            infoItems.send(updatedInfos)
        }
    }
    
    enum Section: Int, CaseIterable {
        case category
        case information
    }
    
    enum Item: Hashable {
        case categoryItem(CategoryEntity)
        case informationItem(InfoEntity)
        
        var title: String {
            switch self {
            case .categoryItem(let data):
                return data.title!
            case .informationItem(let data):
                return data.title!
            }
        }
        
        var id: UUID {
            switch self {
            case .categoryItem(let data):
                return data.id!
            case .informationItem(let data):
                return data.id!
            }
        }
    }

    func didCategorySelect(id: UUID) {
        if let categoryIndex = categoryItems.value.firstIndex(where: { $0.id == id }) {
            categoryItems.value[categoryIndex].isSelected.toggle()
            categoryItems.value.indices
                .filter { $0 != categoryIndex }
                .forEach { categoryItems.value[$0].isSelected = false }
            if !categoryItems.value[categoryIndex].isSelected {
                filteredItems.send(infoItems.value)
            } else {
                let selectedCategory = categoryItems.value[categoryIndex]
                let filteredInfos = infoItems.value.filter { $0.categoryItem?.title == selectedCategory.title }
                filteredItems.send(filteredInfos)
            }
        }
    }
    
    func didInfoSelect(id: UUID) {
        if let info = infoItems.value.first(where: { $0.id == id }) {
            selectedInfo.send(info)
        }
    }
    
    func toggleItemSelection(_ item: InfoEntity) {
        var currentItems = selectedItems.value
        if currentItems.contains(item) {
            currentItems.remove(item)
        } else {
            currentItems.insert(item)
        }
        selectedItems.send(currentItems)
    }
    
    func toggleSelectAll() {
        let newIsSelectAll = !isSelectAll.value
        isSelectAll.send(newIsSelectAll)
        
        if newIsSelectAll {
            let allItems = Set(infoItems.value)
            selectedItems.send(allItems)
        } else {
            selectedItems.send([])
        }
    }
    
    func deleteItems() {
        // 삭제
    }
    
    func clearSelection() {
        selectedItems.send([])
        isSelectAll.send(false)
    }
    
    var selectedItemsCount: Int {
        selectedItems.value.count
    }
}
