//
//  NSManagedObject+TitleRepresentable.swift
//  Ahgmo
//
//  Created by 지현 on 3/31/25.
//

import Foundation
import CoreData

extension CategoryEntity: TitleRepresentable {
    var contextTitle: String {
        return self.title ?? ""
    }
}

extension InfoEntity: TitleRepresentable {
    var contextTitle: String {
        return self.title ?? ""
    }
}
