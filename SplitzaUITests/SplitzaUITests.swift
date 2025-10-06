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
	func testLoginScenario() throws {
		let app = XCUIApplication()
		app.launchEnvironment["ENVIRONMENT"] = "production"
		app.launch()
		
		doLoginScenario(app: app)
	}
	
	func testLaunchAppOnlyScenario() throws {
		let app = XCUIApplication()
		app.launchEnvironment["ENVIRONMENT"] = "production"
		app.launch()
		
		let message = app.otherElements["app-ready-tracked"]
		XCTAssertTrue(message.waitForExistence(timeout: 10))
	}
	
	@MainActor
	func testsLogoutScenario() throws {
		let app = XCUIApplication()
		app.launchEnvironment["ENVIRONMENT"] = "production"
		app.launch()
		
		doLogoutScenario(app: app)
	}
	
	@MainActor
	func doLoginScenario(app: XCUIApplication) {
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
	func doLogoutScenario(app: XCUIApplication) {
		let profileTabbar = app.buttons["Profile"]
		profileTabbar.tap()
		
		let logoutButton = app.buttons["btn-logout"]
		logoutButton.tap()
		
		let alertLogout = app.buttons["alert-logout"]
		alertLogout.tap()
		
		let message = app.staticTexts["Welcome to Splitza"]
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

extension XCTestCase {
	func waitFor(seconds: TimeInterval) {
		let expectation = XCTestExpectation(description: "Wait for \(seconds) seconds")
		DispatchQueue.global().asyncAfter(deadline: .now() + seconds) {
			expectation.fulfill()
		}
		_ = XCTWaiter.wait(for: [expectation], timeout: seconds + 1)
	}
}
