//
//  HowToUITests.swift
//  HowToUITests
//
//  Created by Lorenzo Stanton on 1/14/16.
//  Copyright © 2016 Lorenzo Stanton. All rights reserved.
//

import XCTest

class HowToUITests: XCTestCase {
    
    let kExpectationsTimeout : NSTimeInterval = 20
    let userName = "kostya"
    let password = "kostya"
    let kPublicChannelTag = "public"
    let kPublicChannelName = "public"
    
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
    
    func test01LoginWithValidCredentials() {
        print("test01LoginWithValidCredentials")
        enterCredentials(userName, password: password)
        let app = XCUIApplication()
        
        let expectation = self.expectationWithDescription("Login timed out.")
        
        app.buttons["Login"].tap()
        //XCTAssert(app.activityIndicators.count == 1, "Should show activityIndicator")

        //Wait some time for login callback
        let seconds : UInt64 = 5
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (Int64)(seconds * NSEC_PER_SEC)), dispatch_get_main_queue(), {
            
            XCTAssertFalse(app.buttons["Login"].exists, "If login success - button Login should not exist")
            XCTAssert(app.navigationBars["Features"].exists, "next screen Features should be")
            // Check cells on next screen
            XCTAssert(app.tables.cells.staticTexts["Chat"].exists)
            XCTAssert(app.tables.cells.staticTexts["Publish/Subscribe"].exists)
            XCTAssert(app.tables.cells.staticTexts["User Management"].exists)
            XCTAssert(app.tables.cells.staticTexts["Push"].exists)

            expectation.fulfill()
        })
        
        self.waitForExpectationsWithTimeout(kExpectationsTimeout, handler: nil)
    }
    
    func test02LoginWithNonValidCredentials() {
        print("test02LoginWithNonValidCredentials")
        enterCredentials("wrong", password: "wrong")
        let app = XCUIApplication()
        
        let expectation = self.expectationWithDescription("Login timed out.")
        
        app.buttons["Login"].tap()
        
        //Wait some time for login callback
        let seconds : UInt64 = 5
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (Int64)(seconds * NSEC_PER_SEC)), dispatch_get_main_queue(), {
            // If login success - button Login should not exist
            XCTAssert(app.buttons["Login"].exists)
            XCTAssert(app.staticTexts["Invalid username or password"].exists)
            XCTAssertEqual(app.staticTexts["Invalid username or password"].label, "Invalid username or password")
            expectation.fulfill()
        })
        
        self.waitForExpectationsWithTimeout(kExpectationsTimeout, handler: nil)
    }
    
    func test03RegisterSuccess() {
        print("test03RegisterSuccess")
        enterCredentials("user", password: "user")
        
        let app = XCUIApplication()
        app.buttons["Register"].tap()

        let registerExpectation = self.expectationWithDescription("Register timed out.")
        
        //XCTAssert(app.activityIndicators.count == 1, "Should show activityIndicator")
        
        //Wait some time for Register callback
        let seconds : UInt64 = 5
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (Int64)(seconds * NSEC_PER_SEC)), dispatch_get_main_queue(), {
//            app.alerts.collectionViews.buttons["OK"].tap()
//            XCTAssert(app.alerts.count == 0, "Alert is dismised")
            
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
    
    // MARK: - Chat
    
    func test04ChatSendMessage() {
        print("test04ChatSendMessage")
        let messageText = "hello everyone"
        let app = XCUIApplication()
        enterCredentials(userName, password: password)
        
        /*
        Test login
        */
        
        app.buttons["Login"].tap()
        
        let loginExpectation = self.expectationWithDescription("Login expactation")
        
        //Wait some time for login callback
        let seconds : UInt64 = 5
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (Int64)(seconds * NSEC_PER_SEC)), dispatch_get_main_queue(), {
            loginExpectation.fulfill()
        })
        
        waitForExpectationsWithTimeout(kExpectationsTimeout, handler: nil)
        
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

        //XCTAssert(app.activityIndicators.count == 1, "Should show activityIndicator")
        let fetchMessageExpectation = self.expectationWithDescription("Fetch Message expectation")
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (Int64)(seconds * NSEC_PER_SEC)), dispatch_get_main_queue(), {
            XCTAssert(app.activityIndicators.count == 0, "Should hide activityIndicator")
            XCTAssert(app.tables.cells.count > 0, "Should see messages")
            fetchMessageExpectation.fulfill()
        })
        self.waitForExpectationsWithTimeout(kExpectationsTimeout, handler: nil)
        
        // Go back
        sendReceiveMessagesNavigationBar.buttons["Back"].tap()
        XCTAssertFalse(sendReceiveMessagesNavigationBar.exists, "Should be dismissed")
    }
    
    // MARK: - Publish / Subscribe
    
    func test05CreatePublicChannel() {
        print("test04ChatSendMessage")
        let app = XCUIApplication()
        enterCredentials(userName, password: password)
        
        /*
        Test login
        */
        
        app.buttons["Login"].tap()
        
        let loginExpectation = self.expectationWithDescription("Login expactation")
        
        //Wait some time for login callback
        let seconds : UInt64 = 5
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (Int64)(seconds * NSEC_PER_SEC)), dispatch_get_main_queue(), {
            
            XCTAssertFalse(app.buttons["Login"].exists, "If login success - button Login should not exist")
            // Check cells on next screen
            XCTAssert(app.tables.cells.staticTexts["Chat"].exists)
            XCTAssert(app.tables.cells.staticTexts["Publish/Subscribe"].exists)
            XCTAssert(app.tables.cells.staticTexts["User Management"].exists)
            XCTAssert(app.tables.cells.staticTexts["Push"].exists)
            
            loginExpectation.fulfill()
        })
        
        self.waitForExpectationsWithTimeout(kExpectationsTimeout, handler: nil)
        
        let tablesQuery = app.tables
        tablesQuery.staticTexts["Publish/Subscribe"].tap()
        tablesQuery.staticTexts["Create channel"].tap()
        
        let nameWOSpacesTextField = app.textFields["Name w/o Spaces"]
        nameWOSpacesTextField.tap()
        // Change channel name, otherwise channel creation error
        nameWOSpacesTextField.typeText(kPublicChannelName)
        
        let summaryTextField = app.textFields["Summary"]
        summaryTextField.tap()
        summaryTextField.typeText("public channel")
        
        let tag1Tag2Tag3Tag4TextField = app.textFields["Tag 1, Tag 2, Tag 3, Tag 4"]
        tag1Tag2Tag3Tag4TextField.tap()
        tag1Tag2Tag3Tag4TextField.typeText(kPublicChannelTag)
        
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
    
    func test06PublishSubscribe_AllSubscribed() {
        print("test04ChatSendMessage")
        let seconds : UInt64 = 5
        let app = XCUIApplication()
        toPublishSubscribe()
        
//        enterCredentials(userName, password: password)
//        
//        /*
//        Login
//        */
//        
//        app.buttons["Login"].tap()
//        let loginExpectation = self.expectationWithDescription("Login expactation")
//        
//        //Wait some time for login callback
//        let seconds : UInt64 = 5
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (Int64)(seconds * NSEC_PER_SEC)), dispatch_get_main_queue(), {
//            loginExpectation.fulfill()
//        })
//        self.waitForExpectationsWithTimeout(kExpectationsTimeout, handler: nil)
//        
//        /*
//        Publish/Subscribe
//        Create public and private channels before
//        */
//        
//        let tablesQuery = app.tables
//        tablesQuery.staticTexts["Publish/Subscribe"].tap()
//        XCTAssert(app.navigationBars["Publish / Subscribe"].exists)
        
        let tablesQuery = app.tables
        tablesQuery.staticTexts["Subscribed channels"].tap()
        XCTAssert(app.navigationBars["Subscribed channels"].exists)
        
        let subscribedExpectation = self.expectationWithDescription("Subscribed channels expectation")
        
        //Wait some time for login callback
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (Int64)(seconds * NSEC_PER_SEC)), dispatch_get_main_queue(), {
            XCTAssert(app.tables.cells.count > 0, "Should see channels")
            subscribedExpectation.fulfill()
        })
        self.waitForExpectationsWithTimeout(kExpectationsTimeout, handler: nil)
        
    }
    
    func test07PublishSubscribe_AllPublic() {
        print("test04ChatSendMessage")
        let seconds : UInt64 = 5
        let app = XCUIApplication()
        toPublishSubscribe()
        
        //app.navigationBars["Subscribed channels"].childrenMatchingType(.Button).matchingIdentifier("Back").elementBoundByIndex(0).tap()
        let tablesQuery = app.tables
        tablesQuery.staticTexts["All public channels"].tap()
        XCTAssert(app.navigationBars["All public channels"].exists)
        
        let allPublicExpectation = self.expectationWithDescription("All public channels expectation")
        //Wait some time for callback
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (Int64)(seconds * NSEC_PER_SEC)), dispatch_get_main_queue(), {
            XCTAssert(app.tables.cells.count > 0, "Should see channels")
            tablesQuery.staticTexts["public "].tap()
            let messageTextField = app.textFields["Message"]    //Send Message
            messageTextField.tap()
            messageTextField.typeText("Automated")
            app.navigationBars["public"].buttons["Send"].tap()
            sleep(5)
            XCTAssert(app.tables.cells.count > 0, "Should see messages") //Validate fetch messages not empty
            allPublicExpectation.fulfill()
        })
        self.waitForExpectationsWithTimeout(kExpectationsTimeout, handler: nil)
    }
    
        
        // Following is beyond public channel
