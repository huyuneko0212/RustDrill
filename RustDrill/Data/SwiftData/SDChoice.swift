//
//  SDChoice.swift
//  Rust Drill
//
//  Created by huyuneko on 2026/02/21.
//

import Foundation
import SwiftData

@Model
final class SDChoice {
    @Attribute(.unique) var id: String
    var questionId: String
    var text: String
    var explanation: String?
    var order: Int

    init(
        id: String,
        questionId: String,
        text: String,
        explanation: String? = nil,
        order: Int
    ) {
        self.id = id
        self.questionId = questionId
        self.text = text
        self.explanation = explanation
        self.order = order
    }
}
