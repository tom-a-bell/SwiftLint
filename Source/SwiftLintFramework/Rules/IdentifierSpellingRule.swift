//
//  IdentifierSpellingRule.swift
//  SwiftLint
//
//  Created by Tom Bell on 21/10/17.
//  Copyright © 2017 Realm. All rights reserved.
//

import AppKit
import Foundation
import SourceKittenFramework

public struct IdentifierSpellingRule: ASTRule, OptInRule, ConfigurationProviderRule {
    public var configuration = SpellingConfiguration()

    public init() {}

    public static let description = RuleDescription(
        identifier: "identifier_spelling",
        name: "Identifier Spelling",
        description: "Identifier names should be correctly spelled in the system default language.",
        kind: .style,
        nonTriggeringExamples: IdentifierSpellingRuleExamples.nonTriggeringExamples,
        triggeringExamples: IdentifierSpellingRuleExamples.triggeringExamples
    )

    public func validate(file: File, kind: SwiftDeclarationKind,
                         dictionary: [String: SourceKitRepresentable]) -> [StyleViolation] {
        guard !dictionary.enclosedSwiftAttributes.contains("source.decl.attribute.override") else {
            return []
        }

        return validateName(dictionary: dictionary, kind: kind).map { name, offset in
            let description = Swift.type(of: self).description
            let type = self.type(for: kind)

            let tokensInName = extractTokens(from: name, ofKind: kind)
            if isMisspelled(tokensInName.joined(separator: " ")) {
                let misspelledWords = findMisspelledWords(in: tokensInName)
                    .map { "'\($0)'" }
                    .joined(separator: ", ")
                let reason = "\(type) '\(name)' contains incorrectly spelled word(s): \(misspelledWords)"
                return [
                    StyleViolation(ruleDescription: description,
                                   severity: .warning,
                                   location: Location(file: file, byteOffset: offset),
                                   reason: reason)
                ]
            }

            return []
        } ?? []
    }

    private func validateName(dictionary: [String: SourceKitRepresentable],
                              kind: SwiftDeclarationKind) -> (name: String, offset: Int)? {
        guard let name = dictionary.name,
            let offset = dictionary.offset,
            kinds.contains(kind) else {
                return nil
        }

        return (name.nameStrippingLeadingUnderscoreIfPrivate(dictionary), offset)
    }

    private func extractTokens(from name: String, ofKind kind: SwiftDeclarationKind) -> [String] {
        let isFunction = SwiftDeclarationKind.functionKinds.contains(kind)
        let tokens = isFunction ? extractFunctionName(from: name).camelCaseTokens : name.camelCaseTokens
        return tokens.filter { !configuration.excluded.contains($0.lowercased()) }
    }

    private func extractFunctionName(from string: String) -> String {
        return string.components(separatedBy: "(").first ?? string
    }

    private func isMisspelled(_ string: String) -> Bool {
        guard !string.isEmpty else {
            return false
        }

        let checker = NSSpellChecker.shared()
        checker.setLanguage(configuration.language)
        let misspelledRange = checker.checkSpelling(of: string, startingAt: 0)
        return misspelledRange.location != NSNotFound
    }

    private func findMisspelledWords(in tokens: [String]) -> [String] {
        return tokens.filter(isMisspelled)
    }

    private let kinds: Set<SwiftDeclarationKind> = {
        return SwiftDeclarationKind.variableKinds
            .union(SwiftDeclarationKind.functionKinds)
    }()

    private func type(for kind: SwiftDeclarationKind) -> String {
        if SwiftDeclarationKind.functionKinds.contains(kind) {
            return "Function"
        } else {
            return "Variable"
        }
    }
}

private extension String {
    var isNumeric: Bool {
        return CharacterSet.decimalDigits.isSuperset(of: CharacterSet(charactersIn: self))
    }

    var camelCaseTokens: [String] {
        guard !self.isEmpty else {
            return []
        }

        var token = ""
        var tokens = [String]()

        for scalar in self.unicodeScalars {
            if CharacterSet.uppercaseLetters.contains(scalar), !token.isEmpty {
                tokens.append(token)
                token = ""
            }
            if CharacterSet.decimalDigits.contains(scalar), !token.isNumeric {
                tokens.append(token)
                token = ""
            }
            token.append(Character(scalar))
        }
        tokens.append(token)

        return combineAcronyms(in: tokens)
    }

    private func combineAcronyms(in tokens: [String]) -> [String] {
        return tokens.reduce([]) {result, token in
            var lastToken = result.last ?? ""
            if token.isUppercase() && lastToken.isUppercase() {
                lastToken.append(token)
                return result.dropLast() + [lastToken]
            }
            return result + [token]
        }
    }
}
