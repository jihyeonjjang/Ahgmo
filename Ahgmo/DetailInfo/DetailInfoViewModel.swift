//
//  DetailInfoViewModel.swift
//  Ahgmo
//
//  Created by 지현 on 3/10/25.
//

import Foundation
import Combine

final class DetailInfoViewModel {
    let infoItem: CurrentValueSubject<InfoEntity, Never>
    let selectedItem: CurrentValueSubject<URL?, Never>
    
    init(infoItem: InfoEntity, selectedItem: URL? = nil) {
        self.infoItem = CurrentValueSubject(infoItem)
        self.selectedItem = CurrentValueSubject(selectedItem)
    }
    
    enum Section: Int, CaseIterable {
        case details
        case url
        
        var title: String {
            switch self {
            case .details: return "설명"
            case .url: return "URL"
            }
        }
    }
    
    struct Item: Hashable {
        let id = UUID()
        let contentText: String
    }
    
    func didSelect() {
        guard let url = URL(string: infoItem.value.urlString!) else {
            return
        }
        selectedItem.send(url)
    }
    
    func deleteItem() {
        // 삭제
    }
}
