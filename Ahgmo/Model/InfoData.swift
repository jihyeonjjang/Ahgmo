//
//  InfoData.swift
//  Ahgmo
//
//  Created by 지현 on 12/23/24.
//

import Foundation

struct InfoData: Codable, Hashable, Identifiable, Searchable {
    let id: UUID
    var title: String
    var details: String
    var urlString: String
    var imageURL: String
    var category: CategoryData
    
    init(id: UUID = UUID(), title: String, details: String, urlString: String, imageURL: String, category: CategoryData) {
        self.id = id
        self.title = title
        self.details = details
        self.urlString = urlString
        self.imageURL = imageURL
        self.category = category
    }
}

extension InfoData {
        static var list = [
            InfoData(title: "로제파스타 레시피", details: "편스토랑 류수영 레시피", urlString: "https://youtu.be/myYOcLR8Ni4?si=QYaZ3Fb0AwKKH-oD", imageURL: "https://img.youtube.com/vi/myYOcLR8Ni4/mqdefault.jpg", category: CategoryData(title: "요리")),
            InfoData(title: "호카 본디 8", details: "족저근막염에 좋은 신발", urlString: "https://youtu.be/xDHDEWG1kG4?si=fsXPT7DbxKMgzZEd", imageURL: "https://img.youtube.com/vi/xDHDEWG1kG4/mqdefault.jpg", category: CategoryData(title: "신발")),
            InfoData(title: "다이소 트윙클팝 블러머드팟", details: "3:17 3호 베일모브", urlString: "https://youtu.be/Sz-v47t3aJc?si=eKSM9CmCkjVjqCvP", imageURL: "https://img.youtube.com/vi/Sz-v47t3aJc/mqdefault.jpg", category: CategoryData(title: "화장품")),
            InfoData(title: "코스트코 베이글", details: "13번", urlString: "https://blog.naver.com/sum-merr/223288534510", imageURL: "https://img.youtube.com/vi/myYOcLR8Ni4/mqdefault.jpg", category: CategoryData(title: "코스트코")),
            InfoData(title: "코스트코 샐러드", details: "14번", urlString: "https://blog.naver.com/sum-merr/223288534510", imageURL: "https://img.youtube.com/vi/myYOcLR8Ni4/mqdefault.jpg", category: CategoryData(title: "코스트코")),
            InfoData(title: "무탠다드 코트", details: "발마칸, 99890원", urlString: "https://www.musinsa.com/products/4209266", imageURL: "https://img.youtube.com/vi/myYOcLR8Ni4/mqdefault.jpg", category: CategoryData(title: "아우터")),
            InfoData(title: "디네댓 패딩", details: "덕다운, 191200원", urlString: "https://www.musinsa.com/products/4460714", imageURL: "https://img.youtube.com/vi/myYOcLR8Ni4/mqdefault.jpg", category: CategoryData(title: "아우터")),
            InfoData(title: "뉴발란스 패딩", details: "구스다운, 299000원", urlString: "https://www.musinsa.com/products/4507921", imageURL: "https://img.youtube.com/vi/myYOcLR8Ni4/mqdefault.jpg", category: CategoryData(title: "아우터")),
        ]
}
