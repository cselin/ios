//
//  IssueParsingTest.swift
//  FiveCallsTests
//
//  Created by Nick O'Neill on 12/19/23.
//  Copyright © 2023 5calls. All rights reserved.
//

import XCTest
@testable import FiveCalls

final class IssueParsingTest: XCTestCase {
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testParseIssues() throws {
        let exp = expectation(description: "parsing issues")
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [ProtocolMock.self]
        let fetchIssues = FetchIssuesOperation(config: config)
        fetchIssues.completionBlock = {
            guard let issues = fetchIssues.issuesList else { return XCTFail("no issues present") }
            let issueCountExpected = 60
            XCTAssert(issues.count == issueCountExpected, "found \(issues.count) issues, expected \(issueCountExpected)")
            let issueIDExpected = 664
            XCTAssert(issues[0].id == issueIDExpected, "first issue was not id \(issueIDExpected) as expected")
            let issueCreatedAtExpected: Double = 1565582054
            XCTAssert(issues[11].createdAt.timeIntervalSince1970 == issueCreatedAtExpected, "12th issue did not have created date as expected")
            exp.fulfill()
        }
        OperationQueue.main.addOperation(fetchIssues)
        // TODO: as part of an operations refactor, await this return so this test finishes ~immediately
        waitForExpectations(timeout: 2)
    }
}
