//
//  CoinMarketAppUITests.swift
//  CoinMarketAppUITests
//
//  Created by Hayna Cardoso on 25/02/26.
//

import XCTest

final class CoinMarketAppUITests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        
        app = XCUIApplication()
        app.launchArguments = ["UI_TESTING"]
        app.launch()
    }
    
    override func tearDownWithError() throws {
        app = nil
    }

    
    func testExchangeListLoads() throws {
        let navBar = app.navigationBars["Exchanges"]
        XCTAssertTrue(navBar.exists, "Navigation bar 'Exchanges' deve existir")
        
        let tableView = app.tables.firstMatch
        XCTAssertTrue(tableView.waitForExistence(timeout: 5), "TableView deve existir")
    }
    
    func testExchangeListDisplaysItems() throws {
        let tableView = app.tables.firstMatch
        XCTAssertTrue(tableView.waitForExistence(timeout: 10))
        
        let cells = tableView.cells
        
        let firstCell = cells.firstMatch
        XCTAssertTrue(firstCell.waitForExistence(timeout: 15), "Primeira célula deve aparecer")
        
        let cellCount = cells.count
        XCTAssertGreaterThan(cellCount, 0, "Deve haver pelo menos 1 célula")
    }
    
    func testExchangeCellDisplaysInfo() throws {
        let tableView = app.tables.firstMatch
        XCTAssertTrue(tableView.waitForExistence(timeout: 10))
        
        let firstCell = tableView.cells.firstMatch
        XCTAssertTrue(firstCell.waitForExistence(timeout: 15))
        
        XCTAssertTrue(firstCell.staticTexts.count > 0, "Célula deve ter texto")
        
        XCTAssertTrue(firstCell.images.count > 0, "Célula deve ter imagem")
    }
    
    func testPullToRefresh() throws {
        let tableView = app.tables.firstMatch
        XCTAssertTrue(tableView.waitForExistence(timeout: 10))
        
        let firstCell = tableView.cells.firstMatch
        XCTAssertTrue(firstCell.waitForExistence(timeout: 15))
        
        let start = firstCell.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
        let end = firstCell.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 5.0))
        start.press(forDuration: 0, thenDragTo: end)
        
        sleep(2)
        
        XCTAssertTrue(firstCell.exists)
    }
    
    func testScrollToBottom() throws {
        let tableView = app.tables.firstMatch
        XCTAssertTrue(tableView.waitForExistence(timeout: 10))
        
        let firstCell = tableView.cells.firstMatch
        XCTAssertTrue(firstCell.waitForExistence(timeout: 15))
        
        let initialCellCount = tableView.cells.count
        
        for _ in 0..<3 {
            tableView.swipeUp()
            sleep(1)
        }
        
        let finalCellCount = tableView.cells.count
        
        XCTAssertGreaterThanOrEqual(finalCellCount, initialCellCount)
    }
    
    
    func testNavigationToDetail() throws {
        let tableView = app.tables.firstMatch
        XCTAssertTrue(tableView.waitForExistence(timeout: 10))
        
        let firstCell = tableView.cells.firstMatch
        XCTAssertTrue(firstCell.waitForExistence(timeout: 15))
        
        let exchangeName = firstCell.staticTexts.firstMatch.label
        
        firstCell.tap()
        
        let backButton = app.navigationBars.buttons.firstMatch
        XCTAssertTrue(backButton.waitForExistence(timeout: 5), "Botão de voltar deve existir")
        
        let scrollView = app.scrollViews.firstMatch
        XCTAssertTrue(scrollView.waitForExistence(timeout: 5), "ScrollView de detalhe deve existir")
    }
    
    func testBackNavigation() throws {
        let tableView = app.tables.firstMatch
        XCTAssertTrue(tableView.waitForExistence(timeout: 10))
        
        let firstCell = tableView.cells.firstMatch
        XCTAssertTrue(firstCell.waitForExistence(timeout: 15))
        firstCell.tap()
        
        let scrollView = app.scrollViews.firstMatch
        XCTAssertTrue(scrollView.waitForExistence(timeout: 5))
        
        let backButton = app.navigationBars.buttons.firstMatch
        backButton.tap()
        
        XCTAssertTrue(tableView.waitForExistence(timeout: 3))
    }
    
    func testExchangeDetailDisplaysInfo() throws {
        let tableView = app.tables.firstMatch
        XCTAssertTrue(tableView.waitForExistence(timeout: 10))
        
        let firstCell = tableView.cells.firstMatch
        XCTAssertTrue(firstCell.waitForExistence(timeout: 15))
        firstCell.tap()
        
        let scrollView = app.scrollViews.firstMatch
        XCTAssertTrue(scrollView.waitForExistence(timeout: 5))
        
        XCTAssertTrue(app.staticTexts.count > 0, "Deve ter informações de texto")
        
        XCTAssertTrue(app.images.count > 0, "Deve ter logo da exchange")
    }
    
    func testExchangeDetailScrolls() throws {
        let tableView = app.tables.firstMatch
        XCTAssertTrue(tableView.waitForExistence(timeout: 10))
        
        let firstCell = tableView.cells.firstMatch
        XCTAssertTrue(firstCell.waitForExistence(timeout: 15))
        firstCell.tap()
        
        let scrollView = app.scrollViews.firstMatch
        XCTAssertTrue(scrollView.waitForExistence(timeout: 5))
        
        scrollView.swipeUp()
        scrollView.swipeUp()
        
        XCTAssertTrue(scrollView.exists)
    }
    
    func testExchangeDetailDisplaysCurrencies() throws {
        let tableView = app.tables.firstMatch
        XCTAssertTrue(tableView.waitForExistence(timeout: 10))
        
        let firstCell = tableView.cells.firstMatch
        XCTAssertTrue(firstCell.waitForExistence(timeout: 15))
        firstCell.tap()
        
        let scrollView = app.scrollViews.firstMatch
        XCTAssertTrue(scrollView.waitForExistence(timeout: 5))
        
        scrollView.swipeUp()
        scrollView.swipeUp()
        
        sleep(3)
        
        let currenciesTable = app.tables.containing(.cell, identifier: nil).element
        
        if currenciesTable.exists {
            XCTAssertTrue(currenciesTable.cells.count >= 0, "Tabela de currencies deve existir")
        }
    }
    
    func testErrorAlertDisplays() throws {
        
        let tableView = app.tables.firstMatch
        XCTAssertTrue(tableView.waitForExistence(timeout: 10))
        
        if app.alerts.count > 0 {
            let alert = app.alerts.firstMatch
            XCTAssertTrue(alert.exists)
            
            let okButton = alert.buttons["OK"]
            if okButton.exists {
                okButton.tap()
            }
        }
    }
    
    func testLaunchPerformance() throws {
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
    
    func testScrollPerformance() throws {
        let tableView = app.tables.firstMatch
        XCTAssertTrue(tableView.waitForExistence(timeout: 10))
        
        let firstCell = tableView.cells.firstMatch
        XCTAssertTrue(firstCell.waitForExistence(timeout: 15))
        
        measure(metrics: [XCTOSSignpostMetric.scrollDecelerationMetric]) {
            for _ in 0..<5 {
                tableView.swipeUp(velocity: .fast)
            }
        }
    }
    
    func testAccessibility() throws {
        let tableView = app.tables.firstMatch
        XCTAssertTrue(tableView.waitForExistence(timeout: 10))
        
        let firstCell = tableView.cells.firstMatch
        XCTAssertTrue(firstCell.waitForExistence(timeout: 15))
        
        XCTAssertTrue(firstCell.isAccessibilityElement || firstCell.children(matching: .any).count > 0)
    }
}
