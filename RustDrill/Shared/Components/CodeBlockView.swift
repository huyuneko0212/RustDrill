//
//  CodeBlockView.swift
//  Rust Drill
//
//  Created by huyuneko on 2026/02/21.
//

import SwiftUI

struct CodeBlockView: View {
    let code: String
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: true) {
            Text(highlightedCode(code))
                .font(.system(size: 15, weight: .regular, design: .monospaced))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .textSelection(.enabled)
        }
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color(red: 0.12, green: 0.13, blue: 0.16))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        )
    }
}
    
private func highlightedCode(_ source: String) -> AttributedString {
    var attributed = AttributedString(source)
    attributed.foregroundColor = Color(red: 0.90, green: 0.92, blue: 0.96)
    
    let nsRange = NSRange(source.startIndex..., in: source)
    
    let rules: [(pattern: String, color: Color)] = [
        (#"\b(fn|let|mut|if|else|match|struct|enum|impl|trait|pub|use|mod|return|while|for|loop|in|break|continue)\b"#,
         Color(red: 0.38, green: 0.68, blue: 1.00)),
        (#"\b(i8|i16|i32|i64|i128|u8|u16|u32|u64|u128|usize|isize|f32|f64|bool|char|str|String|Option|Result|Vec)\b"#,
         Color(red: 0.40, green: 0.86, blue: 0.75)),
        (#""[^"]*""#,
         Color(red: 1.00, green: 0.55, blue: 0.55)),
        (#"//.*"#,
         Color(red: 0.55, green: 0.60, blue: 0.67)),
        (#"\b[0-9]+\b"#,
         Color(red: 0.98, green: 0.76, blue: 0.38)),
        (#"\b[a-zA-Z_][a-zA-Z0-9_]*!"#,
         Color(red: 0.78, green: 0.55, blue: 1.00))
    ]
    
    for rule in rules {
        guard let regex = try? NSRegularExpression(pattern: rule.pattern) else { continue }
        let matches = regex.matches(in: source, range: nsRange)
        
        for match in matches {
            guard
                let range = Range(match.range, in: source),
                let attrRange = Range(range, in: attributed)
            else { continue }
            
            attributed[attrRange].foregroundColor = rule.color
        }
    }
    
    return attributed
}
