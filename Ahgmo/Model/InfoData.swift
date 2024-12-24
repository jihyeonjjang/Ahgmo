//
//  InfoData.swift
//  Ahgmo
//
//  Created by 지현 on 12/23/24.
//

import Foundation

struct InfoData: Codable, Hashable {
    
//    let infoID: String
    let title: String
    let description: String
    let urlString: String
    let category: CategoryData
}

extension InfoData {
        static let list = [
            InfoData(title: "로제파스타 레시피", description: "편스토랑 류수영 레시피", urlString: "https://youtu.be/myYOcLR8Ni4?si=QYaZ3Fb0AwKKH-oD", category: CategoryData(title: "요리", emoji: "👩‍🍳")),
            InfoData(title: "호카 본디 8", description: "족저근막염에 좋은 신발", urlString: "https://youtu.be/xDHDEWG1kG4?si=fsXPT7DbxKMgzZEd", category: CategoryData(title: "신발", emoji: "👟")),
            InfoData(title: "다이소 트윙클팝 블러머드팟", description: "3:17 3호 베일모브", urlString: "https://youtu.be/Sz-v47t3aJc?si=eKSM9CmCkjVjqCvP", category: CategoryData(title: "화장품", emoji: "💄"))
        ]
}
