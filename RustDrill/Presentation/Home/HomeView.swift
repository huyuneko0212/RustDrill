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

    @State private var totalSolvedCount = 0
    @State private var totalQuestionCount = 0
    @State private var selectedCategory: Category?

    private var recommendedCategory: Category? {
        categories.first
    }

    private var recommendedCategoryId: Category.ID? {
        recommendedCategory?.id
    }

    private var progressMessage: String {
        guard totalQuestionCount > 0 else {
            return "まずは最初のカテゴリから始めましょう"
        }

        if totalSolvedCount == 0 {
            return "まずは1問解いてみましょう"
        }

        if totalSolvedCount == totalQuestionCount {
            return "すべての問題を完了しています 🎉"
        }

        return "あと\(totalQuestionCount - totalSolvedCount)問で全問完了です"
    }

    var body: some View {
        NavigationStack {
            List {
                content
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Rust Drill")
            .navigationDestination(item: $selectedCategory) { category in
                CategoryChildrenView(parentCategory: category)
            }
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

    @ViewBuilder
    private var content: some View {
        if isLoading && !didLoad {
            ProgressView("読み込み中...")
                .frame(maxWidth: .infinity, alignment: .center)
                .listRowSeparator(.hidden)
        } else {
            overallProgressSection
            curriculumSection
        }
    }

    private var overallProgressSection: some View {
        Section {
            VStack(alignment: .leading, spacing: 12) {
                OverallProgressCardView(
                    solvedCount: totalSolvedCount,
                    totalCount: totalQuestionCount
                )

                Text(progressMessage)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 4)

                restartButton
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .listRowInsets(.init())
        } header: {
            EmptyView()
        }
    }

    @ViewBuilder
    private var restartButton: some View {
        if let recommendedCategory {
            Button {
                selectedCategory = recommendedCategory
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "play.fill")
                        .font(.caption)

                    Text("続きから再開")
                        .font(.subheadline.weight(.semibold))

                    Spacer()

                    Text(recommendedCategory.name)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color.orange.opacity(0.10))
                )
            }
            .buttonStyle(.plain)
        }
    }

    private var curriculumSection: some View {
        Section {
            ForEach(categories) { category in
                Button {
                    selectedCategory = category
                } label: {
                    CategoryRowView(
                        category: category,
                        isRecommended: category.id == recommendedCategoryId
                    )
                }
                .buttonStyle(.plain)
            }
        } header: {
            curriculumHeader
        }
    }

    private var curriculumHeader: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("カリキュラム")
                .font(.headline)

            Text("カテゴリごとの進捗を確認できます")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .textCase(nil)
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

            var solved = 0
            var total = 0

            for category in categories {
                let progress = try appContainer.repository
                    .fetchCategoryProgress(categoryId: category.id)
                solved += progress.solvedCount
                total += progress.totalCount
            }

            totalSolvedCount = solved
            totalQuestionCount = total
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
