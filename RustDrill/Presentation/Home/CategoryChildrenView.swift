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
    
    // 最下層判定用
    @State private var questionsCount: Int = 0
    
    // クイズ遷移制御
    @State private var shouldNavigateToQuiz = false
    @State private var hasAutoNavigatedToQuiz = false   // ← 追加（初回だけ自動遷移）
    
    var body: some View {
        List {
            if isLoading && !didLoad {
                ProgressView("読み込み中...")
                    .frame(maxWidth: .infinity, alignment: .center)
                
            } else if children.isEmpty {
                // 最下層カテゴリ
                Section {
                    if questionsCount > 0 {
                        // 初回自動遷移後に戻ってきた時は、邪魔な文言を出さずボタンだけ表示
                        NavigationLink("このカテゴリを開始") {
                            QuizView(
                                viewModel: QuizViewModel(
                                    repository: appContainer.repository,
                                    source: .category(parentCategory.id)
                                )
                            )
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
                            CategoryRowView(category: child)
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
            
            // 3) 最下層 + 問題あり + 初回だけ自動遷移
            if children.isEmpty && questionsCount > 0 && !hasAutoNavigatedToQuiz {
                hasAutoNavigatedToQuiz = true
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
