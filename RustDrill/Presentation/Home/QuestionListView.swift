//
//  QuizListView.swift
//  RustDrill
//
//  Created by huyuneko on 2026/03/15.
//
import SwiftUI

struct QuestionListView: View {
    @EnvironmentObject private var appContainer: AppContainer
    
    let category: Category
    
    @State private var questions: [QuizQuestion] = []
    @State private var isLoading = false
    @State private var didLoad = false
    @State private var errorMessage: String?
    @State private var solvedQuestionIds: Set<String> = []
    
    
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
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if questions.isEmpty {
                ContentUnavailableView(
                    "問題がありません",
                    systemImage: "questionmark.circle",
                    description: Text("このカテゴリにはまだ問題が登録されていません。")
                )
            } else {
                List {
                    Section("問題") {
                        ForEach(Array(questions.enumerated()), id: \.element.id) { index, question in
                            NavigationLink {
                                QuizView(
                                    viewModel: QuizViewModel(
                                        repository: appContainer.repository,
                                        source: .category(category.id, initialQuestionId: question.categoryId)
                                    )
                                )
                            } label: {
                                QuestionRowView(
                                    index: index + 1,
                                    question: question,
                                    isSolved: solvedQuestionIds.contains(question.id)
                                )
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle(category.name)
        .task {
            guard !didLoad else { return }
            await loadQuestions()
        }
        .refreshable {
            await loadQuestions(force: true)
        }
    }
    
    private func loadQuestions(force: Bool = false) async {
        if isLoading { return }
        
        isLoading = true
        errorMessage = nil
        
        defer {
            isLoading = false
            didLoad = true
        }
        
        do {
            questions = try repositoryFetchQuestions(force: force)
            solvedQuestionIds = try appContainer.repository.fetchSolvedQuestionIds(categoryId: category.id)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    private func repositoryFetchQuestions(force: Bool) throws -> [QuizQuestion] {
        try appContainer.repository.fetchQuestions(categoryId: category.id)
    }
}
