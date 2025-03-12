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
            
            XCTAssertTrue(firstBCell.exists, "B cell이 존재하지 않습니다.")
            
            let filteredBCellLabel = firstBCell.staticTexts.element.label
            XCTAssertEqual(filteredBCellLabel, "로제파스타 레시피", "B cell의 필터링된 값이 예상과 다릅니다.")
        }
    }
}
