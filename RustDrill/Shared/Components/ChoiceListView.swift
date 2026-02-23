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
    let isSubmitted: Bool
    let onSelect: (String) -> Void
    
    @State private var measuredHeights: [String: CGFloat] = [:]
    
    private var unifiedHeight: CGFloat {
        // 最低高さを確保しつつ、最も高い選択肢に合わせる
        max(52, measuredHeights.values.max() ?? 52)
    }
    
    var body: some View {
        VStack(spacing: 10) {
            ForEach(choices) { choice in
                ChoiceButton(
                    text: choice.text,
                    isSelected: selectedChoiceId == choice.id,
                    isDisabled: isSubmitted,
                    minHeight: unifiedHeight,
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
}
