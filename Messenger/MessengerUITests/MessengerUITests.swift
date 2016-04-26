//  MessengerUITests.swift
//  MessengerUITests
//  Created by agordyman on 4/5/16.
//  Copyright © 2016 Lorenzo Stanton. All rights reserved.

import XCTest

class MessengerUITests: XCTestCase {
    
    let kExpectationsTimeout : NSTimeInterval = 60
    let password = "Temp1234%"
    let passwordagain = "Temp1234%"
    let lName = "test"
    let Group = "Group"
    
    let userName = "test05@magnet.com"
    let fName = "TestUser05"
    let fullName = "TestUser05 test"
    
    let userNameTwo = "test06@magnet.com"
    let fNameTwo = "TestUser06"
    let fullNameTwo = "TestUser06 test"
    
    let userNameThree = "test07@magnet.com"
    let fNameThree = "TestUser07"
    let fullNameThree = "TestUser07 test"
    
    let userNameFour = "test08@magnet.com"
    let fNameFour = "TestUser08"
    let fullNameFour = "TestUser08 test"
    
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    //Help mark - Delay for opened app screen
    func delay()
    {
        let expactation = self.expectationWithDescription("app screen timed out.")
        let seconds : UInt64 = 3
        //waiting for time (3 sec) to app screen callback
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (Int64)(seconds * NSEC_PER_SEC)), dispatch_get_main_queue(), {
            expactation.fulfill()
        })
        self.waitForExpectationsWithTimeout(kExpectationsTimeout, handler: nil)
    }
    
    //Help mark - Registration a new user
    func registration(userName:String!, password:String!, passwordagain:String!, fName:String!, lName:String!)
    {
        let app = XCUIApplication()
        let createbutton = app.buttons["Create account"]
        let firstNameTextField = app.textFields["First name"]
        let lastNameTextField = app.textFields["Last name"]
        let emailAddressTextField = app.textFields["Email Address"]
        let passwordSecureTextField = app.secureTextFields["Password"]
        let passwordAgainSecureTextField = app.secureTextFields["Password again"]
        
        self.delay()
        createbutton.tap()
        
        firstNameTextField.tap()
        firstNameTextField.typeText(fName)
        
        lastNameTextField.tap()
        lastNameTextField.typeText(lName)
        
        emailAddressTextField.tap()
        emailAddressTextField.typeText(userName)
        
        passwordSecureTextField.tap()
        passwordSecureTextField.typeText(password!)
        
        passwordAgainSecureTextField.tap()
        passwordAgainSecureTextField.typeText(passwordagain)
        
        app.navigationBars["Register"].buttons["Register"].tap()
        self.delay()
    }
    
    //Help mark - Login to the app
    func login(userName:String!, password:String!)
    {
        let app = XCUIApplication()
        let emailAddressTextField = app.textFields["Email Address"]
        let passwordSecureTextField = app.secureTextFields["Password"]
        let button = app.otherElements.containingType(.NavigationBar, identifier:"Messenger.SignInView").childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.childrenMatchingType(.Button).elementBoundByIndex(0)
        
        self.delay()
        emailAddressTextField.tap()
        emailAddressTextField.typeText(userName)
        
        passwordSecureTextField.tap()
        passwordSecureTextField.typeText(password)
        
        button.tap()
        app.buttons["Sign in"].tap()
        self.delay()
        self.delay()
    }
    
    //Help mark - Logout of the app when registration is successful
    func logout_after_registration(fullName:String!)
    {
        let app = XCUIApplication()
        let navBar = app.navigationBars[fullName]
        let button = navBar.buttons["≣"]
        let signOutStaticText = app.tables.staticTexts["Sign out"]
        
        self.delay()
        //checks
        XCTAssertFalse(app.navigationBars["Register"].buttons["Register"].exists)
        XCTAssert(app.navigationBars.staticTexts[fullName].exists)
        self.delay()
        button.tap()
        
        //sign out check
        XCTAssert(app.tables.staticTexts["Sign out"].exists)
        signOutStaticText.tap()
        self.delay()
    }
    
    //Help mark - Logout of the app when login is successful
    func logout_after_login(fullName:String!)
    {
        let app = XCUIApplication()
        let navBar = app.navigationBars[fullName]
        let menuButton = navBar.buttons["≣"]
        let signOutStaticText = app.tables.staticTexts["Sign out"]
        
        XCTAssert(app.navigationBars.staticTexts[fullName].exists)
        self.delay()
        menuButton.tap();
        
        //sign out checks
        XCTAssert(app.tables.staticTexts["Sign out"].exists)
        signOutStaticText.tap()
        self.delay()
    }
    
    //Help mark - Send a few photos
    func SendAFewPhotos()
    {
        let app = XCUIApplication()
        let button = app.toolbars.childrenMatchingType(.Other).element.childrenMatchingType(.Other).elementBoundByIndex(0).childrenMatchingType(.Button).element
        let photoLibraryButton = app.sheets["Media Messages"].collectionViews.buttons["Photo Library"]
        
        button.tap()
        photoLibraryButton.tap()
        app.tables.buttons["Moments"].tap()
        app.collectionViews["PhotosGridView"].childrenMatchingType(.Cell).elementBoundByIndex(1).tap()
        self.delay()
        
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
    }
    
    //Help mark - Check the created chat between users
    func CheckCreatedChannel(userNameTwo:String!, password:String!, fullName:String!)
    {
        let app = XCUIApplication()
        
        /* login user */
        self.login(userNameTwo, password: password)
        //self.delay()
        
        /* check created channel*/
        self.delay()
        self.delay()
        //created chat check
        XCTAssert(app.tables.staticTexts[fullName].exists)
        app.tables.staticTexts[fullName].tap()
        self.delay()
    }
    
    //Help mark - User leaves the created chat and check that user doesn't see the channels that are no longer subscribed on home page
    func UserLeavesTheChat(userNameTwo:String!, password:String!, fullNameTwo:String!)
    {
        let app = XCUIApplication()
        let tablesQuery = app.tables
        
        /* login user */
        self.login(userNameTwo, password: password)
        
        /* check created channel*/
        self.delay()
        self.delay()
        XCTAssert(tablesQuery.cells.containingType(.StaticText, identifier:"Attachment location").staticTexts[fullNameTwo].exists)
        
        tablesQuery.cells.containingType(.StaticText, identifier:"Attachment location").staticTexts[fullNameTwo].swipeLeft()
        tablesQuery.cells.buttons["Leave"].tap()
        
        self.delay()
        /* check that user1 (owner) doesn't see channels that are no longer subscribed on home page */
        XCTAssertFalse(tablesQuery.cells.containingType(.StaticText, identifier:"Attachment location").staticTexts[fullNameTwo].exists)
    }
    
    //Help mark - Asserts, related to the chat navigation and channel details
    func Asserts(Group:String!, fullNameTwo:String!)
    {
        /* check channel details */
        let app = XCUIApplication()
        let navBarDetail = app.navigationBars[Group]
        let detailbutton = navBarDetail.buttons["Details"]
        let tablesQueryTwo = XCUIApplication().tables
        
        /* chat navigation checks*/
        XCTAssert(navBarDetail.buttons["Back"].exists)
        XCTAssert(detailbutton.exists)
        XCTAssertEqual(navBarDetail.staticTexts[Group].label, Group)
        detailbutton.tap()
        self.delay()
        
        /* channel details checks */
        XCTAssert(app.navigationBars["In Group"].exists)
        XCTAssert(app.navigationBars["In Group"].buttons["Back"].exists)
        XCTAssertEqual(tablesQueryTwo.staticTexts[fullNameTwo].label, fullNameTwo)
        self.delay()
    }
    
    //Help mark - Send a text
    func SendAText()
    {
        let app = XCUIApplication()
        let sendButton = app.toolbars.buttons["Send"]
        
        /* send a text for creating 1-1 chat */
        app.toolbars.childrenMatchingType(.Other).element.childrenMatchingType(.TextView).element.tap()
        app.toolbars.childrenMatchingType(.Other).element.childrenMatchingType(.TextView).element.typeText("Test")
        sendButton.tap()
        self.delay()
    }
    
    //Help mark - Check sent text
    func SentTextCheck()
    {
        let app = XCUIApplication()
        XCTAssert(app.collectionViews.cells.childrenMatchingType(.TextView).element.exists)
        XCTAssertNotNil(app.collectionViews.cells.childrenMatchingType(.TextView).element)
    }
    
    //Help mark - Send location
    func SendLocation()
    {
        let app = XCUIApplication()
        app.toolbars.childrenMatchingType(.Other).element.childrenMatchingType(.Other).elementBoundByIndex(0).childrenMatchingType(.Button).element.tap()
        app.sheets["Media Messages"].collectionViews.buttons["Send Location"].tap()
        self.delay()
    }
    
    //Help mark - Check sent location
    func SentLocationCheck()
    {
        let app = XCUIApplication()
        XCTAssertNotNil(app.childrenMatchingType(.Window).elementBoundByIndex(0).childrenMatchingType(.Other).element.childrenMatchingType(.Other).element)
    }
    
    //Help mark - Sent Photos Checks
    func SentPhotosChecks()
    {
        let app = XCUIApplication()
        self.delay()
        
        XCTAssert(app.childrenMatchingType(.Window).elementBoundByIndex(0).childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.exists)
        XCTAssertNotNil(app.childrenMatchingType(.Window).elementBoundByIndex(0).childrenMatchingType(.Other).element.childrenMatchingType(.Other).element)
    }
    
    //Help mark - Contact list
    func ContactList(userNameTwo:String!, fullNameThree:String!, fullNameTwo:String!)
    {
        let app = XCUIApplication()
        let navBar = app.navigationBars[fullNameTwo]
        let newMessage = navBar.buttons["new message"]
        
        /* login user*/
        self.login(userNameTwo, password: password)
        
        /* user checks that another user is blocked */
        newMessage.tap()
        self.delay()
    }
    
    /**********************************************Test01-Test36************************************************/
    //Test1 Negative scenario - Login with empty credentials
    func test01LoginWithEmptyCredentials()
    {
        let app = XCUIApplication()
        self.login("", password: "")
        //a few checks, related to appeared error alert
        XCTAssert(app.alerts["Please fill in email and password"].exists)
        XCTAssert(app.staticTexts["Please fill in email and password"].exists)
        XCTAssertEqual(app.alerts["Please fill in email and password"].childrenMatchingType(.Other).element.childrenMatchingType(.Other).elementBoundByIndex(1).childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.childrenMatchingType(.Other).childrenMatchingType(.StaticText).matchingIdentifier("Please fill in email and password").elementBoundByIndex(0).label, "Please fill in email and password")
        XCTAssertEqual(app.alerts["Please fill in email and password"].childrenMatchingType(.Other).element.childrenMatchingType(.Other).elementBoundByIndex(1).childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.childrenMatchingType(.Other).childrenMatchingType(.StaticText).matchingIdentifier("Please fill in email and password").elementBoundByIndex(1).label, "Please fill in email and password")
        app.collectionViews.buttons["Close"].tap()
    }
    
    //Test2 Negative scenario - Login with invalid credentials
    func test02LoginWithInvalidCredentials()
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
    
    //Test3 Negative scenario - Register a user with empty fields
    func test03RegisterUserWithEmptyFields()
    {
        let app = XCUIApplication()
        let fieldRequiredAlert = app.alerts["Field required"]
        self.registration("", password: "", passwordagain: "", fName: "", lName: "")
        //a few checks, related to appeared error alert
        XCTAssert(app.alerts["Field required"].exists)
        XCTAssert(app.staticTexts["Field required"].exists)
        XCTAssertEqual(app.staticTexts["Please enter your first and last name"].label, "Please enter your first and last name")
        fieldRequiredAlert.collectionViews.buttons["Close"].tap()
    }
    
    //Test4 Negative scenario - Register a user with empty password
    func test04RegisterUserWithEmptyPassword()
    {
        let app = XCUIApplication()
        let fieldRequiredAlert = app.alerts["Field required"]
        self.registration(userName, password: "", passwordagain: "", fName: fName, lName: lName)
        //a few checks, related to appeared error alert
        XCTAssert(app.alerts["Field required"].exists)
        XCTAssert(app.staticTexts["Please enter your password and verify your password again"].exists)
        XCTAssertEqual(app.staticTexts["Please enter your password and verify your password again"].label, "Please enter your password and verify your password again")
        fieldRequiredAlert.collectionViews.buttons["Close"].tap()
    }
    
    //Test5 Negative scenario - Register a user with mismatch passwords
    func test05RegisterUserWithMismatchPassword()
    {
        let app = XCUIApplication()
        let fieldRequiredAlert = app.alerts["Field required"]
        self.registration(userName, password: "alexander1", passwordagain: "alexander2", fName: fName, lName: lName)
        //a few checks, related to appeared error alert
        XCTAssert(app.alerts["Field required"].exists)
        XCTAssert(app.staticTexts["Please enter your password and verify your password again"].exists)
        XCTAssertEqual(app.staticTexts["Please enter your password and verify your password again"].label, "Please enter your password and verify your password again")
        fieldRequiredAlert.collectionViews.buttons["Close"].tap()
    }
    
    //Test6 Negative scenario - Register a user with invalid email
    func test06RegisterUserWithInvalidEmail()
    {
        let app = XCUIApplication()
        let fieldRequiredAlert = app.alerts["Field required"]
        self.registration("$##$#$#$#$#$", password: password, passwordagain: passwordagain, fName: fName, lName: lName)
        //a few checks, related to appeared error alert
        XCTAssert(app.alerts["Field required"].exists)
        XCTAssert(app.staticTexts["Please enter your email"].exists)
        XCTAssertEqual(app.staticTexts["Please enter your email"].label, "Please enter your email")
        fieldRequiredAlert.collectionViews.buttons["Close"].tap()
    }
    
    //Test7-8 Positive scenarios - Register a new user with valid data and logout of the app
    func test07_08RegisterANewUser()
    {
        self.registration(userName, password: password, passwordagain: passwordagain, fName: fName, lName: lName);
        self.delay()
        XCTAssertFalse(XCUIApplication().navigationBars["Register"].buttons["Register"].exists)
        self.logout_after_registration(fullName)
    }
    
    //Test9 Negative scenario - Register an existing user (just new created)
    func test09RegisterAnExistingUser()
    {
        let app = XCUIApplication()
        let emailTakenAlert = app.alerts["Username taken"]
        self.registration(userName, password: password, passwordagain: passwordagain, fName: fName, lName: lName);
        //a few checks, related to appeared error alert
        XCTAssert(app.alerts["Username taken"].exists)
        XCTAssert(app.staticTexts["Sorry, that username is already taken. Please select a new username and try again."].exists)
        XCTAssertEqual(app.staticTexts["Sorry, that username is already taken. Please select a new username and try again."].label, "Sorry, that username is already taken. Please select a new username and try again.")
        emailTakenAlert.collectionViews.buttons["Close"].tap()
    }
    
    //Test10 Positive scenario - Login to the app with valid credentials
    func test10LoginWithValidCredentials()
    {
        let app = XCUIApplication()
        let button = app.buttons["Sign in"]
        /* login user1 */
        self.login(userName, password: password)
        self.delay()
        self.delay()
        //login check
        XCTAssertFalse(button.exists)
    }
    
    //Test11 Positive scenario - Check "Remember me" option functionality
    func test11CheckRememberMeOption()
    {
        let app = XCUIApplication()
        let emailAddressTextField = app.textFields["Email Address"]
        let passwordSecureTextField = app.secureTextFields["Password"]
        let button = app.buttons["Sign in"]
        
        self.delay()
        emailAddressTextField.tap()
        emailAddressTextField.typeText(userName)
        
        passwordSecureTextField.tap()
        passwordSecureTextField.typeText(password)
        
        button.tap()
        self.delay()
        self.delay()
        
        app.terminate()
        self.delay()
        app.launch()
        self.delay()
        self.delay()
        //login check
        XCTAssertFalse(button.exists)
        self.logout_after_login(fullName)
    }
    
    
    //Test12 Positive scenario - User sets avatar
    func test12SetAvatar()
    {
        let app = XCUIApplication()
        let navBar = app.navigationBars[fullName];
        let buttons = navBar.buttons["≣"];
        let tablesQuery = app.tables
        let savedAlert = app.alerts["Saved"]
        
        /* login user1 */
        self.login(userName, password: password)
        
        /* set avatar */
        self.delay()
        buttons.tap()
        
        tablesQuery.staticTexts[fullName].tap()
        
        app.childrenMatchingType(.Window).elementBoundByIndex(0).childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.childrenMatchingType(.Button).elementBoundByIndex(0).tap()
        
        tablesQuery.buttons["Moments"].tap()
        app.collectionViews["PhotosGridView"].childrenMatchingType(.Cell).elementBoundByIndex(1).tap()
        app.buttons["Save changes"].tap()
        //alert checks
        XCTAssert(savedAlert.exists)
        XCTAssert(savedAlert.collectionViews.buttons["Close"].exists)
        savedAlert.collectionViews.buttons["Close"].tap()
        self.delay()
    }
    
    //Test13 Positive scenario - User checks Ask Magnet Banner
    func test13AskMagnetBanner()
    {
        let app = XCUIApplication()
        let tables = app.tables.staticTexts["Ask Magnet"]
        
        /* login user1*/
        self.login(userName, password: password)
        
        /* Ask Magnet banner */
        tables.tap()
        self.delay()
        
        /* Ask Magnet navigation checks */
        XCTAssert(app.navigationBars["Ask Magnet"].buttons["Details"].exists)
        XCTAssert(app.navigationBars["Ask Magnet"].childrenMatchingType(.Button).matchingIdentifier("Back").elementBoundByIndex(0).exists)
        app.navigationBars["Ask Magnet"].buttons["Details"].tap()
        self.delay()
        XCTAssertEqual(app.navigationBars["In Group"].staticTexts["In Group"].label, "In Group")
        XCTAssert(app.tables.otherElements.buttons["Add Contacts +"].exists)
        
        app.navigationBars["In Group"].buttons["Back"].tap()
        app.navigationBars["Ask Magnet"].childrenMatchingType(.Button).matchingIdentifier("Back").elementBoundByIndex(0).tap()
        self.delay()
        XCTAssertFalse(app.navigationBars["Ask Magnet"].buttons["Details"].exists)
        self.delay()
    }
    
    //Test14 Positive scenario - Register more users (user2, user3, user4) for further testing
    func test14RegisterMoreUsersForFurtherTesting()
    {
        /* register user2 */
        self.registration(userNameTwo, password: password, passwordagain: passwordagain, fName: fNameTwo, lName: lName)
        
        /* logout user2 */
        self.logout_after_registration(fullNameTwo)
        
        /* register user3 */
        self.registration(userNameThree, password: password, passwordagain: passwordagain, fName: fNameThree, lName: lName)
        
        /* logout user3 */
        self.logout_after_registration(fullNameThree)
        
        /* register user4 */
        self.registration(userNameFour, password: password, passwordagain: passwordagain, fName: fNameFour, lName: lName)
        
        /* logout user4 */
        self.logout_after_registration(fullNameFour)
    }
    
    //Test15-16 Negative and Positive scenarios - Search for non exisitng and existing contacts
    func test15_16SearchForNonExistingContact()
    {
        let app = XCUIApplication()
        let navBar = app.navigationBars[fullName]
        let newMessage = navBar.buttons["new message@2x"]
        
        /* login user1 */
        self.login(userName, password: password)
        newMessage.tap()
        
        /* search for non existing contact */
        app.childrenMatchingType(.Window).elementBoundByIndex(0).childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.childrenMatchingType(.SearchField).element.tap()
        
        app.childrenMatchingType(.Window).elementBoundByIndex(0).childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.childrenMatchingType(.SearchField).element.typeText("NonExistingUser")
        
        self.delay()
        XCTAssertFalse(app.tables.cells.staticTexts["NonExistingUser"].exists)
        
        /* search for existing contact */
        app.searchFields.buttons["Clear text"].tap()
        
        app.childrenMatchingType(.Window).elementBoundByIndex(0).childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.childrenMatchingType(.SearchField).element.tap()
        
        app.childrenMatchingType(.Window).elementBoundByIndex(0).childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.childrenMatchingType(.SearchField).element.typeText(fNameTwo)
        
        self.delay()
        XCTAssert(app.tables.cells.staticTexts[fullNameTwo].exists)
    }
    
    //Test17-18 Positive scenarios - User1 (initiator) creates a new 1-1 chat and checks the channel details page
    func test17_18CreateANew1to1Chat()
    {
        let app = XCUIApplication()
        let navBar = app.navigationBars[fullName]
        let newMessage = navBar.buttons["new message@2x"]
        let tablesQuery = app.tables
        let navBarTwo = app.navigationBars["Contacts"]
        let buttonNext = navBarTwo.buttons["Next"]
        
        /* login user1 */
        self.login(userName, password: password)
        
        /* create a new 1-1 chat */
        newMessage.tap()
        tablesQuery.staticTexts[fullNameTwo].tap()
        
        //next button check
        XCTAssert(buttonNext.exists)
        buttonNext.tap()
        
        /* send a text for creating 1-1 chat */
        self.SendAText()
        
        /* check sent text */
        self.SentTextCheck()
        
        /* send a few photos for created 1-1 chat */
        self.SendAFewPhotos()
        
        /* check sent photos */
        self.SentPhotosChecks()
        
        /* send location for created 1-1 chat */
        self.SendLocation()
        
        /* check sent location */
        self.SentLocationCheck()
        
        /* check channel details using asserts function + additional check assert */
        self.Asserts(fullNameTwo, fullNameTwo:fullNameTwo)
        XCTAssert(tablesQuery.otherElements.buttons["Add Contacts +"].exists)
    }
    
    
    //Test19-20 Positive scenarios - User2 (subscriber) checks 1-1 chat created by user1 and checks the channel details page
    func test19_20CheckCreatedChannelAndDetails()
    {
        let app = XCUIApplication()
        
        /* user2 checks 1-1 chat which was created by user1 */
        self.CheckCreatedChannel(userNameTwo, password: password, fullName: fullName)
        
        /* check sent text */
        self.SentTextCheck()
        
        /* check sent photos */
        self.SentPhotosChecks()
        
        /* check sent location */
        XCTAssertNotNil(app.childrenMatchingType(.Window).elementBoundByIndex(0).childrenMatchingType(.Other).element.childrenMatchingType(.Other).element)
        
        /* check channel details using assert function + additional check assert */
        self.Asserts(fullName, fullNameTwo:fullName)
        XCTAssertFalse(app.tables.otherElements.buttons["Add Contacts +"].exists)
    }
    
    //Test21-22 Positive scenario - User2 (subscriber) leaves the 1-1 chat created by user1 and checks that he doesn't see channel that are no longer subscribed on home page
    func test21_22User2LeavesTheChat()
    {
        /* user2*/
        self.UserLeavesTheChat(userNameTwo, password: password, fullNameTwo: fullName)
    }
    
    //Test23-24 Positive scenarios - User1 (initiator) creates a multiple 1-2 chat and checks the channel details page
    func test23_24CreateAMultipleChat()
    {
        let app = XCUIApplication()
        let navBar = app.navigationBars[fullName]
        let newMessage = navBar.buttons["new message@2x"]
        let tablesQuery = app.tables
        let navBarTwo = app.navigationBars["Contacts"]
        let buttonNext = navBarTwo.buttons["Next"]
        
        /* login user1 */
        self.login(userName, password: password)
        
        /* create 1-2 multiple chat */
        newMessage.tap()
        tablesQuery.staticTexts[fullNameTwo].tap()
        tablesQuery.staticTexts[fullNameThree].tap()
        //next button check
        XCTAssert(buttonNext.exists)
        buttonNext.tap()
        
        /* send a text for creating 1-1 chat */
        self.SendAText()
        
        /* check sent text */
        self.SentTextCheck()
        
        /* send a few photos for created multiple 1-2 chat */
        self.SendAFewPhotos()
        
        /* check sent photos */
        self.SentPhotosChecks()
        
        /* send location for created 1-1 chat */
        self.SendLocation()
        
        /* check sent location */
        self.SentLocationCheck()
        
        /* check channel details using asserts function + additional checks assert */
        self.Asserts(Group, fullNameTwo:fullNameTwo)
        XCTAssertEqual(tablesQuery.staticTexts[fullNameThree].label, fullNameThree)
        XCTAssert(tablesQuery.otherElements.buttons["Add Contacts +"].exists)
        self.delay()
    }
    
    //Test25-26 Positive scenarios - User2 checks multiple 1-2 chat created by user1 and checks the chat details page
    func test25_26CheckCreatedChannelAndDetailsUser2()
    {
        /* user2 checks created multiple 1-2 chat */
        let app = XCUIApplication()
        let tablesQueryTwo = app.tables
        let UserTwoSees = fullName + ", " + fullNameThree
        self.CheckCreatedChannel(userNameTwo, password: password, fullName: UserTwoSees)
        
        /* check sent text */
        self.SentTextCheck()
        
        /* check sent photos */
        self.SentPhotosChecks()
        
        /* check channel details using asserts function + additional checks assert */
        self.Asserts(Group, fullNameTwo: fullName)
        XCTAssertEqual(tablesQueryTwo.staticTexts[fullNameThree].label, fullNameThree)
        XCTAssertFalse(tablesQueryTwo.otherElements.buttons["Add Contacts +"].exists)
    }
    
    //Test27-28 Positive scenarios - User3 checks multiple 1-2 chat created by user1 and checks the chat details page
    func test27_28CheckCreatedChannelAndDetailsUser3()
    {
        /* user3 checks created multiple 1-2 chat */
        let app = XCUIApplication()
        let tablesQueryTwo = app.tables
        let UserThreeSees = fullName + ", " + fullNameTwo
        self.CheckCreatedChannel(userNameThree, password: password, fullName: UserThreeSees)
        
        /* check sent text */
        self.SentTextCheck()
        
        /* check sent photos */
        self.SentPhotosChecks()
        
        /* check channel details using asserts function + additional checks assert */
        self.Asserts(Group, fullNameTwo: fullName)
        XCTAssertEqual(tablesQueryTwo.staticTexts[fullNameTwo].label, fullNameTwo)
        XCTAssertFalse(tablesQueryTwo.otherElements.buttons["Add Contacts +"].exists)
    }
    
    //Test29-30 Positive scenarios - User1 (initiator) adds user4 to the created multiple 1-2 chat and checks the chat details page (user4 should be successfully added and displayed)
    func test29_30User1InitiatorAddsOneMoreUser()
    {
        let app = XCUIApplication()
        let UserOneSees = fullNameTwo + ", " + fullNameThree
        let navBarDetail = app.navigationBars[Group]
        let detailbutton = navBarDetail.buttons["Details"]
        let tablesQuery = XCUIApplication().tables
        let navBarTwo = app.navigationBars["Contacts"]
        let buttonNext = navBarTwo.buttons["Next"]
        
        /* user1 adds user4 */
        self.CheckCreatedChannel(userName, password: password, fullName: UserOneSees)
        detailbutton.tap()
        self.delay()
        
        XCTAssert(tablesQuery.otherElements.buttons["Add Contacts +"].exists)
        tablesQuery.otherElements.buttons["Add Contacts +"].tap()
        tablesQuery.staticTexts[fullNameFour].tap()
        //Next button check
        XCTAssert(buttonNext.exists)
        buttonNext.tap()
        self.delay()
        
        /* check chat details */
        detailbutton.tap()
        self.delay()
        XCTAssert(app.navigationBars["In Group"].exists)
        //XCTAssert(app.navigationBars["Details"].buttons[fNameTwo].exists)
        XCTAssertEqual(tablesQuery.staticTexts[fullNameTwo].label, fullNameTwo)
        XCTAssertEqual(tablesQuery.staticTexts[fullNameThree].label, fullNameThree)
        XCTAssertEqual(tablesQuery.staticTexts[fullNameFour].label, fullNameFour)
        self.delay()
    }
    
    //Test31-32 Positive scenarios - User4 checks updated multiple 1-3 chat created by user1 and checks the channel details page
    func test31_32CheckCreatedChannelAndDetailsUser4()
    {
        /* user4 checks created multiple 1-3 chat */
        let app = XCUIApplication()
        let tablesQueryTwo = app.tables
        let UserFourSees = fullName + ", " + fullNameTwo + ", " + fullNameThree
        self.CheckCreatedChannel(userNameFour, password: password, fullName: UserFourSees)
        
        /* check sent text */
        self.SentTextCheck()
        
        /* check sent photos */
        self.SentPhotosChecks()
        
        /* user4 checks chat details */
        self.Asserts(Group, fullNameTwo: fullName)
        XCTAssertEqual(tablesQueryTwo.staticTexts[fullNameTwo].label, fullNameTwo)
        XCTAssertEqual(tablesQueryTwo.staticTexts[fullNameThree].label, fullNameThree)
        XCTAssertFalse(tablesQueryTwo.otherElements.buttons["Add Contacts +"].exists)
    }
    
    //Test33-34 Positive scenarios - User1 (initiator) leaves the updated multiple 1-3 chat and checks that he doesn't see channel that are no longer subscribed on home page
    func test33_34User1InitiatorLeavesTheChat()
    {
        /* user1 */
        let UserOneSees = fullNameTwo + ", " + fullNameThree + ", " + fullNameFour
        self.UserLeavesTheChat(userName, password: password, fullNameTwo: UserOneSees)
    }
    
    //Test35-36 Positive scenarios - User2 checks updated multiple 1-2 chat when user1 (initiator) left chat and checks the channel details page
    func test35_36CheckCreatedChannelAndDetailsUser2()
    {
        /* user4 checks created multiple 1-3 chat */
        let app = XCUIApplication()
        let tablesQueryTwo = app.tables
        let UserTwoSees = fullNameThree + ", " + fullNameFour
        self.CheckCreatedChannel(userNameTwo, password: password, fullName: UserTwoSees)
        
        /* check sent text */
        self.SentTextCheck()
        
        /* check sent photos */
        self.SentPhotosChecks()
        
        /* user4 checks chat details */
        self.Asserts(Group, fullNameTwo: fullNameThree)
        XCTAssertEqual(tablesQueryTwo.staticTexts[fullNameFour].label, fullNameFour)
        XCTAssertFalse(tablesQueryTwo.otherElements.buttons["Add Contacts +"].exists)
    }
}