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
    let difficulty: Int
    let tags: [String]
}
