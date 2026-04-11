//
//  TextBlockView.swift
//  RustDrill
//
//  Created by huyuneko on 2026/03/07.
//

import SwiftUI

struct TextBlockView: View {
    let text: String
    
    var body: some View {
        Text(attributedText(from: text))
            .font(.body)
            .foregroundStyle(.primary)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private func attributedText(from text: String) -> AttributedString {
        let parts = splitBacktickText(text)
        var result = AttributedString()
        
        for part in parts {
            result.append(attributedSegment(for: part))
        }
        
        return result
    }
    
    private func attributedSegment(for part: TextPart) -> AttributedString {
        switch part {
        case .normal(let value):
            return AttributedString(value)
        case .emphasis(let value):
            var segment = AttributedString(value)
            segment.inlinePresentationIntent = .stronglyEmphasized
            return segment
        }
    }
    
    private func splitBacktickText(_ text: String) -> [TextPart] {
        var result: [TextPart] = []
        var buffer = ""
        var isEmphasis = false
        
        for char in text {
            if char == "`" {
                if !buffer.isEmpty {
                    result.append(isEmphasis ? .emphasis(buffer) : .normal(buffer))
                    buffer = ""
                }
                isEmphasis.toggle()
            } else {
                buffer.append(char)
            }
        }
        
        if !buffer.isEmpty {
            result.append(isEmphasis ? .emphasis(buffer) : .normal(buffer))
        }
        
        return result
    }
}

private enum TextPart {
    case normal(String)
    case emphasis(String)
}
