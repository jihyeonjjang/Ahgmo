//
//  ServiceData.swift
//  Ahgmo
//
//  Created by 지현 on 2/1/25.
//

import Foundation

struct ServiceData: Codable, Hashable {

    let title: String
}

extension ServiceData {
    static let list = [
        ServiceData(title: "앱정보"),
        ServiceData(title: "문의하기")
    ]
}
