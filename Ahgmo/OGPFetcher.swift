//
//  OGPFetcher.swift
//  Ahgmo
//
//  Created by 지현 on 2/5/25.
//

import Foundation
import SwiftSoup

struct OGPData {
    let title: String
    let description: String
    let imageUrl: String?
    let siteUrl: String
}

final class OGPFetcher {
    func fetchOGPData(from url: String, completion: @escaping ((OGPData?) -> Void)) {
        guard let url = URL(string: url) else {
            completion(nil)
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil, let html = String(data: data, encoding: .utf8) else {
                completion(nil)
                return
            }
            
            do {
                let document = try SwiftSoup.parse(html)
                
                let title = try? document.select("meta[property=og:title]").attr("content")
                let description = try? document.select("meta[property=og:description]").attr("content")
                let imageUrl = try? document.select("meta[property=og:image]").attr("content")
                let siteUrl = try? document.select("meta[property=og:url]").attr("content")
                
                let ogpData = OGPData(title: title ?? "제목 없음",
                                      description: description ?? "설명 없음",
                                      imageUrl: imageUrl,
                                      siteUrl: siteUrl ?? url.absoluteString)
                
                completion(ogpData)
                
            } catch {
                print("Error parsing HTML: \(error)")
                completion(nil)
            }
        }
        task.resume()
    }
}
