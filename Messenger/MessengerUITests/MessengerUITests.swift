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
    let userName = "test23@automation.gmail.com"
    let password = "Temp1234%"
    
    let fName = "AutomationTestUser23"
    let lName = "test"
    let fullName = "AutomationTestUser23 test"
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
    func test01LoginWithInvalidCredentials()
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
    func test02RegisterUserWithEmptyFields()
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
    func test03RegisterUserWithEmptyPassword()
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
    func test04RegisterUserWithMismatchPassword()
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
    func test05RegisterUserWithInvalidEmail()
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
    
    //Test6-7 Positive scenarios - Register a new user with valid data and logout of the app
    func test06_07RegisterANewUser()
    {
        let app = XCUIApplication()
        app.buttons["Create account"].tap()
        
        let firstNameTextField = app.textFields["First name"]
        firstNameTextField.tap()
        firstNameTextField.typeText(fName)
        
        let lastNameTextField = app.textFields["Last name"]
        lastNameTextField.tap()
        lastNameTextField.typeText(lName)
        
        let emailAddressTextField = app.textFields["Email Address"]
        emailAddressTextField.tap()
        emailAddressTextField.typeText(userName)
        
        
        let passwordSecureTextField = app.secureTextFields["Password"]
        passwordSecureTextField.tap()
        passwordSecureTextField.typeText(password)
        
        let passwordAgainSecureTextField = app.secureTextFields["Password again"]
        passwordAgainSecureTextField.tap()
        passwordAgainSecureTextField.typeText(password)
        
        app.navigationBars["Register"].buttons["Register"].tap()
        
        let expectation = self.expectationWithDescription("Registration timed out.")
        
        XCTAssert(app.activityIndicators.count == 1, "Should show activityIndicator")
        
        //waiting for time (7 sec) to register callback
        let seconds : UInt64 = 7
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (Int64)(seconds * NSEC_PER_SEC)), dispatch_get_main_queue(), {
            //a few checks, related to success registration
            XCTAssertFalse(app.navigationBars.buttons["Register"].exists)
            XCTAssert(app.navigationBars["My Profile"].exists)
            expectation.fulfill()
        })
        
        self.waitForExpectationsWithTimeout(kExpectationsTimeout, handler: nil)
        
        /*LogOut*/
        let editNavBar = XCUIApplication().navigationBars["My Profile"];
        let buttonClose = editNavBar.buttons["Close"];
        buttonClose.tap();
        XCTAssert(app.navigationBars.staticTexts[fullName].exists)
        
        let navBar = XCUIApplication().navigationBars[fullName]
        let menuButton = navBar.buttons["menu"]
        menuButton.tap();
        XCTAssert(app.tables.staticTexts["Sign out"].exists)
        
        let signOutStaticText = app.tables.staticTexts["Sign out"]
        let collectionViewsQuery = app.alerts["Sign out"].collectionViews
        
        signOutStaticText.tap()
        XCTAssert(app.alerts["Sign out"].exists)
        XCTAssert(app.staticTexts["Do you want sign out?"].exists)
        XCTAssert(app.alerts.collectionViews.buttons["No"].exists)
        collectionViewsQuery.buttons["No"].tap()
        
        
        signOutStaticText.tap()
        XCTAssert(app.alerts.collectionViews.buttons["Yes"].exists)
        collectionViewsQuery.buttons["Yes"].tap()
        
        
        let logoutexpectation = self.expectationWithDescription("Logout time out.")
        //waiting for time (7 sec) to logout callback
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (Int64)(seconds * NSEC_PER_SEC)), dispatch_get_main_queue(), {
            logoutexpectation.fulfill()
        })
        
        self.waitForExpectationsWithTimeout(kExpectationsTimeout, handler: nil)
    }
    
    //Test8 Negative scenario - Register an existing user (just new created)
    func test08RegisterAnExistingUser()
    {
        
        let app = XCUIApplication()
        app.buttons["Create account"].tap()
        
        let firstNameTextField = app.textFields["First name"]
        firstNameTextField.tap()
        firstNameTextField.typeText(fName)
        
        let lastNameTextField = app.textFields["Last name"]
        lastNameTextField.tap()
        lastNameTextField.typeText(lName)
        
        let emailAddressTextField = app.textFields["Email Address"]
        emailAddressTextField.tap()
        emailAddressTextField.typeText(userName)
        
        
        let passwordSecureTextField = app.secureTextFields["Password"]
        passwordSecureTextField.tap()
        passwordSecureTextField.typeText(password)
        
        let passwordAgainSecureTextField = app.secureTextFields["Password again"]
        passwordAgainSecureTextField.tap()
        passwordAgainSecureTextField.typeText(password)
        
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
    
    //Test9 Positive scenario - Login to the app with valid credentials
    func test09LoginWithValidCredentials()
    {
        
        let app = XCUIApplication()
        let emailAddressTextField = app.textFields["Email Address"]
        emailAddressTextField.tap()
        emailAddressTextField.typeText(userName)
        
        let passwordSecureTextField = app.secureTextFields["Password"]
        passwordSecureTextField.tap()
        passwordSecureTextField.typeText(password)
        
        let button = app.otherElements.containingType(.NavigationBar, identifier:"Messenger.SignInView").childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.childrenMatchingType(.Button).elementBoundByIndex(0)
        button.tap()
        
        let expactation = self.expectationWithDescription("Login timed out.")
        
        app.buttons["Sign in"].tap()
        
        //waiting for time (7 sec) to login callback
        let seconds : UInt64 = 7
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (Int64)(seconds * NSEC_PER_SEC)), dispatch_get_main_queue(), {
            XCTAssertFalse(app.buttons["Login"].exists, "No login button")
            XCTAssert(app.tables.searchFields["Search message by user"].exists, "Search message by user should exist")
            expactation.fulfill()
        })
        
        self.waitForExpectationsWithTimeout(kExpectationsTimeout, handler: nil)
    }
    
    //Test10 Negative scenario - Search for non existing chat by user
    func test10SearchForNonExistingChatByUser()
    {
        /* login*/
        let app = XCUIApplication()
        let emailAddressTextField = app.textFields["Email Address"]
        emailAddressTextField.tap()
        emailAddressTextField.typeText(userName)
        
        let passwordSecureTextField = app.secureTextFields["Password"]
        passwordSecureTextField.tap()
        passwordSecureTextField.typeText(password)
        
        let button = app.otherElements.containingType(.NavigationBar, identifier:"Messenger.SignInView").childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.childrenMatchingType(.Button).elementBoundByIndex(0)
        button.tap()
        
        let expactation = self.expectationWithDescription("Login timed out.")
        
        app.buttons["Sign in"].tap()
        
        //waiting for time (5 sec) to login callback
        let seconds : UInt64 = 5
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (Int64)(seconds * NSEC_PER_SEC)), dispatch_get_main_queue(), {
            expactation.fulfill()
        })
        
        self.waitForExpectationsWithTimeout(kExpectationsTimeout, handler: nil)
        
        /* search for non existing user */
        
        app.tables.searchFields["Search message by user"].tap()
        let searchMessageByUserSearchField = app.searchFields["Search message by user"]
        searchMessageByUserSearchField.typeText("A")
        searchMessageByUserSearchField.typeText("l")
        searchMessageByUserSearchField.typeText("e")
        searchMessageByUserSearchField.typeText("x")
        app.buttons["Search"].tap()
        XCTAssertFalse(app.tables.staticTexts["Alex"].exists)
        
    }
    
    //Test11 Positive scenario - Set user avatar
    func test11SetAvatar()
    {
        /* login*/
        let app = XCUIApplication()
        let emailAddressTextField = app.textFields["Email Address"]
        emailAddressTextField.tap()
        emailAddressTextField.typeText(userName)
        
        let passwordSecureTextField = app.secureTextFields["Password"]
        passwordSecureTextField.tap()
        passwordSecureTextField.typeText(password)
        
        let button = app.otherElements.containingType(.NavigationBar, identifier:"Messenger.SignInView").childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.childrenMatchingType(.Button).elementBoundByIndex(0)
        button.tap()
        
        let expactation = self.expectationWithDescription("Login timed out.")
        
        app.buttons["Sign in"].tap()
        
        //waiting for time (7 sec) to login callback
        let seconds : UInt64 = 5
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (Int64)(seconds * NSEC_PER_SEC)), dispatch_get_main_queue(), {
            expactation.fulfill()
        })
        
        self.waitForExpectationsWithTimeout(kExpectationsTimeout, handler: nil)
        /* Set avatar */
        
        let navBar = app.navigationBars[fullName];
        let buttons = navBar.buttons["menu"];
        buttons.tap()
        
        let tablesQuery = app.tables
        tablesQuery.staticTexts[fullName].tap()
        app.childrenMatchingType(.Window).elementBoundByIndex(0).childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.childrenMatchingType(.Button).elementBoundByIndex(0).tap()
        tablesQuery.buttons["Moments"].tap()
        app.collectionViews.childrenMatchingType(.Cell).elementBoundByIndex(6).tap()
        app.buttons["Save changes"].tap()
        
        let savedAlert = app.alerts["Saved"]
        XCTAssert(savedAlert.exists)
        XCTAssert(savedAlert.collectionViews.buttons["Close"].exists)
        savedAlert.collectionViews.buttons["Close"].tap()
        
    }
}





