//
//  RPSLSUITests.swift
//  RPSLSUITests
//
//  Created by Daniel Gulko on 10/5/15.
//  Copyright © 2015 Magnet Systems, Inc. All rights reserved.
//

import XCTest

class RPSLSUITests: XCTestCase {
    let app = XCUIApplication()

    override func setUp() {
        super.setUp()
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        app.launch()
        
        // added condition to look for notification alert and confirm
        if XCUIApplication().alerts.collectionViews.buttons["OK"].exists {
            app.alerts.collectionViews.buttons["OK"].tap()
        }

    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    // sign in
    private func signIn(user:String, password:String) {
        let usernameTextField = app.textFields["Username"]
        usernameTextField.tap()
        usernameTextField.typeText(user)
        
        let passwordSecureTextField = app.secureTextFields["Password"]
        passwordSecureTextField.tap()
        passwordSecureTextField.typeText(password)
    }
    
    // wait for element
    private func evaluateElementExist(element:AnyObject) {
        let exists = NSPredicate(format: "exists == 1")
        expectationForPredicate(exists, evaluatedWithObject: element, handler: nil)
        waitForExpectationsWithTimeout(30, handler: nil)
    }
    
    // confirm alert
    private func confirmAlert(title: String, message: String) {
        if app.alerts.collectionViews.buttons["OK"].exists {
            let title = app.staticTexts[title]
            let message = app.staticTexts[message]
            
            evaluateElementExist(title)
            evaluateElementExist(message)
            app.buttons["OK"].tap()
        }
    }
    
    // sign in and registration tests
    func test1signInNonExistingUser() {
        let signinButton = app.buttons["Sign In"]
        
        evaluateElementExist(signinButton)
        app.textFields["Username"].tap() // get app focus by tapping username if notification was confirmed
        signIn("nonexistinguser", password: "password")
        app.buttons["Sign In"].tap()
        confirmAlert("Error", message: "Not Authorized. Please check your credentials and try again.")
    }
    
    func test2registerExistingUser() {
        signIn("serveruser", password: "password")
        app.buttons["Register"].tap()
        confirmAlert("Error Registering User", message: "You have tried to create a duplicate entry.")
    }
    
    func test3registerEmptyUserName() {
        signIn("", password: "password")
        app.buttons["Register"].tap()
        confirmAlert("Error", message: "Username must be at least 5 characters in length.")
    }
    
    func test4registerEmptyPassword() {
        signIn("newuser", password: "")
        app.buttons["Register"].tap()
        confirmAlert("Error", message: "You must provide a password")
    }
    
    func test5signInEmptyUsername() {
        signIn("", password: "password")
        app.buttons["Sign In"].tap()
        confirmAlert("Error", message: "Username must be at least 5 characters in length.")
    }
    
    func test6signInEmptyPassword() {
        signIn("newuser", password: "")
        app.buttons["Sign In"].tap()
        confirmAlert("Error", message: "You must provide a password")
    }
    
    func test7registerUser() {
        let findOpponentButton = app.buttons["Find Opponent"]
        
        signIn("newuser", password: "password")
        app.buttons["Register"].tap()
        evaluateElementExist(findOpponentButton)
        XCTAssertEqual(app.staticTexts["Connected as newuser"].exists, true)
    }
    
    func test8signInUser() {
        let findOpponentButton = app.buttons["Find Opponent"]
        
        signIn("newuser", password: "password")
        app.buttons["Sign In"].tap()
        evaluateElementExist(findOpponentButton)
        XCTAssertEqual(app.staticTexts["Connected as newuser"].exists, true)
    }
}