//
//  InfoData.swift
//  Ahgmo
//
//  Created by 지현 on 12/23/24.
//

import Foundation

struct InfoData: Codable, Hashable {
    
//    let infoID: UUID
    let title: String
    let description: String
    let urlString: String
    let category: CategoryData
}

extension InfoData {
        static let list = [
            InfoData(title: "로제파스타 레시피", description: "편스토랑 류수영 레시피", urlString: "https://youtu.be/myYOcLR8Ni4?si=QYaZ3Fb0AwKKH-oD", category: CategoryData(title: "요리")),
            InfoData(title: "호카 본디 8", description: "족저근막염에 좋은 신발", urlString: "https://youtu.be/xDHDEWG1kG4?si=fsXPT7DbxKMgzZEd", category: CategoryData(title: "신발")),
            InfoData(title: "다이소 트윙클팝 블러머드팟", description: "3:17 3호 베일모브", urlString: "https://youtu.be/Sz-v47t3aJc?si=eKSM9CmCkjVjqCvP", category: CategoryData(title: "화장품")),
            InfoData(title: "코스트코 베이글", description: "13번", urlString: "https://blog.naver.com/sum-merr/223288534510", category: CategoryData(title: "코스트코")),
            InfoData(title: "코스트코 샐러드", description: "14번", urlString: "https://blog.naver.com/sum-merr/223288534510", category: CategoryData(title: "코스트코")),
            InfoData(title: "무탠다드 코트", description: "발마칸, 99890원", urlString: "https://www.musinsa.com/products/4209266", category: CategoryData(title: "아우터")),
            InfoData(title: "디네댓 패딩", description: "덕다운, 191200원", urlString: "https://www.musinsa.com/products/4460714", category: CategoryData(title: "아우터")),
            InfoData(title: "뉴발란스 패딩", description: "구스다운, 299000원", urlString: "https://www.musinsa.com/products/4507921", category: CategoryData(title: "아우터")),
        ]
}
