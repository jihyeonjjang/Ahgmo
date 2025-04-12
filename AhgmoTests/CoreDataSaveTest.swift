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
    private var categoryController: NSFetchedResultsController<CategoryEntity>!
    private var infoController: NSFetchedResultsController<InfoEntity>!
    
    override func setUpWithError() throws {

    }
    
    override func tearDownWithError() throws {

    }
    
    func testSaveCategoryEntity() throws {
        CoreDataManager.shared.saveCategory(title: "Test Category", isSelected: false)
        
        guard let fetchedResultsController = CoreDataManager.shared.fetch(for: CategoryEntity.self) else { return }
        self.categoryController = fetchedResultsController
        let results = self.categoryController.fetchedObjects ?? []
        
        XCTAssertEqual(results.count, 1, "count error")
        XCTAssertEqual(results.first?.title, "Test Category", "title error")
    }
    
    func testSaveInfoEntity() throws {
        guard let savedCategoryID = CoreDataManager.shared.saveCategory(title: "Test Category", isSelected: false) else { return }
        
        CoreDataManager.shared.saveInfo(title: "Test Information", details: "Test Description", urlString: "https://example.com" , imageURL: "https://example2.com", categoryID: savedCategoryID)
        
        guard let fetchedResultsController = CoreDataManager.shared.fetch(for: InfoEntity.self) else { return }
        self.infoController = fetchedResultsController
        let results = self.infoController.fetchedObjects ?? []
        
        XCTAssertEqual(results.count, 1, "count error")
        XCTAssertEqual(results.first?.title, "Test Information", "title error")
        XCTAssertEqual(results.first?.categoryItem?.title, "Test Category", "category title error")
    }
}
