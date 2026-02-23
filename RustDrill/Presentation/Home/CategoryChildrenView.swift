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

    // 最下層判定用（UI表示には使わない）
    @State private var questionsCount: Int = 0

    var body: some View {
        Group {
            if let message = errorMessage {
                ContentUnavailableView(
                    "エラー",
                    systemImage: "exclamationmark.triangle",
                    description: Text(message)
                )
            } else if isLoading && !didLoad {
                ProgressView("読み込み中...")
                    .frame(
                        maxWidth: .infinity,
                        maxHeight: .infinity,
                        alignment: .center
                    )

            } else if children.isEmpty {
                // 最下層カテゴリは直接クイズ画面へ
                if questionsCount > 0 {
                    QuizView(
                        viewModel: QuizViewModel(
                            repository: appContainer.repository,
                            source: .category(parentCategory.id)
                        )
                    )
                } else {
                    ContentUnavailableView(
                        "問題がありません",
                        systemImage: "questionmark.circle",
                        description: Text("このカテゴリにはまだ問題が登録されていません。")
                    )
                }
            } else {
                List {
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
                .navigationTitle(parentCategory.name)
                .refreshable {
                    await loadCategoryState(force: true)
                }
            }
        }
        .task {
            guard !didLoad else { return }
            await loadCategoryState()
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
            children = try appContainer.repository.fetchChildren(
                of: parentCategory.id
            )
            questionsCount = try appContainer.repository
                .countQuestionsRecursively(categoryId: parentCategory.id)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
