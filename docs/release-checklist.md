# Rust Drill リリースチェックリスト

最終更新日: 2026年4月12日

## App Store Connect に必要な URL

- Privacy Policy URL: https://huyuneko0212.github.io/RustDrill/docs/privacy-policy.html
- Support URL: https://huyuneko0212.github.io/RustDrill/docs/support.html
- Terms of Use URL: 必須ではないが、必要な場合は `docs/terms-of-use.md` を公開する

## 提出前確認

- App Privacy は `docs/app-store-privacy.md` の内容で回答する
- スクリーンショットを必要サイズ分用意する
- アプリ説明文、キーワード、カテゴリ、年齢制限を入力する
- バージョン番号とビルド番号を確認する
- Deployment Target が iOS 17.0 になっていることを確認する
- Signing & Capabilities で App Store Connect に登録した Team / Bundle Identifier を設定する
- 実機または Simulator で初回起動、クイズ、復習、単語集、設定画面を確認する
- 外部リンクが開けることを確認する
- プライバシーポリシー、利用規約、サポートが設定画面から読めることを確認する

## 審査メモ候補

Rust Drill は Rust 学習用のクイズアプリです。ログイン、課金、広告 SDK、解析 SDK、クラッシュ解析 SDK は使用していません。学習履歴、復習対象、表示設定、進捗は端末内に保存され、開発者のサーバーへ送信されません。
