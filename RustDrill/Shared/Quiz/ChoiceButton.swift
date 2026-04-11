//
//  ChoiceButton.swift
//  Rust Drill
//
//  Created by huyuneko on 2026/02/21.
//

import SwiftUI

struct ChoiceButton: View {
    enum VisualState {
        case normal
        case selected
        case correct
        case wrongSelected
    }
    
    let text: String
    let visualState: VisualState
    let isDisabled: Bool
    let minHeight: CGFloat
    let showCorrectBadge: Bool
    let onHeightMeasured: (CGFloat) -> Void
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(alignment: .top, spacing: 10) {
                markerView
                    .padding(.top, 1)
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(text)
                        .font(.body)
                        .foregroundStyle(.primary)
                        .multilineTextAlignment(.leading)
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            HeightReader { height in
                                onHeightMeasured(height + 30) // badge分を少し余裕みる
                            }
                        )
                    
                    if showCorrectBadge {
                        HStack(spacing: 4) {
                            Image(systemName: QuizUIConstants.Symbols.result(isCorrect: true))
                                .font(.caption)
                            Text(QuizUIConstants.Strings.correctChoiceLabel)
                                .font(.caption)
                                .fontWeight(.semibold)
                        }
                        .foregroundStyle(QuizUIConstants.Colors.correctTone)
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity, minHeight: minHeight, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(backgroundColor)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(borderColor, lineWidth: borderColor == .clear ? 0 : 1.2)
            )
        }
        .buttonStyle(.plain)
        .disabled(isDisabled)
    }
    
    // MARK: - UI Parts
    
    @ViewBuilder
    private var markerView: some View {
        switch visualState {
        case .normal:
            Circle()
                .stroke(Color.gray.opacity(0.5), lineWidth: 1.5)
                .frame(width: 18, height: 18)
            
        case .selected:
            Circle()
                .stroke(AppUIConstants.Colors.selectedTone, lineWidth: 1.5)
                .frame(width: 18, height: 18)
                .overlay {
                    Circle()
                        .fill(AppUIConstants.Colors.selectedTone)
                        .frame(width: 10, height: 10)
                }
            
        case .correct:
            Circle()
                .stroke(QuizUIConstants.Colors.correctTone, lineWidth: 1.5)
                .frame(width: 18, height: 18)
                .overlay {
                    Image(systemName: QuizUIConstants.Symbols.correctMark)
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(QuizUIConstants.Colors.correctTone)
                }
            
        case .wrongSelected:
            Circle()
                .stroke(QuizUIConstants.Colors.incorrectTone, lineWidth: 1.5)
                .frame(width: 18, height: 18)
                .overlay {
                    Image(systemName: QuizUIConstants.Symbols.incorrectMark)
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(QuizUIConstants.Colors.incorrectTone)
                }
        }
    }
    
    private var backgroundColor: Color {
        switch visualState {
        case .normal:
            return Color.gray.opacity(0.08)
        case .selected:
            return AppUIConstants.Colors.selectedTone.opacity(0.10)
        case .correct:
            return QuizUIConstants.Colors.correctTone.opacity(0.10)
        case .wrongSelected:
            return QuizUIConstants.Colors.incorrectTone.opacity(0.10)
        }
    }
    
    private var borderColor: Color {
        switch visualState {
        case .normal:
            return .clear
        case .selected:
            return AppUIConstants.Colors.selectedTone.opacity(0.6)
        case .correct:
            return QuizUIConstants.Colors.correctTone.opacity(0.7)
        case .wrongSelected:
            return QuizUIConstants.Colors.incorrectTone.opacity(0.7)
        }
    }
}
