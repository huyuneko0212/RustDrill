//
//  HomeView.swift
//  Rust Drill
//
//  Created by huyuneko on 2026/02/21.
//

import SwiftUI

struct HomeView: View {
    @StateObject var viewModel: HomeViewModel

    var body: some View {
        NavigationStack {
            List {
                Section("カリキュラム") {
                    ForEach(viewModel.categories) { category in
                        NavigationLink(category.name) {
                            CategoryChildrenView(
                                parentCategory: category,
                                repository: getRepository(from: viewModel)
                            )
                        }
                    }
                }
            }
            .navigationTitle("Rust Drill")
            .overlay {
                if let message = viewModel.errorMessage {
                    ContentUnavailableView(
                        "エラー",
                        systemImage: "exclamationmark.triangle",
                        description: Text(message)
                    )
                }
            }
        }
    }

    // 簡易。実際はDIをもう少し綺麗にしてOK
    private func getRepository(from vm: HomeViewModel) -> QuizRepository {
        Mirror(reflecting: vm).children.first { $0.label == "repository" }?
            .value as? QuizRepository
            ?? DummyQuizRepository()
    }
}

// 子カテゴリを辿る画面（大→中→小）
struct CategoryChildrenView: View {
    let parentCategory: Category
    let repository: QuizRepository

    @State private var children: [Category] = []
    @State private var errorMessage: String?

    var body: some View {
        List {
            if children.isEmpty {
                // 子がなければそのカテゴリの問題を開始
                NavigationLink("このカテゴリを開始") {
                    QuizView(
                        viewModel: QuizViewModel(
                            repository: repository,
                            categoryId: parentCategory.id
                        )
                    )
                }
            } else {
                ForEach(children) { child in
                    NavigationLink(child.name) {
                        CategoryChildrenView(
                            parentCategory: child,
                            repository: repository
                        )
                    }
                }
            }
        }
        .navigationTitle(parentCategory.name)
        .task {
            do {
                children = try repository.fetchChildren(of: parentCategory.id)
            } catch {
                errorMessage = error.localizedDescription
            }
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

// 仮のダミー（上のMirrorを避けたいならDI設計を後で整理）
private struct DummyQuizRepository: QuizRepository {
    func fetchRootCategories() throws -> [Category] { [] }
    func fetchChildren(of parentId: String) throws -> [Category] { [] }
    func fetchQuestions(categoryId: String) throws -> [QuizQuestion] { [] }
    func fetchProgress(questionId: String) throws -> QuestionProgress? { nil }
    func saveAnswer(
        questionId: String,
        selectedChoiceId: String,
        isCorrect: Bool
    ) throws {}
    func toggleFavorite(questionId: String) throws {}
    func fetchReviewQuestions() throws -> [QuizQuestion] { [] }
    func seedIfNeeded() throws {}
}
