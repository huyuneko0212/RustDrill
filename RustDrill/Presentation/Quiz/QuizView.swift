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
                ScrollView {
                    VStack(spacing: 14) {
                        questionHeader
                        questionCard(question)
                        choiceList(question)
                    }
                    .padding()
                    .padding(.bottom, 8)
                }
                .safeAreaInset(edge: .bottom) {
                    bottomBar
                        .background(.ultraThinMaterial)
                }

            } else if let message = viewModel.errorMessage {
                ContentUnavailableView(
                    "エラー",
                    systemImage: "exclamationmark.triangle",
                    description: Text(message)
                )
            } else {
                ContentUnavailableView(
                    "問題がありません",
                    systemImage: "questionmark.circle"
                )
            }
        }
        .navigationTitle("クイズ")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $showExplanation) {
            if let result = explanationResult {
                ExplanationView(
                    result: result,
                    onNext: { viewModel.nextQuestion() },
                    isLastQuestion: viewModel.isLastQuestion
                )
            }
        }
    }

    // MARK: - Content

    private var questionHeader: some View {
        HStack {
            Text(
                "Q\(viewModel.currentIndex + 1) / \(viewModel.questions.count)"
            )
            .font(.caption)
            .foregroundStyle(.secondary)
            Spacer()
        }
    }

    @ViewBuilder
    private func questionCard(_ question: QuizQuestion) -> some View {
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
    }

    @ViewBuilder
    private func choiceList(_ question: QuizQuestion) -> some View {
        ChoiceListView(
            choices: question.choices,
            selectedChoiceId: viewModel.selectedChoiceId,
            correctChoiceId: (viewModel.submittedResult != nil)
                ? question.correctChoiceId : nil,
            isSubmitted: viewModel.submittedResult != nil,
            onSelect: { id in
                viewModel.selectChoice(id)
            }
        )
    }

    // MARK: - Fixed Bottom Bar

    private var bottomBar: some View {
        VStack(spacing: 10) {
            Divider()
            
            if let result = viewModel.submittedResult {
                resultBanner(isCorrect: result.isCorrect)
                
                let shouldEmphasizeExplanation = !result.isCorrect
                
                HStack(spacing: 10) {
                    // 解説へ（不正解時は主ボタン / 正解時はサブボタン）
                    if shouldEmphasizeExplanation {
                        explanationButtonProminent(result: result)
                    } else {
                        explanationButtonSecondary(result: result)
                    }
                    
                    // 次へ / 終了（正解時は主ボタン / 不正解時はサブボタン）
                    if viewModel.isLastQuestion {
                        if shouldEmphasizeExplanation {
                            endButtonSecondary()
                        } else {
                            endButtonProminent()
                        }
                    } else {
                        if shouldEmphasizeExplanation {
                            nextButtonSecondary()
                        } else {
                            nextButtonProminent()
                        }
                    }
                }
            } else {
                Button("回答する") {
                    viewModel.submit()
                }
                .frame(maxWidth: .infinity, minHeight: 44)
                .buttonStyle(.borderedProminent)
                .disabled(!viewModel.canSubmit)
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 4)
        .padding(.bottom, 10)
    }
    
    @ViewBuilder
    private func resultBanner(isCorrect: Bool) -> some View {
        HStack(spacing: 8) {
            Image(
                systemName: isCorrect
                    ? "checkmark.circle.fill" : "xmark.circle.fill"
            )
            .foregroundStyle(isCorrect ? .green : .red)

            Text(isCorrect ? "正解" : "不正解")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(isCorrect ? .green : .red)

            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill((isCorrect ? Color.green : Color.red).opacity(0.08))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(
                    (isCorrect ? Color.green : Color.red).opacity(0.25),
                    lineWidth: 1
                )
        )
    }

    @ViewBuilder
    private func explanationButtonProminent(result: QuizResult) -> some View {
        Button {
            Task { await openExplanation(result: result) }
        } label: {
            explanationButtonLabel
        }
        .buttonStyle(.borderedProminent)
        .disabled(isOpeningExplanation)
    }
    
    @ViewBuilder
    private func explanationButtonSecondary(result: QuizResult) -> some View {
        Button {
            Task { await openExplanation(result: result) }
        } label: {
            explanationButtonLabel
        }
        .buttonStyle(.bordered)
        .disabled(isOpeningExplanation)
    }
    
    private var explanationButtonLabel: some View {
        HStack(spacing: 6) {
            if isOpeningExplanation {
                ProgressView()
                    .controlSize(.small)
            }
            Text("解説へ")
                .fontWeight(.semibold)
        }
        .frame(minHeight: 42)
        .frame(maxWidth: 120)
    }
    
    @ViewBuilder
    private func nextButtonProminent() -> some View {
        Button("次へ") {
            viewModel.nextQuestion()
        }
        .frame(maxWidth: .infinity, minHeight: 42)
        .buttonStyle(.borderedProminent)
        .disabled(isOpeningExplanation)
    }
    
    @ViewBuilder
    private func nextButtonSecondary() -> some View {
        Button("次へ") {
            viewModel.nextQuestion()
        }
        .frame(maxWidth: .infinity, minHeight: 42)
        .buttonStyle(.bordered)
        .disabled(isOpeningExplanation)
    }
    
    @ViewBuilder
    private func endButtonProminent() -> some View {
        Button("終了") {
            dismissQuiz()
        }
        .frame(maxWidth: .infinity, minHeight: 42)
        .buttonStyle(.borderedProminent)
        .disabled(isOpeningExplanation)
    }
    
    @ViewBuilder
    private func endButtonSecondary() -> some View {
        Button("終了") {
            dismissQuiz()
        }
        .frame(maxWidth: .infinity, minHeight: 42)
        .buttonStyle(.bordered)
        .disabled(isOpeningExplanation)
    }
    
    // MARK: - Actions

    private func dismissQuiz() {
        dismiss()
    }

    private func openExplanation(result: QuizResult) async {
        guard !isOpeningExplanation else { return }

        isOpeningExplanation = true
        defer { isOpeningExplanation = false }

        let ok = await appContainer.adGateService.showGateIfNeeded()
        guard ok else { return }

        explanationResult = result
        showExplanation = true
    }
    
}
