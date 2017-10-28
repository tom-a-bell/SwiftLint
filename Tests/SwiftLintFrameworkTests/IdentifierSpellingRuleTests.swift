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
            "let garp = 0",
            "let myFoobar = 0",
            "func == (firstGarp: SyntaxToken, secondGarp: SyntaxToken) -> Bool"
        ]

        let description = baseDescription.with(nonTriggeringExamples: nonTriggeringExamples)
        verifyRule(description, ruleConfiguration: ["excluded": ["FOOBAR", "garp"]])
    }

    func testIdentifierSpellingWithExclusionsAndViolation() {
        let baseDescription = IdentifierSpellingRule.description
        let triggeringExamples = baseDescription.triggeringExamples + [
            "let myGarp↓Verson = 0",
            "func == (garp↓Vilue: SyntaxToken, gurp↓Vilue: SyntaxToken) -> Bool"
        ]

        let description = baseDescription.with(triggeringExamples: triggeringExamples)
        verifyRule(description, ruleConfiguration: ["excluded": ["garp", "gurp"]])
    }

    func testIdentifierSpellingWithMinWordLength() {
        let baseDescription = IdentifierSpellingRule.description
        let nonTriggeringExamples = baseDescription.nonTriggeringExamples + [
            "let otp = 0",
            "let sdkVersion = 0",
            "func == (lhs: SyntaxToken, rhs: SyntaxToken) -> Bool"
        ]

        let description = baseDescription.with(nonTriggeringExamples: nonTriggeringExamples)
        verifyRule(description, ruleConfiguration: ["min_length": 4])
    }

    func testIdentifierSpellingWithMinWordLengthViolations() {
        let baseDescription = IdentifierSpellingRule.description
        let triggeringExamples = baseDescription.triggeringExamples + [
            "let ↓otp = 0",
            "let current↓SdkVersion = 0",
            "func == (↓lhs: SyntaxToken, ↓rhs: SyntaxToken) -> Bool"
        ]

        let description = baseDescription
            .with(nonTriggeringExamples: [])
            .with(triggeringExamples: triggeringExamples)
        verifyRule(description, ruleConfiguration: ["min_length": 2])
    }
}
