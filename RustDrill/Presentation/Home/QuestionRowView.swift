//
//  QuestionRowView.swift
//  RustDrill
//
//  Created by huyuneko on 2026/03/15.
//

import SwiftUI

struct QuestionRowView: View {
    let index: Int
    let question: QuizQuestion
    let isSolved: Bool
    let showsStatus: Bool
    
    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Q\(index)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Text(question.title)
                    .font(.headline)
                    .foregroundStyle(.primary)
                    .lineLimit(2)
            }
            
            Spacer()
            
            if showsStatus {
                Text(Constants.Strings.statusLabel(isSolved: isSolved))
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(AppUIConstants.Colors.solvedStatusTone(isSolved: isSolved))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(AppUIConstants.Colors.solvedStatusTone(isSolved: isSolved).opacity(0.12))
                    )
            }
        }
        .padding(.vertical, 6)
    }
}

private enum Constants {
    enum Strings {
        static func statusLabel(isSolved: Bool) -> String {
            isSolved ? "解答済み" : "未解答"
        }
    }
}
