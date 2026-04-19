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
                    VStack(spacing: Constants.Layout.contentSpacing) {
                        questionHeader
                        
                        if let result = viewModel.submittedResult {
                            resultBanner(isCorrect: result.isCorrect)
                                .transition(.move(edge: .top).combined(with: .opacity))
                        }
                        
                        questionCard(question)
                        choiceList(question)
                    }
                    .padding()
                    .padding(.bottom, Constants.Layout.scrollBottomPadding)
                }
                .safeAreaInset(edge: .bottom) {
                    bottomBar
                        .background(.ultraThinMaterial)
                }
                
            } else if let message = viewModel.errorMessage {
                ContentUnavailableView(
                    AppUIConstants.Strings.errorTitle,
                    systemImage: AppUIConstants.Symbols.error,
                    description: Text(message)
                )
            } else {
                ContentUnavailableView(
                    AppUIConstants.Strings.emptyQuestionsTitle,
                    systemImage: AppUIConstants.Symbols.emptyQuestions
                )
            }
        }
        .animation(
            .easeInOut(duration: Constants.Animation.resultDuration),
            value: viewModel.submittedResult != nil
        )
        .navigationTitle(Constants.Strings.navigationTitle)
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $showExplanation) {
            if let result = explanationResult {
                ExplanationView(
                    result: result,
                    onNext: { viewModel.nextQuestion() },
                    onFinish: { finishQuizFromExplanation() },
                    isLastQuestion: viewModel.isLastQuestion
                )
            }
        }
    }
    
    // MARK: - Content
    
    private var questionHeader: some View {
        HStack {
            Text(
                Constants.Strings.questionProgress(
                    currentIndex: viewModel.currentIndex,
                    questionCount: viewModel.questions.count
                )
            )
                .font(.caption)
                .foregroundStyle(.secondary)
            Spacer()
        }
    }
    
    @ViewBuilder
    private func questionCard(_ question: QuizQuestion) -> some View {
        VStack(alignment: .leading, spacing: Constants.Layout.questionCardSpacing) {
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
                    .padding(.top, Constants.Layout.codeBlockTopPadding)
            }
        }
        .padding(Constants.Layout.questionCardPadding)
        .background(
            RoundedRectangle(cornerRadius: Constants.Layout.questionCardCornerRadius)
                .fill(Color.gray.opacity(Constants.Colors.cardFillOpacity))
        )
        .overlay(
            RoundedRectangle(cornerRadius: Constants.Layout.questionCardCornerRadius)
                .stroke(
                    Color.gray.opacity(Constants.Colors.cardStrokeOpacity),
                    lineWidth: Constants.Layout.strokeWidth
                )
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
        VStack(spacing: Constants.Layout.bottomBarSpacing) {
            Divider()
            
            if let result = viewModel.submittedResult {
                HStack(spacing: Constants.Layout.bottomButtonSpacing) {
                    explanationButtonUnified(result: result)
                    nextOrEndButtonUnified()
                }
            } else {
                Button {
                    viewModel.submit()
                } label: {
                    bottomActionLabel(Constants.Strings.submitButtonTitle)
                }
                .buttonStyle(.borderedProminent)
                .disabled(!viewModel.canSubmit)
            }
        }
        .padding(.horizontal, Constants.Layout.bottomBarHorizontalPadding)
        .padding(.top, Constants.Layout.bottomBarTopPadding)
        .padding(.bottom, Constants.Layout.bottomBarBottomPadding)
    }
    
    @ViewBuilder
    private func resultBanner(isCorrect: Bool) -> some View {
        let title = Constants.Strings.resultBannerTitle(isCorrect: isCorrect)
        let symbol = QuizUIConstants.Symbols.result(isCorrect: isCorrect)
        let toneColor = QuizUIConstants.Colors.resultTone(isCorrect: isCorrect)
        
        HStack(alignment: .top, spacing: Constants.Layout.resultBannerSpacing) {
            Image(systemName: symbol)
                .foregroundStyle(toneColor)
                .padding(.top, Constants.Layout.resultIconTopPadding)
            
            Text(title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(toneColor)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Spacer(minLength: 0)
        }
        .padding(.horizontal, Constants.Layout.resultBannerHorizontalPadding)
        .padding(.vertical, Constants.Layout.resultBannerVerticalPadding)
        .background(
            RoundedRectangle(cornerRadius: Constants.Layout.resultBannerCornerRadius)
                .fill(toneColor.opacity(Constants.Colors.resultFillOpacity))
        )
        .overlay(
            RoundedRectangle(cornerRadius: Constants.Layout.resultBannerCornerRadius)
                .stroke(
                    toneColor.opacity(Constants.Colors.resultStrokeOpacity),
                    lineWidth: Constants.Layout.strokeWidth
                )
        )
    }
    
    @ViewBuilder
    private func explanationButtonUnified(result: QuizResult) -> some View {
        let button = Button {
            Task { await openExplanation(result: result) }
        } label: {
            HStack(spacing: Constants.Layout.explanationButtonSpacing) {
                if isOpeningExplanation {
                    ProgressView()
                        .controlSize(.small)
                }
                
                Text(Constants.Strings.explanationButtonTitle)
            }
            .fontWeight(.semibold)
            .frame(maxWidth: .infinity)
            .frame(height: QuizUIConstants.Layout.bottomButtonHeight)
            .contentShape(Rectangle())
        }
            .font(.headline)
            .tint(AppUIConstants.Colors.explanation)
            .disabled(isOpeningExplanation)
        button.buttonStyle(.bordered)
    }
    
    @ViewBuilder
    private func nextOrEndButtonUnified() -> some View {
        if viewModel.isLastQuestion {
            actionButton(
                title: Constants.Strings.finishButtonTitle,
                action: { dismissQuiz() }
            )
        } else {
            actionButton(
                title: Constants.Strings.nextButtonTitle,
                action: { viewModel.nextQuestion() }
            )
        }
    }
    
    @ViewBuilder
    private func actionButton(
        title: String,
        action: @escaping () -> Void
    ) -> some View {
        let button = Button(action: action) {
            bottomActionLabel(title)
        }
            .disabled(isOpeningExplanation)
        button.buttonStyle(.borderedProminent)
    }

    private func bottomActionLabel(_ title: String) -> some View {
        Text(title)
            .font(.headline)
            .fontWeight(.semibold)
            .frame(maxWidth: .infinity)
            .frame(height: QuizUIConstants.Layout.bottomButtonHeight)
            .contentShape(Rectangle())
    }
    
    // MARK: - Actions
    
    private func dismissQuiz() {
        dismiss()
    }

    private func finishQuizFromExplanation() {
        explanationResult = nil
        dismissQuiz()
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

private enum Constants {
    enum Strings {
        static let navigationTitle = "クイズ"
        static let submitButtonTitle = "回答する"
        static let explanationButtonTitle = "解説へ"
        static let finishButtonTitle = "終了"
        static let nextButtonTitle = "次へ"
        
        static func questionProgress(currentIndex: Int, questionCount: Int) -> String {
            "Q\(currentIndex + 1) / \(questionCount)"
        }
        
        static func resultBannerTitle(isCorrect: Bool) -> String {
            QuizUIConstants.Strings.resultTitle(
                isCorrect: isCorrect,
                incorrectTitle: QuizUIConstants.Strings.incorrectResultPrompt
            )
        }
    }
    
    enum Layout {
        static let bottomBarBottomPadding: CGFloat = 12
        static let bottomBarHorizontalPadding: CGFloat = 16
        static let bottomBarSpacing: CGFloat = 12
        static let bottomBarTopPadding: CGFloat = 6
        static let bottomButtonSpacing: CGFloat = 12
        static let codeBlockTopPadding: CGFloat = 2
        static let contentSpacing: CGFloat = 14
        static let explanationButtonSpacing: CGFloat = 8
        static let questionCardCornerRadius: CGFloat = 14
        static let questionCardPadding: CGFloat = 14
        static let questionCardSpacing: CGFloat = 10
        static let resultBannerCornerRadius: CGFloat = 10
        static let resultBannerHorizontalPadding: CGFloat = 12
        static let resultBannerSpacing: CGFloat = 8
        static let resultBannerVerticalPadding: CGFloat = 10
        static let resultIconTopPadding: CGFloat = 1
        static let scrollBottomPadding: CGFloat = 8
        static let strokeWidth: CGFloat = 1
    }
    
    enum Colors {
        static let cardFillOpacity = 0.08
        static let cardStrokeOpacity = 0.25
        static let resultFillOpacity = 0.08
        static let resultStrokeOpacity = 0.25
    }
    
    enum Animation {
        static let resultDuration = 0.2
    }
}
