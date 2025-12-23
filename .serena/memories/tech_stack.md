# 技術スタック

## バックエンド
- **Ruby**: 3.3+
- **Rails**: 8.0.2
- **データベース**: PostgreSQL

## フロントエンド
- **CSS Framework**: Tailwind CSS
- **JavaScript**: 
  - Hotwire (Turbo + Stimulus)
  - Importmap-rails

## バックグラウンドジョブ
- **GoodJob**: データベースベースのジョブプロセッサー
  - リトライ機能（3回、多項式バックオフ）
  - 定期実行機能（cron） - Phase 2で使用予定

## メール送信
- **Action Mailer**: 予約確認メール送信
- **Letter Opener**: 開発環境でのメールプレビュー

## テスト
- **RSpec**: テストフレームワーク
- **FactoryBot**: テストデータ生成
- **Capybara**: システムテスト（E2E）

## コード品質
- **RuboCop**: Linter（rubocop-rails-omakase）
- **Brakeman**: セキュリティチェック

## デプロイ
- **Kamal**: Docker コンテナデプロイツール
- **Thruster**: HTTP asset caching/compression

## その他のGem
- **Kaminari**: ページネーション
- **holiday_jp**: 日本の祝日判定（Phase 2で追加予定）
- **solid_cache**: データベースバックのキャッシュ
- **solid_queue**: ジョブキュー
- **solid_cable**: WebSocket
