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
        })?.text ?? Constants.Strings.missingCorrectChoice
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
                    TextBlockView(text: result.question.explanation)
                    
                    ForEach(result.question.explanationContent.sections) { section in
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
}

private enum Constants {
    enum Strings {
        static let correctChoiceLabel = QuizUIConstants.Strings.correctChoiceLabel
        static let explanationHeading = "解説"
        static let missingCorrectChoice = "-"
        static let navigationTitle = "解説"
        
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
    }
}
