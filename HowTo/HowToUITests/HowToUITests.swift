//
//  HowToUITests.swift
//  HowToUITests
//
//  Created by Lorenzo Stanton on 1/14/16.
//  Copyright © 2016 Lorenzo Stanton. All rights reserved.
//

import XCTest

class HowToUITests: XCTestCase {
    
    let kExpectationsTimeout : NSTimeInterval = 60
        
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    //MARK: - Tests
    
    func testLoginWithValidCredentials() {
        
        enterCredentials("kostya", password: "kostya")
        let app = XCUIApplication()
        
        let expactation = self.expectationWithDescription("Login timed out.")
        
        app.buttons["Login"].tap()
        XCTAssert(app.activityIndicators.count == 1, "Should show activityIndicator")

        //Wait some time for login callback
        let seconds : UInt64 = 20
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (Int64)(seconds * NSEC_PER_SEC)), dispatch_get_main_queue(), {
            
            XCTAssertFalse(app.buttons["Login"].exists, "If login success - button Login should not exist")
            XCTAssert(app.navigationBars["Features"].exists, "next screen Features should be")
            // Check cells on next screen
            XCTAssert(app.tables.cells.staticTexts["Chat"].exists)
            XCTAssert(app.tables.cells.staticTexts["Publish/Subscribe"].exists)
            XCTAssert(app.tables.cells.staticTexts["User Management"].exists)
            XCTAssert(app.tables.cells.staticTexts["Push"].exists)

            expactation.fulfill()
        })
        
        self.waitForExpectationsWithTimeout(kExpectationsTimeout, handler: nil)
    }
    
    func testLoginWithNonValidCredentials() {
        
        enterCredentials("wrong", password: "wrong")
        let app = XCUIApplication()
        
        let expactation = self.expectationWithDescription("Login timed out.")
        
        app.buttons["Login"].tap()
        
        //Wait some time for login callback
        let seconds : UInt64 = 10
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (Int64)(seconds * NSEC_PER_SEC)), dispatch_get_main_queue(), {
            // If login success - button Login should not exist
            XCTAssert(app.buttons["Login"].exists)
            XCTAssert(app.staticTexts["Invalid username or password"].exists)
            XCTAssertEqual(app.staticTexts["Invalid username or password"].label, "Invalid username or password")
            expactation.fulfill()
        })
        
        self.waitForExpectationsWithTimeout(kExpectationsTimeout, handler: nil)
    }
    
    func testRegisterSuccess() {
        enterCredentials("user", password: "user")
        
        let app = XCUIApplication()
        app.buttons["Register"].tap()

        let registerExpectation = self.expectationWithDescription("Register timed out.")
        
        XCTAssert(app.activityIndicators.count == 1, "Should show activityIndicator")
        
        //Wait some time for Register callback
        let seconds : UInt64 = 20
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (Int64)(seconds * NSEC_PER_SEC)), dispatch_get_main_queue(), {
            
            XCTAssertFalse(app.buttons["Register"].exists, "If success - button Register should not exist")
            // Check cells on next screen
            XCTAssert(app.tables.cells.staticTexts["Chat"].exists)
            XCTAssert(app.tables.cells.staticTexts["Publish/Subscribe"].exists)
            XCTAssert(app.tables.cells.staticTexts["User Management"].exists)
            XCTAssert(app.tables.cells.staticTexts["Push"].exists)
            
            registerExpectation.fulfill()
        })
        
        self.waitForExpectationsWithTimeout(kExpectationsTimeout, handler: nil)
    }
    
    func testCreatePublicChannel() {
        
        let app = XCUIApplication()
        enterCredentials("kostya", password: "kostya")
        
        /*
            Test login
        */
        
        app.buttons["Login"].tap()

        let loginExpactation = self.expectationWithDescription("Login expactation")
        
        //Wait some time for login callback
        let seconds : UInt64 = 20
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (Int64)(seconds * NSEC_PER_SEC)), dispatch_get_main_queue(), {
            
            XCTAssertFalse(app.buttons["Login"].exists, "If login success - button Login should not exist")
            // Check cells on next screen
            XCTAssert(app.tables.cells.staticTexts["Chat"].exists)
            XCTAssert(app.tables.cells.staticTexts["Publish/Subscribe"].exists)
            XCTAssert(app.tables.cells.staticTexts["User Management"].exists)
            XCTAssert(app.tables.cells.staticTexts["Push"].exists)
            
            loginExpactation.fulfill()
        })
        
        self.waitForExpectationsWithTimeout(kExpectationsTimeout, handler: nil)
        
        let tablesQuery = app.tables
        tablesQuery.staticTexts["Publish/Subscribe"].tap()
        tablesQuery.staticTexts["Create channel"].tap()
        
        let nameWOSpacesTextField = app.textFields["Name w/o Spaces"]
        nameWOSpacesTextField.tap()
        // Change channel name, otherwise channel creation error
        nameWOSpacesTextField.typeText("police_\(channelName())")
        
        let summaryTextField = app.textFields["Summary"]
        summaryTextField.tap()
        summaryTextField.typeText("police channel")
        
        let tag1Tag2Tag3Tag4TextField = app.textFields["Tag 1, Tag 2, Tag 3, Tag 4"]
        tag1Tag2Tag3Tag4TextField.tap()
        tag1Tag2Tag3Tag4TextField.typeText("police")
        
        /*
            Test create channel
        */
        
        let saveButton = app.navigationBars["Create channel"].buttons["Save"]
        saveButton.tap()
        
        let createChannelExpectation = self.expectationWithDescription("Create channel expectation")

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (Int64)(seconds * NSEC_PER_SEC)), dispatch_get_main_queue(), {
            XCTAssert(app.alerts.count == 1, "Alert is visible")
            
            createChannelExpectation.fulfill()
        })
        
        self.waitForExpectationsWithTimeout(kExpectationsTimeout, handler: nil)
        
        app.alerts.collectionViews.buttons["OK"].tap()
        XCTAssert(app.alerts.count == 0, "Alert is dismised")
    }
    
    func testChatSendMessage() {
        
        let messageText = "hello everyone"
        let app = XCUIApplication()
        enterCredentials("kostya", password: "kostya")
        
        /*
            Test login
        */
        
        app.buttons["Login"].tap()
        
        let loginExpactation = self.expectationWithDescription("Login expactation")
        
        //Wait some time for login callback
        let seconds : UInt64 = 10
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (Int64)(seconds * NSEC_PER_SEC)), dispatch_get_main_queue(), {
            loginExpactation.fulfill()
        })
        
        self.waitForExpectationsWithTimeout(kExpectationsTimeout, handler: nil)
        
        app.tables.cells.staticTexts["Chat"].tap()
        
        let messageTextField = app.textFields["Message"]
        messageTextField.tap()
        messageTextField.tap()
        messageTextField.typeText(messageText)
        app.switches["1"].tap()
        
        /*
            Test send message
        */
        
        let sendReceiveMessagesNavigationBar = app.navigationBars["Send & Receive Messages"]
        sendReceiveMessagesNavigationBar.buttons["Send"].tap()
        
        let sendMessageExpectation = self.expectationWithDescription("Send Message expectation")
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (Int64)(seconds * NSEC_PER_SEC)), dispatch_get_main_queue(), {
            XCTAssert(app.alerts.count == 1, "Alert is not visible")
            XCTAssert(app.tables.cells.staticTexts[messageText].exists, "Should see recieved message")
            sendMessageExpectation.fulfill()
        })
        self.waitForExpectationsWithTimeout(kExpectationsTimeout, handler: nil)
        
        app.alerts["Message received"].collectionViews.buttons["OK"].tap()
        XCTAssertFalse(app.alerts["Message received"].exists, "Alert is not dismissed")
        
        /*
            Test fetch messages
        */
        
        app.buttons["Fetch all messages posted in the last 24 hours"].tap()

        XCTAssert(app.activityIndicators.count == 1, "Should show activityIndicator")
        
        let fetchMessageExpectation = self.expectationWithDescription("Fetch Message expectation")
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (Int64)(seconds * NSEC_PER_SEC)), dispatch_get_main_queue(), {
            XCTAssert(app.activityIndicators.count == 0, "Should hide activityIndicator")
            XCTAssert(app.tables.cells.count > 0, "Should see messages")
            fetchMessageExpectation.fulfill()
        })
        self.waitForExpectationsWithTimeout(kExpectationsTimeout, handler: nil)
        
        // Go back
        sendReceiveMessagesNavigationBar.buttons["Features"].tap()
        XCTAssertFalse(sendReceiveMessagesNavigationBar.exists, "Should be dismissed")
    }
    
    //MARK: - Helpers
    
    func enterCredentials(userName:String, password: String) {
        let app = XCUIApplication()
        let usernameTextField = app.textFields["Username"]
        usernameTextField.tap()
        usernameTextField.typeText(userName)
        
        let passwordSecureTextField = app.secureTextFields["Password"]
        passwordSecureTextField.tap()
        passwordSecureTextField.typeText(password)
    }
    
    func channelName() -> String {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyyMMddHHmmss"
        return formatter.stringFromDate(NSDate())
    }
}
