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
        "let my↓IncorectLet = 0",
        "var my↓IncorectVariable = 0",
        "private let _my↓SeperateVariable = 0",
        "func is↓Oparator(name: String) -> Bool",
        "func isEven(↓nuber: Int) -> Bool"
    ]
}
