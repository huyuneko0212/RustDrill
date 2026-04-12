//
//  SettingsView.swift
//  RustDrill
//
//  Created by Codex on 2026/04/12.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage(AppSettingsKeys.hideSolvedQuestions) private var hideSolvedQuestions = false
    @AppStorage(AppSettingsKeys.showQuestionStatus) private var showQuestionStatus = true
    @AppStorage(AppSettingsKeys.showRuby) private var showRuby = true
    @AppStorage(AppSettingsKeys.compactVocabulary) private var compactVocabulary = false

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Toggle("解答済みの問題を一覧で隠す", isOn: $hideSolvedQuestions)
                    Toggle("問題の状態バッジを表示", isOn: $showQuestionStatus)
                } header: {
                    Text("問題一覧")
                } footer: {
                    Text("カテゴリ内の問題一覧に反映されます。復習対象の判定には影響しません。")
                }

                Section {
                    Toggle("用語の読みを表示", isOn: $showRuby)
                    Toggle("単語集をコンパクトに表示", isOn: $compactVocabulary)
                } header: {
                    Text("単語集")
                } footer: {
                    Text("単語集の一覧表示に反映されます。")
                }

                Section {
                    Link(destination: URL(string: "https://www.rust-lang.org/")!) {
                        Label("Rust 公式サイト", systemImage: "safari")
                    }
                    Link(destination: URL(string: "https://doc.rust-lang.org/book/")!) {
                        Label("The Rust Programming Language", systemImage: "book")
                    }
                } header: {
                    Text("学習リンク")
                }

                Section {
                    NavigationLink {
                        LegalDocumentView(document: .privacyPolicy)
                    } label: {
                        Label("プライバシーポリシー", systemImage: "hand.raised")
                    }

                    NavigationLink {
                        LegalDocumentView(document: .termsOfUse)
                    } label: {
                        Label("利用規約", systemImage: "doc.text")
                    }

                    NavigationLink {
                        LegalDocumentView(document: .support)
                    } label: {
                        Label("サポート", systemImage: "questionmark.circle")
                    }
                } header: {
                    Text("リリース情報")
                }

                Section {
                    Button(role: .destructive) {
                        resetDisplaySettings()
                    } label: {
                        Label("表示設定を初期状態に戻す", systemImage: "arrow.counterclockwise")
                    }
                } footer: {
                    Text("進捗や復習履歴は消えません。")
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle(AppUIConstants.Strings.settingsTitle)
        }
    }

    private func resetDisplaySettings() {
        hideSolvedQuestions = false
        showQuestionStatus = true
        showRuby = true
        compactVocabulary = false
    }
}
