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
        VStack(spacing: 14) {
            // 進行表示
            HStack {
                Text("Q\(viewModel.currentIndex + 1) / \(viewModel.questions.count)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
            }
            
            // 問題カード
            VStack(alignment: .leading, spacing: 10) {
                Text(question.title)
                    .font(.title3)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Divider()
                
                Text(question.body)
                    .font(.body)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                if let code = question.codeSnippet, !code.isEmpty {
                    CodeBlockView(code: code)
                        .padding(.top, 2)
                }
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.gray.opacity(0.08))
            )
            
            // 選択肢
            ChoiceListView(
                choices: question.choices,
                selectedChoiceId: viewModel.selectedChoiceId,
                isSubmitted: viewModel.submittedResult != nil,
                onSelect: { id in
                    viewModel.selectChoice(id)
                }
            )
            
            Spacer(minLength: 8)
            
            if let result = viewModel.submittedResult {
                NavigationLink {
                    ExplanationView(
                        result: result,
                        onNext: { viewModel.nextQuestion() },
                        isLastQuestion: viewModel.isLastQuestion
                    )
                } label: {
                    Text(viewModel.isLastQuestion ? "解説を見る（最後）" : "解説へ")
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
