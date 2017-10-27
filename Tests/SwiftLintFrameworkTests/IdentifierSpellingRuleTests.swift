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
            "let mySdkVersion = 0",
            "func == (lhs: SyntaxToken, rhs: SyntaxToken) -> Bool"
        ]

        let description = baseDescription.with(nonTriggeringExamples: nonTriggeringExamples)
        verifyRule(description, ruleConfiguration: ["excluded": ["lhs", "rhs", "SDK"]])
    }

    func testIdentifierSpellingWithExclusionsAndViolation() {
        let baseDescription = IdentifierSpellingRule.description
        let triggeringExamples = baseDescription.triggeringExamples + [
            "let mySdk↓Verson = 0",
            "func == (lhs↓Vilue: SyntaxToken, rhs↓Vilue: SyntaxToken) -> Bool"
        ]

        let description = baseDescription.with(triggeringExamples: triggeringExamples)
        verifyRule(description, ruleConfiguration: ["excluded": ["lhs", "rhs", "SDK"]])
    }
}
