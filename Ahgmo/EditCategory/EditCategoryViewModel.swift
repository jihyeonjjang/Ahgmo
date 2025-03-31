//
//  EditCategoryViewModel.swift
//  Ahgmo
//
//  Created by 지현 on 3/10/25.
//

import Foundation
import Combine

final class EditCategoryViewModel {
    let categoryItems: CurrentValueSubject<Category, Never>
    
    init(categoryItems: Category) {
        self.categoryItems = CurrentValueSubject(categoryItems)
    }
    
    enum Section {
        case main
    }
    
    typealias Item = Category
}
