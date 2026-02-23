//
//  QuizView.swift
//  Rust Drill
//
//  Created by huyuneko on 2026/02/21.
//

import SwiftUI

struct QuizView: View {
    @EnvironmentObject private var appContainer: AppContainer
    @Environment(\.dismiss) private var dismiss
    
    @StateObject var viewModel: QuizViewModel
    
    @State private var showExplanation = false
    @State private var isOpeningExplanation = false
    @State private var explanationResult: QuizResult?
    
    var body: some View {
        Group {
            if let question = viewModel.currentQuestion {
                content(question: question)
            } else if let message = viewModel.errorMessage {
                ContentUnavailableView(
                    "エラー",
                    systemImage: "exclamationmark.triangle",
                    description: Text(message)
                )
            } else {
                ContentUnavailableView("問題がありません", systemImage: "questionmark.circle")
            }
        }
        .navigationTitle("クイズ")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $showExplanation) {
            if let result = explanationResult {
                ExplanationView(
                    result: result,
                    onNext: {
                        viewModel.nextQuestion()
                    },
                    isLastQuestion: viewModel.isLastQuestion
                )
            }
        }
    }
    
    @ViewBuilder
    private func content(question: QuizQuestion) -> some View {
        VStack(spacing: 14) {
            // 問題番号
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
            
            // 下部ボタン群
            if let result = viewModel.submittedResult {
                answeredButtons(result: result)
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
    
    @ViewBuilder
    private func answeredButtons(result: QuizResult) -> some View {
        VStack(spacing: 10) {
            Button {
                Task {
                    await openExplanation(result: result)
                }
            } label: {
                HStack(spacing: 8) {
                    if isOpeningExplanation {
                        ProgressView()
                            .controlSize(.small)
                    }
                    Text("解説へ")
                }
                .frame(maxWidth: .infinity, minHeight: 50)
            }
            .buttonStyle(.borderedProminent)
            .disabled(isOpeningExplanation)
            
            if viewModel.isLastQuestion {
                Button("終了（解説をスキップ）") {
                    dismissQuiz()
                }
                .frame(maxWidth: .infinity, minHeight: 46)
                .buttonStyle(.bordered)
            } else {
                Button("次へ（解説をスキップ）") {
                    viewModel.nextQuestion()
                }
                .frame(maxWidth: .infinity, minHeight: 46)
                .buttonStyle(.bordered)
            }
        }
    }
    
    private func dismissQuiz() {
        dismiss()
    }
    
    private func openExplanation(result: QuizResult) async {
        guard !isOpeningExplanation else { return }
        
        isOpeningExplanation = true
        defer { isOpeningExplanation = false }
        
        // 広告ゲート（頻度制御つき）
        let ok = await appContainer.adGateService.showGateIfNeeded()
        guard ok else { return }
        
        explanationResult = result
        showExplanation = true
    }
}
