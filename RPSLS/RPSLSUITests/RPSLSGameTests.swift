//
//  RPSLSGameTests.swift
//  RPSLS
//
//  Created by Daniel Gulko on 10/6/15.
//  Copyright © 2015 Magnet Systems, Inc. All rights reserved.
//

import XCTest

class RPSLSGameTests: XCTestCase {
    let app = XCUIApplication()
    
    override func setUp() {
        super.setUp()
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        //app.launch()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    private func runApp() {
        let appImage = app.images["splash"]
        
        app.launch()
        sleep(2)
        evaluateElementExist(appImage)
        
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
    
    // alert confirmation
    private func alertConfirmation(message:String) {
        let findOpponentButton = app.buttons["Find Opponent"]
        let availablePlayers = app.navigationBars["Available Players"].staticTexts["Available Players"]
        
        app.buttons[message].tap()
        XCTAssertEqual(app.buttons[message].exists, false)
        evaluateElementExist(availablePlayers)
        app.navigationBars["Available Players"].childrenMatchingType(.Button).matchingIdentifier("Back").elementBoundByIndex(0).tap()
        evaluateElementExist(findOpponentButton)
    }
    
    // choose player
    private func choosePlayer(player:String) {
        let findOpponentButton = app.buttons["Find Opponent"]
        
        evaluateElementExist(findOpponentButton)
        app.buttons["Find Opponent"].tap()
        app.tables.staticTexts[player].tap()
    }
    
    // game choice
    private func gameChoice(choice:String) {
        let rock = app.buttons["rock"]
        
        evaluateElementExist(rock)
        app.buttons[choice].tap()
        sleep(5)
        //XCTAssertEqual(app.staticTexts["You chose..."].exists, true)
        XCTAssertNotEqual(app.buttons[choice].exists, false)
    }
    
    // wait for element exist
    private func evaluateElementExist(element:AnyObject) {
        let exists = NSPredicate(format: "exists == 1")
        expectationForPredicate(exists, evaluatedWithObject: element, handler: nil)
        waitForExpectationsWithTimeout(30, handler: nil)
    }
    
    // wait for element not exist
    private func evaluateElementNotExist(element:AnyObject) {
        let exists = NSPredicate(format: "exists == 0")
        expectationForPredicate(exists, evaluatedWithObject: element, handler: nil)
        waitForExpectationsWithTimeout(30, handler: nil)
    }

    // rpsls game tests
    func test01launchRPSLS() {
        let signinButton = app.buttons["Sign In"]
        
        runApp()
        evaluateElementExist(signinButton)

    }
    
    func test02registerPlayer() {
        let user:String! = "\(NSDate().timeIntervalSince1970)"
        //print("^^^^^^^^^^^^^ \(user)");
        let findOpponentButton = app.buttons["Find Opponent"]
        
        signIn(user, password: "password")
        app.buttons["Register"].tap()
        evaluateElementExist(findOpponentButton)
        XCTAssertEqual(app.staticTexts["Connected as " + user].exists, true)
    }
    
    func test03chooseRock() {
        choosePlayer("player_bot")
        gameChoice("rock")
        alertConfirmation("OK")
    }
    
    func test04choosePaper() {
        choosePlayer("player_bot")
        gameChoice("paper")
        alertConfirmation("OK")
    }
    
    func test05chooseScissors() {
        choosePlayer("player_bot")
        gameChoice("scissors")
        alertConfirmation("OK")
    }
    
    func test06chooseLizard() {
        choosePlayer("player_bot")
        gameChoice("lizard")
        alertConfirmation("OK")
    }
    
    func test07chooseSpock() {
        choosePlayer("player_bot")
        gameChoice("spock")
        alertConfirmation("OK")
    }
    
//    func test08() {
//        //app.staticTexts[spockStaticText].tap()
//        let findOpponentButton = app.buttons["Find Opponent"]
//        
//        evaluateElementExist(findOpponentButton)
//        app.buttons["Find Opponent"].tap()
//        app.tables.staticTexts["player_bot"].tap()
//        sleep(3)
//        
//        if app.staticTexts["SPOCK"].exists {
//            gameChoice("rock")
//        }
//        else if app.staticTexts["ROCK"].exists {
//            gameChoice("rock")
//        }
//        else if app.staticTexts["PAPER"].exists {
//            gameChoice("rock")
//        }
//        else if app.staticTexts["LIZARD"].exists {
//            gameChoice("rock")
//        }
//        else if app.staticTexts["SCISSORS"].exists {
//            gameChoice("rock")
//        }
//    }
}
