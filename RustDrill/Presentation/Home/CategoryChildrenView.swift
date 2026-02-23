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
    
    @State private var children: [Category] = []
    @State private var errorMessage: String?
    @State private var isLoading = false
    @State private var didLoad = false
    
    // 最下層判定 & 自動遷移用（UI表示には使わない）
    @State private var questionsCount: Int = 0
    @State private var shouldNavigateToQuiz = false
    
    var body: some View {
        List {
            if isLoading && !didLoad {
                ProgressView("読み込み中...")
                    .frame(maxWidth: .infinity, alignment: .center)
                
            } else if children.isEmpty {
                // 最下層: 自動遷移前の一瞬だけ見える可能性がある保険UI
                Section {
                    if questionsCount > 0 {
                        HStack(spacing: 8) {
                            Text("問題を開いています...")
                            Spacer()
                            ProgressView()
                                .controlSize(.small)
                        }
                    } else {
                        ContentUnavailableView(
                            "問題がありません",
                            systemImage: "questionmark.circle",
                            description: Text("このカテゴリにはまだ問題が登録されていません。")
                        )
                    }
                }
            } else {
                Section("カテゴリ") {
                    ForEach(children) { child in
                        NavigationLink {
                            CategoryChildrenView(parentCategory: child)
                        } label: {
                            CategoryRowView(category: child) // ← 進捗バー表示はここに集約
                        }
                    }
                }
            }
        }
        .navigationTitle(parentCategory.name)
        .task {
            guard !didLoad else { return }
            await loadCategoryState()
        }
        .refreshable {
            await loadCategoryState(force: true)
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
        .navigationDestination(isPresented: $shouldNavigateToQuiz) {
            QuizView(
                viewModel: QuizViewModel(
                    repository: appContainer.repository,
                    source: .category(parentCategory.id)
                )
            )
        }
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
            // 1) 子カテゴリ取得
            children = try appContainer.repository.fetchChildren(of: parentCategory.id)
            
            // 2) このカテゴリ配下の総問題数（再帰）
            questionsCount = try appContainer.repository.countQuestionsRecursively(categoryId: parentCategory.id)
            
            // 3) 最下層かつ問題ありなら自動でクイズへ
            if children.isEmpty && questionsCount > 0 {
                // 同フレーム遷移回避
                DispatchQueue.main.async {
                    shouldNavigateToQuiz = true
                }
            } else {
                shouldNavigateToQuiz = false
            }
            
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
