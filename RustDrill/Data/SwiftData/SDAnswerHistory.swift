//
//  SDAnswerHistory.swift
//  Rust Drill
//
//  Created by huyuneko on 2026/02/21.
//

import Foundation
import SwiftData

@Model
final class SDAnswerHistory {
    var questionId: String
    var selectedChoiceId: String
    var isCorrect: Bool
    var answeredAt: Date

    init(
        questionId: String,
        selectedChoiceId: String,
        isCorrect: Bool,
        answeredAt: Date = Date()
    ) {
        self.questionId = questionId
        self.selectedChoiceId = selectedChoiceId
        self.isCorrect = isCorrect
        self.answeredAt = answeredAt
    }
}
