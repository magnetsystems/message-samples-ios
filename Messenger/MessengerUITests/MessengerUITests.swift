//  MessengerUITests.swift
//  MessengerUITests
//  Created by agordyman on 3/14/16.
//  Copyright © 2016 Magnet Systems, Inc. All rights reserved.

import XCTest

class MessengerUITests: XCTestCase {
    
    let kExpectationsTimeout : NSTimeInterval = 60
    let password = "Temp1234%"
    let passwordagain = "Temp1234%"
    let lName = "test"
    let Group = "Group"
    
    let userName = "test39@automation.gmail.com"
    let fName = "AutomationTestUser39"
    let fullName = "AutomationTestUser39 test"
    
    let userNameTwo = "test40@automation.gmail.com"
    let fNameTwo = "AutomationTestUser40"
    let fullNameTwo = "AutomationTestUser40 test"
    
    let userNameThree = "test41@automation.gmail.com"
    let fNameThree = "AutomationTestUser41"
    let fullNameThree = "AutomationTestUser41 test"
    
    let userNameFour = "test42@automation.gmail.com"
    let fNameFour = "AutomationTestUser42"
    let fullNameFour = "AutomationTestUser42 test"
    
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
        self.delay()
    }
    
    //Help mark - logout of the app when registration is successful
    func logout_after_registration(fullName:String!){
        let app = XCUIApplication()
        let editNavBar = XCUIApplication().navigationBars["My Profile"];
        let buttonClose = editNavBar.buttons["Close"];
        self.delay()
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
        self.delay()
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
    
    //Help mark - Send a few photos
    func SendAFewPhotos()
    {
        let app = XCUIApplication()
        let element = app.otherElements.containingType(.NavigationBar, identifier:"SWRevealView").childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.toolbars.childrenMatchingType(.Other).element
        element.childrenMatchingType(.TextView).element.tap()
        element.childrenMatchingType(.Other).elementBoundByIndex(0).childrenMatchingType(.Button).element.tap()
        app.sheets["Media Messages"].collectionViews.buttons["Photo Library"].tap()
        app.tables.buttons["Moments"].tap()
        app.collectionViews["PhotosGridView"].childrenMatchingType(.Cell).elementBoundByIndex(1).tap()
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
    }
    
    //Help mark - check created channel between users
    func CheckCreatedChannel(userNameTwo:String!, password:String!, fullName:String!)
    {
        /* login user2 */
        let app = XCUIApplication()
        self.login(userNameTwo, password: password)
        
        /* check created channel*/
        self.delay()
        self.delay()
        self.delay()
        
        XCTAssert(app.tables.staticTexts[fullName].exists)
        app.tables.staticTexts[fullName].tap()
        
        self.delay()
    }
    
    //Help mark - user leaves the created chat
    func UserLeavesTheChat(userNameTwo:String!, password:String!, fullName:String!, fName:String!, fullNameTwo:String!)
    {
        /* login user2 */
        let app = XCUIApplication()
        self.login(userNameTwo, password: password)
        
        /* check created channel*/
        self.delay()
        self.delay()
        
        app.tables.staticTexts[fullName].tap()
        
        self.delay()
        
        /* leave the chat */
        
        let navbar = app.navigationBars[fName]
        let detail = navbar.buttons["Detail"]
        detail.tap()
        
        let leave = app.navigationBars["Details"].buttons["Leave"]
        leave.tap()
        //XCTAssertFalse(app.tables.staticTexts[fullName].exists) commented due to bug MAX-275. Creating test20 in order to check behavior of the messenger after re-login.
        
        self.delay()
        self.logout_after_login(fullNameTwo)
    }
    
    //Help mark - Asserts
    func Asserts(fNameTwo:String!, fullName:String!, fullNameTwo:String)
    {
        /* Check channel details */
        let app = XCUIApplication()
        let navBarDetail = app.navigationBars[fNameTwo]
        let detailbutton = navBarDetail.buttons["Detail"]
        
        XCTAssert(navBarDetail.buttons["Back"].exists)
        XCTAssert(detailbutton.exists)
        XCTAssertEqual(navBarDetail.staticTexts[fNameTwo].label, fNameTwo)
        detailbutton.tap()
        
        self.delay()
        let tablesQueryTwo = XCUIApplication().tables
        XCTAssert(app.navigationBars["Details"].exists)
        //       XCTAssert(app.navigationBars["Details"].buttons[fNameTwo].exists)
        XCTAssertEqual(tablesQueryTwo.staticTexts[fullName].label, fullName)
        XCTAssertEqual(tablesQueryTwo.staticTexts[fullNameTwo].label, fullNameTwo)
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
        self.registration(userName, password: password, passwordagain: passwordagain, fName: fName, lName: lName);
        self.delay()
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
        self.delay()
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
        
        /* LogOut */
        self.logout_after_registration(fullNameTwo)
        
        /* Register User3 */
        self.registration(userNameThree, password: password, passwordagain: passwordagain, fName: fNameThree, lName: lName)
        
        /* LogOut */
        self.logout_after_registration(fullNameThree)
        
        /* Register User4 */
        self.registration(userNameFour, password: password, passwordagain: passwordagain, fName: fNameFour, lName: lName)
        
        /* LogOut */
        self.logout_after_registration(fullNameFour)
    }
    
    //Test14-15 Positive scenarios - Create a new 1-1 chat, check the channel details page
    func test14_15CreateANew1to1Chat()
    {
        /* login*/
        let app = XCUIApplication()
        self.login(userName, password: password)
        
        /* Create a new 1-1 chat */
        let navBar = app.navigationBars[fullName]
        let newMessage = navBar.buttons["new message"]
        newMessage.tap()
        
        let tablesQuery = XCUIApplication().tables
        tablesQuery.staticTexts[fullNameTwo].tap()
        
        let navBarTwo = app.navigationBars["New message"]
        let buttonNext = navBarTwo.buttons["Next"]
        XCTAssert(buttonNext.exists)
        buttonNext.tap()
        
        self.SendAFewPhotos()
        
        /* Check channel details */
        let tablesQueryTwo = app.tables
        self.Asserts(fNameTwo, fullName: fullName, fullNameTwo: fullNameTwo)
        XCTAssertEqual(tablesQueryTwo.staticTexts["+ Add Contact"].label, "+ Add Contact")
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
    
    //Test17-18 Positive scenarios - check created channel between user1 & user2 and check channel details by user2
    func test17_18CheckCreatedChannelAndDetails()
    {
        let app = XCUIApplication()
        self.CheckCreatedChannel(userNameTwo, password: password, fullName: fullName)
        
        /* check channel details */
        self.Asserts(fName, fullName: fullNameTwo, fullNameTwo: fullName)
        XCTAssert(app.navigationBars["Details"].buttons["Leave"].exists)
    }
    
    //Test19 Positive scenario - user2 (subscriber) leaves the created 1-1 chat by user1
    func test19User2LeavesTheChat()
    {
        self.UserLeavesTheChat(userNameTwo, password: password, fullName: fullName, fName: fName, fullNameTwo: fullNameTwo)
    }
    
    //Test20 Positive scenario - check that user2 (subscriber) doesn't see abandoned channel on home page
    func test20CheckAbandonedChat()
    {
        /* login user2 */
        let app = XCUIApplication()
        self.login(userNameTwo, password: password)
        
        /* check abandoned channel*/
        self.delay()
        self.delay()
        
        XCTAssertFalse(app.tables.staticTexts[fullName].exists)
    }
    
    //Test21-22 Positive scenario - create a multiple 1-2 chat and check channel details page
    func test21_22CreateAMultipleChat()
    {
        /* login user1 */
        let app = XCUIApplication()
        self.login(userName, password: password)
        
        /* create 1-2 multiple chat */
        let navBar = XCUIApplication().navigationBars[fullName]
        let newMessage = navBar.buttons["new message"]
        newMessage.tap()
        
        let tablesQuery = XCUIApplication().tables
        tablesQuery.staticTexts[fullNameTwo].tap()
        tablesQuery.staticTexts[fullNameThree].tap()
        
        let navBarTwo = XCUIApplication().navigationBars["New message"]
        let buttonNext = navBarTwo.buttons["Next"]
        XCTAssert(buttonNext.exists)
        buttonNext.tap()
        
        self.SendAFewPhotos()
        
        /* Check channel details */
        self.Asserts(Group, fullName: fullName, fullNameTwo: fullNameTwo)
        
        let tablesQueryTwo = app.tables
        XCTAssertEqual(tablesQueryTwo.staticTexts[fullNameThree].label, fullNameThree)
        XCTAssertEqual(tablesQueryTwo.staticTexts["+ Add Contact"].label, "+ Add Contact")
        self.delay()
    }
    
    //Test23-24 Positive scenarios - check created multiple 1-2 chat and check channel details by user2
    func test23_24CheckCreatedChannelAndDetailsUser2()
    {
        /* check created channel */
        let app = XCUIApplication()
        let tablesQueryTwo = app.tables
        let UserTwoSees = fullName + ", " + fullNameThree
        self.CheckCreatedChannel(userNameTwo, password: password, fullName: UserTwoSees)
        
        /* check channel details */
        self.Asserts(Group, fullName: fullNameTwo, fullNameTwo: fullName)
        XCTAssertEqual(tablesQueryTwo.staticTexts[fullNameThree].label, fullNameThree)
        XCTAssert(app.navigationBars["Details"].buttons["Leave"].exists)
        XCTAssertFalse(tablesQueryTwo.staticTexts["+ Add Contact"].exists)
    }
    
    //Test25-26 Positive scenarios - check created multiple 1-2 chat and check channel details by user3
    func test25_26CheckCreatedChannelAndDetailsUser3()
    {
        /* check created channel */
        let app = XCUIApplication()
        let tablesQueryTwo = app.tables
        let UserThreeSees = fullName + ", " + fullNameTwo
        self.CheckCreatedChannel(userNameThree, password: password, fullName: UserThreeSees)
        
        /* check channel details */
        self.Asserts(Group, fullName: fullNameThree, fullNameTwo: fullName)
        XCTAssertEqual(tablesQueryTwo.staticTexts[fullNameThree].label, fullNameThree)
        XCTAssert(app.navigationBars["Details"].buttons["Leave"].exists)
        XCTAssertFalse(tablesQueryTwo.staticTexts["+ Add Contact"].exists)
    }
    
    //Test27-28 Positive scenarios - user1 (initiator) adds user4 to the created multiple 1-2 chat and check channel details (user4 should be successfully added and displayed)
    func test27_28User1InitiatorAddsOneMoreUser()
    {
        /* user1 checks created channel and then adds user4*/
        let app = XCUIApplication()
        let UserOneSees = fullNameTwo + ", " + fullNameThree
        self.CheckCreatedChannel(userName, password: password, fullName: UserOneSees)
        
        let navBarDetail = app.navigationBars[Group]
        let detailbutton = navBarDetail.buttons["Detail"]
        detailbutton.tap()
        self.delay()
        
        let tablesQuery = XCUIApplication().tables
        tablesQuery.staticTexts["+ Add Contact"].tap()
        tablesQuery.staticTexts[fullNameFour].tap()
        
        let navBarTwo = app.navigationBars["Add a contact"]
        let buttonNext = navBarTwo.buttons["Next"]
        XCTAssert(buttonNext.exists)
        buttonNext.tap()
        
        self.delay()
        
        /* Check channel details */
        detailbutton.tap()
        
        self.delay()
        XCTAssert(app.navigationBars["Details"].exists)
        //        XCTAssert(app.navigationBars["Details"].buttons[fNameTwo].exists)
        XCTAssertEqual(tablesQuery.staticTexts[fullName].label, fullName)
        XCTAssertEqual(tablesQuery.staticTexts[fullNameTwo].label, fullNameTwo)
        XCTAssertEqual(tablesQuery.staticTexts[fullNameFour].label, fullNameFour)
        self.delay()
    }
    
    //Test29-30 Positive scenarios - check updated multiple 1-3 chat and check channel details by user4
    func test29_30CheckCreatedChannelAndDetailsUser4()
    {
        /* check created channel */
        let app = XCUIApplication()
        let tablesQueryTwo = app.tables
        let UserFourSees = fullName + ", " + fullNameTwo + ", " + fullNameThree
        self.CheckCreatedChannel(userNameFour, password: password, fullName: UserFourSees)
        
        /* check channel details */
        self.Asserts(Group, fullName: fullNameFour, fullNameTwo: fullName)
        XCTAssertEqual(tablesQueryTwo.staticTexts[fullNameFour].label, fullNameFour)
        XCTAssert(app.navigationBars["Details"].buttons["Leave"].exists)
        XCTAssertFalse(tablesQueryTwo.staticTexts["+ Add Contact"].exists)
    }
    
    //Test31 Positive scenario - user1 (initiator) leaves the created multiple 1-3 chat
    func test31User1InitiatorLeavesTheChat()
    {
        let UserOneSees = fullNameTwo + ", " + fullNameThree + ", " + fullNameFour
        self.UserLeavesTheChat(userName, password: password, fullName: UserOneSees, fName: Group, fullNameTwo: fullName)
    }
    
    //Test32 Positive scenario - check that user1 (initiator) doesn't see abandoned channel on home page
    func test32CheckAbandonedChat()
    {
        /* login user1 */
        let app = XCUIApplication()
        let UserOneSees = fullNameTwo + ", " + fullNameThree + ", " + fullNameFour
        self.login(userName, password: password)
        
        /* check abandoned channel*/
        self.delay()
        self.delay()
        
        XCTAssertFalse(app.tables.staticTexts[UserOneSees].exists)
    }
    
    //Test33 Positive scenario - user3 (subscriber) sends a few photos to the updated multiple 1-2 chat
    func test33User3SendsAFewPhotos()
    {
        /* check updated multiple 1-2 chat */
        let UserThreeSees = fullNameTwo + ", " + fullNameFour
        
        /* user3 sends a few photos */
        self.CheckCreatedChannel(userNameThree, password: password, fullName: UserThreeSees)
        self.delay()
        self.SendAFewPhotos()
        self.delay()
    }
    
    //Test34 Positive scenario - user2 blockes user3
    func test34User2BlocksUser3()
    {
        /* check updated multiple 1-2 chat */
        let app = XCUIApplication()
        let UserTwoSees = fullNameThree + ", " + fullNameFour
        
        self.CheckCreatedChannel(userNameTwo, password: password, fullName: UserTwoSees)
        self.delay()
        self.delay()
        
        /* user2 blocks user3*/
        
        let block = app.collectionViews.childrenMatchingType(.Cell).elementBoundByIndex(7).childrenMatchingType(.Other).element.childrenMatchingType(.Other).elementBoundByIndex(1).childrenMatchingType(.Image).element
        self.delay()
        self.delay()
        block.tap()
        app.sheets["Additional Options"].buttons["Cancel"].tap()
        
        block.tap()
        app.sheets["Additional Options"].buttons["Block User"].tap()
        
        let alert = app.alerts["Block User"]
        alert.staticTexts["Block User"].tap()
        XCTAssert(alert.exists)
        XCTAssertEqual(alert.staticTexts["Block User"].label, "Block User")
        app.alerts["Block User"].collectionViews.buttons["No"].tap()
        
        block.tap()
        app.sheets["Additional Options"].buttons["Block User"].tap()
        app.alerts["Block User"].collectionViews.buttons["Yes"].tap()
        self.delay()
    }
    
    //Test35-36 Positive scenarios - user2 checks that he does not see messages from user3 and checks that user3 is present in the chat details
    func test35_36User2ChecksHidenMessagesFromUser3()
    {
        /* Check updated multiple 1-2 chat */
        let app = XCUIApplication()
        let UserTwoSees = fullNameThree + ", " + fullNameFour
        
        self.CheckCreatedChannel(userNameTwo, password: password, fullName: UserTwoSees)
        self.delay()
        self.delay()
        
        /* User2 checks that he does not see messages from user3 */
        let photo = app.collectionViews.childrenMatchingType(.Cell).elementBoundByIndex(7).childrenMatchingType(.Other).element.childrenMatchingType(.Other).elementBoundByIndex(1).childrenMatchingType(.Image).element
        XCTAssertFalse(photo.exists)
        
        self.delay()
        
        /* Check channel details */
        let navBarDetail = app.navigationBars[Group]
        let detailbutton = navBarDetail.buttons["Detail"]
        XCTAssert(navBarDetail.buttons["Back"].exists)
        XCTAssert(detailbutton.exists)
        XCTAssertEqual(navBarDetail.staticTexts[Group].label, Group)
        detailbutton.tap()
        self.delay()
        
        let tablesQueryTwo = app.tables
        XCTAssertEqual(tablesQueryTwo.staticTexts[fullNameTwo].label, fullNameTwo)
        XCTAssertEqual(tablesQueryTwo.staticTexts[fullNameThree].label, fullNameThree)
        XCTAssertEqual(tablesQueryTwo.staticTexts[fullNameFour].label, fullNameFour)
        
        self.delay()
    }
    
    //Test37 Positive scenario - Check that user3 is blocked by user2
    func test37CheckThatUser3IsBlockedByUser2()
    {
        /* login*/
        let app = XCUIApplication()
        let blockedUser = fullNameThree + " [BLOCKED]"
        self.login(userNameTwo, password: password)
        
        let navBar = app.navigationBars[fullNameTwo]
        let newMessage = navBar.buttons["new message"]
        newMessage.tap()
        
        let tablesQuery = XCUIApplication().tables
        self.delay()
        XCTAssert(tablesQuery.staticTexts[blockedUser].exists)
        self.delay()
    }
}