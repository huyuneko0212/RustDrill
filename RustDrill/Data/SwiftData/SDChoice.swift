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
    var order: Int

    init(
        id: String,
        questionId: String,
        text: String,
        order: Int
    ) {
        self.id = id
        self.questionId = questionId
        self.text = text
        self.order = order
    }
}
