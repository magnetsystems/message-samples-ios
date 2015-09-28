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
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()
        sleep(5)

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    // sign in function
    private func signIn(user:String, password:String) {
        let usernameTextField = app.textFields["Username"]
        usernameTextField.tap()
        usernameTextField.typeText(user)
        
        let passwordSecureTextField = app.secureTextFields["Password"]
        passwordSecureTextField.tap()
        passwordSecureTextField.typeText(password)
    }
    
    // alert function
    private func confirmAlert(message: String, error: String) {
        
        if app.alerts.collectionViews.buttons[message].exists {
            XCTAssertEqual(app.staticTexts[error].exists, true)
            app.alerts.collectionViews.buttons["OK"].tap()
            //XCTAssert(app.alerts["Error"]).exists, true
        }
    }
        

        
//        let errorAlert = app.alerts["Error"]
//        errorAlert.staticTexts["Error"].tap()
//        errorAlert.staticTexts["Not Authorized. Please check your credentials and try again."].tap()
//        errorAlert.collectionViews.buttons["OK"].tap()
//    }
    
    
    
    func test1signInNonExistingUser() {
        signIn("nonexistinguser", password: "password")
        app.buttons["Sign In"].tap()
        sleep(5)
        //need alert function for failure case
    }
    
    func test2registerExistingUser() {
        signIn("serveruser", password: "password")
        app.buttons["Register"].tap()
        // need alert function for failure case
    }
    
    func test3registerEmptyUserName() {
        signIn("", password: "password")
        app.buttons["Register"].tap()
        // need alert function for failure case
    }
    
    func test4registerEmptyPassword() {
        signIn("newuser", password: "")
        app.buttons["Register"].tap()
        // need alert function for failure case
    }
    
    func test5signInEmptyUsername() {
        signIn("", password: "password")
        app.buttons["Sign In"].tap()
        // need alert function for failure case
    }
    
    func test6signInEmptyPassword() {
        signIn("newuser", password: "")
        app.buttons["Sign In"].tap()
        // need alert function for failure case
    }
    
    func test7registerUser() {
        signIn("newuser", password: "password")
        app.buttons["Register"].tap()
        // need assert registration was successful
    }
    
    func test8signInUser() {
        signIn("newuser", password: "password")
        app.buttons["Sign In"].tap()
        // need assert sign in was successful
    }
}
