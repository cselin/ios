//
//  FiveCallsUITests.swift
//  FiveCallsUITests
//
//  Created by Ben Scheirman on 2/8/17.
//  Copyright © 2017 5calls. All rights reserved.
//

import XCTest
@testable import FiveCalls

class FiveCallsUITests: XCTestCase {

    var app: XCUIApplication!
        
    @MainActor override func setUp() {
        super.setUp()
        
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchEnvironment = ["UI_TESTING" : "1"]
        loadJSONFixtures(application: app)
        setupSnapshot(app)
        app.launch()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    @MainActor func testTakeScreenshots() {
        snapshot("0-welcome")
        
        let predicate = NSPredicate(format: "label LIKE 'Turn your passive participation into active resistance. Facebook likes and Twitter retweets can’t create the change you want to see. Calling your Government on the phone can.'")
        let label = app.staticTexts.element(matching: predicate)
        label.swipeLeft()
        
        snapshot("1-welcome2")

        app.buttons["Get Started"].tap()
        app.buttons["Set Location"].tap()
        app.textFields["Zip or Address"].tap()
        app.typeText("77429")
        app.buttons["Submit"].tap()

        snapshot("2-issues")
        
        app.tables.cells.staticTexts["Urge Congress to Pass Legislation to Prevent Future Shutdowns"].tap()
        snapshot("3-issue-detail")
        let issueTable = app.tables.element(boundBy: 0)
        issueTable.swipeUp()
        issueTable.swipeUp()
        issueTable.swipeUp()
        
        app.cells.staticTexts["Nancy Pelosi"].tap()
        snapshot("4-call-script")
    }
    
    private func loadJSONFixtures(application: XCUIApplication) {
        let bundle = Bundle(for: FiveCallsUITests.self)
        application.launchEnvironment["GET:/v1/reps"] = bundle.path(forResource: "GET-v1-reps", ofType: "json")
        application.launchEnvironment["GET:/v1/issues"] = bundle.path(forResource: "GET-v1-issues", ofType: "json")
        application.launchEnvironment["GET:/v1/report"] = bundle.path(forResource: "GET-report", ofType: "json")
        application.launchEnvironment["POST:/report"] = bundle.path(forResource: "POST-report", ofType: "json")
    }
}
