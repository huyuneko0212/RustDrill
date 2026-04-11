//
//  CategoryRowView.swift
//  RustDrill
//
//  Created by huyuneko on 2026/02/23.
//

import SwiftUI

struct CategoryRowView: View {
    let category: Category
    let isRecommended: Bool
    let progress: CategoryProgress
    
    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            VStack(alignment: .leading, spacing: 12) {
                titleView

                CategoryProgressBar(
                    solvedCount: progress.solvedCount,
                    totalCount: progress.totalCount
                )
            }
            
            Spacer(minLength: 8)
            
            chevronView
        }
        .padding(.vertical, 10)
        .contentShape(Rectangle())
    }
    
    private var titleView: some View {
        Text(category.name)
            .font(.system(size: 19, weight: .semibold))
            .foregroundStyle(.primary)
            .lineLimit(1)
    }
    
    private var chevronView: some View {
        Image(systemName: AppUIConstants.Symbols.chevronRight)
            .font(.system(size: 12, weight: .semibold))
            .foregroundStyle(.secondary.opacity(0.75))
            .padding(.trailing, 2)
    }
}
