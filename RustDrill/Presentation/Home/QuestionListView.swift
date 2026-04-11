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
                    AppUIConstants.Strings.errorTitle,
                    systemImage: AppUIConstants.Symbols.error,
                    description: Text(message)
                )
            } else if isLoading && !didLoad {
                ProgressView(AppUIConstants.Strings.loading)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if questions.isEmpty {
                ContentUnavailableView(
                    AppUIConstants.Strings.emptyQuestionsTitle,
                    systemImage: AppUIConstants.Symbols.emptyQuestions,
                    description: Text(AppUIConstants.Strings.emptyQuestionsDescription)
                )
            } else {
                List {
                    Section("問題") {
                        ForEach(Array(questions.enumerated()), id: \.element.id) { index, question in
                            NavigationLink {
                                QuizView(
                                    viewModel: QuizViewModel(
                                        repository: appContainer.repository,
                                        source: .category(category.id, initialQuestionId: question.id)
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
        .onAppear {
            guard didLoad else { return }
            Task { await loadQuestions(force: true) }
        }
        .onReceive(appContainer.repository.progressDidChange) { _ in
            Task { await loadQuestions(force: true) }
        }
        .refreshable {
            await loadQuestions(force: true)
        }
    }
    
    private func loadQuestions(force _: Bool = false) async {
        if isLoading { return }
        
        isLoading = true
        errorMessage = nil
        
        defer {
            isLoading = false
            didLoad = true
        }
        
        do {
            questions = try appContainer.repository.fetchQuestions(categoryId: category.id)
            solvedQuestionIds = try appContainer.repository.fetchSolvedQuestionIds(categoryId: category.id)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
