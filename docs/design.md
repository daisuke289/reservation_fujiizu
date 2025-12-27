# 設計仕様書

Sample Organization 相続相談予約システム

## 目次

1. [機能仕様](#機能仕様)
2. [構造仕様](#構造仕様)
3. [画面遷移](#画面遷移)
4. [Slot生成・管理](#slot生成管理)
5. [セキュリティ](#セキュリティ)
6. [パフォーマンス最適化](#パフォーマンス最適化)
7. [依存関係](#依存関係)
8. [エラーハンドリング](#エラーハンドリング)
9. [運用仕様](#運用仕様)
10. [今後の拡張可能性](#今後の拡張可能性)

---

## 機能仕様

### 1. 利用者向け機能

#### 1.1 予約フロー（4ステップWizard形式）

**エリア・支店選択**
- 8つのエリアから1つを選択
- 選択したエリアに属する支店から1つを選択
- セッションに選択情報を保存

**日時選択**
- 今月を含む2ヶ月後の月末までの予約可能枠を表示
  - 例：12月中は12月・1月・2月の枠が表示
  - 例：1月1日以降は1月・2月・3月の枠が表示
- 30分刻みの時間枠（9:00-12:00、13:00-16:30）
- 昼休み（12:00-13:00）は予約不可
- 土日祝日は予約枠なし（holiday_jp gemで判定）
- 空き状況をリアルタイムで表示
- 満員の枠は選択不可

**顧客情報入力**
- 必須項目
  - 氏名
  - フリガナ（全角カタカナ）
  - 電話番号（10-11桁、ハイフンなし）
  - メールアドレス
  - 来店人数（1人以上）
  - 相談種別（6種類から選択）
  - プライバシーポリシー同意
- 任意項目
  - 相談目的（自由記述）
  - 備考

**予約確認・完了**
- 入力内容の確認画面
- 予約確定処理
  - トランザクション管理
  - 枠の空き再確認
  - 重複予約チェック（同一電話番号・同一日）
- メール送信（バックグラウンドジョブ）
- 受付番号の表示

#### 1.2 バリデーション

**電話番号**
- 形式: 10-11桁の数字のみ（ハイフン不可）
- 同一日の重複予約禁止

**フリガナ**
- 全角カタカナのみ許可
- パターン: `/\A[ァ-ヶー・＝　]+\z/`

**メールアドレス**
- URI::MailTo::EMAIL_REGEXP による検証
- 必須項目

**来店人数**
- 1人以上の整数

**予約枠の残り定員**
- 予約時点での空き状況を確認
- 楽観的ロックによる競合制御

#### 1.3 メール送信

**確認メール**
- 件名: `【Sample Org】ご予約を承りました（受付番号: XXXXXX）`
- 送信先: 利用者が入力したメールアドレス
- 内容
  - 受付番号
  - 予約日時
  - 支店名・住所・電話番号
  - 顧客情報
  - 相談種別
- バックグラウンド送信（GoodJob）
- リトライ: 3回（多項式バックオフ）

---

### 2. 管理者向け機能

#### 2.1 認証

**Basic認証**
- ユーザー名: `admin`（環境変数 `BASIC_AUTH_USER` で変更可能）
- パスワード: `password`（環境変数 `BASIC_AUTH_PASSWORD` で変更可能）
- セキュリティ: `ActiveSupport::SecurityUtils.secure_compare` による定数時間比較
- テスト環境では認証スキップ

#### 2.2 ダッシュボード

**統計情報**
- 本日の予約数
- 翌日の予約数
- 未確認予約数（予約済みステータス）

**クイックリスト**
- 本日の予約一覧（最大10件）
- 翌日の予約一覧（最大10件）
- 最近の予約（最新5件）

**アクション**
- 予約一覧への遷移
- 支店管理への遷移
- 印刷画面への遷移

#### 2.3 予約管理

**一覧表示**
- ページネーション（20件/ページ、Kaminari使用）
- ソート: 予約日時降順

**フィルター機能**
- 日付フィルター
  - 本日
  - 翌日
- ステータスフィルター
  - 予約済み（booked）
  - 来店済み（visited）
  - 要フォローアップ（needs_followup）
  - キャンセル（canceled）
- 支店フィルター
- 日付範囲フィルター（開始日・終了日）

**検索機能**
- 氏名（部分一致、大文字小文字区別なし）
- 電話番号（部分一致）

**詳細表示**
- 受付番号（8桁ゼロパディング）
- 全予約情報の表示
- ステータス変更
- 管理者メモの追加・編集

**ステータス管理**
- 予約済み → 来店済み
- 予約済み → 要フォローアップ
- 予約済み → キャンセル（予約枠の開放処理）
- キャンセル → 予約済み（予約枠の再確保）

#### 2.4 支店管理

**一覧表示**
- 全支店の一覧
- エリアでグループ化
- 各支店の基本情報表示

**編集機能**
- 支店名
- 住所
- 電話番号
- 営業時間
- デフォルト定員（default_capacity）

**注意事項**
- default_capacity の変更は、変更後に生成される新しいSlotにのみ適用
- 既存のSlotには影響しない
- 既存Slotの定員を個別に変更したい場合は、将来的な拡張機能として検討

#### 2.5 印刷機能

**印刷レイアウト**
- 日付指定（デフォルト: 当日）
- 支店別グループ化
- A4用紙対応の専用レイアウト
- ステータスがアクティブな予約のみ対象
- ソート: 支店名 → 予約時刻

**印刷情報**
- 受付番号
- 予約時刻
- 氏名・フリガナ
- 電話番号
- 相談種別
- 来店人数
- 相談目的
- 備考
- 管理者メモ

---

## 構造仕様

### 1. ER図

```mermaid
erDiagram
    Area ||--o{ Branch : "has_many"
    Branch ||--o{ Slot : "has_many"
    Branch ||--o{ Appointment : "has_many"
    Slot ||--o{ Appointment : "has_many"
    AppointmentType ||--o{ Appointment : "has_many"

    Area {
        bigint id PK
        string name "エリア名"
        datetime created_at
        datetime updated_at
    }

    Branch {
        bigint id PK
        bigint area_id FK "エリアID"
        string name "支店名"
        string address "住所"
        string phone "電話番号"
        text open_hours "営業時間"
        integer default_capacity "デフォルト定員"
        datetime created_at
        datetime updated_at
    }

    Slot {
        bigint id PK
        bigint branch_id FK "支店ID"
        datetime starts_at "開始時刻"
        datetime ends_at "終了時刻"
        integer capacity "定員"
        integer booked_count "予約済み数"
        datetime created_at
        datetime updated_at
    }

    AppointmentType {
        bigint id PK
        string name "相談種別名"
        datetime created_at
        datetime updated_at
    }

    Appointment {
        bigint id PK
        bigint branch_id FK "支店ID"
        bigint slot_id FK "時間枠ID"
        bigint appointment_type_id FK "相談種別ID"
        string name "氏名"
        string furigana "フリガナ"
        string phone "電話番号"
        string email "メールアドレス"
        integer party_size "来店人数"
        text purpose "相談目的"
        text notes "備考"
        boolean accept_privacy "プライバシー同意"
        integer status "ステータス"
        text admin_memo "管理者メモ"
        datetime created_at
        datetime updated_at
    }
```

### 2. テーブル定義

#### 2.1 areas（エリア）

| カラム名 | データ型 | NULL | デフォルト | 説明 |
|---------|---------|------|----------|------|
| id | bigint | NO | AUTO | 主キー |
| name | string | NO | - | エリア名 |
| created_at | datetime | NO | - | 作成日時 |
| updated_at | datetime | NO | - | 更新日時 |

**インデックス**
- PRIMARY KEY (id)

**制約・バリデーション**
- name: 必須、ユニーク

**マスターデータ（8エリア）**
- Area A
- Area B
- Area C
- Area D
- Area E
- Area F
- Area G
- Area H

---

#### 2.2 branches（支店）

| カラム名 | データ型 | NULL | デフォルト | 説明 |
|---------|---------|------|----------|------|
| id | bigint | NO | AUTO | 主キー |
| area_id | bigint | NO | - | エリアID（外部キー） |
| name | string | NO | - | 支店名 |
| address | string | NO | - | 住所 |
| phone | string | NO | - | 電話番号 |
| open_hours | text | NO | - | 営業時間 |
| default_capacity | integer | NO | 1 | デフォルト定員 |
| created_at | datetime | NO | - | 作成日時 |
| updated_at | datetime | NO | - | 更新日時 |

**インデックス**
- PRIMARY KEY (id)
- INDEX (area_id)

**外部キー**
- area_id → areas(id)

**制約・バリデーション**
- name: 必須
- address: 必須
- phone: 必須、10-11桁の数字
- open_hours: 必須
- default_capacity: 必須、1以上

**マスターデータ**
- 各エリアに1支店（計8支店）
- 初期値: default_capacity = 1

---

#### 2.3 slots（時間枠）

| カラム名 | データ型 | NULL | デフォルト | 説明 |
|---------|---------|------|----------|------|
| id | bigint | NO | AUTO | 主キー |
| branch_id | bigint | NO | - | 支店ID（外部キー） |
| starts_at | datetime | NO | - | 開始時刻 |
| ends_at | datetime | NO | - | 終了時刻 |
| capacity | integer | NO | 1 | 定員 |
| booked_count | integer | NO | 0 | 予約済み数 |
| created_at | datetime | NO | - | 作成日時 |
| updated_at | datetime | NO | - | 更新日時 |

**インデックス**
- PRIMARY KEY (id)
- INDEX (branch_id)
- UNIQUE INDEX (branch_id, starts_at)

**外部キー**
- branch_id → branches(id)

**制約・バリデーション**
- starts_at: 必須
- ends_at: 必須、starts_atより後
- capacity: 必須、1以上
- booked_count: 必須、0以上、capacity以下

**スコープ**
- `available`: booked_count < capacity
- `future`: starts_at > 現在時刻
- `on_date(date)`: 指定日の枠

**インスタンスメソッド**
- `available?`: 空きあり判定
- `full?`: 満員判定
- `remaining_capacity`: 残り定員
- `increment_booked_count!(count)`: 予約数増加（ロック付き）
- `decrement_booked_count!(count)`: 予約数減少（ロック付き）

---

#### 2.4 appointment_types（相談種別）

| カラム名 | データ型 | NULL | デフォルト | 説明 |
|---------|---------|------|----------|------|
| id | bigint | NO | AUTO | 主キー |
| name | string | NO | - | 相談種別名 |
| created_at | datetime | NO | - | 作成日時 |
| updated_at | datetime | NO | - | 更新日時 |

**インデックス**
- PRIMARY KEY (id)

**制約・バリデーション**
- name: 必須、ユニーク

**マスターデータ（6種別）**
- 住宅ローン相談
- 資産運用相談
- 保険相談
- Business Loan Consultation
- 相続関連相談
- その他金融相談

---

#### 2.5 appointments（予約）

| カラム名 | データ型 | NULL | デフォルト | 説明 |
|---------|---------|------|----------|------|
| id | bigint | NO | AUTO | 主キー |
| branch_id | bigint | NO | - | 支店ID（外部キー） |
| slot_id | bigint | NO | - | 時間枠ID（外部キー） |
| appointment_type_id | bigint | NO | - | 相談種別ID（外部キー） |
| name | string | NO | - | 氏名 |
| furigana | string | NO | - | フリガナ |
| phone | string | NO | - | 電話番号 |
| email | string | NO | - | メールアドレス |
| party_size | integer | NO | 1 | 来店人数 |
| purpose | text | YES | - | 相談目的 |
| notes | text | YES | - | 備考 |
| accept_privacy | boolean | NO | false | プライバシー同意 |
| status | integer | NO | 0 | ステータス |
| admin_memo | text | YES | - | 管理者メモ |
| created_at | datetime | NO | - | 作成日時 |
| updated_at | datetime | NO | - | 更新日時 |

**インデックス**
- PRIMARY KEY (id)
- INDEX (branch_id)
- INDEX (slot_id)
- INDEX (appointment_type_id)
- UNIQUE INDEX (phone, slot_id)

**外部キー**
- branch_id → branches(id)
- slot_id → slots(id)
- appointment_type_id → appointment_types(id)

**制約・バリデーション**
- name: 必須
- furigana: 必須、全角カタカナ形式
- phone: 必須、10-11桁の数字
- email: 必須、メール形式
- party_size: 必須、1以上
- accept_privacy: 必須（true）

**Enum: status**
- 0: booked（予約済み）
- 1: visited（来店済み）
- 2: needs_followup（要フォローアップ）
- 3: canceled（キャンセル）

**カスタムバリデーション**
- 同一電話番号・同一日の重複予約禁止
- 時間枠の残り定員チェック

**スコープ**
- `active`: キャンセル以外
- `today`: 本日の予約
- `future`: 未来の予約
- `past`: 過去の予約

**コールバック**
- `after_create`: 時間枠の予約数をインクリメント
- `after_update`: ステータス変更時の予約数調整

**インスタンスメソッド**
- `appointment_date`: 予約日
- `appointment_time`: 予約時刻（文字列）
- `can_cancel?`: キャンセル可否
- `cancel!`: キャンセル処理

---

#### 2.6 good_jobs（バックグラウンドジョブ）

GoodJob gem が管理するテーブル群。詳細は省略。

- good_jobs
- good_job_executions
- good_job_batches
- good_job_processes
- good_job_settings

**用途**
- メール送信の非同期処理
- リトライ管理
- 定期実行ジョブ（Slot自動生成）

---

### 3. データフロー

#### 3.1 予約作成フロー

```
1. 利用者が予約フォームを入力
   ↓
2. セッションに段階的に保存（session[:reservation]）
   - area_id
   - branch_id
   - slot_id
   - customer_info (hash)
   ↓
3. 確認画面で最終確認
   ↓
4. AppointmentService.create_appointment
   ├─ トランザクション開始
   ├─ スロットのロック取得
   ├─ 空き状況の再確認
   ├─ 重複予約チェック
   ├─ Appointmentレコード作成
   ├─ スロットのbooked_countをインクリメント（コールバック）
   ├─ コミット
   └─ AppointmentMailJob をキューに追加
   ↓
5. バックグラウンドでメール送信
   ↓
6. 完了画面を表示
```

#### 3.2 キャンセルフロー

```
1. 管理者がステータスを「キャンセル」に変更
   ↓
2. Appointment#update
   ├─ ステータス更新
   ├─ after_update コールバック発動
   └─ slot.decrement_booked_count!(party_size)
      ├─ ロック取得
      ├─ booked_count減算
      └─ コミット
   ↓
3. 予約枠が再び利用可能に
```

---

## 画面遷移

### 利用者向け

```
TOP (/)
  ↓
エリア選択 (/reserve/steps/area)
  ↓
支店選択 (/reserve/steps/branch?area_id=X)
  ↓
日時選択 (/reserve/steps/datetime?branch_id=X)
  ↓
顧客情報入力 (/reserve/steps/customer?slot_id=X)
  ↓
確認画面 (/reserve/confirm)
  ↓
完了画面 (/reserve/complete?id=X)
```

### 管理者向け

```
ログイン (Basic認証)
  ↓
ダッシュボード (/admin/dashboard)
  ├─→ 予約一覧 (/admin/appointments)
  │     ├─→ 予約詳細 (/admin/appointments/:id)
  │     │     └─→ ステータス更新
  │     └─→ フィルター・検索
  ├─→ 支店管理 (/admin/branches)
  │     └─→ 支店編集 (/admin/branches/:id/edit)
  │           └─→ デフォルト定員変更
  └─→ 印刷画面 (/admin/prints)
        └─→ 日付指定印刷
```

---

## Slot生成・管理

### 自動生成仕様

**概要**
- 月末区切りで2ヶ月後までの予約枠を自動生成
- 今月を含む3ヶ月分の予約枠が常に利用可能

**生成タイミング**
- 毎月1日 深夜2:00に翌々月分を一括生成
- GoodJobの定期実行機能を使用（cron設定）

**生成ロジック**
```
1. 対象月の全日をループ（1日～月末）
2. 各日について以下をチェック：
   - 土曜日 → スキップ
   - 日曜日 → スキップ
   - 祝日（holiday_jp gem） → スキップ
3. 営業日について以下の時間枠を生成：
   【午前】
   - 9:00-9:30
   - 9:30-10:00
   - 10:00-10:30
   - 10:30-11:00
   - 11:00-11:30
   - 11:30-12:00
   【昼休み 12:00-13:00 は除外】
   【午後】
   - 13:00-13:30
   - 13:30-14:00
   - 14:00-14:30
   - 14:30-15:00
   - 15:00-15:30
   - 15:30-16:00
   - 16:00-16:30
4. 全8支店それぞれに対して生成
5. capacity = 支店の default_capacity を使用
6. 重複チェック（branch_id + starts_at のユニーク制約）
```

**初回データ生成**
```bash
# デプロイ時に1回のみ実行
bin/rails slots:generate_initial

# 今月、翌月、翌々月の3ヶ月分を生成
```

**定期実行設定**
```ruby
# config/initializers/good_job.rb
config.cron = {
  generate_monthly_slots: {
    cron: "0 2 1 * *", # 毎月1日 2:00
    class: "SlotGeneratorJob",
    description: "Generate slots for 2 months ahead"
  }
}
```

### 休業日管理

**判定ロジック**
```ruby
# holiday_jp gem を使用
require 'holiday_jp'

def business_day?(date)
  return false if date.saturday?
  return false if date.sunday?
  return false if HolidayJp.holiday?(date)
  true
end
```

**対象の休業日**
- 土曜日
- 日曜日
- 国民の祝日（holiday_jp gemが管理）
  - 元日、成人の日、建国記念の日、天皇誕生日、春分の日、昭和の日
  - 憲法記念日、みどりの日、こどもの日、海の日、山の日、敬老の日
  - 秋分の日、スポーツの日、文化の日、勤労感謝の日
- 振替休日
- 年末年始（12/31-1/3は祝日として判定される）

**将来的な拡張**
- 臨時休業日の管理画面での登録機能（holidaysテーブル）
- 支店ごとの個別休業日設定

### 実装詳細

**サービスクラス**
```ruby
# app/services/slot_generator_service.rb
class SlotGeneratorService
  TIME_SLOTS = [
    ["09:00", "09:30"], ["09:30", "10:00"], ["10:00", "10:30"],
    ["10:30", "11:00"], ["11:00", "11:30"], ["11:30", "12:00"],
    # 昼休み 12:00-13:00 は除外
    ["13:00", "13:30"], ["13:30", "14:00"], ["14:00", "14:30"],
    ["14:30", "15:00"], ["15:00", "15:30"], ["15:30", "16:00"],
    ["16:00", "16:30"]
  ].freeze
  
  # 指定月の全営業日に対してSlot生成
  def self.generate_for_month(year, month)
    start_date = Date.new(year, month, 1)
    end_date = start_date.end_of_month
    
    (start_date..end_date).each do |date|
      next unless business_day?(date)
      
      Branch.find_each do |branch|
        generate_slots_for_branch(branch, date)
      end
    end
  end
  
  # 特定の支店・日付に対してSlot生成
  def self.generate_slots_for_branch(branch, date)
    TIME_SLOTS.each do |start_time, end_time|
      starts_at = Time.zone.parse("#{date} #{start_time}")
      ends_at = Time.zone.parse("#{date} #{end_time}")
      
      # 既に存在する場合はスキップ
      next if Slot.exists?(branch_id: branch.id, starts_at: starts_at)
      
      Slot.create!(
        branch: branch,
        starts_at: starts_at,
        ends_at: ends_at,
        capacity: branch.default_capacity,
        booked_count: 0
      )
    end
  end
  
  # 営業日判定
  def self.business_day?(date)
    return false if date.saturday?
    return false if date.sunday?
    return false if HolidayJp.holiday?(date)
    true
  end
end
```

**バックグラウンドジョブ**
```ruby
# app/jobs/slot_generator_job.rb
class SlotGeneratorJob < ApplicationJob
  queue_as :default
  
  def perform
    # 翌々月分のSlotを生成
    target_date = 2.months.from_now
    SlotGeneratorService.generate_for_month(target_date.year, target_date.month)
    
    Rails.logger.info "Generated slots for #{target_date.strftime('%Y年%m月')}"
  end
end
```

**Rakeタスク**
```ruby
# lib/tasks/slots.rake
namespace :slots do
  desc "Generate initial slot data for 3 months (current + next 2 months)"
  task generate_initial: :environment do
    puts "Generating slots for 3 months..."
    
    today = Date.today
    
    # 今月
    SlotGeneratorService.generate_for_month(today.year, today.month)
    puts "Generated slots for #{today.strftime('%Y年%m月')}"
    
    # 翌月
    next_month = today.next_month
    SlotGeneratorService.generate_for_month(next_month.year, next_month.month)
    puts "Generated slots for #{next_month.strftime('%Y年%m月')}"
    
    # 翌々月
    month_after_next = today.next_month.next_month
    SlotGeneratorService.generate_for_month(month_after_next.year, month_after_next.month)
    puts "Generated slots for #{month_after_next.strftime('%Y年%m月')}"
    
    puts "Done! Total slots: #{Slot.count}"
  end
  
  desc "Generate slots for a specific month (YEAR=2025 MONTH=3)"
  task generate_month: :environment do
    year = ENV['YEAR']&.to_i || Date.today.year
    month = ENV['MONTH']&.to_i || Date.today.month
    
    SlotGeneratorService.generate_for_month(year, month)
    puts "Generated slots for #{year}年#{month}月"
  end
end
```

---

## セキュリティ

### 1. 認証・認可

**Basic認証**
- 管理画面全体にBasic認証を適用
- 定数時間比較（`ActiveSupport::SecurityUtils.secure_compare`）でタイミング攻撃を防止
- 環境変数による認証情報管理
- テスト環境では認証スキップ

**実装例**
```ruby
# app/controllers/admin/base_controller.rb
class Admin::BaseController < ApplicationController
  before_action :authenticate_admin
  
  private
  
  def authenticate_admin
    return true if Rails.env.test?
    
    authenticate_or_request_with_http_basic do |username, password|
      expected_username = ENV.fetch('BASIC_AUTH_USER', 'admin')
      expected_password = ENV.fetch('BASIC_AUTH_PASSWORD', 'password')
      
      username_match = ActiveSupport::SecurityUtils.secure_compare(username, expected_username)
      password_match = ActiveSupport::SecurityUtils.secure_compare(password, expected_password)
      
      username_match && password_match
    end
  end
end
```

### 2. データ保護

**楽観的ロック**
- Slot#increment_booked_count! / decrement_booked_count! でロック取得
- 予約競合時の排他制御

**トランザクション管理**
- AppointmentService で予約作成時にトランザクション使用
- 一連の処理をアトミックに実行

**CSRF対策**
- Rails標準のCSRF保護を有効化
- すべてのフォームに authenticity_token を含める

### 3. バリデーション

**サーバーサイドバリデーション**
- 入力値の厳格な検証
- ホワイトリスト方式（Strong Parameters）

**SQLインジェクション対策**
- ActiveRecordのパラメータ化クエリを使用
- 生SQLの使用を最小限に

### 4. 個人情報保護

**最小限の情報収集**
- 予約に必要な情報のみ収集
- 任意項目は最小限に

**プライバシーポリシー**
- 予約時に同意必須
- 個人情報の利用目的を明示

---

## パフォーマンス最適化

### 1. データベース

**インデックス戦略**
- 外部キーにインデックス
- 複合ユニーク制約
  - (phone, slot_id) - 重複予約防止
  - (branch_id, starts_at) - Slot重複防止
- 検索・フィルタリング対象カラムにインデックス

**Eager Loading**
- N+1問題の回避
- `includes`, `preload`, `eager_load` の適切な使用

```ruby
# 例：予約一覧
@appointments = Appointment
  .includes(:branch, :slot, :appointment_type)
  .page(params[:page])
```

### 2. バックグラウンド処理

**非同期ジョブ（GoodJob）**
- メール送信の非同期化
- Slot自動生成の定期実行
- リトライ機能（3回、多項式バックオフ）

**ジョブ優先度**
- メール送信: デフォルト優先度
- Slot生成: 低優先度（深夜実行）

### 3. キャッシュ戦略

**セッションベース**
- ウィザードフローの一時データ保存
- セッションストア: Cookie（小容量）またはRedis（大容量時）

**ページネーション**
- 20件/ページで負荷分散
- Kaminari gemによる効率的なクエリ

### 4. フロントエンド

**アセットパイプライン**
- CSS: Tailwind CSS（プロダクションビルドで最適化）
- JavaScript: 必要最小限の使用
- 画像: WebP形式の使用を検討

---

## 依存関係

### Gem

**必須**
- Rails 8.0
- PostgreSQL (pg gem)
- GoodJob（バックグラウンドジョブ・定期実行）
- Tailwind CSS
- Kaminari（ページネーション）
- holiday_jp（祝日判定）

**開発・テスト**
- RSpec（テストフレームワーク）
- FactoryBot（テストデータ生成）
- Faker（ダミーデータ生成）
- Capybara（統合テスト）
- selenium-webdriver（ブラウザテスト）

### 外部サービス

**本番環境**
- PostgreSQL Database
- SMTP サーバー（メール送信）
  - Gmail SMTP
  - SendGrid
  - AWS SES
  - など

**開発環境**
- MailCatcher / Letter Opener（メール確認）

---

## エラーハンドリング

### 1. 予約競合時

**楽観的ロックエラー**
```ruby
rescue ActiveRecord::StaleObjectError
  flash[:error] = "申し訳ございません。この時間枠は満席になりました。別の時間をお選びください。"
  redirect_to reserve_datetime_path(branch_id: @branch.id)
end
```

**表示メッセージ**
- 「申し訳ございません。この時間は満席になりました」
- リトライ促進UI
- 近い時間帯の空き枠を提案

### 2. メール送信失敗時

**ジョブリトライ**
- 最大3回リトライ
- 多項式バックオフ（1分、5分、15分）

**エラー通知**
- 管理画面でメール送信エラーを確認可能
- ログファイルに詳細記録

### 3. バリデーションエラー

**ユーザーフレンドリーなメッセージ**
```yaml
# config/locales/ja.yml
ja:
  activerecord:
    errors:
      models:
        appointment:
          attributes:
            phone:
              invalid: "は10桁または11桁の数字で入力してください"
              taken: "この電話番号では本日すでに予約があります"
            furigana:
              invalid: "は全角カタカナで入力してください"
            email:
              invalid: "の形式が正しくありません"
```

**フィールドごとのエラー表示**
- エラーフィールドを赤枠でハイライト
- エラーメッセージをフィールド下に表示

### 4. システムエラー

**500エラー**
- ユーザーには汎用エラーメッセージ
- 詳細はログに記録
- 必要に応じて管理者に通知

**404エラー**
- カスタム404ページ
- トップページへの誘導

---

## 運用仕様

### 1. データ保持期間

**予約データ**
- 過去の予約: 3年間保持（税務対応）
- 定期的なアーカイブ処理（年1回）

**Slotデータ**
- 過去のSlot: 1年間保持
- 古いデータは自動削除またはアーカイブ

### 2. バックアップ

**データベース**
- 日次: フルバックアップ
- 保存期間: 30日間
- 自動バックアップスクリプト

**設定ファイル**
- 環境変数のバックアップ
- バージョン管理（Git）

### 3. ログ管理

**アプリケーションログ**
- 予約作成・変更・キャンセルを記録
- ログローテーション（日次、7日保持）

**管理者操作ログ**
- 管理画面での全操作を記録
- 誰が・いつ・何を変更したか

**エラーログ**
- 例外の詳細を記録
- スタックトレース保存

### 4. モニタリング

**ヘルスチェック**
- データベース接続確認
- ジョブキューの状態確認

**アラート**
- メール送信失敗
- ジョブの長時間実行
- データベースエラー

### 5. デプロイ手順

```bash
# 1. コードのデプロイ
git pull origin main

# 2. 依存関係のインストール
bundle install

# 3. データベースマイグレーション
bin/rails db:migrate

# 4. アセットのプリコンパイル
bin/rails assets:precompile

# 5. 初回のみ: Slot初期データ生成
bin/rails slots:generate_initial

# 6. アプリケーション再起動
# (環境に応じた再起動コマンド)
```

### 6. 定期メンテナンス

**月次タスク**
- 予約データの統計レポート作成
- Slot生成状況の確認（自動実行の検証）

**年次タスク**
- 古いデータのアーカイブ
- バックアップの検証

---

## 今後の拡張可能性

### 機能拡張案

**優先度: 高**
1. SMS通知機能
   - 予約確定時のSMS送信
   - 前日リマインダー
2. リマインダーメール
   - 前日の自動メール送信
3. 個別Slot編集機能
   - 特定日時の定員を臨時変更
   - 臨時休業日の設定

**優先度: 中**
4. 予約変更機能
   - 利用者による日時変更
   - 変更締切の設定
5. カレンダーUI
   - FullCalendar.js等の導入
   - 月次カレンダー表示
6. CSVエクスポート
   - 予約データの一括ダウンロード
   - 統計データの出力

**優先度: 低**
7. オンライン相談対応
   - Zoom/Google Meet連携
   - ビデオ相談枠の設定
8. 統計レポート機能
   - 予約数の推移グラフ
   - 相談種別別の集計
   - 支店別の利用状況
9. 利用者向けマイページ
   - 予約履歴の確認
   - 会員登録機能

### 技術的改善案

**短期的**
1. Hotwire/Turbo導入
   - ページ遷移のスムーズ化
   - リアルタイムの空き状況更新
2. Redis導入
   - セッション管理の改善
   - キャッシュ戦略の強化

**中長期的**
3. Action Cable
   - リアルタイム空き状況の同期
   - 複数ユーザー間の競合表示
4. REST API化
   - モバイルアプリ対応
   - 外部システム連携
5. 他のジョブキューへの移行検討
   - Sidekiq（高スループット必要時）
   - Solid Queue（Rails 8標準）

### インフラ改善案

1. CDN導入（CloudFront等）
2. 読み取りレプリカの導入（負荷分散）
3. Auto Scaling設定
4. コンテナ化（Docker）

---

## 付録

### A. 環境変数一覧

```bash
# 認証
BASIC_AUTH_USER=admin
BASIC_AUTH_PASSWORD=password

# データベース
DATABASE_URL=postgresql://user:password@localhost/db_name

# メール
SMTP_ADDRESS=smtp.gmail.com
SMTP_PORT=587
SMTP_DOMAIN=example.com
SMTP_USER_NAME=user@example.com
SMTP_PASSWORD=password
SMTP_AUTHENTICATION=plain
SMTP_ENABLE_STARTTLS_AUTO=true

# アプリケーション
RAILS_ENV=production
SECRET_KEY_BASE=generate_with_rails_secret
```

### B. 初期セットアップ手順

```bash
# 1. リポジトリのクローン
git clone [repository_url]
cd [project_name]

# 2. 依存関係のインストール
bundle install

# 3. データベースの作成とマイグレーション
bin/rails db:create
bin/rails db:migrate

# 4. マスターデータの投入
bin/rails db:seed

# 5. Slot初期データの生成（3ヶ月分）
bin/rails slots:generate_initial

# 6. 開発サーバーの起動
bin/dev
```

### C. テストの実行

```bash
# 全テストの実行
bundle exec rspec

# 特定のファイルのみ
bundle exec rspec spec/models/appointment_spec.rb

# 統合テスト
bundle exec rspec spec/features
```

---

**文書バージョン**: 1.0  
**最終更新日**: 2025年12月21日  
**作成者**: 廣瀬大輔