//
//  HomeView.swift
//  Rust Drill
//
//  Created by huyuneko on 2026/02/21.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var appContainer: AppContainer
    
    @State private var categories: [Category] = []
    @State private var errorMessage: String?
    @State private var isLoading = false
    @State private var didLoad = false
    
    @State private var totalSolvedCount = 0
    @State private var totalQuestionCount = 0
    
    var body: some View {
        NavigationStack {
            List {
                if isLoading && !didLoad {
                    ProgressView("読み込み中...")
                        .frame(maxWidth: .infinity, alignment: .center)
                } else {
                    Section {
                        OverallProgressCardView(
                            solvedCount: totalSolvedCount,
                            totalCount: totalQuestionCount
                        )
                        .listRowInsets(EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16))
                    }
                    
                    Section("カリキュラム") {
                        ForEach(categories) { category in
                            NavigationLink {
                                CategoryChildrenView(parentCategory: category)
                            } label: {
                                CategoryRowView(category: category)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Rust Drill")
            .task {
                guard !didLoad else { return }
                await loadRootCategories()
            }
            .refreshable {
                await loadRootCategories(force: true)
            }
            .overlay {
                if let message = errorMessage {
                    ContentUnavailableView(
                        "エラー",
                        systemImage: "exclamationmark.triangle",
                        description: Text(message)
                    )
                }
            }
        }
    }
    
    private func loadRootCategories(force: Bool = false) async {
        if isLoading { return }
        if didLoad && !force { return }
        
        isLoading = true
        errorMessage = nil
        defer {
            isLoading = false
            didLoad = true
        }
        
        do {
            categories = try appContainer.repository.fetchRootCategories()
            
            var solved = 0
            var total = 0
            
            for category in categories {
                let progress = try appContainer.repository.fetchCategoryProgress(categoryId: category.id)
                solved += progress.solvedCount
                total += progress.totalCount
            }
            
            totalSolvedCount = solved
            totalQuestionCount = total
            
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
