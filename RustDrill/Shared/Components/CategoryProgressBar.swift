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
                Text(
                    AppUIConstants.Strings.progressQuestionCount(
                        solvedCount: solvedCount,
                        totalCount: totalCount
                    )
                )
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Spacer()
                
                Text(AppUIConstants.Strings.progressPercentage(progressValue))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            ProgressView(value: progressValue)
                .progressViewStyle(.linear)
                .tint(AppUIConstants.Colors.selectedTone)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(
            AppUIConstants.Strings.progressAccessibility(
                solvedCount: solvedCount,
                totalCount: totalCount
            )
        )
    }
}
