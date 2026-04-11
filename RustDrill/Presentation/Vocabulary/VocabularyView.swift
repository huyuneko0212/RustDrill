//
//  VocabularyView.swift
//  RustDrill
//
//  Created by Codex on 2026/04/12.
//

import SwiftUI

struct VocabularyView: View {
    @AppStorage(AppSettingsKeys.showRuby) private var showRuby = true
    @AppStorage(AppSettingsKeys.compactVocabulary) private var compactVocabulary = false

    @State private var categories: [VocabularyCategory] = []
    @State private var terms: [VocabularyTerm] = []
    @State private var errorMessage: String?
    @State private var isLoading = false
    @State private var didLoad = false
    @State private var searchText = Constants.Strings.emptySearchText
    @State private var expandedSectionIds: Set<String> = []

    private var filteredTerms: [VocabularyTerm] {
        guard !searchText.isEmpty else { return terms }

        return terms.filter { term in
            let category = category(for: term)

            return term.title.localizedStandardContains(searchText)
            || term.reading.localizedStandardContains(searchText)
            || term.description.localizedStandardContains(searchText)
            || term.detailDescription.localizedStandardContains(searchText)
            || category?.title.localizedStandardContains(searchText) == true
            || category?.description.localizedStandardContains(searchText) == true
            || term.keyPoints.contains { $0.localizedStandardContains(searchText) }
            || term.pitfalls.contains { $0.localizedStandardContains(searchText) }
            || term.codeExamples.contains { example in
                example.title.localizedStandardContains(searchText)
                || example.code.localizedStandardContains(searchText)
            }
        }
    }

    private var termSections: [VocabularyTermSection] {
        let termGroups = Dictionary(grouping: filteredTerms, by: \.categoryId)
        var sections = categories.compactMap { category -> VocabularyTermSection? in
            guard let terms = termGroups[category.id], !terms.isEmpty else { return nil }

            return VocabularyTermSection(
                id: category.id,
                title: category.title,
                description: category.description,
                terms: terms
            )
        }

        let knownCategoryIds = Set(categories.map(\.id))
        let uncategorizedTerms = filteredTerms.filter { !knownCategoryIds.contains($0.categoryId) }
        if !uncategorizedTerms.isEmpty {
            sections.append(
                VocabularyTermSection(
                    id: Constants.Strings.uncategorizedSectionId,
                    title: Constants.Strings.uncategorizedSectionTitle,
                    description: Constants.Strings.uncategorizedSectionDescription,
                    terms: uncategorizedTerms
                )
            )
        }

        return sections
    }

