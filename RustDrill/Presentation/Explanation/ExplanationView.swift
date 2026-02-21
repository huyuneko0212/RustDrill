//
//  ExplanationView.swift
//  Rust Drill
//
//  Created by huyuneko on 2026/02/21.
//

import SwiftUI

struct ExplanationView: View {
    let result: QuizResult
    let onNext: () -> Void
    let isLastQuestion: Bool

    @Environment(\.dismiss) private var dismiss

    private var correctChoiceText: String {
        result.question.choices.first(where: {
            $0.id == result.question.correctChoiceId
        })?.text ?? "-"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 8) {
                Image(
                    systemName: result.isCorrect
                        ? "checkmark.circle.fill" : "xmark.circle.fill"
                )
                .foregroundStyle(result.isCorrect ? .green : .red)
                Text(result.isCorrect ? "正解！" : "不正解")
                    .font(.title3).bold()
            }

            Group {
                Text("正解")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(correctChoiceText)
                    .font(.body)
            }

            Divider()

            Text("解説")
                .font(.headline)

            ScrollView {
                Text(result.question.explanation)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            Spacer()

            Button(isLastQuestion ? "クイズを終了" : "次の問題へ") {
                if isLastQuestion {
                    dismiss()
                } else {
                    onNext()
                    dismiss()
                }
            }
            .frame(maxWidth: .infinity, minHeight: 50)
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .navigationTitle("解説")
        .navigationBarTitleDisplayMode(.inline)
    }
}
