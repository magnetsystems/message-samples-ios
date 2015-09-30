//
//  SoapboxChannelTests.swift
//  Soapbox
//
//  Created by Daniel Gulko on 9/30/15.
//  Copyright © 2015 Magnet Systems, Inc. All rights reserved.
//

import XCTest

class SoapboxChannelTests: XCTestCase {
    let app = XCUIApplication()
    
    override func setUp() {
        super.setUp()
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        //app.launch()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    private func runApp() {
        app.launch()
        sleep(2)
        XCTAssertEqual(app.images["soapbox_splash_image"].exists, true)
    }
    
    // sign in function
    private func signIn(user:String, password:String) {
        let usernameTextField = app.textFields["Username"]
        usernameTextField.tap()
        usernameTextField.typeText(user)
        
        let passwordSecureTextField = app.secureTextFields["Password"]
        passwordSecureTextField.tap()
        passwordSecureTextField.typeText(password)
    }
    
    // alert function
    private func confirmAlert(title: String, message: String) {
        if app.alerts.collectionViews.buttons["OK"].exists {
            XCTAssertEqual(app.staticTexts[title].exists, true)
            XCTAssertEqual(app.staticTexts[message].exists, true)
        }
    }
    
    
    private func chooseChannel(channelName:String) {
        app.tables.staticTexts[channelName].tap()
        XCTAssertEqual(app.navigationBars[channelName].staticTexts[channelName].exists, true)
    }

    private func subscribeChannel(channel:String) {
        app.navigationBars[channel].buttons["Share"].tap()
        app.sheets.collectionViews.buttons["Subscribe"].tap()
    }
    
    private func unsubscribeChannel(channel:String) {
        app.navigationBars[channel].buttons["Share"].tap()
        app.sheets.collectionViews.buttons["Unsubscribe"].tap()
    }


    
    // channel tests
    func test1launchSoapbox() {
        app.launch()
    }
    
    func test2registerUser() {
        app.launch()
        signIn("soapboxuser1", password: "password")
        app.buttons["Register"].tap()
        XCTAssertEqual(app.tables.staticTexts["company_announcements"].exists, true)
        XCTAssertEqual(app.tables.staticTexts["lunch_buddies"].exists, true)
    }
    
    func test3subscribeChannel() {
        chooseChannel("lunch_buddies")
        subscribeChannel("lunch_buddies")
        confirmAlert("Successfully Subscribed", message: "You have successfully subscribed to the channel.")
        app.buttons["OK"].tap()
        app.navigationBars["lunch_buddies"].buttons["Channels"].tap()
    }
    
    func test4unsubscribeChannel() {
        chooseChannel("lunch_buddies")
        unsubscribeChannel("lunch_buddies")
        confirmAlert("Successfully Unsubscribed", message: "You have successfully unsubscribed from the channel.")
        app.buttons["OK"].tap()
        app.navigationBars["lunch_buddies"].buttons["Channels"].tap()
    }
}
