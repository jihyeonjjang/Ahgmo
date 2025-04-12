//
//  CoreDataUpdateTest.swift
//  AhgmoTests
//
//  Created by 지현 on 4/9/25.
//

import XCTest
import CoreData
@testable import Ahgmo

final class CoreDataUpdateTest: XCTestCase {
    private var categoryController: NSFetchedResultsController<CategoryEntity>!
    private var infoController: NSFetchedResultsController<InfoEntity>!
    
    override func setUpWithError() throws {
        
    }

    override func tearDownWithError() throws {

    }
    
    func saveEntity() -> [UUID] {
        guard let categoryId = CoreDataManager.shared.saveCategory(title: "Test Category") else { return [] }

        guard let infoId = CoreDataManager.shared.saveInfo(title: "Test Information", details: "Test Description", urlString: "https://example.com" , imageURL: "https://example2.com", categoryID: categoryId) else { return [] }
        
        return [categoryId, infoId]
    }

    func testEditCategoryEntity() throws {
        let idArray = saveEntity()
        
        let predicate = NSPredicate(format: "id == %@", idArray[0] as CVarArg)
        CoreDataManager.shared.updateCategory(id: idArray[0], title: "Test Category2")
        
        let results = CoreDataManager.shared.fetchSingleEntity(ofType: CategoryEntity.self, withPredicate: predicate)
        
        XCTAssertEqual(results?.title, "Test Category2", "title error")
    }
    
    func testEditInfoEntity() throws {
        let idArray = saveEntity()
        
        let predicate = NSPredicate(format: "id == %@", idArray[1] as CVarArg)
        CoreDataManager.shared.updateInfo(id: idArray[1], title: "Test Information2", details: "Test Description2", urlString: "https://example2.com", imageURL: "https://imageexample2.com", categoryID: idArray[0])
        
        let results = CoreDataManager.shared.fetchSingleEntity(ofType: InfoEntity.self, withPredicate: predicate)
        
        XCTAssertEqual(results?.title, "Test Information2", "title error")
        XCTAssertEqual(results?.categoryItem?.title, "Test Category", "category title error")
    }

}
