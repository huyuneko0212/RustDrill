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
    
    private let bottomButtonHeight: CGFloat = 56

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
                VStack(alignment: .leading, spacing: 16) {
                    TextBlockView(text: result.question.explanation)
                    
                    ForEach(result.question.explanationContent.sections) { section in
                        VStack(alignment: .leading, spacing: 8) {
                            Text(section.title)
                                .font(.headline)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            switch section.kind {
                            case .text:
                                if let body = section.body, !body.isEmpty {
                                    TextBlockView(text: body)
                                }
                                
                            case .code:
                                if let code = section.code, !code.isEmpty {
                                        CodeBlockView(code: code)
                                }
                                
                            case .diagram:
                                if let body = section.body, !body.isEmpty {
                                    Text(body)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
                .padding()
            }
            Spacer()

            Button {
                if isLastQuestion {
                    dismiss()
                } else {
                    onNext()
                    dismiss()
                }
            } label: {
                Text(isLastQuestion ? "クイズを終了" : "次の問題へ")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .frame(height: bottomButtonHeight)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .navigationTitle("解説")
        .navigationBarTitleDisplayMode(.inline)
    }
}
