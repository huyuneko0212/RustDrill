//
//  HeightReader.swift
//  RustDrill
//
//  Created by huyuneko on 2026/02/23.
//

import SwiftUI

private struct HeightPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}

struct HeightReader: View {
    let onChange: (CGFloat) -> Void
    
    var body: some View {
        GeometryReader { proxy in
            Color.clear
                .preference(key: HeightPreferenceKey.self, value: proxy.size.height)
        }
        .onPreferenceChange(HeightPreferenceKey.self, perform: onChange)
    }
}
