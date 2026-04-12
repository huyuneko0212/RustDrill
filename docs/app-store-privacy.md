# App Store Connect プライバシー回答メモ

最終確認日: 2026年4月12日

## 現在の実装前提

- アカウント作成、ログイン機能なし
- 広告 SDK なし
- 解析 SDK なし
- クラッシュ解析 SDK なし
- 課金、サブスクリプションなし
- 開発者サーバーへの通信なし
- 学習履歴、復習対象、表示設定、進捗は端末内に保存
- 外部リンクは Rust 公式サイトと The Rust Programming Language のみ

## App Privacy

App Store Connect の「App Privacy」は、現在の実装では次の回答を想定します。

- Data Collection: No, we do not collect data from this app.
- Tracking: No, we do not use data for tracking.

## 注意

今後、広告 SDK、解析 SDK、クラッシュ解析 SDK、ログイン、クラウド同期、問い合わせフォーム、課金、プッシュ通知を追加した場合は、App Privacy とプライバシーポリシーを再確認してください。
