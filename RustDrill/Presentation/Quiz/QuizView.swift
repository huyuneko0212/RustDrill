//
//  QuizView.swift
//  Rust Drill
//
//  Created by huyuneko on 2026/02/21.
//

import SwiftUI

struct QuizView: View {
    @StateObject var viewModel: QuizViewModel
    
    var body: some View {
        Group {
            if let question = viewModel.currentQuestion {
                content(question: question)
            } else if let message = viewModel.errorMessage {
                ContentUnavailableView("エラー", systemImage: "exclamationmark.triangle", description: Text(message))
            } else {
                ContentUnavailableView("問題がありません", systemImage: "questionmark.circle")
            }
        }
        .navigationTitle("クイズ")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    @ViewBuilder
    private func content(question: QuizQuestion) -> some View {
        VStack(spacing: 16) {
            // 問題ヘッダ
            VStack(alignment: .leading, spacing: 8) {
                Text("Q\(viewModel.currentIndex + 1) / \(viewModel.questions.count)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Text(question.title)
                    .font(.headline)
                
                Text(question.body)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            // コード表示
            if let code = question.codeSnippet, !code.isEmpty {
                CodeBlockView(code: code)
            }
            
            // 選択肢
            VStack(spacing: 10) {
                ForEach(question.choices) { choice in
                    ChoiceButton(
                        text: choice.text,
                        isSelected: viewModel.selectedChoiceId == choice.id,
                        isDisabled: viewModel.submittedResult != nil,
                        action: { viewModel.selectChoice(choice.id) }
                    )
                }
            }
            
            Spacer()
            
            // 下部ボタン
            if let result = viewModel.submittedResult {
                NavigationLink {
                    ExplanationView(
                        result: result,
                        onNext: {
                            viewModel.nextQuestion()
                        },
                        isLastQuestion: viewModel.isLastQuestion
                    )
                } label: {
                    Text(viewModel.isLastQuestion ? "結果を見る" : "解説へ")
                        .frame(maxWidth: .infinity, minHeight: 50)
                }
                .buttonStyle(.borderedProminent)
            } else {
                Button("回答する") {
                    viewModel.submit()
                }
                .frame(maxWidth: .infinity, minHeight: 50)
                .buttonStyle(.borderedProminent)
                .disabled(!viewModel.canSubmit)
            }
        }
        .padding()
    }
}
