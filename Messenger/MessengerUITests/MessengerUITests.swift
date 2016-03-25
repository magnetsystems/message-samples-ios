//  MessengerUITests.swift
//  MessengerUITests
//
//  Created by agordyman on 3/14/16.
//  Copyright © 2016 Magnet Systems, Inc. All rights reserved.
//

import XCTest

class MessengerUITests: XCTestCase {
    
    let kExpectationsTimeout : NSTimeInterval = 60
    let password = "Temp1234%"
    let passwordagain = "Temp1234%"
    let lName = "test"
    
    let userName = "test62@automation.gmail.com"
    let fName = "AutomationTestUser62"
    let fullName = "AutomationTestUser62 test"
    
    let userNameTwo = "test63@automation.gmail.com"
    let fNameTwo = "AutomationTestUser63"
    let fullNameTwo = "AutomationTestUser63 test"
    
    let userNameThree = "test64@automation.gmail.com"
    let fNameThree = "AutomationTestUser64"
    let fullNameThree = "AutomationTestUser64 test"
    
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
    
    //Help mark - delay for opened app
    func delay()    {
        let expactation = self.expectationWithDescription("app timed out.")
        let seconds : UInt64 = 3
        //waiting for time (3 sec) to app callback
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (Int64)(seconds * NSEC_PER_SEC)), dispatch_get_main_queue(), {
            expactation.fulfill()
        })
        
        self.waitForExpectationsWithTimeout(kExpectationsTimeout, handler: nil)
    }
    
    //Help mark - registration a new user
    func registration(userName:String!, password:String!, passwordagain:String!, fName:String!, lName:String!){
        let app = XCUIApplication()
        let createbutton = app.buttons["Create account"]
        self.delay()
        createbutton.tap()
        
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
        passwordSecureTextField.typeText(password!)
        
        let passwordAgainSecureTextField = app.secureTextFields["Password again"]
        passwordAgainSecureTextField.tap()
        passwordAgainSecureTextField.typeText(passwordagain)
        
        app.navigationBars["Register"].buttons["Register"].tap()
        
        self.delay()
        
        XCTAssert(app.activityIndicators.count == 1, "ActivityIndicator is missed")
    }
    
    //Help mark - login to the app
    func login(userName:String!, password:String!)
    {
        let app = XCUIApplication()
        let emailAddressTextField = app.textFields["Email Address"]
        
        self.delay()
        
        emailAddressTextField.tap()
        emailAddressTextField.typeText(userName)
        
        let passwordSecureTextField = app.secureTextFields["Password"]
        passwordSecureTextField.tap()
        passwordSecureTextField.typeText(password)
        
        let button = app.otherElements.containingType(.NavigationBar, identifier:"Messenger.SignInView").childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.childrenMatchingType(.Button).elementBoundByIndex(0)
        button.tap()
        
        app.buttons["Sign in"].tap()
        
        self.delay()
    }
    
    //Help mark - logout of the app when registration is successful
    func logout_after_registration(fullName:String!){
        let app = XCUIApplication()
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
        
        self.delay()
    }
    
    //Help mark - logout of the app when login is successful
    func logout_after_login(fullName:String!){
        let app = XCUIApplication()
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
        
        self.delay()
    }
    
    //Test1 Negative scenario - Login with invalid credentials
    func test01LoginWithInvalidCredentials()
    {
        let app = XCUIApplication()
        
        self.login("agordyman@geeksforless.net", password: "HJSDFHJSDFJ")
        //a few checks, related to appeared error alert
        XCTAssert(app.alerts["Couldn't log in"].exists)
        XCTAssert(app.staticTexts["Couldn't log in"].exists)
        XCTAssert(app.staticTexts["Username and password not found.  Please try again."].exists)
        XCTAssertEqual(app.staticTexts["Username and password not found.  Please try again."].label, "Username and password not found.  Please try again.")
        app.collectionViews.buttons["Close"].tap()
    }
    
    //Test2 Negative scenario - Register a user with empty fields
    func test02RegisterUserWithEmptyFields()
    {
        let app = XCUIApplication()
        
        self.registration("", password: "", passwordagain: "", fName: "", lName: "")
        
        let fieldRequiredAlert = app.alerts["Field required"]
        //a few checks, related to appeared error alert
        XCTAssert(app.alerts["Field required"].exists)
        XCTAssert(app.staticTexts["Field required"].exists)
        XCTAssertEqual(app.staticTexts["Please enter your first and last name"].label, "Please enter your first and last name")
        fieldRequiredAlert.collectionViews.buttons["Close"].tap()
    }
    
    //Test3 Negative scenario - Register a user with empty password
    func test03RegisterUserWithEmptyPassword()
    {
        let app = XCUIApplication()
        
        self.registration(userName, password: "", passwordagain: "", fName: fName, lName: lName)
        
        let fieldRequiredAlert = app.alerts["Field required"]
        //a few checks, related to appeared error alert
        XCTAssert(app.alerts["Field required"].exists)
        XCTAssert(app.staticTexts["Please enter your password and verify your password again"].exists)
        XCTAssertEqual(app.staticTexts["Please enter your password and verify your password again"].label, "Please enter your password and verify your password again")
        fieldRequiredAlert.collectionViews.buttons["Close"].tap()
    }
    
    //Test4 Negative scenario - Register a user with mismatch passwords
    func test04RegisterUserWithMismatchPassword()
    {
        let app = XCUIApplication()
        
        self.registration(userName, password: "alexander1", passwordagain: "alexander2", fName: fName, lName: lName)
        
        let fieldRequiredAlert = app.alerts["Field required"]
        //a few checks, related to appeared error alert
        XCTAssert(app.alerts["Field required"].exists)
        XCTAssert(app.staticTexts["Please enter your password and verify your password again"].exists)
        XCTAssertEqual(app.staticTexts["Please enter your password and verify your password again"].label, "Please enter your password and verify your password again")
        fieldRequiredAlert.collectionViews.buttons["Close"].tap()
    }
    
    //Test5 Negative scenario - Register a user with invaild email
    func test05RegisterUserWithInvalidEmail()
    {
        let app = XCUIApplication()
        
        self.registration("$##$#$#$#$#$", password: password, passwordagain: passwordagain, fName: fName, lName: lName)
        
        let fieldRequiredAlert = app.alerts["Field required"]
        //a few checks, related to appeared error alert
        XCTAssert(app.alerts["Field required"].exists)
        XCTAssert(app.staticTexts["Please enter your email"].exists)
        XCTAssertEqual(app.staticTexts["Please enter your email"].label, "Please enter your email")
        fieldRequiredAlert.collectionViews.buttons["Close"].tap()
    }
    
    //Test6-7 Positive scenarios - Register a new user with valid data and logout of the app
    func test06_07RegisterANewUser()
    {
        let app = XCUIApplication()
        self.registration(userName, password: password, passwordagain: passwordagain, fName: fName, lName: lName);
        self.delay()
        let myprofile = app.navigationBars["My Profile"]
        XCTAssert(myprofile.exists)
        self.logout_after_registration(fullName)
    }
    
    //Test8 Negative scenario - Register an existing user (just new created)
    func test08RegisterAnExistingUser()
    {
        let app = XCUIApplication()
        
        self.registration(userName, password: password, passwordagain: passwordagain, fName: fName, lName: lName);
        
        let emailTakenAlert = XCUIApplication().alerts["Email taken"]
        //a few checks, related to appeared error alert
        XCTAssert(app.alerts["Email taken"].exists)
        XCTAssert(app.staticTexts["Sorry, that email is already taken. Please select a new email and try again."].exists)
        XCTAssertEqual(app.staticTexts["Sorry, that email is already taken. Please select a new email and try again."].label, "Sorry, that email is already taken. Please select a new email and try again.")
        emailTakenAlert.collectionViews.buttons["Close"].tap()
    }
    
    //Test9 Positive scenario - Login to the app with valid credentials
    func test09LoginWithValidCredentials()
    {
        let app = XCUIApplication()
        self.login(userName, password: password)
        let button = app.buttons["Sign in"]
        self.delay()
        XCTAssertFalse(button.exists)
    }
    
    //Test10 Positive scenario - Set user avatar
    func test10SetAvatar()
    {
        /* login*/
        let app = XCUIApplication()
        self.login(userName, password: password)
        
        /* Set avatar */
        let navBar = app.navigationBars[fullName];
        let buttons = navBar.buttons["menu"];
        buttons.tap()
        
        let tablesQuery = app.tables
        tablesQuery.staticTexts[fullName].tap()
        app.childrenMatchingType(.Window).elementBoundByIndex(0).childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.childrenMatchingType(.Button).elementBoundByIndex(0).tap()
        tablesQuery.buttons["Moments"].tap()
        app.collectionViews["PhotosGridView"].childrenMatchingType(.Cell).elementBoundByIndex(1).tap()
        app.buttons["Save changes"].tap()
        
        let savedAlert = app.alerts["Saved"]
        XCTAssert(savedAlert.exists)
        XCTAssert(savedAlert.collectionViews.buttons["Close"].exists)
        savedAlert.collectionViews.buttons["Close"].tap()
        self.delay()
    }
    
    //Test11 Negative scenario - Search for non existing chat by user
    func test11SearchForNonExistingChatByUser()
    {
        /* login*/
        let app = XCUIApplication()
        self.login(userName, password: password)
        
        /* search for non existing user */
        app.tables.searchFields["Search message by user"].tap()
        let searchMessageByUserSearchField = app.searchFields["Search message by user"]
        searchMessageByUserSearchField.typeText("Alex")
        app.buttons["Search"].tap()
        self.delay()
        XCTAssertFalse(app.tables.staticTexts["Alex"].exists)
    }
    //Test12 Positive scenario - Check Ask Magnet Banner functionality
    func test12AskMagnetBanner()
    {
        /* login*/
        let app = XCUIApplication()
        self.login(userName, password: password)
        
        /* Ask Magnet Banner */
        let tables = app.tables.staticTexts["Ask Magnet"]
        tables.tap()
        
        self.delay()
        
        let askMagnetNavigationBar = XCUIApplication().navigationBars["Ask Magnet"]
        askMagnetNavigationBar.staticTexts["Ask Magnet"].tap()
        let backButton = askMagnetNavigationBar.childrenMatchingType(.Button).matchingIdentifier("Back").elementBoundByIndex(0)
        backButton.tap()
        XCTAssertFalse(backButton.exists)
        self.delay()
    }
    
    //Test13 Positive scenario - Register more users for further testing
    func test13RegisterMoreUsersForFurtherTesting()
    {
        /* Register User2 */
        self.registration(userNameTwo, password: password, passwordagain: passwordagain, fName: fNameTwo, lName: lName)
        
        /*LogOut*/
        self.logout_after_registration(fullNameTwo)
        
        /* Register User3 */
        self.registration(userNameThree, password: password, passwordagain: passwordagain, fName: fNameThree, lName: lName)
        
        /*LogOut*/
        self.logout_after_registration(fullNameThree)
    }
    
    //Test14-15 Positive scenarios - Create a new 1-1 chat and check channel details page
    func test14_15CreateANew1to1Chat()
    {
        /* login*/
        let app = XCUIApplication()
        self.login(userName, password: password)
        
        /* Create a new 1-1 chat */
        let navBar = XCUIApplication().navigationBars[fullName]
        let newMessage = navBar.buttons["new message"]
        newMessage.tap()
        
        let tablesQuery = XCUIApplication().tables
        tablesQuery.staticTexts[fullNameTwo].tap()
        
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
        self.delay()
        
        /* Check channel details */
        let navBarDetail = app.navigationBars[fNameTwo]
        let detailbutton = navBarDetail.buttons["Detail"]
        detailbutton.tap()
        
        let tablesQueryTwo = XCUIApplication().tables
        XCTAssert(tablesQueryTwo.staticTexts[fullName].exists)
        XCTAssert(tablesQueryTwo.staticTexts[fullNameTwo].exists)
        XCTAssert(tablesQueryTwo.staticTexts["+ Add Contact"].exists)
        self.delay()
    }
    
    //Test16 Positive scenario - Search for existing chat by user
    func test16SearchForExistingChatByUser()
    {
        /* login*/
        let app = XCUIApplication()
        self.login(userName, password: password)
        
        /* search for non existing user */
        app.tables.searchFields["Search message by user"].tap()
        let searchMessageByUserSearchField = app.searchFields["Search message by user"]
        searchMessageByUserSearchField.typeText(fullNameTwo)
        app.buttons["Search"].tap()
        self.delay()
        let user = app.tables.staticTexts[fullNameTwo]
        XCTAssert(user.exists)
    }
    
    //Test17 Positive scenario - send a couple photos by user1
    func test17SendACouplePhotos()
    {
        /* login*/
        let app = XCUIApplication()
        self.login(userName, password: password)
        
        /* send a couple photos by user1 */
        self.delay()
        self.delay()
        
        app.tables.staticTexts[fullNameTwo].tap()
        
        self.delay()
        
        let button = app.otherElements.containingType(.NavigationBar, identifier:"SWRevealView").childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.toolbars.childrenMatchingType(.Other).element.childrenMatchingType(.Other).elementBoundByIndex(0).childrenMatchingType(.Button).element
        let photoLibraryButton = app.sheets["Media Messages"].collectionViews.buttons["Photo Library"]
        button.tap()
        photoLibraryButton.tap()
        app.tables.buttons["Moments"].tap()
        app.collectionViews["PhotosGridView"].childrenMatchingType(.Cell).elementBoundByIndex(2).tap()
        
        self.delay()
        
        button.tap()
        photoLibraryButton.tap()
        app.navigationBars["Photos"].buttons["Cancel"].tap()
        button.tap()
        photoLibraryButton.tap()
        app.tables.buttons["Moments"].tap()
        app.collectionViews["PhotosGridView"].childrenMatchingType(.Cell).elementBoundByIndex(3).tap()
        
        self.delay()
        /*send location */
    }
}



