//
//  SDQuestion.swift
//  Rust Drill
//
//  Created by huyuneko on 2026/02/21.
//

import Foundation
import SwiftData

@Model
final class SDQuestion {
    @Attribute(.unique) var id: String
    var categoryId: String
    var typeRaw: String
    var title: String
    var body: String
    var codeSnippet: String?
    var correctChoiceId: String
    var explanation: String
    var difficulty: Int
    var tags: [String]

    @Relationship(deleteRule: .cascade)
    var choices: [SDChoice]

    init(
        id: String,
        categoryId: String,
        typeRaw: String,
        title: String,
        body: String,
        codeSnippet: String?,
        correctChoiceId: String,
        explanation: String,
        difficulty: Int,
        tags: [String],
        choices: [SDChoice] = []
    ) {
        self.id = id
        self.categoryId = categoryId
        self.typeRaw = typeRaw
        self.title = title
        self.body = body
        self.codeSnippet = codeSnippet
        self.correctChoiceId = correctChoiceId
        self.explanation = explanation
        self.difficulty = difficulty
        self.tags = tags
        self.choices = choices
    }
}
