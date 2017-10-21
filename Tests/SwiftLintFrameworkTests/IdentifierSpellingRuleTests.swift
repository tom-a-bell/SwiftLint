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
}
