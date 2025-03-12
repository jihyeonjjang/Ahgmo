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
    
    let selectedCategory: CurrentValueSubject<CategoryData?, Never>
    let selectedInfo: CurrentValueSubject<InfoData?, Never>
    
    let selectedItems: CurrentValueSubject<Set<InfoData>, Never>
    let isSelectAll: CurrentValueSubject<Bool, Never>
    
    init(categoryItems: [CategoryData], infoItems: [InfoData], selectedCategory: CategoryData? = nil, selectedInfo: InfoData? = nil) {
        self.categoryItems = CurrentValueSubject(categoryItems)
        self.infoItems = CurrentValueSubject(infoItems)
        self.selectedCategory = CurrentValueSubject(selectedCategory)
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
        if let category = categoryItems.value.first(where: { $0.id == id }) {
            selectedCategory.send(category)
        }
    }
    
    func didInfoSelect(id: UUID) {
        if let info = infoItems.value.first(where: { $0.id == id }) {
            selectedInfo.send(info)
        }
//        let selectedInfo = infoItems.value[indexPath.item]
//        self.selectedInfo.send(selectedInfo)
    }
    
    func toggleItemSelection(_ item: InfoData, isEditing: Bool) {
        if isEditing {
            var currentItems = selectedItems.value
            if currentItems.contains(item) {
                currentItems.remove(item)
            } else {
                currentItems.insert(item)
            }
            selectedItems.send(currentItems)
        } else {
            selectedInfo.send(item)
        }
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
