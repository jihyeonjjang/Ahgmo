//
//  EditInfoViewModel.swift
//  Ahgmo
//
//  Created by 지현 on 3/10/25.
//

import Foundation
import Combine

final class EditInfoViewModel {
    let infoItems: CurrentValueSubject<InfoData, Never>
    let selectedItem: CurrentValueSubject<CategoryData?, Never>
    
    init(infoItems: InfoData, selectedItem: CategoryData? = nil) {
        self.infoItems = CurrentValueSubject(infoItems)
        self.selectedItem = CurrentValueSubject(selectedItem)
    }
    
    enum Section: Int, CaseIterable {
        case title
        case details
        case url
        case button
        
        var title: String {
            switch self {
            case .title: return "제목"
            case .details: return "설명"
            case .url: return "URL"
            case .button: return "카테고리"
            }
        }
    }
    typealias Item = InfoData

    func didSelect() {
        selectedItem.send(infoItems.value.category)
    }
}
