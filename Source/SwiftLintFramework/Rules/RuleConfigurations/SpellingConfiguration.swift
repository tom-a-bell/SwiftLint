//
//  SpellingConfiguration.swift
//  SwiftLint
//
//  Created by Tom Bell on 21/10/17.
//  Copyright © 2017 Realm. All rights reserved.
//

import Foundation

public struct SpellingConfiguration: RuleConfiguration, Equatable {
    public var consoleDescription: String {
        return "language: \(language), " +
            "min_length: \(minLength), " +
            "excluded: \(excluded.sorted())"
    }

    var language: String
    var minLength: Int
    var excluded: Set<String>

    public init(language: String = "en",
                minLength: Int = 4,
                excluded: [String] = []) {
        self.language = language
        self.minLength = minLength
        self.excluded = Set(excluded)
    }

    public mutating func apply(configuration: Any) throws {
        guard let configurationDict = configuration as? [String: Any] else {
            throw ConfigurationError.unknownConfiguration
        }

        if let language = configurationDict["language"] as? String {
            self.language = language
        }
        if let minLength = configurationDict["min_length"] as? Int {
            self.minLength = minLength
        }
        if let excluded = [String].array(of: configurationDict["excluded"]) {
            self.excluded = Set(excluded.map { $0.lowercased() })
        }
    }

    public static func == (lhs: SpellingConfiguration, rhs: SpellingConfiguration) -> Bool {
        return lhs.language == rhs.language &&
            lhs.minLength == rhs.minLength &&
            zip(lhs.excluded, rhs.excluded).reduce(true) { $0 && ($1.0 == $1.1) }
    }
}
