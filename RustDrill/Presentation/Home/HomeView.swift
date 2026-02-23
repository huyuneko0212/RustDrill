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
    
    var body: some View {
        NavigationStack {
            List {
                if isLoading && !didLoad {
                    ProgressView("読み込み中...")
                        .frame(maxWidth: .infinity, alignment: .center)
                } else {
                    Section("カリキュラム") {
                        ForEach(categories) { category in
                            NavigationLink {
                                CategoryChildrenView(parentCategory: category)
                            } label: {
                                CategoryRowView(category: category)
                            }
                        }
                    }
                    
                    Section("ショートカット") {
                        NavigationLink("復習問題を解く") {
                            ReviewQuizEntryView()
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
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
