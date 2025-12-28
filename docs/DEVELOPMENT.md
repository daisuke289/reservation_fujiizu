# Development Guide

開発環境のセットアップ、コマンド、テスト、コーディング規約をまとめた開発者向けガイドです。

---

## Tech Stack

- **Rails**: 8.0
- **Database**: PostgreSQL
- **CSS Framework**: Tailwind CSS
- **Background Jobs**: GoodJob
- **Holidays**: holiday_jp
- **Testing**: RSpec, FactoryBot, Capybara
- **Code Quality**: RuboCop, Brakeman, Bundle Audit

---

## Quick Start Guide

新規開発者向けの初回セットアップ手順:

```bash
# 1. リポジトリのクローン
git clone [repository_url]
cd [project_name]

# 2. 依存関係のインストール
bundle install

# 3. データベースのセットアップ
bin/rails db:create db:migrate db:seed

# 4. Slot初期データ生成（3ヶ月分）
bin/rails slots:generate_initial

# 5. スモークテストで動作確認
bundle exec rspec spec/system/reservations_smoke_spec.rb

# 6. 開発サーバー起動
bin/dev

# 7. ブラウザで動作確認
# http://localhost:3000 - 利用者画面
# http://localhost:3000/admin - 管理画面（admin/password）
```

**注意事項**:
- PostgreSQLが事前にインストールされている必要があります
- Rubyバージョン: 3.x（.ruby-versionを確認）
- Node.jsが必要（Tailwind CSSのビルド用）

---

## セットアップ

### 初回セットアップ

```bash
# 初回セットアップ
bundle install
bin/rails db:drop db:create db:migrate db:seed

# Slot初期データ生成（Phase 2完了後）
bin/rails slots:generate_initial

# データベースのリセット
bin/rails db:reset

# マイグレーションのみ実行
bin/rails db:migrate

# シードデータの再投入
bin/rails db:seed
```

### 依存関係

主要なGem:
- `rails` - フレームワーク
- `pg` - PostgreSQLアダプター
- `good_job` - バックグラウンドジョブ
- `holiday_jp` - 日本の祝日判定
- `kaminari` - ページネーション
- `tailwindcss-rails` - CSSフレームワーク
- `rspec-rails` - テストフレームワーク
- `factory_bot_rails` - テストデータ生成

---

## Development Commands

### Slot管理コマンド

```bash
# 初回データ生成（3ヶ月分）
bin/rails slots:generate_initial

# 特定月の生成
bin/rails slots:generate_month YEAR=2025 MONTH=3

# 未来のSlotをクリア（注意して使用）
bin/rails slots:clear_future

# Slot数の確認
bin/rails console
> Slot.count
> Slot.where('starts_at >= ?', Date.today).group_by { |s| s.starts_at.strftime('%Y年%m月') }.transform_values(&:count)
```

### サーバー起動

```bash
# 開発サーバー（バックグラウンドジョブ含む）
bin/dev

# Railsサーバーのみ
bin/rails server

# GoodJobワーカーのみ
bundle exec good_job start

# コンソール
bin/rails console
```

### テスト

```bash
# テストDBのセットアップ
RAILS_ENV=test bin/rails db:drop db:create db:migrate

# 全テスト実行
bundle exec rspec

# スモークテスト（基本動作確認）
bundle exec rspec spec/models/appointment_spec.rb spec/system/reservations_smoke_spec.rb

# フルフローテスト
bundle exec rspec spec/system/reservations_full_flow_spec.rb

# 特定のファイルのみ
bundle exec rspec spec/models/appointment_spec.rb

# 特定の行のみ
bundle exec rspec spec/models/appointment_spec.rb:42

# タグ指定
bundle exec rspec --tag smoke

# Phase 2完了後のテスト
bundle exec rspec spec/services/slot_generator_service_spec.rb
bundle exec rspec spec/requests/admin/branches_spec.rb
```

### デバッグ

```bash
# メール確認（開発環境）
# ブラウザで http://localhost:3000/letter_opener にアクセス

# ログ確認
tail -f log/development.log
tail -f log/test.log
tail -f log/good_job.log

# GoodJobダッシュボード
# config/routes.rb に mount GoodJob::Engine を追加後アクセス
# http://localhost:3000/good_job

# Slot生成ログ確認
tail -f log/development.log | grep SlotGenerator
```

