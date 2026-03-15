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
            
            Text(isSolved ? "解答済み" : "未解答")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(isSolved ? .green : .orange)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill((isSolved ? Color.green : Color.orange).opacity(0.12))
                )
        }
        .padding(.vertical, 6)
    }
}
