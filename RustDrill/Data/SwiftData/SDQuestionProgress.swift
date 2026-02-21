//
//  SDQuestionProgress.swift
//  Rust Drill
//
//  Created by huyuneko on 2026/02/21.
//

import Foundation
import SwiftData

@Model
final class SDQuestionProgress {
    @Attribute(.unique) var questionId: String
    var correctCount: Int
    var wrongCount: Int
    var lastAnsweredAt: Date?
    var isFavorite: Bool
    var needsReview: Bool
    var updatedAt: Date

    init(
        questionId: String,
        correctCount: Int = 0,
        wrongCount: Int = 0,
        lastAnsweredAt: Date? = nil,
        isFavorite: Bool = false,
        needsReview: Bool = false,
        updatedAt: Date = Date()
    ) {
        self.questionId = questionId
        self.correctCount = correctCount
        self.wrongCount = wrongCount
        self.lastAnsweredAt = lastAnsweredAt
        self.isFavorite = isFavorite
        self.needsReview = needsReview
        self.updatedAt = updatedAt
    }
}
