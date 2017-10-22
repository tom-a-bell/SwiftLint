//
//  IdentifierSpellingRuleTests.swift
//  SwiftLint
//
//  Created by Tom Bell on 21/10/17.
//  Copyright © 2017 Realm. All rights reserved.
//

import SwiftLintFramework
import XCTest

class IdentifierSpellingRuleTests: XCTestCase {

    func testIdentifierSpelling() {
        verifyRule(IdentifierSpellingRule.description)
    }

    func testIdentifierSpellingWithExclusions() {
        let baseDescription = IdentifierSpellingRule.description
        let nonTriggeringExamples = baseDescription.nonTriggeringExamples + [
            "let lhs = 0",
            "let mySdk = 0",
            "func == (lhs: SyntaxToken, rhs: SyntaxToken) -> Bool"
        ]

        let description = baseDescription.with(nonTriggeringExamples: nonTriggeringExamples)
        verifyRule(description, ruleConfiguration: ["excluded": ["lhs", "rhs", "SDK"]])
    }
}
