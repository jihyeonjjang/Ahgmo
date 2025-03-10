//
//  DetailInfoViewModel.swift
//  Ahgmo
//
//  Created by 지현 on 3/10/25.
//

import Foundation
import Combine

final class DetailInfoViewModel {
    let infoItems: CurrentValueSubject<InfoData, Never>
    let selectedItem: CurrentValueSubject<URL?, Never>
    
    init(infoItems: InfoData, selectedItem: URL? = nil) {
        self.infoItems = CurrentValueSubject(infoItems)
        self.selectedItem = CurrentValueSubject(selectedItem)
    }
    
    enum Section: Int, CaseIterable {
        case url
        case description
        
        var title: String {
            switch self {
            case .url: return "URL"
            case .description: return "설명"
            }
        }
    }
    typealias Item = InfoData
    
    func didSelect() {
        guard let url = URL(string: infoItems.value.urlString) else {
            return
        }
        selectedItem.send(url)
    }
}
