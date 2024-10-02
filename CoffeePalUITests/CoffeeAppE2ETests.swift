//
//  CoffeeAppE2ETests.swift
//  CoffeePalUITests
//
//  Created by Mac User on 21/10/2024.
//

import XCTest

final class CoffeeAppE2ETests: XCTestCase {

    func test_should_make_sure_no_orders_message_is_displayed_if_no_orders() {
        let app = XCUIApplication()
        continueAfterFailure = false
        app.launch()
        
        XCTAssertEqual("No orders available!", app.staticTexts["noOrdersText"].label)
    }
}
