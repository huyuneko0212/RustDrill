//
//  ReviewQuizEntryView.swift
//  RustDrill
//
//  Created by huyuneko on 2026/02/23.
//

import SwiftUI

struct ReviewQuizEntryView: View {
    @EnvironmentObject private var appContainer: AppContainer

    @State private var reviewQuestions: [QuizQuestion] = []
    @State private var errorMessage: String?
    @State private var isLoading = false

    var body: some View {
        List {
            if isLoading {
                ProgressView("読み込み中...")
                    .frame(maxWidth: .infinity, alignment: .center)
            } else {
                Section("復習") {
                    Text("復習対象: \(reviewQuestions.count)問")
                }

                Section {
                    if reviewQuestions.isEmpty {
                        Text("復習対象はありません")
                            .foregroundStyle(.secondary)
                    } else {
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
        }
        .navigationTitle("復習問題")
        .task {
            await load()
        }
        .refreshable {
            await load()
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

    private func load() async {
        if isLoading { return }
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            reviewQuestions = try appContainer.repository.fetchReviewQuestions()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
