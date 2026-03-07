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
        buildText(from: text)
            .font(.body)
            .foregroundStyle(.primary)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private func buildText(from text: String) -> Text {
        let parts = splitBacktickText(text)
        
        return parts.reduce(Text("")) { partial, part in
            partial + styledText(for: part)
        }
    }
    
    private func styledText(for part: TextPart) -> Text {
        switch part {
        case .normal(let value):
            return Text(value)
        case .emphasis(let value):
            return Text(value).fontWeight(.bold)
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
