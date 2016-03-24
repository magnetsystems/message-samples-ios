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
    let userName = "test24@automation.gmail.com"
    let password = "Temp1234%"
    
    let fName = "AutomationTestUser24"
    let lName = "test"
    let fullName = "AutomationTestUser24 test"
    //let kPublicChannelTag = "public"
    //let kPublicChannelName = "public"
    
    let userNameTwo = "test30@automation.gmail.com"
    let fNameTwo = "AutomationTestUser30"
    let fullNameTwo = "AutomationTestUser30 test"
    
    let userNameThree = "test31@automation.gmail.com"
    let fNameThree = "AutomationTestUser31"
    let fullNameThree = "AutomationTestUser31 test"
    
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
    
    //Test10 Positive scenario - Set user avatar
    func test10SetAvatar()
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
    //Test11 Negative scenario - Search for non existing chat by user
    func test11SearchForNonExistingChatByUser()
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
        let expactationresults = self.expectationWithDescription("Login timed out.")
        //waiting for time (5 sec) to login callback
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (Int64)(seconds * NSEC_PER_SEC)), dispatch_get_main_queue(), {
            expactationresults.fulfill()
        })
        self.waitForExpectationsWithTimeout(kExpectationsTimeout, handler: nil)
    }
    //Test12 Positive scenario - Check Ask Magnet Banner functionality
    func test12AskMagnetBanner()
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
        
        /* Ask Magnet Banner */
        
        let tables = app.tables.staticTexts["Ask Magnet"]
        tables.tap()
        
        XCTAssert(app.navigationBars["Messenger.ChatView"].buttons["Back"].exists)
        XCTAssert(app.navigationBars["Messenger.ChatView"].childrenMatchingType(.Button).matchingIdentifier("Back").elementBoundByIndex(0).exists)
        
        let expactationcontacts = self.expectationWithDescription("Login timed out.")
        //waiting for time (5 sec) to get available contacts
        let sec : UInt64 = 5
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (Int64)(sec * NSEC_PER_SEC)), dispatch_get_main_queue(), {
            app.navigationBars["Messenger.ChatView"].childrenMatchingType(.Button).matchingIdentifier("Back").elementBoundByIndex(0).tap()
            expactationcontacts.fulfill()
        })
        self.waitForExpectationsWithTimeout(kExpectationsTimeout, handler: nil)
        
        let expactationhome = self.expectationWithDescription("Login timed out.")
        //waiting for time (3 sec) to get home page
        let second : UInt64 = 3
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (Int64)(second * NSEC_PER_SEC)), dispatch_get_main_queue(), {
            expactationhome.fulfill()
        })
        self.waitForExpectationsWithTimeout(kExpectationsTimeout, handler: nil)
        
    }
    
    //Test13 Positive scenario - Register more users for further testing
    func test13RegisterMoreUsersForFurtherTesting()
    {
        /* Register User2 */
        let app = XCUIApplication()
        app.buttons["Create account"].tap()
        
        let firstNameTextField = app.textFields["First name"]
        firstNameTextField.tap()
        firstNameTextField.typeText(fNameTwo)
        
        let lastNameTextField = app.textFields["Last name"]
        lastNameTextField.tap()
        lastNameTextField.typeText(lName)
        
        let emailAddressTextField = app.textFields["Email Address"]
        emailAddressTextField.tap()
        emailAddressTextField.typeText(userNameTwo)
        
        
        let passwordSecureTextField = app.secureTextFields["Password"]
        passwordSecureTextField.tap()
        passwordSecureTextField.typeText(password)
        
        let passwordAgainSecureTextField = app.secureTextFields["Password again"]
        passwordAgainSecureTextField.tap()
        passwordAgainSecureTextField.typeText(password)
        
        app.navigationBars["Register"].buttons["Register"].tap()
        
        let expectation = self.expectationWithDescription("Registration timed out.")
        
        //waiting for time (7 sec) to register callback
        let seconds : UInt64 = 7
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (Int64)(seconds * NSEC_PER_SEC)), dispatch_get_main_queue(), {
            expectation.fulfill()
        })
        
        self.waitForExpectationsWithTimeout(kExpectationsTimeout, handler: nil)
        
        /*LogOut*/
        let editNavBar = XCUIApplication().navigationBars["My Profile"];
        let buttonClose = editNavBar.buttons["Close"];
        buttonClose.tap();
        
        let navBar = XCUIApplication().navigationBars[fullNameTwo]
        let menuButton = navBar.buttons["menu"]
        menuButton.tap();
        
        let signOutStaticText = app.tables.staticTexts["Sign out"]
        let collectionViewsQuery = app.alerts["Sign out"].collectionViews
        
        signOutStaticText.tap()
        collectionViewsQuery.buttons["Yes"].tap()
        
        
        let logoutexpectation = self.expectationWithDescription("Logout time out.")
        //waiting for time (7 sec) to logout callback
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (Int64)(seconds * NSEC_PER_SEC)), dispatch_get_main_queue(), {
            logoutexpectation.fulfill()
        })
        
        self.waitForExpectationsWithTimeout(kExpectationsTimeout, handler: nil)
        /* Register User3 */
        app.buttons["Create account"].tap()
        
        firstNameTextField.tap()
        firstNameTextField.typeText(fNameThree)
        
        lastNameTextField.tap()
        lastNameTextField.typeText(lName)
        
        emailAddressTextField.tap()
        emailAddressTextField.typeText(userNameThree)
        
        passwordSecureTextField.tap()
        passwordSecureTextField.typeText(password)
        
        passwordAgainSecureTextField.tap()
        passwordAgainSecureTextField.typeText(password)
        
        app.navigationBars["Register"].buttons["Register"].tap()
        
        let expectationTwo = self.expectationWithDescription("Registration time out.")
        //waiting for time (7 sec) to register callback
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (Int64)(seconds * NSEC_PER_SEC)), dispatch_get_main_queue(), {
            expectationTwo.fulfill()
        })
        self.waitForExpectationsWithTimeout(kExpectationsTimeout, handler: nil)
        
        /*LogOut*/
        buttonClose.tap();
        
        let navBarTwo = XCUIApplication().navigationBars[fullNameThree]
        let menuButtonTwo = navBarTwo.buttons["menu"]
        menuButtonTwo.tap();
        
        signOutStaticText.tap()
        collectionViewsQuery.buttons["Yes"].tap()
        
        let logoutexpectationtwo = self.expectationWithDescription("Log time out.")
        //waiting for time (7 sec) to logout callback
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (Int64)(seconds * NSEC_PER_SEC)), dispatch_get_main_queue(), {
            logoutexpectationtwo.fulfill()
        })
        
        self.waitForExpectationsWithTimeout(kExpectationsTimeout, handler: nil)
    }
    //Test14-15 Positive scenario - Create a new 1-1 chat and check channel details page
    func test14_15CreateANew1to1Chat()
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
        
        /* Create a new 1-1 chat */
        
        let navBar = XCUIApplication().navigationBars["AutomationTestUser24 test"]
        let newMessage = navBar.buttons["new message"]
        newMessage.tap()
        
        let tablesQuery = XCUIApplication().tables
        tablesQuery.otherElements["T"].tap()
        tablesQuery.staticTexts["AutomationTestUser30 test"].tap()
        
        let navBarTwo = XCUIApplication().navigationBars["New message"]
        let buttonNext = navBarTwo.buttons["Next"]
        XCTAssert(buttonNext.exists)
        buttonNext.tap()
        
        let element = app.otherElements.containingType(.NavigationBar, identifier:"SWRevealView").childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.toolbars.childrenMatchingType(.Other).element
        element.childrenMatchingType(.TextView).element.tap()
        element.childrenMatchingType(.Other).elementBoundByIndex(0).childrenMatchingType(.Button).element.tap()
        app.sheets["Media Messages"].collectionViews.buttons["Photo Library"].tap()
        app.tables.buttons["Moments"].tap()
        app.collectionViews["PhotosGridView"].childrenMatchingType(.Cell).elementBoundByIndex(1).tap()
        let expactationchannel = self.expectationWithDescription("Login timed out.")
        
        //waiting for time (5 sec) to channel callback
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (Int64)(seconds * NSEC_PER_SEC)), dispatch_get_main_queue(), {
            expactationchannel.fulfill()
        })
        
        self.waitForExpectationsWithTimeout(kExpectationsTimeout, handler: nil)
        
        /* Check channel details */
        
        app.navigationBars["AutomationTestUser30"].buttons["Detail"].tap()
        
        let tablesQueryTwo = XCUIApplication().tables
        XCTAssert(tablesQueryTwo.staticTexts[fullName].exists)
        XCTAssert(tablesQueryTwo.staticTexts[fullNameTwo].exists)
        XCTAssert(tablesQueryTwo.staticTexts["+ Add Contact"].exists)
        let expactationchanneldetails = self.expectationWithDescription("Login timed out.")
        
        //waiting for time (5 sec) to channel callback
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (Int64)(seconds * NSEC_PER_SEC)), dispatch_get_main_queue(), {
            expactationchanneldetails.fulfill()
        })
        
        self.waitForExpectationsWithTimeout(kExpectationsTimeout, handler: nil)
    }
}





