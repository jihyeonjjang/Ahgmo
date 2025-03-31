//
//  SearchViewControllerTest.swift
//  AhgmoTests
//
//  Created by 지현 on 3/11/25.
//

import XCTest
import CoreData
@testable import Ahgmo

final class SearchTest: XCTestCase {
    
    var searchManager: SearchManager!
    
    override func setUpWithError() throws {
        let container = NSPersistentContainer(name: "Ahgmo")
        let description = container.persistentStoreDescriptions.first!
        description.type = NSInMemoryStoreType
        
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Failed to load Core Data stack: \(error)")
            }
        }
        
        searchManager = SearchManager()
    }
    
    override func tearDownWithError() throws {
        searchManager = nil
    }
    
    func testFilterItemsWithInfoData() throws {
        let fetchRequest = NSFetchRequest<InfoEntity>(entityName: "InfoEntity")
        let items = CoreDataManager.shared.fetchContext(request: fetchRequest)
        
        let result = searchManager.filterItems(items, with: "로제파스타 레시피")
        
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?.title, "로제파스타 레시피")
    }
    
    func testFilterItemsWithCategoryData() throws {
        let fetchRequest = NSFetchRequest<CategoryEntity>(entityName: "CategoryEntity")
        let items = CoreDataManager.shared.fetchContext(request: fetchRequest)
        
        let result = searchManager.filterItems(items, with: "코스트코")
        
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?.title, "코스트코")
    }
    
    func testFilterItemsWithEmptyQuery() throws {
        let fetchRequest = NSFetchRequest<InfoEntity>(entityName: "InfoEntity")
        let items = CoreDataManager.shared.fetchContext(request: fetchRequest)
        
        let result = searchManager.filterItems(items, with: "")
        
        XCTAssertEqual(result.count, items.count)
    }
    
    func testFilterItemsWithNoMatch() throws {
        let fetchRequest = NSFetchRequest<CategoryEntity>(entityName: "CategoryEntity")
        let items = CoreDataManager.shared.fetchContext(request: fetchRequest)
        
        let result = searchManager.filterItems(items, with: "파스타 레시피")
        
        XCTAssertEqual(result.count, 0)
    }
    
//    func testFilterItems_CaseInsensitive() throws {
//        let fetchRequest = NSFetchRequest<InfoEntity>(entityName: "InfoEntity")
//        let items = CoreDataManager.shared.fetchContext(request: fetchRequest)
//        
//        let result = searchManager.filterItems(items, with: "ApPlE")
//
//        
//        XCTAssertEqual(result.count, 1)
//        XCTAssertEqual(result.first?.title, "Apple")
//    }
    
}
