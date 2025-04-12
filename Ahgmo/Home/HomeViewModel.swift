//
//  HomeViewModel.swift
//  Ahgmo
//
//  Created by 지현 on 3/10/25.
//

import Foundation
import Combine
import CoreData

final class HomeViewModel {
    let categoryItems: CurrentValueSubject<[CategoryEntity], Never>
    let infoItems: CurrentValueSubject<[InfoEntity], Never>
    var filteredItems: CurrentValueSubject<[InfoEntity], Never>
    var selectedInfo: CurrentValueSubject<InfoEntity?, Never>
    var selectedItems: CurrentValueSubject<Set<InfoEntity>, Never>
    var isSelectAll: CurrentValueSubject<Bool, Never>
    
    init(selectedInfo: InfoEntity? = nil) {
        self.categoryItems = CurrentValueSubject([])
        self.infoItems = CurrentValueSubject([])
        self.filteredItems = CurrentValueSubject([])
        self.selectedInfo = CurrentValueSubject(selectedInfo)
        self.selectedItems = CurrentValueSubject([])
        self.isSelectAll = CurrentValueSubject(false)
        fetchDatas()
    }
    
    private func fetchDatas() {
        let categoryFetchRequest = NSFetchRequest<CategoryEntity>(entityName: "CategoryEntity")
        let informationsFetchRequest = NSFetchRequest<InfoEntity>(entityName: "InfoEntity")
        
        self.categoryItems.value = CoreDataManager.shared.fetchContext(request: categoryFetchRequest)
        let informations = CoreDataManager.shared.fetchContext(request: informationsFetchRequest)
        self.infoItems.value = informations
        self.filteredItems.value = informations
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
