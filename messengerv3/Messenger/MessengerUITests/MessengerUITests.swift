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
    
    let userName = "test002@automation.gmail.com"
    let fName = "AutomationTestUser002"
    let fullName = "AutomationTestUser002 test"
    
    let userNameTwo = "test008@automation.gmail.com"
    let fNameTwo = "AutomationTestUser008"
    let fullNameTwo = "AutomationTestUser008 test"
    
    let userNameThree = "test008@automation.gmail.com"
    let fNameThree = "AutomationTestUser008"
    let fullNameThree = "AutomationTestUser008 test"
    
    let userNameFour = "test009@automation.gmail.com"
    let fNameFour = "AutomationTestUser009"
    let fullNameFour = "AutomationTestUser009 test"
    
    // let temporaryfullName = "1Test 1Test"
    //let temporaryfNameTwo = "1Test"
    
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
    
    //Help mark - User leaves the created chat
    func UserLeavesTheChat(userNameTwo:String!, password:String!, fullName:String!, fullNameTwo:String!)
    {
        let app = XCUIApplication()
        // let navbar = app.navigationBars[fullName]
        // let detail = navbar.buttons["Detail"]
        // let leave = app.navigationBars["Details"].buttons["Leave"]
        
        /* login user */
        self.login(userNameTwo, password: password)
        
        /* check created channel*/
        self.delay()
        self.delay()
        
        
        app.tables.staticTexts[fullName].tap()
        self.delay()
        
        /* leave the chat */
        //  detail.tap()
        self.delay()
        //  leave.tap()
        //XCTAssertFalse(app.tables.staticTexts[fullName].exists) commented due to bug MAX-275. Creating test20 in order to check behavior of the messenger after re-login.
        self.delay()
        self.logout_after_login(fullNameTwo)
    }
    
    //Help mark - Asserts, related to the chat navigation and channel details
    func Asserts(fullNameTwo:String!)
    {
        /* check channel details */
        let app = XCUIApplication()
        let navBarDetail = app.navigationBars[fullNameTwo]
        let detailbutton = navBarDetail.buttons["Details"]
        let tablesQueryTwo = XCUIApplication().tables
        
        /* chat navigation checks*/
        XCTAssert(navBarDetail.buttons["Back"].exists)
        XCTAssert(detailbutton.exists)
        XCTAssertEqual(navBarDetail.staticTexts[fullNameTwo].label, fullNameTwo)
        detailbutton.tap()
        self.delay()
        
        /* channel details checks */
        XCTAssert(app.navigationBars["In Group"].exists)
        //XCTAssert(app.navigationBars["In Group"].buttons[fullNameTwo].exists)
        XCTAssertEqual(tablesQueryTwo.staticTexts[fullNameTwo].label, fullNameTwo)
        self.delay()
    }
    
    //Help mark - SentPhotosChecks
    func SentPhotosChecks()
    {
        let app = XCUIApplication()
        self.delay()
        
        XCTAssert(app.collectionViews.childrenMatchingType(.Cell).elementBoundByIndex(1).childrenMatchingType(.Other).element.exists)
        XCTAssertNotNil(app.collectionViews.childrenMatchingType(.Cell).elementBoundByIndex(1).childrenMatchingType(.Other).element)
        
        XCTAssert(app.collectionViews.childrenMatchingType(.Cell).elementBoundByIndex(2).childrenMatchingType(.Other).element.exists)
        XCTAssertNotNil(app.collectionViews.childrenMatchingType(.Cell).elementBoundByIndex(2).childrenMatchingType(.Other).element)
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
    
    /**********************************************Test01-Test40************************************************/
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
        let fieldRequiredAlert = app.alerts["Field required"]
        self.registration("", password: "", passwordagain: "", fName: "", lName: "")
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
        let fieldRequiredAlert = app.alerts["Field required"]
        self.registration(userName, password: "", passwordagain: "", fName: fName, lName: lName)
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
        let fieldRequiredAlert = app.alerts["Field required"]
        self.registration(userName, password: "alexander1", passwordagain: "alexander2", fName: fName, lName: lName)
        //a few checks, related to appeared error alert
        XCTAssert(app.alerts["Field required"].exists)
        XCTAssert(app.staticTexts["Please enter your password and verify your password again"].exists)
        XCTAssertEqual(app.staticTexts["Please enter your password and verify your password again"].label, "Please enter your password and verify your password again")
        fieldRequiredAlert.collectionViews.buttons["Close"].tap()
    }
    
    //Test5 Negative scenario - Register a user with invalid email
    func test05RegisterUserWithInvalidEmail()
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
    
    //Test6-7 Positive scenarios - Register a new user with valid data and logout of the app
    func test06_07RegisterANewUser()
    {
        self.registration(userName, password: password, passwordagain: passwordagain, fName: fName, lName: lName);
        self.delay()
        XCTAssertFalse(XCUIApplication().navigationBars["Register"].buttons["Register"].exists)
        self.logout_after_registration(fullName)
    }
    
    //Test8 Negative scenario - Register an existing user (just new created)
    func test08RegisterAnExistingUser()
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
    
    //Test9 Positive scenario - Login to the app with valid credentials
    func test09LoginWithValidCredentials()
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
    
    //Test10 Positive scenario - User sets avatar
    func test10SetAvatar()
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
    
    //Test11 Positive scenario - User checks Ask Magnet Banner
    func test11AskMagnetBanner()
    {
        let app = XCUIApplication()
        let tables = app.tables.staticTexts["Ask Magnet"]
        
        /* login user1*/
        self.login(userName, password: password)
        
        /* Ask Magnet banner */
        tables.tap()
        self.delay()
        
        /* Ask Magnet navigation checks */
        XCTAssert(app.navigationBars[fullName].buttons["Details"].exists)
        XCTAssert(app.navigationBars[fullName].childrenMatchingType(.Button).matchingIdentifier("Back").elementBoundByIndex(0).exists)
        app.navigationBars[fullName].buttons["Details"].tap()
        self.delay()
        XCTAssertEqual(app.navigationBars["In Group"].staticTexts["In Group"].label, "In Group")
        XCTAssert(app.tables.otherElements.buttons["Add Contacts +"].exists)
        
        app.navigationBars["In Group"].buttons["Back"].tap()
        app.navigationBars[fullName].childrenMatchingType(.Button).matchingIdentifier("Back").elementBoundByIndex(0).tap()
        self.delay()
        XCTAssertFalse(app.navigationBars[fullName].buttons["Details"].exists)
        self.delay()
    }
    
    //Test12 Positive scenario - Register more users (user2, user3, user4) for further testing
    func test12RegisterMoreUsersForFurtherTesting()
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
    
    //Test13-14 Positive scenarios - User1 (initiator) creates a new 1-1 chat and checks the channel details page
    func test13_14CreateANew1to1Chat()
    {
        let app = XCUIApplication()
        let navBar = app.navigationBars[fullName]
        let newMessage = navBar.buttons["new message@2x"]
        let tablesQuery = app.tables
        let navBarTwo = app.navigationBars["Contacts"]
        let buttonNext = navBarTwo.buttons["Next"]
        let tablesQueryTwo = app.tables
        
        /* login user1 */
        self.login(userName, password: password)
        
        /* create a new 1-1 chat */
        newMessage.tap()
        // tablesQuery.staticTexts[temporaryfullName].tap()
        tablesQuery.staticTexts[fullNameTwo].tap()
        
        //next button check
        XCTAssert(buttonNext.exists)
        buttonNext.tap()
        
        /* send a few photos for creating 1-1 chat */
        self.SendAFewPhotos()
        
        /* check sent photos */
        self.SentPhotosChecks()
        
        /* check channel details using asserts function + additional check assert */
        self.Asserts(fullNameTwo)
        XCTAssert(tablesQueryTwo.otherElements.buttons["Add Contacts +"].exists)
    }
    
    //Test15-16 Positive scenarios - User2 (subscriber) checks 1-1 chat created by user1 and checks the channel details page
    func test15_16CheckCreatedChannelAndDetails()
    {
        let app = XCUIApplication()
        
        /* user2 checks 1-1 chat which was created by user1 */
        self.CheckCreatedChannel(userNameTwo, password: password, fullName: fullName)
        
        /* check sent photos */
        self.SentPhotosChecks()
        
        /* check channel details using assert function + additional check assert */
        self.Asserts(fullName)
        XCTAssertFalse(app.tables.otherElements.buttons["Add Contacts +"].exists)
    }
    
    //    //Test19 Positive scenario - User2 (subscriber) leaves the 1-1 chat created by user1
    //    func test19User2LeavesTheChat()
    //    {
    //        /* user2*/
    //        self.UserLeavesTheChat(userNameTwo, password: password, fullName: fullName, fName: fName, fullNameTwo: fullNameTwo)
    //    }
    
    //    //Test20 Positive scenario - Check that user2 (subscriber) doesn't see channels that are no longer subscribed on home page
    //    func test20CheckAbandonedChat()
    //    {
    //        let app = XCUIApplication()
    //
    //        /* login user2 */
    //        self.login(userNameTwo, password: password)
    //
    //        /* check abandoned channel */
    //        self.delay()
    //        self.delay()
    //        //abandoned chat check
    //        XCTAssertFalse(app.tables.staticTexts[fullName].exists)
    //    }
    //
    //    //Test21-22 Positive scenarios - User1 (initiator) creates a multiple 1-2 chat and checks the channel details page
    //    func test21_22CreateAMultipleChat()
    //    {
    //        let app = XCUIApplication()
    //        let navBar = app.navigationBars[fullName]
    //        let newMessage = navBar.buttons["new message"]
    //        let tablesQuery = app.tables
    //        let tablesQueryTwo = app.tables
    //        let navBarTwo = app.navigationBars["New message"]
    //        let buttonNext = navBarTwo.buttons["Next"]
    //
    //        /* login user1 */
    //        self.login(userName, password: password)
    //
    //        /* create 1-2 multiple chat */
    //        newMessage.tap()
    //        tablesQuery.staticTexts[fullNameTwo].tap()
    //        tablesQuery.staticTexts[fullNameThree].tap()
    //        //next button check
    //        XCTAssert(buttonNext.exists)
    //        buttonNext.tap()
    //
    //        /* send a few photos for creating multiple 1-2 chat */
    //        self.SendAFewPhotos()
    //
    //        /* check sent photos */
    //        self.SentPhotosChecks()
    //
    //        /* check channel details using asserts function + additional checks assert */
    //        self.Asserts(Group, fullName: fullName, fullNameTwo: fullNameTwo)
    //        XCTAssertEqual(tablesQueryTwo.staticTexts[fullNameThree].label, fullNameThree)
    //        XCTAssertEqual(tablesQueryTwo.staticTexts["+ Add Contact"].label, "+ Add Contact")
    //        self.delay()
    //    }
    //
    //    //Test23-24 Positive scenarios - User2 checks multiple 1-2 chat created by user1 and checks the chat details page
    //    func test23_24CheckCreatedChannelAndDetailsUser2()
    //    {
    //        /* user2 checks created multiple 1-2 chat */
    //        let app = XCUIApplication()
    //        let tablesQueryTwo = app.tables
    //        let UserTwoSees = fullName + ", " + fullNameThree
    //        self.CheckCreatedChannel(userNameTwo, password: password, fullName: UserTwoSees)
    //
    //        /* check sent photos */
    //        self.SentPhotosChecks()
    //
    //        /* check channel details using asserts function + additional checks assert */
    //        self.Asserts(Group, fullName: fullNameTwo, fullNameTwo: fullName)
    //        XCTAssertEqual(tablesQueryTwo.staticTexts[fullNameThree].label, fullNameThree)
    //        XCTAssert(app.navigationBars["Details"].buttons["Leave"].exists)
    //        XCTAssertFalse(tablesQueryTwo.staticTexts["+ Add Contact"].exists)
    //    }
    //
    //    //Test25-26 Positive scenarios - User3 checks multiple 1-2 chat created by user1 and checks the chat details page
    //    func test25_26CheckCreatedChannelAndDetailsUser3()
    //    {
    //        /* user3 checks created multiple 1-2 chat */
    //        let app = XCUIApplication()
    //        let tablesQueryTwo = app.tables
    //        let UserThreeSees = fullName + ", " + fullNameTwo
    //        self.CheckCreatedChannel(userNameThree, password: password, fullName: UserThreeSees)
    //
    //        /* check sent photos */
    //        self.SentPhotosChecks()
    //
    //        /* check channel details using asserts function + additional checks assert */
    //        self.Asserts(Group, fullName: fullNameThree, fullNameTwo: fullName)
    //        XCTAssertEqual(tablesQueryTwo.staticTexts[fullNameThree].label, fullNameThree)
    //        XCTAssert(app.navigationBars["Details"].buttons["Leave"].exists)
    //        XCTAssertFalse(tablesQueryTwo.staticTexts["+ Add Contact"].exists)
    //    }
    //
    //    //Test27-28 Positive scenarios - User1 (initiator) adds user4 to the created multiple 1-2 chat and checks the chat details page (user4 should be successfully added and displayed)
    //    func test27_28User1InitiatorAddsOneMoreUser()
    //    {
    //        let app = XCUIApplication()
    //        let UserOneSees = fullNameTwo + ", " + fullNameThree
    //        let navBarDetail = app.navigationBars[Group]
    //        let detailbutton = navBarDetail.buttons["Detail"]
    //        let tablesQuery = XCUIApplication().tables
    //        let navBarTwo = app.navigationBars["Add a contact"]
    //        let buttonNext = navBarTwo.buttons["Next"]
    //
    //        /* user1 adds user4 */
    //        self.CheckCreatedChannel(userName, password: password, fullName: UserOneSees)
    //        detailbutton.tap()
    //        self.delay()
    //
    //        tablesQuery.staticTexts["+ Add Contact"].tap()
    //        tablesQuery.staticTexts[fullNameFour].tap()
    //        //Next button check
    //        XCTAssert(buttonNext.exists)
    //        buttonNext.tap()
    //        self.delay()
    //
    //        /* check chat details */
    //        detailbutton.tap()
    //        self.delay()
    //        XCTAssert(app.navigationBars["Details"].exists)
    //        //XCTAssert(app.navigationBars["Details"].buttons[fNameTwo].exists)
    //        XCTAssertEqual(tablesQuery.staticTexts[fullName].label, fullName)
    //        XCTAssertEqual(tablesQuery.staticTexts[fullNameTwo].label, fullNameTwo)
    //        XCTAssertEqual(tablesQuery.staticTexts[fullNameFour].label, fullNameFour)
    //        self.delay()
    //    }
    //
    //    //Test29-30 Positive scenarios - User4 checks updated multiple 1-3 chat created by user1 and checks the channel details page
    //    func test29_30CheckCreatedChannelAndDetailsUser4()
    //    {
    //        /* user4 checks created multiple 1-3 chat */
    //        let app = XCUIApplication()
    //        let tablesQueryTwo = app.tables
    //        let UserFourSees = fullName + ", " + fullNameTwo + ", " + fullNameThree
    //        self.CheckCreatedChannel(userNameFour, password: password, fullName: UserFourSees)
    //
    //        /* check sent photos */
    //        self.SentPhotosChecks()
    //
    //        /* user4 checks chat details */
    //        self.Asserts(Group, fullName: fullNameFour, fullNameTwo: fullName)
    //        XCTAssertEqual(tablesQueryTwo.staticTexts[fullNameFour].label, fullNameFour)
    //        XCTAssert(app.navigationBars["Details"].buttons["Leave"].exists)
    //        XCTAssertFalse(tablesQueryTwo.staticTexts["+ Add Contact"].exists)
    //    }
    //
    //    //Test31 Positive scenario - User1 (initiator) leaves the updated multiple 1-3 chat
    //    func test31User1InitiatorLeavesTheChat()
    //    {
    //        /* user1 */
    //        let UserOneSees = fullNameTwo + ", " + fullNameThree + ", " + fullNameFour
    //        self.UserLeavesTheChat(userName, password: password, fullName: UserOneSees, fName: Group, fullNameTwo: fullName)
    //    }
    //
    //    //Test32 Positive scenario - Check that user1 (initiator) doesn't see abandoned chat on home page
    //    func test32CheckAbandonedChat()
    //    {
    //        /* login user1 */
    //        let app = XCUIApplication()
    //        let UserOneSees = fullNameTwo + ", " + fullNameThree + ", " + fullNameFour
    //        self.login(userName, password: password)
    //
    //        /* check abandoned chat */
    //        self.delay()
    //        self.delay()
    //        //abandoned chat check
    //        XCTAssertFalse(app.tables.staticTexts[UserOneSees].exists)
    //    }
    //
    //    //Test33 Positive scenario - User3 (subscriber) sends a few photos to the updated multiple 1-2 chat
    //    func test33User3SendsAFewPhotos()
    //    {
    //        let app = XCUIApplication()
    //        let UserThreeSees = fullNameTwo + ", " + fullNameFour
    //
    //        /* user3 sends a few photos */
    //        self.CheckCreatedChannel(userNameThree, password: password, fullName: UserThreeSees)
    //        self.delay()
    //        self.SendAFewPhotos()
    //        self.delay()
    //
    //        /* check sent photos */
    //        XCTAssert(app.collectionViews.childrenMatchingType(.Cell).elementBoundByIndex(7).childrenMatchingType(.Other).element.exists)
    //        XCTAssertNotNil(app.collectionViews.childrenMatchingType(.Cell).elementBoundByIndex(7).childrenMatchingType(.Other).element)
    //
    //        XCTAssert(app.collectionViews.childrenMatchingType(.Cell).elementBoundByIndex(8).childrenMatchingType(.Other).element.exists)
    //        XCTAssertNotNil(app.collectionViews.childrenMatchingType(.Cell).elementBoundByIndex(8).childrenMatchingType(.Other).element)
    //    }
    //
    //    //Test34 Positive scenario - User2 blockes user3
    //    func test34User2BlocksUser3()
    //    {
    //        let app = XCUIApplication()
    //        let UserTwoSees = fullNameThree + ", " + fullNameFour
    //        let block = app.collectionViews.childrenMatchingType(.Cell).elementBoundByIndex(7).childrenMatchingType(.Other).element.childrenMatchingType(.Other).elementBoundByIndex(1).childrenMatchingType(.Image).element
    //        let alert = app.alerts["Block User"]
    //
    //        /* user2 blocks user3 */
    //        self.CheckCreatedChannel(userNameTwo, password: password, fullName: UserTwoSees)
    //        self.delay()
    //        self.delay()
    //        self.delay()
    //        self.delay()
    //        block.tap()
    //        app.sheets["Additional Options"].buttons["Cancel"].tap()
    //
    //        block.tap()
    //        app.sheets["Additional Options"].buttons["Block User"].tap()
    //        alert.staticTexts["Block User"].tap()
    //        //alert checks
    //        XCTAssert(alert.exists)
    //        XCTAssertEqual(alert.staticTexts["Block User"].label, "Block User")
    //        app.alerts["Block User"].collectionViews.buttons["No"].tap()
    //
    //        block.tap()
    //        app.sheets["Additional Options"].buttons["Block User"].tap()
    //        app.alerts["Block User"].collectionViews.buttons["Yes"].tap()
    //        self.delay()
    //    }
    //
    //    //Test35-36 Positive scenarios - User2 checks that he does not see messages from user3 and checks that user3 is present in the chat details
    //    func test35_36User2ChecksHidenMessagesFromUser3()
    //    {
    //        let app = XCUIApplication()
    //        let UserTwoSees = fullNameThree + ", " + fullNameFour
    //        let photo = app.collectionViews.childrenMatchingType(.Cell).elementBoundByIndex(7).childrenMatchingType(.Other).element.childrenMatchingType(.Other).elementBoundByIndex(1).childrenMatchingType(.Image).element
    //        let navBarDetail = app.navigationBars[Group]
    //        let detailbutton = navBarDetail.buttons["Detail"]
    //        let tablesQueryTwo = app.tables
    //
    //        /* user2 checks that he does not see messages from user3 */
    //        self.CheckCreatedChannel(userNameTwo, password: password, fullName: UserTwoSees)
    //        self.delay()
    //        self.delay()
    //        //chat messages check
    //        XCTAssertFalse(photo.exists)
    //        self.delay()
    //
    //        /* user2 checks chat details */
    //        //chat navigation bar checks
    //        XCTAssert(navBarDetail.buttons["Back"].exists)
    //        XCTAssert(detailbutton.exists)
    //        XCTAssertEqual(navBarDetail.staticTexts[Group].label, Group)
    //        detailbutton.tap()
    //        self.delay()
    //        //chat details checks
    //        XCTAssertEqual(tablesQueryTwo.staticTexts[fullNameTwo].label, fullNameTwo)
    //        XCTAssertEqual(tablesQueryTwo.staticTexts[fullNameThree].label, fullNameThree)
    //        XCTAssertEqual(tablesQueryTwo.staticTexts[fullNameFour].label, fullNameFour)
    //        self.delay()
    //    }
    //
    //    //Test37 Positive scenario - Check that user3 is blocked by user2
    //    func test37CheckThatUser3IsBlockedByUser2()
    //    {
    //        let app = XCUIApplication()
    //        let blockedUser = fullNameThree + " [BLOCKED]"
    //        let tablesQuery = app.tables
    //
    //        /* user2 checks that user3 is blocked */
    //        self.ContactList(userNameTwo, fullNameThree: fullNameThree, fullNameTwo: fullNameTwo)
    //        //blocked user check
    //        XCTAssert(tablesQuery.staticTexts[blockedUser].exists)
    //        self.delay()
    //    }
    //
    //    //Test38 Positive scenario - User4 checks that he does see messages from user3 as per user4 hasn't blocked user3
    //    func test38User4ChecksExistingMessagesFromUser3()
    //    {
    //        let app = XCUIApplication()
    //        let UserFourSees = fullNameTwo + ", " + fullNameThree
    //        let photo = app.collectionViews.childrenMatchingType(.Cell).elementBoundByIndex(7).childrenMatchingType(.Other).element.childrenMatchingType(.Other).elementBoundByIndex(1).childrenMatchingType(.Image).element
    //
    //        /* user4 checks that he does see messages from user3 */
    //        self.CheckCreatedChannel(userNameFour, password: password, fullName: UserFourSees)
    //        self.delay()
    //        self.delay()
    //        self.delay()
    //        //chat messages check
    //        XCTAssert(photo.exists)
    //        self.delay()
    //    }
    //
    //    //Test39 Positive scenario - User2 unblocks user3
    //    func test39User2UnblocksUser3()
    //    {
    //        let app = XCUIApplication()
    //        let blockedUser = fullNameThree + " [BLOCKED]"
    //        let tablesQuery = app.tables
    //        let click = tablesQuery.staticTexts[blockedUser]
    //        let unblockUser = app.sheets["Additional Options"].buttons["Unblock User"]
    //
    //        self.ContactList(userNameTwo, fullNameThree: fullNameThree, fullNameTwo: fullNameTwo)
    //
    //        /* user2 unblocks user3 */
    //        click.tap()
    //        app.sheets["Additional Options"].buttons["Cancel"].tap()
    //        click.tap()
    //        click.tap()
    //        unblockUser.tap()
    //        self.delay()
    //
    //        //alert checks
    //        XCTAssert(app.alerts["Unblock User"].exists)
    //        XCTAssertEqual(app.alerts["Unblock User"].staticTexts["Are you sure you want to unblock this user? You will start receiving messages from them."].label, "Are you sure you want to unblock this user? You will start receiving messages from them.")
    //        app.alerts["Unblock User"].collectionViews.buttons["No"].tap()
    //        click.tap()
    //        click.tap()
    //        unblockUser.tap()
    //        self.delay()
    //        app.alerts["Unblock User"].collectionViews.buttons["Yes"].tap()
    //        self.delay()
    //
    //        /* user2 checks that user3 is unblocked */
    //        XCTAssertFalse(tablesQuery.staticTexts[blockedUser].exists)
    //        self.delay()
    //    }
    //
    //    //Test40 Positive scenario - user2 checks that he does see appeared messages from user3
    //    func test40User2ChecksAppearedMessagesFromUser3()
    //    {
    //        /* Check multiple 1-2 chat */
    //        let app = XCUIApplication()
    //        let UserTwoSees = fullNameThree + ", " + fullNameFour
    //        let photo = app.collectionViews.childrenMatchingType(.Cell).elementBoundByIndex(7).childrenMatchingType(.Other).element.childrenMatchingType(.Other).elementBoundByIndex(1).childrenMatchingType(.Image).element
    //
    //        /* User2 checks that he does not see messages from user3 */
    //        self.CheckCreatedChannel(userNameTwo, password: password, fullName: UserTwoSees)
    //        self.delay()
    //        self.delay()
    //        self.delay()
    //        //chat messages check
    //        XCTAssert(photo.exists)
    //        self.delay()
    //    }
}