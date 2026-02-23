//
//  ChoiceButton.swift
//  Rust Drill
//
//  Created by huyuneko on 2026/02/21.
//

import SwiftUI

struct ChoiceButton: View {
    let text: String
    let isSelected: Bool
    let isDisabled: Bool
    let minHeight: CGFloat
    let onHeightMeasured: (CGFloat) -> Void
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(alignment: .top, spacing: 10) {
                // 選択肢マーカー（任意）
                Circle()
                    .stroke(isSelected ? Color.blue : Color.gray.opacity(0.5), lineWidth: 1.5)
                    .frame(width: 18, height: 18)
                    .overlay {
                        if isSelected {
                            Circle()
                                .fill(Color.blue)
                                .frame(width: 10, height: 10)
                        }
                    }
                    .padding(.top, 1)
                
                Text(text)
                    .font(.body)
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.leading)
                    .lineLimit(nil)                  // 改行許可
                    .fixedSize(horizontal: false, vertical: true) // 縦に伸びる
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        HeightReader { height in
                            onHeightMeasured(height + 24) // padding分を少し足す
                        }
                    )
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity, minHeight: minHeight, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.blue.opacity(0.12) : Color.gray.opacity(0.08))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 1.2)
            )
        }
        .buttonStyle(.plain)
        .disabled(isDisabled)
    }
}
