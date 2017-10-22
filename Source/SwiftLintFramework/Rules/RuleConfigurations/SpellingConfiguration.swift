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
            "excluded: \(excluded.sorted())"
    }

    var language: String
    var excluded: Set<String>

    public init(language: String = "en",
                excluded: [String] = []) {
        self.language = language
        self.excluded = Set(excluded)
    }

    public mutating func apply(configuration: Any) throws {
        guard let configurationDict = configuration as? [String: Any] else {
            throw ConfigurationError.unknownConfiguration
        }

        if let language = configurationDict["language"] as? String {
            self.language = language
        }
        if let excluded = [String].array(of: configurationDict["excluded"]) {
            self.excluded = Set(excluded.map { $0.lowercased() })
        }
    }

    public static func ==(lhs: SpellingConfiguration, rhs: SpellingConfiguration) -> Bool {
        return lhs.language == rhs.language &&
            zip(lhs.excluded, rhs.excluded).reduce(true) { $0 && ($1.0 == $1.1) }
    }
}
