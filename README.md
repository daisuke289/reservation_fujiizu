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
bin/rails test
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