//        app.navigationBars["All public channels"].buttons["Back"].tap()
//        
//        tablesQuery.staticTexts["My private channels"].tap()
//        XCTAssert(app.navigationBars["My private channels"].exists)
//        
//        let myPrivateExpactation = self.expectationWithDescription("My private channels expactation")
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (Int64)(seconds * NSEC_PER_SEC)), dispatch_get_main_queue(), {
//            XCTAssert(app.tables.cells.count > 0, "Should see channels")
//            myPrivateExpactation.fulfill()
//        })
//        self.waitForExpectationsWithTimeout(kExpectationsTimeout, handler: nil)
//        
//        // Next - check one of the channels
//        
//        XCTAssert(app.tables.cells.staticTexts[userName].exists, "Private channel with your name should exist")
//        app.tables.cells.staticTexts[userName].tap()
//        XCTAssert(app.navigationBars[userName].exists, "Should show chat screen")
//        XCTAssert(app.tabBars.buttons["Subscribers"].exists)
//        XCTAssert(app.tabBars.buttons["Messages"].exists)
//        app.tabBars.buttons["Subscribers"].tap()
//        
//        XCTAssert(app.navigationBars["Subscribers"].exists, "Subscribers screen is not showing")
//        let subscribersNavigationBar = app.navigationBars["Subscribers"]
//        subscribersNavigationBar.buttons["Invite"].tap()
//        
//        XCTAssert(app.alerts["Invite user"].exists, "Should see alert")
//        let collectionViewsQuery = app.alerts["Invite user"].collectionViews
//        let userNameTextField = collectionViewsQuery.textFields["User name"]
//        XCTAssertEqual(userNameTextField.value as? String, userName, "Should be equal")
//        
//        collectionViewsQuery.buttons["Send"].tap()
//        XCTAssertFalse(app.alerts["Invite user"].exists, "Should hide alert")
//        
//        let inviteExpactation = self.expectationWithDescription("Invite expactation")
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (Int64)(30 * NSEC_PER_SEC)), dispatch_get_main_queue(), {
//            XCTAssert(app.alerts["Invite"].exists, "Should see invite alert")
//            inviteExpactation.fulfill()
//        })
//        self.waitForExpectationsWithTimeout(kExpectationsTimeout, handler: nil)
//        
//        app.alerts["Invite"].collectionViews.buttons["Accept"].tap()
//        XCTAssertFalse(app.alerts["Invite"].exists, "Should hide alert")
//        subscribersNavigationBar.buttons["My private channels"].tap()
//        XCTAssert(app.navigationBars["My private channels"].exists)
//    }
    
    func test10FindChannels() {
        print("test07FindChannels")
        let app = XCUIApplication()
        enterCredentials(userName, password: password)
        
        /*
        Login
        */
        
        app.buttons["Login"].tap()
        let loginExpectation = self.expectationWithDescription("Login expactation")
        
        //Wait some time for login callback
        let seconds : UInt64 = 5
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (Int64)(seconds * NSEC_PER_SEC)), dispatch_get_main_queue(), {
            loginExpectation.fulfill()
        })
        
        self.waitForExpectationsWithTimeout(kExpectationsTimeout, handler: nil)
        
        let tablesQuery = app.tables
        tablesQuery.cells.staticTexts["Publish/Subscribe"].tap()
        tablesQuery.cells.staticTexts["Find channels"].tap()
        XCTAssert(app.navigationBars["Find Channels"].exists, "Should show Find Channels screen")
        
        let element = app.otherElements.containingType(.NavigationBar, identifier:"Find Channels").childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.childrenMatchingType(.Other).element
        let textField = element.childrenMatchingType(.TextField).element
        textField.tap()
        textField.typeText(kPublicChannelName)
        
        // Search public channel by name
        let findChannelsNavigationBar = app.navigationBars["Find Channels"]
        let searchButton = findChannelsNavigationBar.buttons["Search"]
        searchButton.tap()
        
        let searchByNamePublicExpectation = self.expectationWithDescription("Search By Name Public expectation")
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (Int64)(seconds * NSEC_PER_SEC)), dispatch_get_main_queue(), {
            XCTAssert(app.tables.cells.count > 0, "No public channel")

            XCTAssert(app.tables.cells.staticTexts[self.kPublicChannelName].exists, "No public channel")
            searchByNamePublicExpectation.fulfill()
        })
        self.waitForExpectationsWithTimeout(kExpectationsTimeout, handler: nil)
        
        // Search private channel by name
        let button = element.childrenMatchingType(.Button).element
        button.tap() // is public - no
        
        let deleteKey = app.keys["delete"]
        deleteKey.pressForDuration(2)
        textField.typeText(userName)
        searchButton.tap()
        let searchByNamePrivateExpectation = self.expectationWithDescription("Search By Name Private expactation")
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (Int64)(seconds * NSEC_PER_SEC)), dispatch_get_main_queue(), {
            XCTAssert(app.tables.cells.count > 0, "No private channel")
            XCTAssert(app.tables.cells.staticTexts[self.userName].exists, "No private channel")
            searchByNamePrivateExpectation.fulfill()
        })
        self.waitForExpectationsWithTimeout(kExpectationsTimeout, handler: nil)
        
        // Search private channel by Starting with
        app.segmentedControls.buttons["Starting with"].tap()
        textField.tap()
        deleteKey.pressForDuration(2)
        textField.typeText("k")
        searchButton.tap()
        let searchByStartingWithPrivateExpectation = self.expectationWithDescription("Search By Starting with Private expactation")
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (Int64)(seconds * NSEC_PER_SEC)), dispatch_get_main_queue(), {
            XCTAssert(app.tables.cells.count > 0, "No private channel")
            XCTAssert(app.tables.cells.staticTexts[self.userName].exists, "No private channel")
            searchByStartingWithPrivateExpectation.fulfill()
        })
        self.waitForExpectationsWithTimeout(kExpectationsTimeout, handler: nil)
        
        // Search public channel by Starting with
        button.tap() // is public - yes
        deleteKey.tap()
        textField.typeText("p")
        searchButton.tap()
        let searchByStartingWithPublicExpectation = self.expectationWithDescription("Search By Starting with Public expactation")
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (Int64)(seconds * NSEC_PER_SEC)), dispatch_get_main_queue(), {
            XCTAssert(app.tables.cells.count > 0, "No public channel")
            XCTAssert(app.tables.cells.staticTexts[self.kPublicChannelName].exists, "No public channel")
            searchByStartingWithPublicExpectation.fulfill()
        })
        self.waitForExpectationsWithTimeout(kExpectationsTimeout, handler: nil)
        
        // Search public channel by tag
        app.segmentedControls.buttons["By tag"].tap()
        textField.typeText("ublic")
        searchButton.tap()
        
        let searchByTagPublicExpectation = self.expectationWithDescription("Search By tag Public expectation")
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (Int64)(seconds * NSEC_PER_SEC)), dispatch_get_main_queue(), {
            XCTAssert(app.tables.cells.count > 0, "No public channel")
            XCTAssert(app.tables.cells.staticTexts[self.kPublicChannelName].exists, "No public channel")
            searchByTagPublicExpectation.fulfill()
        })
        self.waitForExpectationsWithTimeout(kExpectationsTimeout, handler: nil)
        
        //findChannelsNavigationBar.buttons["Back"].tap()
        findChannelsNavigationBar.childrenMatchingType(.Button).matchingIdentifier("Back").elementBoundByIndex(0).tap()
        XCTAssert(app.navigationBars["Publish / Subscribe"].exists)
    }
    
    // MARK: - User management
    
