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
    let onFinish: () -> Void
    let isLastQuestion: Bool

    @Environment(\.dismiss) private var dismiss

    private var correctChoiceText: String {
        result.question.choices.first(where: {
            $0.id == result.question.correctChoiceId
        })?.text ?? Constants.Strings.missingCorrectChoice
    }

    private var visibleSections: [ExplanationSection] {
        result.question.explanationContent.sections.filter { section in
            section.title != Constants.Strings.pointsSectionTitle
                && section.title != Constants.Strings.incorrectChoicesSectionTitle
        }
    }

    private var incorrectChoices: [QuizChoice] {
        result.question.choices.filter { choice in
            choice.id != result.question.correctChoiceId
                && !(choice.explanation ?? "").isEmpty
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Constants.Layout.contentSpacing) {
            HStack(spacing: Constants.Layout.resultHeaderSpacing) {
                Image(
                    systemName: QuizUIConstants.Symbols.result(isCorrect: result.isCorrect)
                )
                .foregroundStyle(QuizUIConstants.Colors.resultTone(isCorrect: result.isCorrect))
                Text(Constants.Strings.resultTitle(isCorrect: result.isCorrect))
                    .font(.title3).bold()
            }

            Group {
                Text(Constants.Strings.correctChoiceLabel)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(correctChoiceText)
                    .font(.body)
            }

            Divider()

            Text(Constants.Strings.explanationHeading)
                .font(.headline)

            ScrollView {
                VStack(alignment: .leading, spacing: Constants.Layout.explanationSpacing) {
                    ForEach(visibleSections) { section in
                        VStack(alignment: .leading, spacing: Constants.Layout.sectionSpacing) {
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
                        .padding(.vertical, Constants.Layout.sectionVerticalPadding)
                    }

                    if !incorrectChoices.isEmpty {
                        incorrectChoicesSection
                    }
                }
                .padding()
            }
            Spacer()

            Button {
                if isLastQuestion {
                    finishQuiz()
                } else {
                    onNext()
                    dismiss()
                }
            } label: {
                Text(Constants.Strings.bottomButtonTitle(isLastQuestion: isLastQuestion))
                    .font(.headline)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .frame(height: QuizUIConstants.Layout.bottomButtonHeight)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .navigationTitle(Constants.Strings.navigationTitle)
        .navigationBarTitleDisplayMode(.inline)
    }

    private func finishQuiz() {
        dismiss()
        DispatchQueue.main.async {
            onFinish()
        }
    }

    private var incorrectChoicesSection: some View {
        VStack(alignment: .leading, spacing: Constants.Layout.sectionSpacing) {
            Text(Constants.Strings.incorrectChoicesSectionTitle)
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            VStack(alignment: .leading, spacing: Constants.Layout.incorrectChoiceCardSpacing) {
                ForEach(incorrectChoices) { choice in
                    VStack(alignment: .leading, spacing: Constants.Layout.incorrectChoiceTextSpacing) {
                        Text(choice.text)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(.primary)

                        if let explanation = choice.explanation, !explanation.isEmpty {
                            TextBlockView(text: explanation)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(Constants.Layout.incorrectChoiceCardPadding)
                    .background(
                        RoundedRectangle(cornerRadius: Constants.Layout.incorrectChoiceCardCornerRadius)
                            .fill(Color.gray.opacity(Constants.Colors.cardFillOpacity))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: Constants.Layout.incorrectChoiceCardCornerRadius)
                            .stroke(
                                Color.gray.opacity(Constants.Colors.cardStrokeOpacity),
                                lineWidth: Constants.Layout.cardStrokeWidth
                            )
                    )
                }
            }
        }
        .padding(.vertical, Constants.Layout.sectionVerticalPadding)
    }
}

private enum Constants {
    enum Strings {
        static let correctChoiceLabel = QuizUIConstants.Strings.correctChoiceLabel
        static let explanationHeading = "解説"
        static let incorrectChoicesSectionTitle = "他の選択肢が不正解の理由"
        static let missingCorrectChoice = "-"
        static let navigationTitle = "解説"
        static let pointsSectionTitle = "ポイント"
        
        static func bottomButtonTitle(isLastQuestion: Bool) -> String {
            isLastQuestion ? "クイズを終了" : "次の問題へ"
        }
        
        static func resultTitle(isCorrect: Bool) -> String {
            QuizUIConstants.Strings.resultTitle(isCorrect: isCorrect)
        }
    }
    
    enum Layout {
        static let contentSpacing: CGFloat = 16
        static let explanationSpacing: CGFloat = 16
        static let resultHeaderSpacing: CGFloat = 8
        static let sectionSpacing: CGFloat = 8
        static let sectionVerticalPadding: CGFloat = 4
        static let incorrectChoiceCardCornerRadius: CGFloat = 14
        static let incorrectChoiceCardPadding: CGFloat = 14
        static let incorrectChoiceCardSpacing: CGFloat = 12
        static let incorrectChoiceTextSpacing: CGFloat = 10
        static let cardStrokeWidth: CGFloat = 1
    }

    enum Colors {
        static let cardFillOpacity: CGFloat = 0.08
        static let cardStrokeOpacity: CGFloat = 0.14
    }
}
