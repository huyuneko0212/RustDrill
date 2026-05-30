# App Store Connect プライバシー回答メモ

作成日: 2026年5月30日

## 現在の実装前提

- アカウント作成、ログイン機能なし
- Google Mobile Ads SDK（AdMob）でリワード広告を表示
- `SKAdNetworkItems` に Google Mobile Ads SDK の推奨 SKAdNetwork ID を設定
- `NSUserTrackingUsageDescription` を設定し、広告 SDK 起動前に ATT 許可フローを実行
- 解析 SDK なし
- クラッシュ解析 SDK なし
- 課金、サブスクリプションなし
- 開発者サーバーへの通信なし
- 学習履歴、復習対象、表示設定、進捗は端末内に保存
- 外部リンクは Rust 公式サイトと The Rust Programming Language のみ

## App Privacy

App Store Connect の「App Privacy」は、広告 SDK 追加後は次の観点で回答を見直してください。実際の回答は、AdMob の設定、ATT 対応、パーソナライズ広告の有無、Google Mobile Ads SDK の最新仕様に合わせて最終確認してください。

- Data Collection: Yes。Google Mobile Ads SDK が広告配信、広告効果測定、不正利用防止などのためにデータを収集する可能性があります。
- Tracking: パーソナライズ広告や他社所有アプリ・Web サイトをまたぐ広告目的の利用がある場合は Yes を検討してください。本アプリでは `NSUserTrackingUsageDescription` を追加し、広告 SDK 起動前に ATT 許可フローを実行します。
- 想定されるデータカテゴリ: Identifiers（Device ID など）、Usage Data（Advertising Data など）、Diagnostics、Location（Coarse Location など）。Google Mobile Ads SDK と AdMob 管理画面の設定に合わせて精査してください。
- Data Use: Third-Party Advertising、Analytics、Product Personalization、App Functionality、Fraud Prevention, Security, and Compliance など、実際の利用目的に合わせて選択してください。

## 注意

今後、解析 SDK、クラッシュ解析 SDK、ログイン、クラウド同期、問い合わせフォーム、課金、プッシュ通知を追加した場合は、App Privacy とプライバシーポリシーを再確認してください。

本番配信前に、Google の最新ドキュメント、AdMob 管理画面の広告設定、Apple の App Privacy / ATT 要件を確認してください。
