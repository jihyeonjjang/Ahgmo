//
//  CoreDataSaveTest.swift
//  AhgmoTests
//
//  Created by 지현 on 3/31/25.
//

import XCTest
import CoreData
@testable import Ahgmo

final class CoreDataSaveTest: XCTestCase {
    var managedObjectContext: NSManagedObjectContext!
    override func setUpWithError() throws {
        managedObjectContext = CoreDataManager.shared.context
    }
    
    override func tearDownWithError() throws {
        managedObjectContext = nil
        
    }
    
    func testSaveCategoryEntity() throws {
        CoreDataManager.shared.saveCategory(title: "Test Category", isSelected: false)
        
        let fetchRequest = NSFetchRequest<CategoryEntity>(entityName: "CategoryEntity")
        let results = CoreDataManager.shared.fetchContext(request: fetchRequest)
        
        XCTAssertEqual(results.count, 1, "count error")
        XCTAssertEqual(results.first?.title, "Test Category", "title error")
    }
    
    func testSaveInfoEntity() throws {
        guard let savedCategoryID = CoreDataManager.shared.saveCategory(title: "Test Category", isSelected: false) else { return }
        
        CoreDataManager.shared.saveInfo(title: "Test Information", details: "Test Description", urlString: "https://example.com" , imageURL: "https://example2.com", categoryID: savedCategoryID)
        
        let fetchRequest: NSFetchRequest<InfoEntity> = InfoEntity.fetchRequest()
        let results = try managedObjectContext.fetch(fetchRequest)
        
        XCTAssertEqual(results.count, 1, "count error")
        XCTAssertEqual(results.first?.title, "Test Information", "title error")
        XCTAssertEqual(results.first?.categoryItem?.title, "Test Category", "category title error")
    }
}
