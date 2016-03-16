//
//  MessengerUITests.swift
//  MessengerUITests
//
//  Created by agordyman on 3/14/16.
//  Copyright © 2016 Magnet Systems, Inc. All rights reserved.
//

import XCTest

class MessengerUITests: XCTestCase {
    
    let kExpectationsTimeout : NSTimeInterval = 60
    let userName = "agordyman@geeksforless.net"
    let password = "Ry19Bqb4#"
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
    
    //Test1 Negative scenario - Login to the app with invalid credentials
    func test1LoginWithInvalidCredentials()
    {
        
        let app = XCUIApplication()
        let emailAddressTextField = app.textFields["Email Address"]
        emailAddressTextField.tap()
        emailAddressTextField.typeText("allextest")
        
        let passwordSecureTextField = app.secureTextFields["Password"]
        passwordSecureTextField.tap()
        passwordSecureTextField.typeText("testpassword")
        
        let expectation = self.expectationWithDescription("Login timed out.")
        
        let signInButton = app.buttons["Sign in"]
        signInButton.tap()
        
        //waiting for time (7 sec) to login callback
        let seconds : UInt64 = 7
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (Int64)(seconds * NSEC_PER_SEC)), dispatch_get_main_queue(), {
            //a few checks, related to appeared error alert
            XCTAssert(app.alerts["Couldn't log in"].exists)
            XCTAssert(app.staticTexts["Couldn't log in"].exists)
            XCTAssert(app.staticTexts["Username and password not found.  Please try again."].exists)
            XCTAssertEqual(app.staticTexts["Username and password not found.  Please try again."].label, "Username and password not found.  Please try again.")
            app.collectionViews.buttons["Close"].tap()
            expectation.fulfill()
        })
        
        self.waitForExpectationsWithTimeout(kExpectationsTimeout, handler: nil)
        
    }
    
    //Test2 Negative scenario - Register a user with empty fields
    func test2RegisterUserWithEmptyFields()
    {
        let app = XCUIApplication()
        app.buttons["Create account"].tap()
        app.navigationBars["Register"].buttons["Register"].tap()
        
        let expectation = self.expectationWithDescription("Login timed out.")
        
        let fieldRequiredAlert = app.alerts["Field required"]
        
        //waiting for time (7 sec) to register callback
        let seconds : UInt64 = 7
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (Int64)(seconds * NSEC_PER_SEC)), dispatch_get_main_queue(), {
            //a few checks, related to appeared error alert
            XCTAssert(app.alerts["Field required"].exists)
            XCTAssert(app.staticTexts["Field required"].exists)
            XCTAssertEqual(app.staticTexts["Please enter your first and last name"].label, "Please enter your first and last name")
            fieldRequiredAlert.collectionViews.buttons["Close"].tap()
            expectation.fulfill()
        })
        
        self.waitForExpectationsWithTimeout(kExpectationsTimeout, handler: nil)
    }
    
    //Test3 Negative scenario - Register a user with empty password
    func test3RegisterUserWithEmptyPassword()
    {
        
        let app = XCUIApplication()
        app.buttons["Create account"].tap()
        
        let firstNameTextField = app.textFields["First name"]
        firstNameTextField.tap()
        firstNameTextField.typeText("alex")
        
        let lastNameTextField = app.textFields["Last name"]
        lastNameTextField.tap()
        lastNameTextField.typeText("gordyman")
        
        let emailAddressTextField = app.textFields["Email Address"]
        emailAddressTextField.tap()
        emailAddressTextField.typeText("alex.gordyman@gmail.com")
        
        app.navigationBars["Register"].buttons["Register"].tap()
        
        let expectation = self.expectationWithDescription("Login timed out.")
        
        let fieldRequiredAlert = app.alerts["Field required"]
        
        //waiting for time (7 sec) to register callback
        let seconds : UInt64 = 7
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (Int64)(seconds * NSEC_PER_SEC)), dispatch_get_main_queue(), {
            //a few checks, related to appeared error alert
            XCTAssert(app.alerts["Field required"].exists)
            XCTAssert(app.staticTexts["Please enter your password and verify your password again"].exists)
            XCTAssertEqual(app.staticTexts["Please enter your password and verify your password again"].label, "Please enter your password and verify your password again")
            fieldRequiredAlert.collectionViews.buttons["Close"].tap()
            expectation.fulfill()
        })
        
        self.waitForExpectationsWithTimeout(kExpectationsTimeout, handler: nil)
        
    }
    
    //Test4 Negative scenario - Register a user with mismatch passwords
    func test4RegisterUserWithMismatchPassword()
    {
        let app = XCUIApplication()
        app.buttons["Create account"].tap()
        
        let firstNameTextField = app.textFields["First name"]
        firstNameTextField.tap()
        firstNameTextField.typeText("alex")
        
        let lastNameTextField = app.textFields["Last name"]
        lastNameTextField.tap()
        lastNameTextField.typeText("gordyman")
        
        let emailAddressTextField = app.textFields["Email Address"]
        emailAddressTextField.tap()
        emailAddressTextField.typeText("alex.gordyman@gmail.com")
        
        
        let passwordSecureTextField = app.secureTextFields["Password"]
        passwordSecureTextField.tap()
        passwordSecureTextField.typeText("alexander1")
        
        let passwordAgainSecureTextField = app.secureTextFields["Password again"]
        passwordAgainSecureTextField.tap()
        passwordAgainSecureTextField.typeText("alexandert")
        
        app.navigationBars["Register"].buttons["Register"].tap()
        
        let expectation = self.expectationWithDescription("Login timed out.")
        
        let fieldRequiredAlert = app.alerts["Field required"]
        
        //waiting for time (7 sec) to register callback
        let seconds : UInt64 = 7
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (Int64)(seconds * NSEC_PER_SEC)), dispatch_get_main_queue(), {
            //a few checks, related to appeared error alert
            XCTAssert(app.alerts["Field required"].exists)
            XCTAssert(app.staticTexts["Please enter your password and verify your password again"].exists)
            XCTAssertEqual(app.staticTexts["Please enter your password and verify your password again"].label, "Please enter your password and verify your password again")
            fieldRequiredAlert.collectionViews.buttons["Close"].tap()
            expectation.fulfill()
        })
        
        self.waitForExpectationsWithTimeout(kExpectationsTimeout, handler: nil)
        
    }
    
    //Test5 Negative scenario - Register a user with invaild email
    func test5RegisterUserWithInvalidEmail()
    {
        let app = XCUIApplication()
        app.buttons["Create account"].tap()
        
        let firstNameTextField = app.textFields["First name"]
        firstNameTextField.tap()
        firstNameTextField.typeText("alex")
        
        let lastNameTextField = app.textFields["Last name"]
        lastNameTextField.tap()
        lastNameTextField.typeText("gordyman")
        
        let emailAddressTextField = app.textFields["Email Address"]
        emailAddressTextField.tap()
        emailAddressTextField.typeText("№№№№№№№№№№№№№№")
        
        
        let passwordSecureTextField = app.secureTextFields["Password"]
        passwordSecureTextField.tap()
        passwordSecureTextField.typeText("alexander1")
        
        let passwordAgainSecureTextField = app.secureTextFields["Password again"]
        passwordAgainSecureTextField.tap()
        passwordAgainSecureTextField.typeText("alexander1")
        
        app.navigationBars["Register"].buttons["Register"].tap()
        
        let expectation = self.expectationWithDescription("Login timed out.")
        
        let fieldRequiredAlert = app.alerts["Field required"]
        
        //waiting for time (7 sec) to register callback
        let seconds : UInt64 = 7
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (Int64)(seconds * NSEC_PER_SEC)), dispatch_get_main_queue(), {
            //a few checks, related to appeared error alert
            XCTAssert(app.alerts["Field required"].exists)
            XCTAssert(app.staticTexts["Please enter your email"].exists)
            XCTAssertEqual(app.staticTexts["Please enter your email"].label, "Please enter your email")
            fieldRequiredAlert.collectionViews.buttons["Close"].tap()
            expectation.fulfill()
        })
        
        self.waitForExpectationsWithTimeout(kExpectationsTimeout, handler: nil)
        
    }
    
    //Test6 Negative scenario - Register an existing user
    func test6RegisterAnExistingUser()
    {
        let app = XCUIApplication()
        app.buttons["Create account"].tap()
        
        let firstNameTextField = app.textFields["First name"]
        firstNameTextField.tap()
        firstNameTextField.typeText("Alex")
        
        let lastNameTextField = app.textFields["Last name"]
        lastNameTextField.tap()
        lastNameTextField.typeText("Gordyman")
        
        let emailAddressTextField = app.textFields["Email Address"]
        emailAddressTextField.tap()
        emailAddressTextField.typeText("agordyman@geeksforless.net")
        
        
        let passwordSecureTextField = app.secureTextFields["Password"]
        passwordSecureTextField.tap()
        passwordSecureTextField.typeText("Ry19Bqb4#")
        
        let passwordAgainSecureTextField = app.secureTextFields["Password again"]
        passwordAgainSecureTextField.tap()
        passwordAgainSecureTextField.typeText("Ry19Bqb4#")
        
        app.navigationBars["Register"].buttons["Register"].tap()
        
        let expectation = self.expectationWithDescription("Login timed out.")
        
        let emailTakenAlert = XCUIApplication().alerts["Email taken"]
        
        //waiting for time (7 sec) to register callback
        let seconds : UInt64 = 7
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (Int64)(seconds * NSEC_PER_SEC)), dispatch_get_main_queue(), {
            //a few checks, related to appeared error alert
            XCTAssert(app.alerts["Email taken"].exists)
            XCTAssert(app.staticTexts["Sorry, that email is already taken. Please select a new email and try again."].exists)
            XCTAssertEqual(app.staticTexts["Sorry, that email is already taken. Please select a new email and try again."].label, "Sorry, that email is already taken. Please select a new email and try again.")
            emailTakenAlert.collectionViews.buttons["Close"].tap()
            expectation.fulfill()
        })
        
        self.waitForExpectationsWithTimeout(kExpectationsTimeout, handler: nil)
        
    }
    
    //Test7 Positive scenario - Login to the app with valid credentials
    func test7LoginWithValidCredentials()
    {
        
        let app = XCUIApplication()
        let emailAddressTextField = app.textFields["Email Address"]
        emailAddressTextField.tap()
        emailAddressTextField.typeText(userName)
        
        let passwordSecureTextField = app.secureTextFields["Password"]
        passwordSecureTextField.tap()
        passwordSecureTextField.typeText(password)
        
        let expactation = self.expectationWithDescription("Login timed out.")
        
        app.buttons["Sign in"].tap()
        
        XCTAssert(app.activityIndicators.count == 1, "activityIndicator is appeared")
        
        //waiting for time (10 sec) to login callback
        let seconds : UInt64 = 10
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (Int64)(seconds * NSEC_PER_SEC)), dispatch_get_main_queue(), {
            XCTAssertFalse(app.buttons["Login"].exists, "No login button")
            XCTAssert(app.tables.searchFields["Search message by user"].exists, "Search message by user should exist")
            expactation.fulfill()
        })
        
        self.waitForExpectationsWithTimeout(kExpectationsTimeout, handler: nil)
    }
    
    
}






