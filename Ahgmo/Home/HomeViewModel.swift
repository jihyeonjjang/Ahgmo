//
//  HomeViewModel.swift
//  Ahgmo
//
//  Created by 지현 on 3/10/25.
//

import Foundation
import Combine

final class HomeViewModel {
    let categoryItems: CurrentValueSubject<[CategoryData], Never>
    let infoItems: CurrentValueSubject<[InfoData], Never>
    var filteredItems: CurrentValueSubject<[InfoData], Never>
    var selectedInfo: CurrentValueSubject<InfoData?, Never>
    var selectedItems: CurrentValueSubject<Set<InfoData>, Never>
    var isSelectAll: CurrentValueSubject<Bool, Never>
    
    init(categoryItems: [CategoryData], infoItems: [InfoData], filteredItems: [InfoData], selectedInfo: InfoData? = nil) {
        self.categoryItems = CurrentValueSubject(categoryItems)
        self.infoItems = CurrentValueSubject(infoItems)
        self.filteredItems = CurrentValueSubject(filteredItems)
        self.selectedInfo = CurrentValueSubject(selectedInfo)
        self.selectedItems = CurrentValueSubject([])
        self.isSelectAll = CurrentValueSubject(false)
    }
    
    enum Section: Int, CaseIterable {
        case category
        case information
    }
    
    enum Item: Hashable {
        case categoryItem(CategoryData)
        case informationItem(InfoData)
        
        var title: String {
            switch self {
            case .categoryItem(let data):
                return data.title
            case .informationItem(let data):
                return data.title
            }
        }
        
        var id: UUID {
            switch self {
            case .categoryItem(let data):
                return data.id
            case .informationItem(let data):
                return data.id
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
                let filteredInfos = infoItems.value.filter { $0.category.title == selectedCategory.title }
                filteredItems.send(filteredInfos)
            }
        }
    }
    
    func didInfoSelect(id: UUID) {
        if let info = infoItems.value.first(where: { $0.id == id }) {
            selectedInfo.send(info)
        }
    }
    
    func toggleItemSelection(_ item: InfoData) {
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
    
    func clearSelection() {
        selectedItems.send([])
        isSelectAll.send(false)
    }
    
    var selectedItemsCount: Int {
        selectedItems.value.count
    }
}
