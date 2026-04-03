//
//  CategoryChildrenView.swift
//  RustDrill
//
//  Created by huyuneko on 2026/02/23.
//

//
//  CategoryChildrenView.swift
//  RustDrill
//
//  Created by huyuneko on 2026/02/23.
//

import SwiftUI

struct CategoryChildrenView: View {
    @EnvironmentObject private var appContainer: AppContainer
    
    let parentCategory: Category
    let isRecommended: Bool = false
    
    @State private var children: [Category] = []
    @State private var errorMessage: String?
    @State private var isLoading = false
    @State private var didLoad = false
    @State private var questionsCount: Int = 0
    
    @State private var selectedChild: Category?
    
    var body: some View {
        Group {
            if let message = errorMessage {
                errorView(message)
            } else if isLoading && !didLoad {
                loadingView
            } else if children.isEmpty {
                emptyStateView
            } else {
                childrenListView
            }
        }
        .navigationTitle(parentCategory.name)
        .navigationDestination(item: $selectedChild) { category in
            destination(for: category)
        }
        .task {
            guard !didLoad else { return }
            await loadCategoryState()
        }
    }
    
    private var loadingView: some View {
        ProgressView("読み込み中...")
            .frame(
                maxWidth: .infinity,
                maxHeight: .infinity,
                alignment: .center
            )
    }
    
    private func errorView(_ message: String) -> some View {
        ContentUnavailableView(
            "エラー",
            systemImage: "exclamationmark.triangle",
            description: Text(message)
        )
    }
    
    @ViewBuilder
    private var emptyStateView: some View {
        if questionsCount > 0 {
            QuestionListView(category: parentCategory)
        } else {
            ContentUnavailableView(
                "問題がありません",
                systemImage: "questionmark.circle",
                description: Text("このカテゴリにはまだ問題が登録されていません。")
            )
        }
    }
    
    private var childrenListView: some View {
        List {
            Section {
                ForEach(children) { child in
                    Button {
                        selectedChild = child
                    } label: {
                        CategoryRowView(category: child,
                        isRecommended: isRecommended)
                    }
                    .buttonStyle(.plain)
                }
            } header: {
                VStack(alignment: .leading, spacing: 4) {
                    Text("カテゴリ")
                        .font(.headline)
                    
                    Text("学習したいカテゴリを選択してください")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .textCase(nil)
            }
        }
        .listStyle(.insetGrouped)
        .refreshable {
            await loadCategoryState(force: true)
        }
    }
    
    @ViewBuilder
    private func destination(for category: Category) -> some View {
        if isLeafCategory(category) {
            QuestionListView(category: category)
        } else {
            CategoryChildrenView(parentCategory: category)
        }
    }
    
    private func isLeafCategory(_ category: Category) -> Bool {
        category.level >= 3
    }
    
    private func loadCategoryState(force: Bool = false) async {
        if isLoading { return }
        if didLoad && !force { return }
        
        isLoading = true
        errorMessage = nil
        
        defer {
            isLoading = false
            didLoad = true
        }
        
        do {
            children = try appContainer.repository.fetchChildren(of: parentCategory.id)
            questionsCount = try appContainer.repository
                .countQuestionsRecursively(categoryId: parentCategory.id)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
