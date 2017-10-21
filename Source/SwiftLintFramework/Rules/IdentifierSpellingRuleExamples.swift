//
//  IdentifierSpellingRuleExamples.swift
//  SwiftLint
//
//  Created by Tom Bell on 21/10/17.
//  Copyright © 2017 Realm. All rights reserved.
//

import Foundation

internal struct IdentifierSpellingRuleExamples {
    static let nonTriggeringExamples = [
        "let myLet = 0",
        "var myVariable = 0",
        "private let _myLet = 0",
        "let myURLVariable = 0",
        "class Abc { static let MyLet = 0 }",
        "let URL: NSURL? = nil",
        "let XMLString: String? = nil",
        "override var i = 0",
        "enum Foo { case myEnum }",
        "func isOperator(name: String) -> Bool",
        "func typeForKind(_ kind: SwiftDeclarationKind) -> String"
    ]

    static let triggeringExamples = [
        "↓let myIncorectLet = 0",
        "↓var myIncorectVariable = 0",
        "private ↓let _mySeperateVariable = 0",
        "↓func isOparator(name: String) -> Bool",
        "func isEven(↓nuber: Int) -> Bool"
    ]
}
