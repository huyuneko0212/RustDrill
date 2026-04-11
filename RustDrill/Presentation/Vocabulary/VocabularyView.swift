//
//  VocabularyView.swift
//  RustDrill
//
//  Created by Codex on 2026/04/12.
//

import SwiftUI

struct VocabularyView: View {
    @AppStorage("RustDrill.settings.showRuby") private var showRuby = true
    @AppStorage("RustDrill.settings.compactVocabulary") private var compactVocabulary = false

    @State private var terms: [VocabularyTerm] = []
    @State private var errorMessage: String?
    @State private var isLoading = false
    @State private var didLoad = false
    @State private var searchText = ""

    private var filteredTerms: [VocabularyTerm] {
        guard !searchText.isEmpty else { return terms }

        return terms.filter { term in
            term.title.localizedStandardContains(searchText)
            || term.reading.localizedStandardContains(searchText)
            || term.description.localizedStandardContains(searchText)
        }
    }

    var body: some View {
        NavigationStack {
            List {
                if isLoading && !didLoad {
                    ProgressView(AppUIConstants.Strings.loading)
                        .frame(maxWidth: .infinity, alignment: .center)
                } else if filteredTerms.isEmpty {
                    ContentUnavailableView(
                        "単語が見つかりません",
                        systemImage: AppUIConstants.Symbols.vocabulary,
                        description: Text("別のキーワードで探してみましょう")
                    )
                } else {
                    Section {
                        ForEach(filteredTerms) { term in
                            VocabularyTermRow(
                                term: term,
                                showsReading: showRuby,
                                isCompact: compactVocabulary
                            )
                        }
                    } header: {
                        Text("Rust の基礎用語")
                    } footer: {
                        Text("問題でよく出る言葉を短く確認できます。")
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle(AppUIConstants.Strings.vocabularyTitle)
            .searchable(text: $searchText, prompt: "用語を検索")
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
            terms = try SeedLoader.loadVocabularyJSON().terms
        } catch {
            terms = []
            errorMessage = error.localizedDescription
        }
    }
}

private struct VocabularyTermRow: View {
    let term: VocabularyTerm
    let showsReading: Bool
    let isCompact: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: isCompact ? 4 : 8) {
            HStack(alignment: .firstTextBaseline) {
                Text(term.title)
                    .font(.headline)

                if showsReading {
                    Spacer(minLength: 12)

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

            if let example = term.example, !isCompact {
                Text(example)
                    .font(.caption.monospaced())
                    .foregroundStyle(AppUIConstants.Colors.explanation)
                    .padding(.top, 2)
            }
        }
        .padding(.vertical, 4)
    }
}
