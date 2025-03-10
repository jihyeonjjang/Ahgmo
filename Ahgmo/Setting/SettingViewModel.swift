//
//  SettingViewModel.swift
//  Ahgmo
//
//  Created by 지현 on 3/10/25.
//

import Foundation
import Combine

final class SettingViewModel {
    let setData: CurrentValueSubject<[Section: [Item]], Never>
    let isSortedAscending: CurrentValueSubject<Bool, Never>
    let selectedItem: CurrentValueSubject<Item?, Never>
    
    init(setData: [Section : [Item]], isSortedAscending: Bool, selectedItem: Item? = nil) {
        self.setData = CurrentValueSubject(setData)
        self.isSortedAscending = CurrentValueSubject(isSortedAscending)
        self.selectedItem = CurrentValueSubject(selectedItem)
    }
    
    enum Section: Int, CaseIterable {
        case sort
        case service
    }
    
    struct Item: Hashable {
        enum ItemType {
            case info
            case category
            case appInfo
            case contact
        }
        
        let title: String
        let type: ItemType
    }
    
    func didSelect(at indexPath: IndexPath) {
        if let section = Section(rawValue: indexPath.section), let items = setData.value[section] {
            let item = items[indexPath.row]
            selectedItem.send(item)
        }
    }
}
