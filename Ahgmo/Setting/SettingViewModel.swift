//
//  SettingViewModel.swift
//  Ahgmo
//
//  Created by 지현 on 3/10/25.
//

import Foundation
import Combine

final class SettingViewModel {
    let sortingItems: CurrentValueSubject<[SortType], Never>
    let serviceItems: CurrentValueSubject<[String], Never>
    let selectedItem: CurrentValueSubject<String?, Never>
    
    init(sortingItems: [SortType], serviceItems: [String], selectedItem: String? = nil) {
        self.sortingItems = CurrentValueSubject(sortingItems)
        self.serviceItems = CurrentValueSubject(serviceItems)
        self.selectedItem = CurrentValueSubject(selectedItem)
    }
    
    enum Section: Int, CaseIterable {
        case sort
        case service
    }
    
    enum Item: Hashable {
        case sortingItem(SortType)
        case serviceItem(String)
        
        var title: String {
            switch self {
            case .sortingItem(let sortType):
                return sortType.title
            case .serviceItem(let serviceName):
                return serviceName
            }
        }
        
        var isSortedAscending: Bool? {
            switch self {
            case .sortingItem(let sortType):
                return sortType.isSortedAscending
            case .serviceItem(_):
                return nil
            }
        }
    }
    
    func didSelect(at indexPath: IndexPath) {
        let item = serviceItems.value[indexPath.row]
        selectedItem.send(item)
    }
    
    func updateSortOption() {
        // sortOption Update
        
//    func updateSortOption(id: UUID, to isAscending: Bool) {
//        var updatedItems = sortingItems.value
//        if let index = updatedItems.firstIndex(where: { $0.id == id }) {
//            updatedItems[index].isSortedAscending = isAscending
//            sortingItems.send(updatedItems)
//        }
    }
}
