//
//  AddCategoryViewModel.swift
//  Ahgmo
//
//  Created by 지현 on 4/1/25.
//

import Foundation
import Combine

final class AddCategoryViewModel {
    let userInput: CurrentValueSubject<String, Never>
    
    init() {
        self.userInput = CurrentValueSubject("")
    }
    
    enum Section {
        case main
    }
    
    typealias Item = String
    
    func saveCategory() {
        guard !userInput.value.isEmpty else { return }
        CoreDataManager.shared.saveCategory(title: userInput.value)
    }
}
