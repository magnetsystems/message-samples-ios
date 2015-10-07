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
        continueAfterFailure = true
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        //app.launch()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    private func runApp() {
        app.launch()
        sleep(2)
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
        let alertButton = app.buttons[message]
        let availablePlayers = app.navigationBars["Available Players"].staticTexts["Available Players"]
        
        evaluateElementExist(alertButton)
        app.buttons[message].tap()
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
        let choiceConfirmation = app.staticTexts["You chose..."]
        let spock = app.buttons["spock"]
        let rock = app.buttons["rock"]
        let paper = app.buttons["paper"]
        let scissors = app.buttons["scissors"]
        let lizard = app.buttons["lizard"]
        
        evaluateElementExist(spock)
        evaluateElementExist(rock)
        evaluateElementExist(paper)
        evaluateElementExist(scissors)
        evaluateElementExist(lizard)
        app.buttons[choice].tap()
        evaluateElementExist(choiceConfirmation)
    }
    
    // wait for element
    private func evaluateElementExist(element:AnyObject) {
        let exists = NSPredicate(format: "exists == 1")
        expectationForPredicate(exists, evaluatedWithObject: element, handler: nil)
        waitForExpectationsWithTimeout(30, handler: nil)
    }

    // rpsls game tests
    func test01launchRPSLS() {
        app.launch()
        let appImage = app.images["splash"]
        evaluateElementExist(appImage)
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
}