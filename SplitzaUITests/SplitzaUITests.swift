//
//  SplitzaUITests.swift
//  SplitzaUITests
//
//  Created by Jeffry Sandy Purnomo on 03/10/25.
//

import XCTest

final class SplitzaUITests: XCTestCase {
	
	override func setUpWithError() throws {
		continueAfterFailure = false
	}
	
	@MainActor
	func testExample() throws {
		let app = XCUIApplication()
		app.launchEnvironment["ENVIRONMENT"] = "testing"
		app.launch()
		
		let elementsQuery = XCUIApplication().scrollViews.otherElements
		let emailTextField = elementsQuery.textFields["Email"]
		emailTextField.tap()
		emailTextField.typeText("jeffry@gmail.com")
		
		let passwordSecureTextField = elementsQuery.secureTextFields["Password"]
		passwordSecureTextField.tap()
		passwordSecureTextField.typeText("lalalala")
		
		let logInButton = elementsQuery.buttons["Log In"]
		logInButton.tap()
		
		let message = app.staticTexts["Split History"]
		XCTAssertTrue(message.waitForExistence(timeout: 5))
	}
	
	@MainActor
	func testLaunchPerformance() throws {
		if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
			// This measures how long it takes to launch your application.
			measure(metrics: [XCTApplicationLaunchMetric()]) {
				XCUIApplication().launch()
			}
		}
	}
}
