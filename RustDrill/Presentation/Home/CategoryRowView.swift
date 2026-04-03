//
//  CategoryRowView.swift
//  RustDrill
//
//  Created by huyuneko on 2026/02/23.
//

import SwiftUI

struct CategoryRowView: View {
    @EnvironmentObject private var appContainer: AppContainer
    let category: Category
    let isRecommended: Bool
    
    @State private var progress = CategoryProgress(solvedCount: 0, totalCount: 0)
    @State private var isLoading = false
    
    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            VStack(alignment: .leading, spacing: 12) {
                titleView
                
                if isLoading {
                    loadingView
                } else {
                    CategoryProgressBar(
                        solvedCount: progress.solvedCount,
                        totalCount: progress.totalCount
                    )
                }
            }
            
            Spacer(minLength: 8)
            
            chevronView
        }
        .padding(.vertical, 10)
        .contentShape(Rectangle())
        .task {
            await loadProgressIfNeeded()
        }
    }
    
    private var titleView: some View {
        Text(category.name)
            .font(.system(size: 19, weight: .semibold))
            .foregroundStyle(.primary)
            .lineLimit(1)
    }
    
    private var loadingView: some View {
        HStack(spacing: 8) {
            ProgressView()
                .controlSize(.small)
            
            Text("進捗を読み込み中...")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
    
    private var chevronView: some View {
        Image(systemName: "chevron.right")
            .font(.system(size: 12, weight: .semibold))
            .foregroundStyle(.secondary.opacity(0.75))
            .padding(.trailing, 2)
    }
    
    private func loadProgressIfNeeded() async {
        guard !isLoading else { return }
        isLoading = true
        defer { isLoading = false }
        
        do {
            progress = try appContainer.repository.fetchCategoryProgress(categoryId: category.id)
        } catch {
            progress = CategoryProgress(solvedCount: 0, totalCount: 0)
        }
    }
}
