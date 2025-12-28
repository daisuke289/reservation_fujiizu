# System Architecture

システム全体のアーキテクチャ設計と構造を説明します。

---

## Data Model Hierarchy

```
Area (8 regions)
  ↓
Branch (105 branches, default_capacity設定可能)
  ↓
Slot (1-hour intervals, capacity = branch.default_capacity)
  ↓
Appointment
  ↓
AppointmentType (6 consultation types)
```

**モデル関連**
- **Area**: has_many :branches
- **Branch**: belongs_to :area, has_many :slots, has_many :appointments
  - 属性: `default_capacity` (integer, default: 1)
- **Slot**: belongs_to :branch, has_many :appointments
  - `capacity`: 生成時にbranch.default_capacityを使用
- **AppointmentType**: has_many :appointments
- **Appointment**: belongs_to :branch, belongs_to :slot, belongs_to :appointment_type

---

## Controller Structure

### 利用者向けフロー

```
Public::HomeController (/)
  ↓
Reserve::StepsController
  - area (エリア選択)
  - branch (支店選択)
  - calendar (カレンダー表示) ← Phase 5で追加
  - time_selection (時間選択) ← Phase 5で追加
  - customer (顧客情報入力)
  ↓
Reserve::ConfirmController (確認画面)
  ↓
Reserve::CompleteController (完了画面)
```

### 管理者向けフロー

```
Basic認証
  ↓
Admin::BaseController
  ├─ Admin::DashboardController (ダッシュボード)
  ├─ Admin::AppointmentsController (予約管理)
  ├─ Admin::BranchesController (支店管理)
  └─ Admin::PrintsController (印刷)
```

---

## Service Layer

システムの主要なビジネスロジックはServiceクラスに集約されています。

### AppointmentService

**責務**: 予約の作成・管理

**主要メソッド**
- `create_appointment(params)`: 予約作成
  - トランザクション管理
  - 楽観的ロック（Slot#increment_booked_count!）
  - 空き状況のリアルタイムチェック
  - 重複予約防止（同一電話番号・同一日）
  - メール送信ジョブのエンキュー

### SlotGeneratorService

**責務**: 時間枠の自動生成

**主要メソッド**
- `generate_for_month(year, month)`: 月次一括生成
- `generate_slots_for_branch(branch, date)`: 支店・日付単位生成
- `business_day?(date)`: 営業日判定（holiday_jp使用）
- `year_end_new_year?(date)`: 年末年始判定（12/30-1/3）

**特徴**
- 支店のdefault_capacityを使用した容量設定
- 重複チェック（branch_id + starts_at のユニーク制約）

### AppointmentMailer

**責務**: メール送信

**機能**
- 予約確認メール送信
- 受付番号付き件名
- 予約詳細の通知

---

## Session-based Wizard Flow

予約フローは複数画面にまたがるWizard形式で、セッションを使用して状態を管理します。

```
session[:reservation] = {
  area_id: 1,
  branch_id: 23,
  slot_id: 456,
  customer_info: {
    name: "山田太郎",
    furigana: "ヤマダタロウ",
    phone: "09012345678",
    email: "test@example.com",
    party_size: 2,
    appointment_type_id: 3,
    purpose: "住宅ローンについて",
    notes: "平日午前希望",
    accept_privacy: true
  }
}
```

**フロー**
1. **Area/Branch selection** - area_id, branch_id
2. **Calendar** - 日付選択（今月・来月）
3. **Time selection** - slot_id
4. **Customer information** - customer_info (hash)
5. **Confirmation** - 全情報の確認
6. **Transaction completion** - AppointmentService経由で確定、セッションクリア

---

## Key Validations

### 電話番号
- 形式: `/\A\d{10,11}\z/`（10-11桁、ハイフンなし）
- 同一日の重複予約禁止（カスタムバリデーション）

### フリガナ
- 形式: `/\A[ァ-ヶー・＝　]+\z/`（全角カタカナのみ）

### メールアドレス
- `URI::MailTo::EMAIL_REGEXP`
- 必須項目

### 来店人数
- 1人以上の整数

### Slot容量チェック
- `slot.remaining_capacity >= party_size`
- 楽観的ロックによる競合制御

### Branch default_capacity
- 1以上の整数
- 必須項目

---

## Admin Features

### 認証

**Basic認証**
- ユーザー名: `ENV['BASIC_AUTH_USER']` || `'admin'`
- パスワード: `ENV['BASIC_AUTH_PASSWORD']` || `'password'`
- セキュリティ: `ActiveSupport::SecurityUtils.secure_compare`（タイミング攻撃対策）
- テスト環境では認証スキップ

### ダッシュボード

**統計情報**
- 本日の予約数
- 翌日の予約数
- 未確認予約数（booked status）

**クイックリスト**
- 本日の予約一覧（最大10件）
- 翌日の予約一覧（最大10件）
- 最近の予約（最新5件）

### 予約管理

