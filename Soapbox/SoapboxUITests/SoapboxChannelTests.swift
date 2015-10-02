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
        continueAfterFailure = true
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
            sleep(2)
            XCTAssertEqual(app.staticTexts[title].exists, true)
            XCTAssertEqual(app.staticTexts[message].exists, true)
            app.buttons["OK"].tap()
        }
    }
    
    // choose channel
    private func chooseChannel(channelName:String) {
        app.tables.staticTexts[channelName].tap()
        XCTAssertEqual(app.navigationBars[channelName].staticTexts[channelName].exists, true)
    }
    
    // subscribe to channel
    private func subscribeChannel(channel:String) {
        app.navigationBars[channel].buttons["Share"].tap()
        app.sheets.collectionViews.buttons["Subscribe"].tap()
    }
    
    // unsubscribe to channel
    private func unsubscribeChannel(channel:String) {
        app.navigationBars[channel].buttons["Share"].tap()
        app.sheets.collectionViews.buttons["Unsubscribe"].tap()
    }
    
    // send message to channel
    private func sendMessage(text:String) {
        let textView = app.toolbars.containingType(.Button, identifier:"Send").childrenMatchingType(.TextView).element
        textView.tap()
        textView.typeText(text)
    }
    
    // create channel
    private func createChannel(channelName:String) {
        app.navigationBars["Channels"].buttons["Add"].tap()
        let textField = app.tables.childrenMatchingType(.Cell).elementBoundByIndex(0).childrenMatchingType(.TextField).element
        textField.tap()
        textField.typeText(channelName)
        app.navigationBars["New Channel"].buttons["Save"].tap()
        sleep(2)
    }
    
    // wait for element
    private func evaluateElemenExist(element:AnyObject) {
        let exists = NSPredicate(format: "exists == 1")
        expectationForPredicate(exists, evaluatedWithObject: element, handler: nil)
        waitForExpectationsWithTimeout(10, handler: nil)
    }

    
    
    // channel tests
    func test01launchSoapbox() {
        app.launch()
        let appImage = app.images["soapbox_splash_image"]
        evaluateElemenExist(appImage)
    }
    
    func test02registerUser() {
        let signoutButton = app.buttons["Sign Out"]
        let channel = app.tables.staticTexts["company_announcements"]
        
        signIn("soapboxuser", password: "password")
        app.buttons["Register"].tap()
        evaluateElemenExist(signoutButton)
        evaluateElemenExist(channel)
    }
    
    func test03subscribeChannel() {
        chooseChannel("lunch_buddies")
        subscribeChannel("lunch_buddies")
        confirmAlert("Successfully Subscribed", message: "You have successfully subscribed to the channel.")
    }
    
    func test04sendMessageChannel() {
        sendMessage("message to lunch_buddies channel")
        app.toolbars.buttons["Send"].tap()
        app.navigationBars["lunch_buddies"].buttons["Channels"].tap()
    }
    
    func test05unsubscribeChannel() {
        chooseChannel("lunch_buddies")
        unsubscribeChannel("lunch_buddies")
        confirmAlert("Successfully Unsubscribed", message: "You have successfully unsubscribed from the channel.")
        app.navigationBars["lunch_buddies"].buttons["Channels"].tap()
    }
    
    func test06createNewChannel() {
        createChannel("test_channel")
        confirmAlert("Channel Created", message: "Channel created successfully.")
    }
    
    func test07createEmptyChannelName() {
        let NewChannel = app.navigationBars["New Channel"]
        
        createChannel("")
        confirmAlert("Invalid Channel Name", message: "Please check that you have entered a valid topic name. The field cannot be blank.")
        evaluateElemenExist(NewChannel)
        app.navigationBars["New Channel"].buttons["Channels"].tap()
    }

    func test08createDuplicateChannel() {
        let NewChannel = app.navigationBars["New Channel"]
        
        createChannel("test_channel")
        confirmAlert("Channel Creation Failure", message: "Topic already exists: test_channel")
        evaluateElemenExist(NewChannel)
        app.navigationBars["New Channel"].buttons["Channels"].tap()
    }
    
    func test09createChannelMaxCharacters() {
        let NewChannel = app.navigationBars["New Channel"]
        
        createChannel("123456789012345678901234567890123456789012345678901")
        confirmAlert("Channel Creation Failure", message: "Name cannot contain more than 50 characters or less than 1.")
        evaluateElemenExist(NewChannel)
        app.navigationBars["New Channel"].buttons["Channels"].tap()
    }
    
    func test10createChannelInvalidCharacters() {
        let NewChannel = app.navigationBars["New Channel"]
        
        createChannel("&*@_")
        confirmAlert("Channel Creation Failure", message: "The name contains invalid characters.")
        evaluateElemenExist(NewChannel)
        app.navigationBars["New Channel"].buttons["Channels"].tap()
    }
    
    func test11createChannelSlashCharacter() {
        createChannel("test/channel")
        confirmAlert("Channel Creation Failure", message: "Name cannot contain the / character.")
    }
}
