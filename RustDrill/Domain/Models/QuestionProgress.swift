//
//  QuestionProgress.swift
//  Rust Drill
//
//  Created by huyuneko on 2026/02/21.
//

import Foundation

struct QuestionProgress: Identifiable, Codable, Hashable {
    var id: String { questionId }
    let questionId: String
    var correctCount: Int
    var wrongCount: Int
    var lastAnsweredAt: Date?
    var isFavorite: Bool
    var needsReview: Bool
}
