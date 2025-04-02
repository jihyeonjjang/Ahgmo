//
//  CategoryFilterTest.swift
//  AhgmoUITests
//
//  Created by 지현 on 3/12/25.
//

import XCTest

final class CategoryFilterTest: XCTestCase {
    let app = XCUIApplication()
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launch()
    }
    
    func testCellTapFiltersList() {
        func testFilteringWithCellSelection() {
            let collectionView = app.collectionViews["ItemCollectionView"]
            let firstACell = collectionView.cells.element(boundBy: 0)
            let firstBCell = collectionView.cells.element(boundBy: 1)
            
            firstACell.tap()
            
            XCTAssertTrue(firstBCell.exists, "exist error")
            
            let filteredBCellLabel = firstBCell.staticTexts.element.label
            XCTAssertEqual(filteredBCellLabel, "로제파스타 레시피", "expected value error")
        }
    }
}
