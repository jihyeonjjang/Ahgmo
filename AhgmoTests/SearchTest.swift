//
//  SearchViewControllerTest.swift
//  AhgmoTests
//
//  Created by 지현 on 3/11/25.
//

import XCTest
@testable import Ahgmo

final class SearchTest: XCTestCase {
    
    var searchManager: SearchManager!
    
    
    override func setUpWithError() throws {
        searchManager = SearchManager()
        
    }
    
    override func tearDownWithError() throws {
        searchManager = nil
    }
    
    func testFilterItemsWithInfoData() throws {
        let items = InfoData.list
        
        let result = searchManager.filterItems(items, with: "apple")
        
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?.title, "Apple")
    }
    
    func testFilterItemsWithCategoryData() throws {
        let items = CategoryData.list
        
        let result = searchManager.filterItems(items, with: "HELLO")
        
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?.title, "Hello")
    }
    
    func testFilterItemsWithEmptyQuery() throws {
        let items = InfoData.list
        
        let result = searchManager.filterItems(items, with: "")
        
        XCTAssertEqual(result.count, items.count)
    }
    
    func testFilterItemsWithNoMatch() throws {
        let items = CategoryData.list
        
        let result = searchManager.filterItems(items, with: "orange")
        
        XCTAssertEqual(result.count, 0)
    }
    
    func testFilterItems_CaseInsensitive() {
        let items = InfoData.list
        let result = searchManager.filterItems(items, with: "ApPlE")
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?.title, "Apple")
    }
    
}
