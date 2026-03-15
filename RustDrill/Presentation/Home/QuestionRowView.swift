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
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Q\(index)")
                .font(.caption)
                .foregroundStyle(.secondary)
            
            Text(question.title)
                .font(.headline)
                .foregroundStyle(.primary)
            
            if !question.body.isEmpty {
                Text(question.body)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
        }
        .padding(.vertical, 4)
    }
}
