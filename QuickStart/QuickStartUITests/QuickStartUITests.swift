//
//  UITestQuickStart.swift
//  UITestQuickStart
//
//  Created by Daniel Gulko on 9/16/15.
//  Copyright © 2015 Magnet Systems, Inc. All rights reserved.
//

import XCTest
import Foundation

class UITestQuickStart: XCTestCase {
    let expectedNumberOfMessages: UInt = 2
    let app = XCUIApplication()
    
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = true
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()
        sleep(5)
        print("done launching")
        
        if XCUIApplication().alerts.collectionViews.buttons["OK"].exists {
            XCUIApplication().alerts.collectionViews.buttons["OK"].tap()
        }
        
        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    // clears the default hello world from send message text field
    private func launchClearScreen() {
        print("running clear screen function");
        app.toolbars.containingType(.Button, identifier:"Send").childrenMatchingType(.TextView).element.pressForDuration(1.0)
        app.menuItems["Select All"].tap()
        app.menuItems["Cut"].tap()
    }
    
    // send message and assert message sent
    private func sendMessage(message: String) {
        XCTAssert(app.buttons["Send"].exists)
        app.toolbars.containingType(.Button, identifier:"Send").childrenMatchingType(.TextView).element.typeText(message)
        app.toolbars.buttons["Send"].tap()
        XCTAssertEqual(app.staticTexts[message].exists, true)
        XCTAssertEqual(app.tables.cells.staticTexts[message].exists, true)
        sleep(3)
    }
    
    
    func test1SendMessageQuickstart() {
        launchClearScreen()
        app.navigationBars["MessagesView"].buttons["Share"].tap()
        XCTAssert(app.alerts["Send Messages To:"].collectionViews.buttons["QuickstartUser1"].exists)
        app.alerts["Send Messages To:"].collectionViews.buttons["QuickstartUser1"].tap()
        sendMessage("test1")
        XCTAssertEqual(app.tables.cells.count, expectedNumberOfMessages)
    }
    
    func test2SendMessageEchoBot() {
        launchClearScreen()
        app.navigationBars["MessagesView"].buttons["Share"].tap()
        XCTAssert(app.alerts["Send Messages To:"].collectionViews.buttons["echo_bot"].exists)
        app.alerts["Send Messages To:"].collectionViews.buttons["echo_bot"].tap()
        sendMessage("test2")
        XCTAssertEqual(app.tables.cells.count, expectedNumberOfMessages)
    }
    
    func test3SendMessageAmazingBot() {
        launchClearScreen()
        app.navigationBars["MessagesView"].buttons["Share"].tap()
        XCTAssert(app.alerts["Send Messages To:"].collectionViews.buttons["amazing_bot"].exists)
        app.alerts["Send Messages To:"].collectionViews.buttons["amazing_bot"].tap()
        sendMessage("test3")
        XCTAssertEqual(app.tables.cells.count, expectedNumberOfMessages)
    }
    
    func test4SendMessageReservedCharacters() {
        launchClearScreen()
        XCTAssert(app.buttons["Send"].exists)
        sendMessage("!@#$%^&*_.")
        XCTAssertEqual(app.tables.cells.count, expectedNumberOfMessages)
    }
}
