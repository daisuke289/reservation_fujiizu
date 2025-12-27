# コードベース構造

## ディレクトリ構成

### アプリケーション本体（app/）
```
app/
├── controllers/
│   ├── admin/              # 管理画面コントローラー
│   │   ├── base_controller.rb
│   │   ├── dashboard_controller.rb
│   │   ├── appointments_controller.rb
│   │   ├── branches_controller.rb  # Phase 3で追加予定
│   │   └── prints_controller.rb
│   ├── public/             # 公開ページコントローラー
│   │   └── home_controller.rb
│   ├── reserve/            # 予約フローコントローラー
│   │   ├── steps_controller.rb
│   │   ├── confirm_controller.rb
│   │   └── complete_controller.rb
│   └── application_controller.rb
├── models/                 # モデル
│   ├── area.rb
│   ├── branch.rb          # Phase 1でdefault_capacity追加予定
│   ├── slot.rb
│   ├── appointment.rb
│   └── appointment_type.rb
├── services/              # ビジネスロジック（サービスオブジェクト）
│   ├── appointment_service.rb
│   └── slot_generator_service.rb  # Phase 2で追加予定
├── jobs/                  # バックグラウンドジョブ
│   ├── appointment_mail_job.rb
│   └── slot_generator_job.rb  # Phase 2で追加予定
├── mailers/               # メーラー
│   └── appointment_mailer.rb
├── views/
│   ├── admin/             # 管理画面ビュー
│   ├── public/            # 公開ページビュー
│   ├── reserve/           # 予約フロービュー
│   ├── appointment_mailer/  # メールテンプレート
│   └── layouts/
│       ├── application.html.erb
│       ├── admin.html.erb
│       └── print.html.erb
└── helpers/               # ビューヘルパー
```

### 設定（config/）
```
config/
├── routes.rb              # ルーティング定義
├── database.yml           # DB接続設定
├── initializers/
│   └── good_job.rb       # Phase 2でcron設定追加予定
├── locales/
│   └── ja.yml            # 日本語ロケール
└── environments/
    ├── development.rb
    ├── test.rb
    └── production.rb
```

### データベース（db/）
```
db/
├── migrate/               # マイグレーションファイル
├── schema.rb              # スキーマ定義（自動生成）
└── seeds.rb               # シードデータ
```

### タスク（lib/tasks/）
```
lib/
└── tasks/
    └── slots.rake        # Phase 2で追加予定
```

### テスト（spec/）
```
spec/
├── models/               # モデルテスト
├── services/             # Phase 4で追加予定
│   └── slot_generator_service_spec.rb
├── requests/             # Phase 4で追加予定
│   └── admin/
│       └── branches_spec.rb
├── system/               # システムテスト（E2E）
│   ├── reservations_smoke_spec.rb
│   └── reservations_full_flow_spec.rb
├── factories/            # FactoryBot定義
│   ├── appointments.rb
│   ├── branches.rb
│   └── ...
├── support/              # テストサポート
├── rails_helper.rb       # RSpec設定
└── spec_helper.rb
```

### その他の重要ファイル
```
.
├── Gemfile               # Gem依存関係
├── Gemfile.lock          # Gemバージョンロック
├── Rakefile              # Rakeタスク定義
├── config.ru             # Rackアプリ設定
├── Procfile.dev          # 開発サーバー起動設定
├── .rubocop.yml          # RuboCop設定
├── .rspec                # RSpec設定
├── CLAUDE.md             # Claudeへの指示書
└── README.md             # プロジェクト説明
```

## 主要なコントローラーフロー

### 利用者向けフロー
```
Public::HomeController (/)
  ↓
Reserve::StepsController
  - area (エリア選択)
  - branch (支店選択)
  - datetime (日時選択)
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
  ├─ Admin::BranchesController (支店管理) # Phase 3で実装予定
  └─ Admin::PrintsController (印刷)
```

## データモデルの関連
```
Area (8 regions)
  has_many :branches

Branch (1 per area)
  belongs_to :area
  has_many :slots
  has_many :appointments

Slot (30min intervals)
  belongs_to :branch
  has_many :appointments

Appointment
  belongs_to :branch
  belongs_to :slot
  belongs_to :appointment_type

AppointmentType (6 types)
  has_many :appointments
```
