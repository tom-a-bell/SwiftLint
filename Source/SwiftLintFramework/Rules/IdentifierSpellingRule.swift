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

            let tokensInName = extractTokens(from: name)
            if isMisspelled(tokensInName.joined(separator: " ")) {
                let misspelledWords = findMisspelledWords(in: tokensInName)
                let wordsToCorrect = misspelledWords.map { "'\($0)'" }.joined(separator: ", ")
                let reason = "\(type) '\(name)' contains incorrectly spelled word(s): \(wordsToCorrect)"

                var firstSpellingErrorOffset = offset
                if let range = name.range(of: misspelledWords.first!) {
                    firstSpellingErrorOffset += range.lowerBound.encodedOffset
                }

                return [
                    StyleViolation(ruleDescription: description,
                                   severity: .warning,
                                   location: Location(file: file, byteOffset: firstSpellingErrorOffset),
                                   reason: reason)
                ]
            }

            return []
        } ?? []
    }

    private func validateName(dictionary: [String: SourceKitRepresentable],
                              kind: SwiftDeclarationKind) -> (name: String, offset: Int)? {
        guard let name = extractName(from: dictionary, forKind: kind),
            let offset = extractOffset(from: dictionary, forKind: kind),
            kinds.contains(kind) else {
                return nil
        }

        return (name, offset)
    }

    private func extractName(from dictionary: [String: SourceKitRepresentable],
                             forKind kind: SwiftDeclarationKind) -> String? {
        guard let name = dictionary.name else { return nil }
        return kind.isFunction ? extractFunctionName(from: name) : name
    }

    private func extractOffset(from dictionary: [String: SourceKitRepresentable],
                               forKind kind: SwiftDeclarationKind) -> Int? {
        return kind.isParameter ? dictionary.offset : dictionary.nameOffset
    }

    private func extractFunctionName(from string: String) -> String {
        return string.components(separatedBy: "(").first ?? string
    }

    private func extractTokens(from name: String) -> [String] {
        let tokens = name.camelCaseTokens
        return tokens.filter { !configuration.excluded.contains($0.lowercased()) }
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
        return SwiftDeclarationKind.typeKinds
            .union(SwiftDeclarationKind.functionKinds)
            .union(SwiftDeclarationKind.variableKinds)
    }()

    private func type(for kind: SwiftDeclarationKind) -> String {
        if SwiftDeclarationKind.typeKinds.contains(kind) {
            switch kind {
            case .typealias: return "Type alias"
            case .struct: return "Struct"
            case .enum: return "Enum"
            default: return "Class"
            }
        }
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

private extension SwiftDeclarationKind {
    var isFunction: Bool {
        return SwiftDeclarationKind.functionKinds.contains(self)
    }

    var isParameter: Bool {
        return self == .varParameter
    }
}