### コードチェック

```bash
# RuboCop（Linter）
bundle exec rubocop

# 自動修正
bundle exec rubocop -a

# Brakeman（セキュリティチェック）
bundle exec brakeman

# Bundle Audit（脆弱性チェック）
bundle exec bundle-audit check --update
```

---

## Testing Strategy

### テストの種類

**モデルテスト（spec/models/）**
- バリデーションテスト
- アソシエーションテスト
- スコープテスト
- インスタンスメソッドテスト

**サービステスト（spec/services/）**
- SlotGeneratorService
  - business_day?の判定テスト
  - generate_slots_for_branchのテスト
  - generate_for_monthのテスト

**リクエストテスト（spec/requests/）**
- Admin::BranchesController
  - 一覧表示
  - 編集画面
  - 更新処理

**システムテスト（spec/system/）**
- `reservations_smoke_spec.rb`: 基本的なページアクセスとボタン存在確認
- `reservations_full_flow_spec.rb`: E2Eフルフローテスト
- rescue-based UI text flexibility（エラーメッセージの柔軟なマッチング）

**テストDB**
- 分離された test 環境
- `RAILS_ENV=test bin/rails db:drop db:create db:migrate` で完全リセット

### テストデータ

**FactoryBot（推奨）**
```ruby
# spec/factories/appointments.rb
FactoryBot.define do
  factory :appointment do
    association :branch
    association :slot
    association :appointment_type
    name { "テスト太郎" }
    furigana { "テストタロウ" }
    phone { "09012345678" }
    email { "test@example.com" }
    party_size { 1 }
    accept_privacy { true }
  end
end

# spec/factories/branches.rb
FactoryBot.define do
  factory :branch do
    association :area
    name { "テスト支店" }
    address { "静岡県テスト市1-2-3" }
    phone { "0551234567" }
    open_hours { "平日 9:00-16:30" }
    default_capacity { 1 }
  end
end
```

**使用例**
```ruby
let(:appointment) { create(:appointment) }
let(:slot) { create(:slot, capacity: 4, booked_count: 0) }
let(:branch) { create(:branch, default_capacity: 2) }
```

---

## Coding Conventions

### Rubyスタイル

- **インデント**: 2スペース
- **文字列**: ダブルクォート `"` 優先（補間が必要な場合）、シングルクォート `'` 可（固定文字列）
- **ハッシュ**: 新記法優先 `{ key: value }`
- **命名規則**:
  - クラス: PascalCase
  - メソッド/変数: snake_case
  - 定数: SCREAMING_SNAKE_CASE

### Railsベストプラクティス

**コントローラー**
- 1アクションは薄く保つ（ビジネスロジックはServiceクラスへ）
- Strong Parametersの徹底
- before_actionでの共通処理

**モデル**
- Fat Modelは避ける（適切にServiceクラスへ移譲）
- バリデーションは必須
- スコープの活用
- コールバックは最小限に

**ビュー**
- ロジックはヘルパーかPresenterへ
- Partial活用で再利用性を高める
- Form Objectの活用（複雑なフォームの場合）

**Service Object**
- 1クラス1責任
- トランザクション管理の明示
- エラーハンドリングの徹底
- ログ出力の充実

**命名規則**
- Service: `<Domain>Service` (例: AppointmentService, SlotGeneratorService)
- Job: `<Domain>Job` (例: AppointmentMailJob, SlotGeneratorJob)
- Mailer: `<Domain>Mailer` (例: AppointmentMailer)

### データベース

**マイグレーション**
- 可逆性を保つ（rollback可能に）
- インデックスの適切な設定
- 外部キー制約の明示
- デフォルト値とNULL制約の明示

**クエリ最適化**
- N+1クエリ回避（includes, preload, eager_load）
- 適切なスコープ使用
- pluckの活用（必要な属性のみ取得）

### セキュリティ

**認証・認可**
- 管理画面はBasic認証必須
- テスト環境以外では認証スキップ禁止

