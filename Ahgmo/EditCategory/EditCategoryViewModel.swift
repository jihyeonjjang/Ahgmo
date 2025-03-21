//
//  EditCategoryViewModel.swift
//  Ahgmo
//
//  Created by 지현 on 3/10/25.
//

import Foundation
import Combine

final class EditCategoryViewModel {
    let categoryItems: CurrentValueSubject<CategoryData, Never>
    
    init(categoryItems: CategoryData) {
        self.categoryItems = CurrentValueSubject(categoryItems)
    }
    
    enum Section {
        case main
    }
    
    typealias Item = CategoryData
}