//    func test08RegisterNewUser() {
//        print("test08RegisterNewUser")
//        let app = XCUIApplication()
//        let seconds : UInt64 = 5
//        enterCredentials(userName, password: password)
//        
//        /* Login */
//        
//        app.buttons["Login"].tap()
//        let loginExpectation = self.expectationWithDescription("Login expactation")
//        //Wait some time for login callback
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (Int64)(seconds * NSEC_PER_SEC)), dispatch_get_main_queue(), {
//            loginExpectation.fulfill()
//        })
//        self.waitForExpectationsWithTimeout(kExpectationsTimeout, handler: nil)
//        
//        let tablesQuery = app.tables
//        tablesQuery.cells.staticTexts["User Management"].tap()
//        tablesQuery.cells.staticTexts["Register"].tap()
//        XCTAssert(app.navigationBars["Register a new User"].exists, "Should show Register screen")
//        
//        let usernameTextField = app.textFields["Username"]
//        usernameTextField.tap()
//        usernameTextField.typeText("jane")
//        
//        let passwordSecureTextField = app.secureTextFields["Password"]
//        passwordSecureTextField.tap()
//        passwordSecureTextField.typeText("doe")
//        
//        /* Register */
//        
//        app.buttons["Register"].tap()
//        let registerExpectation = self.expectationWithDescription("Register expactation")
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (Int64)(seconds * NSEC_PER_SEC)), dispatch_get_main_queue(), {
//            XCTAssert(app.alerts["User created successfully"].exists, "No visible alerts")  //Alert Not Implemented
//            registerExpectation.fulfill()
//        })
//        self.waitForExpectationsWithTimeout(kExpectationsTimeout, handler: nil)
//        
//        app.alerts["User created successfully"].collectionViews.buttons["OK"].tap()
//        XCTAssert(app.alerts.count == 0, "Alert hasn't disappeared")
//        app.navigationBars["Register a new User"].buttons["User Management"].tap()
//        XCTAssert(app.navigationBars["User Management"].exists, "Should show User Management screen")
//    }
    
    func test11LogOut() {
        print("test09LogOut")
        let app = XCUIApplication()
        let seconds : UInt64 = 5
        enterCredentials(userName, password: password)
        
        /* Login */
        
        app.buttons["Login"].tap()
        let loginExpectation = self.expectationWithDescription("Login expactation")
        //Wait some time for login callback
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (Int64)(seconds * NSEC_PER_SEC)), dispatch_get_main_queue(), {
            loginExpectation.fulfill()
        })
        self.waitForExpectationsWithTimeout(kExpectationsTimeout, handler: nil)
        
        let tablesQuery = app.tables
        tablesQuery.cells.staticTexts["User Management"].tap()
        tablesQuery.cells.staticTexts["Log Out"].tap()
        XCTAssert(app.staticTexts["You are logged in as \(userName)"].exists, "No current user label")
        XCTAssert(app.navigationBars["Log Out"].exists, "Not Log Out screen")
        
        /* Log Out */
        
        app.navigationBars["Log Out"].buttons["Log Out"].tap()
        let loginOutExpectation = self.expectationWithDescription("Log Out expactation")
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (Int64)(seconds * NSEC_PER_SEC)), dispatch_get_main_queue(), {
            XCTAssert(app.navigationBars["Welcome to Magnet Message!"].exists, "Not Login screen")
            loginOutExpectation.fulfill()
        })
        self.waitForExpectationsWithTimeout(kExpectationsTimeout, handler: nil)
    }
    
    func test12SearchForUsers() {
        print("test10SearchForUsers")
        let app = XCUIApplication()
        let seconds : UInt64 = 5
        enterCredentials(userName, password: password)
        
        /* Login */
        
        app.buttons["Login"].tap()
        let loginExpectation = self.expectationWithDescription("Login expactation")
        //Wait some time for login callback
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (Int64)(seconds * NSEC_PER_SEC)), dispatch_get_main_queue(), {
            loginExpectation.fulfill()
        })
        self.waitForExpectationsWithTimeout(kExpectationsTimeout, handler: nil)
        
        let tablesQuery = app.tables
        tablesQuery.cells.staticTexts["User Management"].tap()
        tablesQuery.cells.staticTexts["Search for Users"].tap()
        XCTAssert(app.navigationBars["Search Users"].exists, "Not Search Users screen")

        let searchUsersNavigationBar = app.navigationBars["Search Users"]
        let searchButton = searchUsersNavigationBar.buttons["Search"]
        searchButton.tap()
        
        /* Search userName BEGINSWITH */
        
        let userNameBEGINSWITHExpectation = self.expectationWithDescription("userName BEGINSWITH expactation")
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (Int64)(seconds * NSEC_PER_SEC)), dispatch_get_main_queue(), {
            XCTAssert(app.tables.cells.count > 0, "Should search current user")
            XCTAssert(app.tables.cells.staticTexts[self.userName].exists, "Should search current user")
            userNameBEGINSWITHExpectation.fulfill()
        })
        self.waitForExpectationsWithTimeout(kExpectationsTimeout, handler: nil)
        
        app.segmentedControls.buttons["userName ENDSWITH"].tap()
        searchButton.tap()
        
        /* Search userName BEGINSWITH */
        
        let userNameENDSWITHExpectation = self.expectationWithDescription("userName ENDSWITH expactation")
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (Int64)(seconds * NSEC_PER_SEC)), dispatch_get_main_queue(), {
            XCTAssert(app.tables.cells.count > 0, "Should search current user")
            XCTAssert(app.tables.cells.staticTexts[self.userName].exists, "Should search current user")
            userNameENDSWITHExpectation.fulfill()
        })
        self.waitForExpectationsWithTimeout(kExpectationsTimeout, handler: nil)
        
        //searchUsersNavigationBar.buttons["Back"].tap()
        searchUsersNavigationBar.childrenMatchingType(.Button).matchingIdentifier("Back").elementBoundByIndex(0).tap()
        XCTAssert(app.navigationBars["User Management"].exists, "Should show User Management screen")
    }
    
    func test13RetreiveUsers() {
        print("test11RetreiveUsers")
        let app = XCUIApplication()
        let seconds : UInt64 = 5
        enterCredentials(userName, password: password)
        
        /* Login */
        
        app.buttons["Login"].tap()
        let loginExpectation = self.expectationWithDescription("Login expactation")
        //Wait some time for login callback
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (Int64)(seconds * NSEC_PER_SEC)), dispatch_get_main_queue(), {
            loginExpectation.fulfill()
        })
        self.waitForExpectationsWithTimeout(kExpectationsTimeout, handler: nil)
        
        let tablesQuery = app.tables
        tablesQuery.cells.staticTexts["User Management"].tap()
        tablesQuery.cells.staticTexts["Retrieve Users (by ID or userName)"].tap()
        app.segmentedControls.buttons["Retrieve by ID"].tap()
        
        let retrieveUsersNavigationBar = app.navigationBars["Retrieve Users"]
        let searchButton = retrieveUsersNavigationBar.buttons["Search"]
        searchButton.tap()
        
        /* Retrieve by ID */
        
        let retrieveByIDExpectation = self.expectationWithDescription("Retrieve by ID expactation")
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (Int64)(seconds * NSEC_PER_SEC)), dispatch_get_main_queue(), {
            XCTAssert(app.tables.cells.count > 0, "Should search current user")
            XCTAssert(app.tables.cells.staticTexts[self.userName].exists, "Should search current user")
            retrieveByIDExpectation.fulfill()
        })
        self.waitForExpectationsWithTimeout(kExpectationsTimeout, handler: nil)
        
        app.segmentedControls.buttons["Retrieve by userName"].tap()
        searchButton.tap()
        
        /* Retrieve by userName */
        
        let retrieveByUserNameExpectation = self.expectationWithDescription("Retrieve by userName expactation")
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (Int64)(seconds * NSEC_PER_SEC)), dispatch_get_main_queue(), {
            XCTAssert(app.tables.cells.count > 0, "Should search current user")
            XCTAssert(app.tables.cells.staticTexts[self.userName].exists, "Should search current user")
            retrieveByUserNameExpectation.fulfill()
        })
        self.waitForExpectationsWithTimeout(kExpectationsTimeout, handler: nil)
        
        //retrieveUsersNavigationBar.buttons["Back"].tap()
        retrieveUsersNavigationBar.childrenMatchingType(.Button).matchingIdentifier("Back").elementBoundByIndex(0).tap()
        XCTAssert(app.navigationBars["User Management"].exists, "Should show User Management screen")
    }
    
    // MARK: - Push

    func test14Push() {
        print("test12Push")
        let app = XCUIApplication()
        let seconds : UInt64 = 5
        enterCredentials(userName, password: password)
        
        /* Login */
        
        app.buttons["Login"].tap()
        let loginExpectation = self.expectationWithDescription("Login expactation")
        //Wait some time for login callback
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (Int64)(seconds * NSEC_PER_SEC)), dispatch_get_main_queue(), {
            loginExpectation.fulfill()
        })
        self.waitForExpectationsWithTimeout(kExpectationsTimeout, handler: nil)
        
        let tablesQuery = app.tables
        tablesQuery.cells.staticTexts["Push"].tap()
        
        let messageTextField = app.textFields["Message"]
        messageTextField.tap()
        messageTextField.typeText("hello world")
        
        let pushNavigationBar = app.navigationBars["Push"]
        pushNavigationBar.buttons["Send"].tap()
        XCTAssert(app.alerts["Sending push"].exists, "Should show alert")
        app.alerts["Sending push"].collectionViews.buttons["OK"].tap()
        pushNavigationBar.buttons["Features"].tap()
        XCTAssert(app.navigationBars["Features"].exists, "Should show Features screen")
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
    

    func toPublishSubscribe() {
        print("Navigate to PublishSubscribe")
        let app = XCUIApplication()
        enterCredentials(userName, password: password)
        
        /*
        Login
        */
        
        app.buttons["Login"].tap()
        let loginExpectation = self.expectationWithDescription("Login expactation")
        
        //Wait some time for login callback
        let seconds : UInt64 = 5
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (Int64)(seconds * NSEC_PER_SEC)), dispatch_get_main_queue(), {
            loginExpectation.fulfill()
        })
        self.waitForExpectationsWithTimeout(kExpectationsTimeout, handler: nil)
        
        /*
        Publish/Subscribe
        */
        
        let tablesQuery = app.tables
        tablesQuery.staticTexts["Publish/Subscribe"].tap()
        XCTAssert(app.navigationBars["Publish / Subscribe"].exists)
        
    }}
