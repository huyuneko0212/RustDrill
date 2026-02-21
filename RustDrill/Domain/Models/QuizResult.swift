//
//  QuizResult.swift
//  Rust Drill
//
//  Created by huyuneko on 2026/02/21.
//

import Foundation

struct QuizResult {
    let question: QuizQuestion
    let selectedChoiceId: String
    let isCorrect: Bool
}
