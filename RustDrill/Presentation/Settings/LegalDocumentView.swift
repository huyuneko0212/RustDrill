//
//  LegalDocumentView.swift
//  RustDrill
//
//  Created by Codex on 2026/04/12.
//

import SwiftUI

struct LegalDocumentView: View {
    let document: LegalDocument

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text(document.title)
                    .font(.title.bold())

                Text(document.updatedAt)
                    .font(.footnote)
                    .foregroundStyle(.secondary)

                ForEach(document.sections) { section in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(section.title)
                            .font(.headline)

                        ForEach(section.paragraphs, id: \.self) { paragraph in
                            Text(paragraph)
                                .font(.body)
                                .foregroundStyle(.primary)
                                .textSelection(.enabled)
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
        }
        .navigationTitle(document.navigationTitle)
        .navigationBarTitleDisplayMode(.inline)
    }
}

enum LegalDocument {
    case privacyPolicy
    case termsOfUse
    case support

    var title: String {
        switch self {
        case .privacyPolicy:
            "プライバシーポリシー"
        case .termsOfUse:
            "利用規約"
        case .support:
            "サポート"
        }
    }

    var navigationTitle: String {
        switch self {
        case .privacyPolicy:
            "プライバシー"
        case .termsOfUse:
            "利用規約"
        case .support:
            "サポート"
        }
    }

    var updatedAt: String {
        "制定日: 2026年5月30日"
    }

    var sections: [LegalDocumentSection] {
        switch self {
        case .privacyPolicy:
            [
                LegalDocumentSection(
                    title: "収集する情報",
                    paragraphs: [
                        "Rust Drill は、氏名、メールアドレス、連絡先、写真など、利用者を直接特定する情報を開発者のサーバーへ送信しません。",
                        "クイズの解答履歴、復習対象、表示設定、学習進捗は、アプリの機能提供のために端末内に保存されます。これらの情報は開発者のサーバーへ送信されません。"
                    ]
                ),
                LegalDocumentSection(
                    title: "第三者サービス",
                    paragraphs: [
                        "本アプリでは、解説表示など一部機能の提供に関連して、Google Mobile Ads SDK（AdMob）による広告を表示する場合があります。",
                        "Google Mobile Ads SDK は、広告配信、広告効果測定、不正利用防止、広告のパーソナライズなどのために、広告識別子、端末情報、アプリ利用状況、IP アドレスから推定される地域情報などを取得または利用する場合があります。取得される情報と利用目的は Google のポリシーに従います。",
                        "Google による広告データの取り扱いについては、Google のポリシーと規約をご確認ください: https://policies.google.com/technologies/ads",
                        "設定画面には Rust 公式サイトおよび The Rust Programming Language への外部リンクがあります。外部サイトを開いた後の取り扱いは、各サイトのポリシーに従います。"
                    ]
                ),
                LegalDocumentSection(
                    title: "広告と設定",
                    paragraphs: [
                        "広告のパーソナライズは、端末のプライバシー設定や Google が提供する設定によって制限できる場合があります。",
                        "本アプリは、広告識別子を利用する場合に iOS の App Tracking Transparency（ATT）許可ダイアログを表示することがあります。許可しない場合でも、広告が非パーソナライズまたは制限された形で表示されることがあります。",
                        "Debug 版や開発中のビルドでは、広告表示確認のためにテスト広告が表示される場合があります。"
                    ]
                ),
                LegalDocumentSection(
                    title: "データの削除",
                    paragraphs: [
                        "端末内に保存された学習データは、アプリを削除することで削除できます。",
                        "表示設定のみを初期状態へ戻す操作は設定画面から実行できます。"
                    ]
                ),
                LegalDocumentSection(
                    title: "変更",
                    paragraphs: [
                        "本ポリシーの内容は、機能追加や法令の変更に応じて改定される場合があります。重要な変更がある場合は、アプリ内または配布ページでお知らせします。"
                    ]
                ),
                LegalDocumentSection(
                    title: "お問い合わせ",
                    paragraphs: [
                        "お問い合わせはメールでご連絡ください: rustdrill@wintercats.com"
                    ]
                )
            ]
        case .termsOfUse:
            [
                LegalDocumentSection(
                    title: "利用について",
                    paragraphs: [
                        "Rust Drill は、Rust の学習を補助するためのクイズアプリです。利用者は、本アプリを自己の責任で利用するものとします。"
                    ]
                ),
                LegalDocumentSection(
                    title: "コンテンツ",
                    paragraphs: [
                        "本アプリの問題、解説、単語集は学習支援を目的として提供されます。内容の正確性には注意していますが、完全性や特定目的への適合性を保証するものではありません。",
                        "Rust は Rust Foundation の商標です。本アプリは Rust Foundation による公式アプリではありません。"
                    ]
                ),
                LegalDocumentSection(
                    title: "広告",
                    paragraphs: [
                        "本アプリでは、解説表示など一部機能の利用時にリワード広告を表示する場合があります。",
                        "広告の表示可否、配信内容、リワードの成立条件は、通信状況、端末状態、広告配信事業者の仕様や審査状況により変わる場合があります。",
                        "広告の内容、広告から遷移する外部サイト、広告主が提供する商品またはサービスについて、開発者は責任を負いません。"
                    ]
                ),
                LegalDocumentSection(
                    title: "禁止事項",
                    paragraphs: [
                        "本アプリの不正な解析、改ざん、再配布、第三者の権利を侵害する利用、法令または公序良俗に反する利用を禁止します。"
                    ]
                ),
                LegalDocumentSection(
                    title: "免責",
                    paragraphs: [
                        "本アプリの利用または利用不能により生じた損害について、開発者は法令で認められる範囲で責任を負いません。"
                    ]
                ),
                LegalDocumentSection(
                    title: "変更・終了",
                    paragraphs: [
                        "開発者は、必要に応じて本アプリの内容、仕様、提供方法、本規約を変更または終了できるものとします。"
                    ]
                ),
                LegalDocumentSection(
                    title: "お問い合わせ",
                    paragraphs: [
                        "お問い合わせはメールでご連絡ください: rustdrill@wintercats.com"
                    ]
                )
            ]
        case .support:
            [
                LegalDocumentSection(
                    title: "お問い合わせ先",
                    paragraphs: [
                        "不具合報告、問題文の誤り、改善要望はメールでご連絡ください: rustdrill@wintercats.com"
                    ]
                ),
                LegalDocumentSection(
                    title: "お問い合わせ時に含めてほしい情報",
                    paragraphs: [
                        "利用している端末名、iOS バージョン、アプリのバージョン、不具合が発生した画面、再現手順を添えてください。",
                        "問題文や解説の誤りについては、該当カテゴリ、問題文の冒頭、期待する修正内容を添えてください。"
                    ]
                )
            ]
        }
    }
}

struct LegalDocumentSection: Identifiable {
    var id: String { title }
    let title: String
    let paragraphs: [String]
}
