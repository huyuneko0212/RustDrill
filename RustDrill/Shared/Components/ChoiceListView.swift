//
//  ChoiceListView.swift
//  RustDrill
//
//  Created by huyuneko on 2026/02/23.
//

import SwiftUI

struct ChoiceListView: View {
    let choices: [QuizChoice]
    let selectedChoiceId: String?
    let correctChoiceId: String?      // 回答後に使う
    let isSubmitted: Bool
    let onSelect: (String) -> Void
    
    @State private var measuredHeights: [String: CGFloat] = [:]
    
    private var unifiedHeight: CGFloat {
        max(52, measuredHeights.values.max() ?? 52)
    }
    
    var body: some View {
        VStack(spacing: 10) {
            ForEach(choices) { choice in
                let visualState = state(for: choice)
                
                ChoiceButton(
                    text: choice.text,
                    visualState: visualState,
                    isDisabled: isSubmitted,
                    minHeight: unifiedHeight,
                    showCorrectBadge: shouldShowCorrectBadge(for: choice),
                    onHeightMeasured: { height in
                        measuredHeights[choice.id] = height
                    },
                    action: {
                        onSelect(choice.id)
                    }
                )
            }
        }
    }
    
    private func state(for choice: QuizChoice) -> ChoiceButton.VisualState {
        // 回答前
        guard isSubmitted else {
            return (selectedChoiceId == choice.id) ? .selected : .normal
        }
        
        // 回答後
        guard let selectedChoiceId, let correctChoiceId else {
            return .normal
        }
        
        if choice.id == correctChoiceId {
            return .correct
        }
        
        if choice.id == selectedChoiceId && selectedChoiceId != correctChoiceId {
            return .wrongSelected
        }
        
        return .normal
    }
    
    private func shouldShowCorrectBadge(for choice: QuizChoice) -> Bool {
        guard isSubmitted else { return false }
        guard let selectedChoiceId, let correctChoiceId else { return false }
        
        // 不正解時のみ、正解選択肢にバッジ表示
        let wasWrong = selectedChoiceId != correctChoiceId
        return wasWrong && choice.id == correctChoiceId
    }
}
