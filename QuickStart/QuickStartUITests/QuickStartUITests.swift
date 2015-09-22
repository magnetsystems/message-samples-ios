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
    
    func launchClearScreen() {
        print("running clear screen function");
        app.toolbars.containingType(.Button, identifier:"Send").childrenMatchingType(.TextView).element.pressForDuration(1.0)
        app.menuItems["Select All"].tap()
        app.menuItems["Cut"].tap()
    }
    
    func test1SendMessageQuickstart() {
        print("running first test")
        launchClearScreen()
        XCTAssert(app.buttons["Send"].exists)
        app.navigationBars["MessagesView"].buttons["Share"].tap()
        XCTAssert(app.alerts["Send Messages To:"].collectionViews.buttons["QuickstartUser1"].exists)
        app.alerts["Send Messages To:"].collectionViews.buttons["QuickstartUser1"].tap()
        app.toolbars.containingType(.Button, identifier:"Send").childrenMatchingType(.TextView).element.typeText("test1")
        app.toolbars.buttons["Send"].tap()
        XCTAssertEqual(app.staticTexts["test1"].exists, true)
        sleep(3)
    }
    
    func test2SendMessageEchoBot() {
        
        launchClearScreen()
        app.navigationBars["MessagesView"].buttons["Share"].tap()
        XCTAssert(app.alerts["Send Messages To:"].collectionViews.buttons["echo_bot"].exists)
        app.alerts["Send Messages To:"].collectionViews.buttons["echo_bot"].tap()
        app.toolbars.containingType(.Button, identifier:"Send").childrenMatchingType(.TextView).element.typeText("test2")
        app.toolbars.buttons["Send"].tap()
        XCTAssertEqual(app.staticTexts["test2"].exists, true)
        sleep(3)
    }
    
    func test3SendMessageAmazingBot() {
        
        launchClearScreen()
        app.navigationBars["MessagesView"].buttons["Share"].tap()
        XCTAssert(app.alerts["Send Messages To:"].collectionViews.buttons["amazing_bot"].exists)
        app.alerts["Send Messages To:"].collectionViews.buttons["amazing_bot"].tap()
        app.toolbars.containingType(.Button, identifier:"Send").childrenMatchingType(.TextView).element.typeText("test3")
        app.toolbars.buttons["Send"].tap()
        XCTAssertEqual(app.staticTexts["test3"].exists, true)
        sleep(3)
    }
    
    func test4SendMessageReservedCharacters() {
        
        launchClearScreen()
        XCTAssert(app.buttons["Send"].exists)
        app.toolbars.containingType(.Button, identifier:"Send").childrenMatchingType(.TextView).element.typeText("!@#$%^&*_.")
        app.toolbars.buttons["Send"].tap()
        XCTAssertEqual(app.staticTexts["!@#$%^&*_."].exists, true)
        sleep(3)
    }
    
}