    var body: some View {
        NavigationStack {
            List {
                if isLoading && !didLoad {
                    ProgressView(AppUIConstants.Strings.loading)
                        .frame(maxWidth: .infinity, alignment: .center)
                } else if filteredTerms.isEmpty {
                    ContentUnavailableView(
                        Constants.Strings.emptySearchTitle,
                        systemImage: AppUIConstants.Symbols.vocabulary,
                        description: Text(Constants.Strings.emptySearchDescription)
                    )
                } else {
                    ForEach(termSections) { section in
                        DisclosureGroup(isExpanded: isSectionExpandedBinding(for: section.id)) {
                            ForEach(section.terms) { term in
                                NavigationLink {
                                    VocabularyTermDetailView(
                                        term: term,
                                        category: category(for: term),
                                        relatedTerms: relatedTerms(for: term)
                                    )
                                } label: {
                                    VocabularyTermRow(
                                        term: term,
                                        showsReading: showRuby,
                                        isCompact: compactVocabulary
                                    )
                                }
                            }
                        } label: {
                            VocabularyTermSectionHeader(section: section)
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle(AppUIConstants.Strings.vocabularyTitle)
            .searchable(text: $searchText, prompt: Constants.Strings.searchPrompt)
            .task {
                guard !didLoad else { return }
                loadVocabulary()
            }
            .refreshable {
                loadVocabulary(force: true)
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

    private func loadVocabulary(force: Bool = false) {
        if isLoading { return }
        if didLoad && !force { return }

        isLoading = true
        errorMessage = nil
        defer {
            isLoading = false
            didLoad = true
        }

        do {
            let seed = try SeedLoader.loadVocabularyJSON()
            categories = seed.categories
            terms = seed.terms
        } catch {
            categories = []
            terms = []
            errorMessage = error.localizedDescription
        }
    }

    private func category(for term: VocabularyTerm) -> VocabularyCategory? {
        categories.first { $0.id == term.categoryId }
    }

    private func relatedTerms(for term: VocabularyTerm) -> [VocabularyTerm] {
        term.relatedTermIds.compactMap { id in
            terms.first { $0.id == id }
        }
    }

    private func isSectionExpandedBinding(for sectionId: String) -> Binding<Bool> {
        Binding {
            !searchText.isEmpty || expandedSectionIds.contains(sectionId)
        } set: { isExpanded in
            guard searchText.isEmpty else { return }

            if isExpanded {
                expandedSectionIds.insert(sectionId)
            } else {
                expandedSectionIds.remove(sectionId)
            }
        }
    }
}

private struct VocabularyTermSection: Identifiable {
    let id: String
    let title: String
    let description: String
    let terms: [VocabularyTerm]
}

private struct VocabularyTermSectionHeader: View {
    let section: VocabularyTermSection

    var body: some View {
        VStack(alignment: .leading, spacing: Constants.Layout.sectionHeaderSpacing) {
            HStack(alignment: .firstTextBaseline) {
                Text(section.title)
                    .font(.headline)

                Spacer(minLength: Constants.Layout.sectionHeaderTitleSpacing)

                Text(Constants.Strings.termCount(section.terms.count))
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
            }

            Text(section.description)
                .font(.caption)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.vertical, Constants.Layout.sectionHeaderVerticalPadding)
    }
}

private struct VocabularyTermRow: View {
    let term: VocabularyTerm
    let showsReading: Bool
    let isCompact: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: rowSpacing) {
            HStack(alignment: .firstTextBaseline) {
                Text(term.title)
                    .font(.headline)

                if showsReading {
                    Spacer(minLength: Constants.Layout.rowReadingMinSpacing)

                    Text(term.reading)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            if !isCompact {
                Text(term.description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

        }
        .padding(.vertical, Constants.Layout.rowVerticalPadding)
    }

    private var rowSpacing: CGFloat {
        isCompact ? Constants.Layout.compactRowSpacing : Constants.Layout.rowSpacing
    }
}

private struct VocabularyTermDetailView: View {
    let term: VocabularyTerm
    let category: VocabularyCategory?
    let relatedTerms: [VocabularyTerm]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Constants.Layout.detailContentSpacing) {
                VStack(alignment: .leading, spacing: Constants.Layout.detailHeaderSpacing) {
                    Text(term.title)
                        .font(.largeTitle.bold())
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Text(term.reading)
                        .font(.title3)
                        .foregroundStyle(.secondary)

                    if let category {
                        Text(category.title)
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(AppUIConstants.Colors.explanation)
                            .padding(.horizontal, Constants.Layout.categoryBadgeHorizontalPadding)
                            .padding(.vertical, Constants.Layout.categoryBadgeVerticalPadding)
                            .background(
                                Capsule()
                                    .fill(AppUIConstants.Colors.explanation.opacity(Constants.Layout.categoryBadgeBackgroundOpacity))
                            )
                    }

                    Text(term.detailDescription)
                        .font(.body)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.top, Constants.Layout.detailDescriptionTopPadding)
                }

                VocabularyDetailSection(title: Constants.Strings.keyPointsSectionTitle) {
                    VStack(alignment: .leading, spacing: Constants.Layout.detailListSpacing) {
                        ForEach(term.keyPoints, id: \.self) { point in
                            Label(point, systemImage: Constants.Symbols.keyPoint)
                                .font(.body)
                                .foregroundStyle(.primary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }

                if !term.codeExamples.isEmpty {
                    VocabularyDetailSection(title: Constants.Strings.codeExamplesSectionTitle) {
                        VStack(alignment: .leading, spacing: Constants.Layout.codeExamplesSpacing) {
                            ForEach(term.codeExamples) { example in
                                VStack(alignment: .leading, spacing: Constants.Layout.codeExampleContentSpacing) {
                                    Text(example.title)
                                        .font(.subheadline.weight(.semibold))
                                    CodeBlockView(code: example.code)
                                }
                            }
                        }
                    }
                }

                if !term.pitfalls.isEmpty {
                    VocabularyDetailSection(title: Constants.Strings.pitfallsSectionTitle) {
                        VStack(alignment: .leading, spacing: Constants.Layout.detailListSpacing) {
                            ForEach(term.pitfalls, id: \.self) { pitfall in
                                Label(pitfall, systemImage: Constants.Symbols.pitfall)
                                    .font(.body)
                                    .foregroundStyle(.primary)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                    }
                }

                if !relatedTerms.isEmpty {
                    VocabularyDetailSection(title: Constants.Strings.relatedTermsSectionTitle) {
                        FlowLikeRelatedTermsView(terms: relatedTerms)
                    }
                }
            }
            .padding()
        }
        .navigationTitle(term.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct VocabularyDetailSection<Content: View>: View {
    let title: String
    private let content: Content

    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Constants.Layout.detailSectionSpacing) {
            Text(title)
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            content
        }
    }
}

private struct FlowLikeRelatedTermsView: View {
    let terms: [VocabularyTerm]

    var body: some View {
        LazyVGrid(
            columns: [
                GridItem(
                    .adaptive(minimum: Constants.Layout.relatedTermMinimumWidth),
                    spacing: Constants.Layout.relatedTermGridSpacing,
                    alignment: .leading
                )
            ],
            alignment: .leading,
            spacing: Constants.Layout.relatedTermGridSpacing
        ) {
            ForEach(terms) { term in
                VStack(alignment: .leading, spacing: Constants.Layout.relatedTermTextSpacing) {
                    Text(term.title)
                        .font(.subheadline.weight(.semibold))
                    Text(term.reading)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, Constants.Layout.relatedTermHorizontalPadding)
                .padding(.vertical, Constants.Layout.relatedTermVerticalPadding)
                .background(
                    RoundedRectangle(cornerRadius: Constants.Layout.relatedTermCornerRadius, style: .continuous)
                        .fill(Color.secondary.opacity(Constants.Layout.relatedTermBackgroundOpacity))
                )
            }
        }
    }
}

private enum Constants {
    enum Strings {
        static let emptySearchText = ""
        static let emptySearchTitle = "単語が見つかりません"
        static let emptySearchDescription = "別のキーワードで探してみましょう"
        static let uncategorizedSectionId = "uncategorized"
        static let uncategorizedSectionTitle = "その他"
        static let uncategorizedSectionDescription = "まだ分類されていない用語です。"
        static let searchPrompt = "用語を検索"
        static let keyPointsSectionTitle = "要点"
        static let codeExamplesSectionTitle = "コード例"
        static let pitfallsSectionTitle = "つまずきやすい点"
        static let relatedTermsSectionTitle = "関連用語"

        static func termCount(_ count: Int) -> String {
            "\(count)語"
        }
    }

    enum Symbols {
        static let keyPoint = "checkmark.circle.fill"
        static let pitfall = "exclamationmark.circle"
    }

    enum Layout {
        static let compactRowSpacing: CGFloat = 4
        static let rowSpacing: CGFloat = 8
        static let rowReadingMinSpacing: CGFloat = 12
        static let rowVerticalPadding: CGFloat = 4
        static let sectionHeaderSpacing: CGFloat = 4
        static let sectionHeaderTitleSpacing: CGFloat = 12
        static let sectionHeaderVerticalPadding: CGFloat = 4
        static let detailContentSpacing: CGFloat = 24
        static let detailHeaderSpacing: CGFloat = 10
        static let categoryBadgeHorizontalPadding: CGFloat = 10
        static let categoryBadgeVerticalPadding: CGFloat = 5
        static let categoryBadgeBackgroundOpacity = 0.14
        static let detailDescriptionTopPadding: CGFloat = 4
        static let detailListSpacing: CGFloat = 10
        static let codeExamplesSpacing: CGFloat = 14
        static let codeExampleContentSpacing: CGFloat = 8
        static let detailSectionSpacing: CGFloat = 12
        static let relatedTermMinimumWidth: CGFloat = 120
        static let relatedTermGridSpacing: CGFloat = 8
        static let relatedTermTextSpacing: CGFloat = 2
        static let relatedTermHorizontalPadding: CGFloat = 10
        static let relatedTermVerticalPadding: CGFloat = 8
        static let relatedTermCornerRadius: CGFloat = 8
        static let relatedTermBackgroundOpacity = 0.12
    }
}
