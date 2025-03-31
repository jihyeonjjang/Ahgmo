//
//  EditInfoViewModel.swift
//  Ahgmo
//
//  Created by 지현 on 3/10/25.
//

import Foundation
import Combine

final class EditInfoViewModel {
    let infoItem: CurrentValueSubject<Information, Never>
    let selectedItem: CurrentValueSubject<Category?, Never>
    
    init(infoItem: Information, selectedItem: Category? = nil) {
        self.infoItem = CurrentValueSubject(infoItem)
        self.selectedItem = CurrentValueSubject(selectedItem)
    }
    
    enum Section: Int, CaseIterable {
        case textField
        case button
    }
    
    struct Item: Hashable {
        let id = UUID()
        let contentText: String
        let placeholder: String
    }
    
    func didSelect() {
        selectedItem.send(infoItem.value.categoryItem!)
    }
}
