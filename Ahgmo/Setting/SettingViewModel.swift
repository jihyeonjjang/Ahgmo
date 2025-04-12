//
//  SettingViewModel.swift
//  Ahgmo
//
//  Created by 지현 on 3/10/25.
//

import Foundation
import Combine
import CoreData

final class SettingViewModel: NSObject, NSFetchedResultsControllerDelegate {
    let sortingItems: CurrentValueSubject<[SortTypeEntity], Never>
    let serviceItems: CurrentValueSubject<[String], Never>
    let selectedItem: CurrentValueSubject<String?, Never>
    
    private var sortTypeController: NSFetchedResultsController<SortTypeEntity>!
    
    init(serviceItems: [String], selectedItem: String? = nil) {
        self.sortingItems = CurrentValueSubject([])
        self.serviceItems = CurrentValueSubject(serviceItems)
        self.selectedItem = CurrentValueSubject(selectedItem)
        super.init()
        fetchSortTypes()
    }
    
    private func fetchSortTypes() {
        guard let fetchedResultsController = CoreDataManager.shared.fetch(for: SortTypeEntity.self) else { return }
        self.sortTypeController = fetchedResultsController
        self.sortTypeController.delegate = self
        sortingItems.value = self.sortTypeController.fetchedObjects ?? []
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        if let updatedSortingItems = controller.fetchedObjects as? [SortTypeEntity] {
            sortingItems.send(updatedSortingItems)
        }
    }
    
    enum Section: Int, CaseIterable {
        case sort
        case service
    }
    
    enum Item: Hashable {
        case sortingItem(SortTypeEntity)
        case serviceItem(String)
        
        var title: String {
            switch self {
            case .sortingItem(let sortType):
                return sortType.title!
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
