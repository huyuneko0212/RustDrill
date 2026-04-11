//
//  SettingsView.swift
//  RustDrill
//
//  Created by Codex on 2026/04/12.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("RustDrill.settings.showRuby") private var showRuby = true
    @AppStorage("RustDrill.settings.compactVocabulary") private var compactVocabulary = false

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Toggle("用語の読みを表示", isOn: $showRuby)
                    Toggle("単語集をコンパクトに表示", isOn: $compactVocabulary)
                } header: {
                    Text("表示")
                } footer: {
                    Text("今後の画面調整で使える設定として保存されます。")
                }

                Section {
                    LabeledContent("アプリ名", value: AppUIConstants.Strings.appTitle)
                    LabeledContent("学習モード", value: "Rust 基礎")
                } header: {
                    Text("アプリ")
                }

                Section {
                    Link(destination: URL(string: "https://www.rust-lang.org/")!) {
                        Label("Rust 公式サイト", systemImage: "safari")
                    }
                } header: {
                    Text("リンク")
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle(AppUIConstants.Strings.settingsTitle)
        }
    }
}
