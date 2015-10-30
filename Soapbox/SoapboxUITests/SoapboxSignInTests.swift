//
//  SoapboxUITests.swift
//  SoapboxUITests
//
//  Created by Daniel Gulko on 9/25/15.
//  Copyright © 2015 Magnet Systems, Inc. All rights reserved.
//

import XCTest

class SoapboxUITests: XCTestCase {
    let app = XCUIApplication()
        
    override func setUp() {
        super.setUp()
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        app.launch()
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
    
    // sign in and registraiton tests
    func test1signInNonExistingUser() {
        signIn("nonexistinguser", password: "password")
        app.buttons["Sign In"].tap()
        confirmAlert("Error", message: "Request failed: unauthorized (401)")
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
        let signoutButton = app.buttons["Sign Out"]
        let signinButton = app.buttons["Sign In"]
        
        signIn("newuser", password: "password")
        app.buttons["Register"].tap()
        evaluateElementExist(signoutButton)
        app.buttons["Sign Out"].tap()
        confirmAlert("Sign Out", message: "Continue to sign out?")
        evaluateElementExist(signinButton)
    }
    
    func test8signInUser() {
        let signoutButton = app.buttons["Sign Out"]
        let signinButton = app.buttons["Sign In"]
        
        signIn("newuser", password: "password")
        app.buttons["Sign In"].tap()
        evaluateElementExist(signoutButton)
        app.buttons["Sign Out"].tap()
        confirmAlert("Sign Out", message: "Continue to sign out?")
        evaluateElementExist(signinButton)
    }
}