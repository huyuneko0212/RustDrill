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

    @State private var searchText = ""

    private var filteredTerms: [VocabularyTerm] {
        guard !searchText.isEmpty else { return VocabularyTerm.all }

        return VocabularyTerm.all.filter { term in
            term.title.localizedStandardContains(searchText)
            || term.reading.localizedStandardContains(searchText)
            || term.description.localizedStandardContains(searchText)
        }
    }

    var body: some View {
        NavigationStack {
            List {
                if filteredTerms.isEmpty {
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

private struct VocabularyTerm: Identifiable {
    let id: String
    let title: String
    let reading: String
    let description: String
    let example: String?

    static let all: [VocabularyTerm] = [
        .init(
            id: "ownership",
            title: "Ownership",
            reading: "所有権",
            description: "値の所有者を1つに決め、メモリ安全性を保つ Rust の中心的な仕組みです。",
            example: "let s = String::from(\"rust\");"
        ),
        .init(
            id: "borrow",
            title: "Borrow",
            reading: "借用",
            description: "値を所有せずに参照として一時的に使うことです。",
            example: "&value / &mut value"
        ),
        .init(
            id: "lifetime",
            title: "Lifetime",
            reading: "ライフタイム",
            description: "参照が有効でいられる範囲を表します。多くの場合はコンパイラが推論します。",
            example: "'a"
        ),
        .init(
            id: "trait",
            title: "Trait",
            reading: "トレイト",
            description: "型が持つ振る舞いの約束を定義します。Swift の protocol に近い考え方です。",
            example: "trait DisplayName { ... }"
        ),
        .init(
            id: "enum",
            title: "Enum",
            reading: "列挙型",
            description: "複数の状態や値の形を1つの型として表します。",
            example: "enum Result<T, E>"
        ),
        .init(
            id: "match",
            title: "match",
            reading: "パターンマッチ",
            description: "値の形に応じて分岐します。すべての可能性を扱う必要があります。",
            example: "match value { ... }"
        ),
        .init(
            id: "option",
            title: "Option",
            reading: "値の有無",
            description: "値がある場合は Some、ない場合は None で表します。",
            example: "Option<T>"
        ),
        .init(
            id: "result",
            title: "Result",
            reading: "成功と失敗",
            description: "成功時の Ok と失敗時の Err で、エラーになりうる処理を表します。",
            example: "Result<T, E>"
        ),
        .init(
            id: "closure",
            title: "Closure",
            reading: "クロージャ",
            description: "周囲の値を捕まえて使える無名関数です。",
            example: "|x| x + 1"
        ),
        .init(
            id: "iterator",
            title: "Iterator",
            reading: "イテレータ",
            description: "値の列を順番に取り出す仕組みです。map や filter と組み合わせて使います。",
            example: ".iter().map(...)"
        )
    ]
}
