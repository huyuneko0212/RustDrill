//
//  AppUIConstants.swift
//  Rust Drill
//
//  Created by Codex on 2026/04/12.
//

import SwiftUI

enum AppUIConstants {
    enum Strings {
        static let appTitle = "Rust Drill"
        static let loading = "読み込み中..."
        static let errorTitle = "エラー"
        static let emptyQuestionsTitle = "問題がありません"
        static let emptyQuestionsDescription = "このカテゴリにはまだ問題が登録されていません。"
        static let homeTitle = "ホーム"
        static let reviewTitle = "復習"
        
        static func questionCount(_ count: Int) -> String {
            "\(count)問"
        }
        
        static func progressCount(solvedCount: Int, totalCount: Int) -> String {
            "\(solvedCount) / \(totalCount)"
        }
        
        static func progressQuestionCount(solvedCount: Int, totalCount: Int) -> String {
            "\(progressCount(solvedCount: solvedCount, totalCount: totalCount))問"
        }
        
        static func progressPercentage(_ progress: Double) -> String {
            "\(Int(progress * 100))%"
        }
        
        static func progressAccessibility(solvedCount: Int, totalCount: Int) -> String {
            "進捗 \(solvedCount) / \(totalCount) 問"
        }
    }
    
    enum Symbols {
        static let chevronRight = "chevron.right"
        static let emptyQuestions = "questionmark.circle"
        static let error = "exclamationmark.triangle"
        static let home = "house"
        static let play = "play.fill"
        static let review = "arrow.clockwise.circle"
    }
    
    enum Colors {
        static let accent = Color.accentOrange
        static let selectedTone = Color.blue
        static let solvedTone = Color.green
        static let unsolvedTone = Color.orange
        
        static func solvedStatusTone(isSolved: Bool) -> Color {
            isSolved ? solvedTone : unsolvedTone
        }
    }
}
