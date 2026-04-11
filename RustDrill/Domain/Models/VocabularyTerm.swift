//
//  VocabularyTerm.swift
//  Rust Drill
//
//  Created by Codex on 2026/04/12.
//

import Foundation

struct VocabularyTerm: Identifiable, Codable, Hashable {
    let id: String
    let title: String
    let reading: String
    let description: String
    let detailDescription: String
    let keyPoints: [String]
    let pitfalls: [String]
    let codeExamples: [VocabularyCodeExample]
    let relatedTermIds: [String]
}

struct VocabularyCodeExample: Identifiable, Codable, Hashable {
    let title: String
    let code: String

    var id: String {
        "\(title)-\(code)"
    }
}