**バリデーション**
- クライアント側とサーバー側の両方で実施
- Strong Parametersの徹底

**SQLインジェクション対策**
- プレースホルダーの使用
- 生SQLは避ける

**CSRF対策**
- Rails標準のCSRF保護を有効化（デフォルト）

---

## Troubleshooting

### よくある問題と解決方法

**問題: メールが送信されない**
- GoodJobワーカーが起動しているか確認: `ps aux | grep good_job`
- SMTP設定を確認: `config/environments/development.rb` or `production.rb`
- ジョブキューを確認: `rails console` → `GoodJob::Job.count`

**問題: Slotが生成されない**
- GoodJobのcron設定を確認: `config/initializers/good_job.rb`
- GoodJobプロセスが起動しているか確認: `ps aux | grep good_job`
- ログを確認: `tail -f log/production.log | grep SlotGeneratorJob`
- 手動で生成を試す: `bin/rails slots:generate_month YEAR=2025 MONTH=1`
- holiday_jp gemがインストールされているか確認: `bundle list | grep holiday_jp`
- Branchにdefault_capacityが設定されているか確認: `Branch.pluck(:id, :default_capacity)`

**問題: 予約可能期間が正しく表示されない**
- Slotが正しく生成されているか確認: `bin/rails console` → `Slot.where('starts_at >= ?', Date.today).count`
- 月末までのSlotが存在するか確認: `Slot.where(starts_at: Date.today.beginning_of_month..Date.today.end_of_month).count`
- 3ヶ月分のSlotが存在するか確認: `Slot.where('starts_at >= ?', Date.today).group_by { |s| s.starts_at.strftime('%Y年%m月') }.keys`

**問題: 支店のdefault_capacityが更新されない**
- Strong Parametersで:default_capacityが許可されているか確認
- バリデーションエラーがないか確認: `branch.errors.full_messages`
- ログを確認: `tail -f log/development.log`

**問題: 予約が重複する**
- `slot.increment_booked_count!` でロックが取得されているか確認
- `appointments` テーブルの `phone + slot_id` ユニークインデックスを確認

**問題: テストが失敗する**
- テストDBをリセット: `RAILS_ENV=test bin/rails db:drop db:create db:migrate`
- FactoryBotの定義を確認（特にBranchのdefault_capacity）
- システムテストの場合、セレクタが変更されていないか確認

**問題: ページが表示されない**
- ルーティングを確認: `bin/rails routes | grep <path>`
- ログを確認: `tail -f log/development.log`
- Basic認証が正しく設定されているか確認（管理画面の場合）

---

## Useful Rails Commands

```bash
# ルート一覧
bin/rails routes

# 特定のコントローラーのルート
bin/rails routes -c admin/appointments
bin/rails routes -c admin/branches

# マイグレーション状態確認
bin/rails db:migrate:status

# ロールバック
bin/rails db:rollback
bin/rails db:rollback STEP=3

# コンソールでのデバッグ
bin/rails console
> Appointment.last
> Slot.available.count
> AppointmentService.new.create_appointment(params)

# SlotGeneratorService確認
> SlotGeneratorService.business_day?(Date.today)
> SlotGeneratorService.generate_for_month(2025, 1)
> Slot.where('starts_at >= ?', Date.today).group_by { |s| s.starts_at.strftime('%Y年%m月') }.transform_values(&:count)

# Branch確認
> Branch.first.default_capacity
> Branch.first.update(default_capacity: 3)

# データベースのクリーンアップ
bin/rails db:reset  # drop → create → migrate → seed
```

---

## 関連ドキュメント

- **システム設計**: [docs/ARCHITECTURE.md](ARCHITECTURE.md) - データモデル、コントローラー構造
- **データベース設計**: [docs/DATABASE.md](DATABASE.md) - ER図、テーブル定義、Slot生成
- **実装履歴**: [docs/HISTORY.md](HISTORY.md) - Phase 1-5の詳細実装手順
- **運用ガイド**: [docs/OPERATIONS.md](OPERATIONS.md) - デプロイ、環境変数
- **機能仕様**: [docs/FEATURES.md](FEATURES.md) - 利用者・管理者機能
