//
//  CategoryProgressBar.swift
//  RustDrill
//
//  Created by huyuneko on 2026/02/23.
//

import SwiftUI

struct CategoryProgressBar: View {
    let solvedCount: Int
    let totalCount: Int
    
    private var progressValue: Double {
        guard totalCount > 0 else { return 0 }
        return Double(solvedCount) / Double(totalCount)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("\(solvedCount) / \(totalCount)問")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Spacer()
                
                Text("\(Int(progressValue * 100))%")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            ProgressView(value: progressValue)
                .progressViewStyle(.linear)
                .tint(.blue)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("進捗 \(solvedCount) / \(totalCount) 問")
    }
}