**フィルター**
- today, tomorrow, booked, visited, needs_followup, canceled
- branch_id, date_from, date_to

**検索**
- 氏名・電話番号（部分一致、大文字小文字区別なし）

**ページネーション**
- 20件/ページ（Kaminari）

**ステータス更新**
- booked → visited, needs_followup, canceled
- キャンセル時は自動的にslot.booked_countをデクリメント

### 支店管理

**編集可能項目**
- 支店名、住所、電話番号、営業時間
- **デフォルト定員（default_capacity）**
  - 変更は新規生成Slotにのみ適用
  - 既存Slotには影響なし

### 印刷機能

**印刷レイアウト**
- 日付指定（デフォルト: 当日）
- 支店別グループ化
- A4レイアウト（layout: 'print'）
- アクティブな予約のみ（status != canceled）

---

## Email System

### GoodJob

**特徴**
- バックグラウンドジョブプロセッサー
- データベースベース（PostgreSQL）
- リトライ機能（3回、多項式バックオフ）
- **定期実行機能（cron）** ← Slot自動生成で使用

### バックグラウンドジョブ

**AppointmentMailJob**
- `AppointmentMailJob.perform_later(appointment.id)`
- エラーハンドリング（StandardError）
- ログ出力（送信成功・失敗）

**SlotGeneratorJob**
- 毎月1日深夜2:00に自動実行
- GoodJob cronで管理
- 翌々月分のSlot生成

### メール送信

**テンプレート**
- 件名: `【JAふじ伊豆】ご予約を承りました（受付番号: XXXXXX）`
- ビュー: `app/views/appointment_mailer/confirmed.html.erb`, `confirmed.text.erb`
- 差出人: `no-reply@example.com`（要設定変更）

**Localization**
- `config/locales/ja.yml` で日本語日時フォーマット定義

---

## セキュリティ設計

### 認証・認可
- 管理画面全体にBasic認証適用
- 定数時間比較でタイミング攻撃を防止
- 環境変数による認証情報管理

### データ保護
- **楽観的ロック**: Slotの予約数更新時
- **トランザクション**: 予約作成時の整合性保証
- **ユニーク制約**: 重複予約防止（phone + slot_id）

### バリデーション
- クライアント側（HTML5）とサーバー側の両方で実施
- Strong Parameters徹底

### CSRF・SQLインジェクション対策
- Rails標準のCSRF保護（デフォルト有効）
- プレースホルダー使用、生SQL回避

---

## パフォーマンス最適化

### データベース
- **インデックス**: area_id, branch_id, slot_id, (phone, slot_id)
- **Eager Loading**: `includes`, `preload`でN+1クエリ回避
- **スコープ活用**: `available`, `future`, `on_date`

### バックグラウンド処理
- メール送信（GoodJob）
- Slot自動生成（GoodJob cron）

### キャッシュ戦略
- エリア・支店マスターデータ（Rails.cache）
- ページネーション（Kaminari）

---

## Directory Structure

```
app/
├── controllers/
│   ├── admin/              # 管理画面コントローラー
│   │   ├── base_controller.rb
│   │   ├── dashboard_controller.rb
│   │   ├── appointments_controller.rb
│   │   ├── branches_controller.rb
│   │   └── prints_controller.rb
│   ├── public/             # 公開ページコントローラー
│   ├── reserve/            # 予約フローコントローラー
│   └── application_controller.rb
├── models/
│   ├── area.rb
│   ├── branch.rb
│   ├── slot.rb
│   ├── appointment.rb
│   └── appointment_type.rb
├── services/               # ビジネスロジック
│   ├── appointment_service.rb
│   └── slot_generator_service.rb
├── jobs/                   # バックグラウンドジョブ
│   ├── appointment_mail_job.rb
│   └── slot_generator_job.rb
├── mailers/
│   └── appointment_mailer.rb
├── views/
│   ├── admin/              # 管理画面ビュー
│   ├── public/             # 公開ページビュー
│   ├── reserve/            # 予約フロービュー
│   ├── appointment_mailer/ # メールテンプレート
│   └── layouts/
│       ├── application.html.erb
│       ├── admin.html.erb
│       └── print.html.erb
└── helpers/

config/
├── routes.rb
├── database.yml
├── initializers/
│   └── good_job.rb         # cron設定
└── locales/
    └── ja.yml

db/
├── migrate/
├── schema.rb
└── seeds.rb

lib/
└── tasks/
    └── slots.rake          # Slot生成タスク

spec/
├── models/
├── services/
├── requests/
├── system/
└── factories/
```

---

## 関連ドキュメント

- **データベース設計**: [docs/DATABASE.md](DATABASE.md) - ER図、テーブル定義
- **開発ガイド**: [docs/DEVELOPMENT.md](DEVELOPMENT.md) - セットアップ、テスト
- **機能仕様**: [docs/FEATURES.md](FEATURES.md) - 利用者・管理者機能
- **運用**: [docs/OPERATIONS.md](OPERATIONS.md) - デプロイ、環境変数
