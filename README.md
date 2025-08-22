# 富士伊豆農業協同組合 予約システム

富士伊豆農業協同組合の相談予約システムです。

## 主な機能

- **利用者向け機能**
  - 地区・支店選択
  - 日時選択（30分単位）
  - 相談種別選択
  - お客様情報入力
  - 予約確認・完了
  - 確認メール送信

- **管理者向け機能**
  - ダッシュボード（統計情報）
  - 予約管理（検索・フィルタ・ステータス更新）
  - 印刷機能（A4レイアウト）
  - 管理メモ機能

## 技術構成

- Ruby 3.3+
- Rails 8.0
- PostgreSQL
- Tailwind CSS
- GoodJob（バックグラウンドジョブ）

## セットアップ

### 1. 依存関係のインストール
```bash
bundle install
```

### 2. データベース作成・初期化
```bash
bin/rails db:create db:migrate
```

## Seed（初期データ）

開発・検証用の初期データを投入できます。

### 1. Seed実行
```bash
bin/rails db:drop db:create db:migrate db:seed
```

**作成されるデータ:**
- 8エリア / 各2支店（計16支店）
- 今日と翌日の9:00〜16:30を30分刻み（capacity=4）
- 6種類の相談種別
- サンプル予約データ5件

### 2. Seed動作確認
```bash
bin/rails db:drop db:create db:migrate db:seed
```

## 開発サーバー起動

```bash
bin/dev
```

- 利用者画面: http://localhost:3000
- 管理画面: http://localhost:3000/admin
  - 基本認証: admin / password

## 管理画面アクセス

- URL: `/admin`
- 基本認証: `admin` / `password`

## バックグラウンドジョブ

メール送信にGoodJobを使用しています。

```bash
# ジョブワーカー起動（bin/devに含まれています）
bin/good_job start
```

## テスト

```bash
# テストDB準備
RAILS_ENV=test bin/rails db:drop db:create db:migrate

# まずはモデル＆スモークが通るか
bundle exec rspec spec/models/appointment_spec.rb spec/system/reservations_smoke_spec.rb

# UIが整っていればフルフローも
bundle exec rspec spec/system/reservations_full_flow_spec.rb

# 全テスト実行
bundle exec rspec
```

### よくある詰まりどころ

- **ラベル文字が違って click_on / fill_in が見つからない** → テスト側の文言を実装に合わせて変更
- **スロット選択がJS依存** → そのテストだけ `driven_by(:selenium_chrome_headless)` に変更
- **同日重複予約のバリデーション未実装** → モデルに以下のようなバリデーションを追加

```ruby
validate :no_same_day_duplicate_by_phone

def no_same_day_duplicate_by_phone
  return if phone.blank? || slot.blank?
  day_range = slot.starts_at.beginning_of_day..slot.starts_at.end_of_day
  exists = Appointment.where(phone: phone).joins(:slot).where(slots: { starts_at: day_range })
  exists = exists.where.not(id: id) if persisted?
  errors.add(:base, "同一日・同一電話の重複予約はできません") if exists.exists?
end
```

## 本番環境での注意事項

1. **基本認証の変更**
   - `app/controllers/application_controller.rb`の認証情報を変更
   
2. **メール設定**
   - `config/environments/production.rb`でSMTP設定を追加

3. **データベース**
   - PostgreSQLの本番環境設定

4. **バックグラウンドジョブ**
   - GoodJobワーカーのプロセス管理設定
