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

    @State private var progressByCategoryId: [Category.ID: CategoryProgress] = [:]
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
            .navigationTitle(AppUIConstants.Strings.appTitle)
            .navigationDestination(item: $selectedCategory) { category in
                CategoryChildrenView(parentCategory: category)
            }
            .task {
                guard !didLoad else { return }
                await loadRootCategories()
            }
            .onAppear {
                guard didLoad else { return }
                Task { await loadRootCategories(force: true) }
            }
            .onReceive(appContainer.repository.progressDidChange) { _ in
                Task { await loadRootCategories(force: true) }
            }
            .refreshable {
                await loadRootCategories(force: true)
            }
            .overlay {
                if let message = errorMessage {
                    ContentUnavailableView(
                        AppUIConstants.Strings.errorTitle,
                        systemImage: AppUIConstants.Symbols.error,
                        description: Text(message)
                    )
                }
            }
        }
    }

    @ViewBuilder
    private var content: some View {
        if isLoading && !didLoad {
            ProgressView(AppUIConstants.Strings.loading)
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
                    Image(systemName: AppUIConstants.Symbols.play)
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
                        .fill(AppUIConstants.Colors.unsolvedTone.opacity(0.10))
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
                        isRecommended: category.id == recommendedCategoryId,
                        progress: progressByCategoryId[
                            category.id,
                            default: CategoryProgress(solvedCount: 0, totalCount: 0)
                        ]
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
            progressByCategoryId = try appContainer.repository.fetchProgressByCategory(
                categoryIds: categories.map(\.id)
            )

            totalSolvedCount = progressByCategoryId.values.reduce(0) {
                $0 + $1.solvedCount
            }
            totalQuestionCount = progressByCategoryId.values.reduce(0) {
                $0 + $1.totalCount
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
