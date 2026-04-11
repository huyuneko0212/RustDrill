//
//  QuizUIConstants.swift
//  Rust Drill
//
//  Created by Codex on 2026/04/12.
//

import SwiftUI

enum QuizUIConstants {
    enum Strings {
        static let correctChoiceLabel = "正解"
        static let correctResultTitle = "正解！"
        static let incorrectResultTitle = "不正解"
        static let incorrectResultPrompt = "不正解。解説を確認しましょう"
        
        static func resultTitle(
            isCorrect: Bool,
            incorrectTitle: String = incorrectResultTitle
        ) -> String {
            isCorrect ? correctResultTitle : incorrectTitle
        }
    }
    
    enum Symbols {
        static let correctMark = "checkmark"
        static let incorrectMark = "xmark"
        
        static func result(isCorrect: Bool) -> String {
            isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill"
        }
    }
    
    enum Layout {
        static let bottomButtonHeight: CGFloat = 56
    }
    
    enum Colors {
        static let correctTone = Color.green
        static let incorrectTone = Color.red
        
        static func resultTone(isCorrect: Bool) -> Color {
            isCorrect ? correctTone : incorrectTone
        }
    }
}
