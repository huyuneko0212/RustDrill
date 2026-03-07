//
//  QuizQuestion.swift
//  Rust Drill
//
//  Created by huyuneko on 2026/02/21.
//

import Foundation

enum QuestionType: String, Codable {
    case basic
    case codeReading
}
enum ExplanationSectionKind: String, Codable, Hashable {
    case text
    case code
    case diagram
}

struct QuizQuestion: Identifiable, Codable, Hashable {
    let id: String
    let categoryId: String
    let type: QuestionType
    let title: String
    let body: String
    let codeSnippet: String?
    let choices: [QuizChoice]
    let correctChoiceId: String
    let explanation: String
    let explanationContent: ExplanationContent
    let difficulty: Int
    let tags: [String]
}

struct ExplanationContent: Codable, Hashable {
    let summary: String
    let sections: [ExplanationSection]
}

struct ExplanationSection: Codable, Hashable, Identifiable {
    let kind: ExplanationSectionKind
    let title: String
    let body: String?
    let language: String?
    let code: String?
    
    var id: String {
        "\(kind.rawValue)-\(title)"
    }
}
