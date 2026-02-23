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
    
    @State private var progress = CategoryProgress(solvedCount: 0, totalCount: 0)
    @State private var isLoading = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(category.name)
                .font(.body)
                .foregroundStyle(.primary)
            
            if isLoading {
                HStack(spacing: 8) {
                    ProgressView()
                        .controlSize(.small)
                    Text("進捗を読み込み中...")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            } else {
                CategoryProgressBar(
                    solvedCount: progress.solvedCount,
                    totalCount: progress.totalCount
                )
            }
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
        .task {
            await loadProgressIfNeeded()
        }
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
