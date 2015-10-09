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
    
    // wait for identifier (this is added as identifier "player_bot" in story board)
    private func waitIdentifier(identifier:String) {
        let object = app.staticTexts.elementMatchingType(.Any, identifier: identifier)
        let testPredicate = NSPredicate(format: "label != ''")
        self.expectationForPredicate(testPredicate, evaluatedWithObject: object, handler: nil)
        self.waitForExpectationsWithTimeout(30, handler: nil)
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
    
    func test03tieGame() {
        choosePlayer("player_bot")
        waitIdentifier("player_bot") // identifier has been added to story board
        
        if app.staticTexts["ROCK"].exists {
            gameChoice("rock")}
        else if app.staticTexts["PAPER"].exists {
            gameChoice("paper")}
        else if app.staticTexts["SCISSORS"].exists {
            gameChoice("scissors")}
        else if app.staticTexts["LIZARD"].exists {
            gameChoice("lizard")}
        else if app.staticTexts["SPOCK"].exists {
            gameChoice("spock")}
        
        alertConfirmation("OK")
        app.staticTexts["Ties: 1"].tap()
    }
    
    func test04winGame() {
        choosePlayer("player_bot")
        waitIdentifier("player_bot") // identifier has been added to story board
        
        if app.staticTexts["ROCK"].exists {
            gameChoice("paper")}
        else if app.staticTexts["PAPER"].exists {
            gameChoice("scissors")}
        else if app.staticTexts["SCISSORS"].exists {
            gameChoice("spock")}
        else if app.staticTexts["LIZARD"].exists {
            gameChoice("scissors")}
        else if app.staticTexts["SPOCK"].exists {
            gameChoice("lizard")}
        
        alertConfirmation("OK")
        XCTAssertEqual(app.staticTexts["Wins: 1"].exists, true)
    }

    func test05loseGame() {
        choosePlayer("player_bot")
        waitIdentifier("player_bot") // identifier has been added to story board
        
        if app.staticTexts["ROCK"].exists {
            gameChoice("scissors")}
        else if app.staticTexts["PAPER"].exists {
            gameChoice("rock")}
        else if app.staticTexts["SCISSORS"].exists {
            gameChoice("paper")}
        else if app.staticTexts["LIZARD"].exists {
            gameChoice("paper")}
        else if app.staticTexts["SPOCK"].exists {
            gameChoice("rock")}
        
        alertConfirmation("OK")
        XCTAssertEqual(app.staticTexts["Losses: 1"].exists, true)
    }    
}