//
//  ReviewListView.swift
//  RustDrill
//
//  Created by huyuneko on 2026/02/23.
//

import SwiftUI

struct ReviewListView: View {
    @EnvironmentObject private var appContainer: AppContainer
    
    @State private var reviewQuestions: [QuizQuestion] = []
    @State private var errorMessage: String?
    @State private var isLoading = false
    @State private var didLoad = false
    
    var body: some View {
        NavigationStack {
            List {
                if isLoading && !didLoad {
                    ProgressView("読み込み中...")
                        .frame(maxWidth: .infinity, alignment: .center)
                } else if reviewQuestions.isEmpty {
                    ContentUnavailableView(
                        "復習問題はありません",
                        systemImage: "checkmark.circle",
                        description: Text("間違えた問題があるとここに表示されます")
                    )
                } else {
                    Section("復習対象 (\(reviewQuestions.count)問)") {
                        ForEach(reviewQuestions) { question in
                            VStack(alignment: .leading, spacing: 6) {
                                Text(question.title)
                                    .font(.headline)
                                
                                Text(question.body)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(2)
                                
                                if !question.tags.isEmpty {
                                    Text(question.tags.joined(separator: " / "))
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    
                    Section {
                        NavigationLink("復習クイズを開始") {
                            QuizView(
                                viewModel: QuizViewModel(
                                    repository: appContainer.repository,
                                    source: .review
                                )
                            )
                        }
                    }
                }
            }
            .navigationTitle("復習")
            .task {
                guard !didLoad else { return }
                await loadReviewQuestions()
            }
            .refreshable {
                await loadReviewQuestions(force: true)
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
    
    private func loadReviewQuestions(force: Bool = false) async {
        if isLoading { return }
        if didLoad && !force { return }
        
        isLoading = true
        errorMessage = nil
        defer {
            isLoading = false
            didLoad = true
        }
        
        do {
            reviewQuestions = try appContainer.repository.fetchReviewQuestions()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
