# Operations & Deployment

運用・デプロイ・環境設定に関する情報をまとめたドキュメントです。

---

## Environment Variables

開発・本番環境で設定が必要な環境変数:

```bash
# Basic認証（管理画面）
BASIC_AUTH_USER=admin
BASIC_AUTH_PASSWORD=your_secure_password

# データベース
DATABASE_URL=postgresql://user:password@localhost/dbname

# メール送信
SMTP_ADDRESS=smtp.example.com
SMTP_PORT=587
SMTP_DOMAIN=example.com
SMTP_USER_NAME=user@example.com
SMTP_PASSWORD=password
SMTP_AUTHENTICATION=plain
SMTP_ENABLE_STARTTLS_AUTO=true

# Rails環境
RAILS_ENV=production
RAILS_MASTER_KEY=<config/master.keyの内容>
```

### 環境変数の設定方法

**開発環境（.env使用）**
```bash
# .env.local ファイルを作成
cp .env.example .env.local

# 環境変数を設定
echo "BASIC_AUTH_USER=admin" >> .env.local
echo "BASIC_AUTH_PASSWORD=your_password" >> .env.local
```

**本番環境**
- Heroku: `heroku config:set KEY=VALUE`
- Docker: `docker-compose.yml` の `environment` セクション
- サーバー: `/etc/environment` または systemd の `EnvironmentFile`

---

## Deployment Checklist

本番環境デプロイ前の確認事項:

### データベース関連

- [ ] Branchテーブルにdefault_capacityカラムが追加されている
- [ ] 全てのBranchレコードがdefault_capacity = 1になっている
- [ ] 初回Slotデータが生成されている（`bin/rails slots:generate_initial`）

### Gem・依存関係

- [ ] holiday_jp gemがインストールされている
- [ ] SlotGeneratorService, SlotGeneratorJob, Rakeタスクが実装されている
- [ ] bundle install が完了している

### GoodJob設定

- [ ] GoodJob cron設定が完了している（`config/initializers/good_job.rb`）
- [ ] GoodJobワーカーの起動設定（systemd or Procfile）
- [ ] GoodJobダッシュボードのアクセス制限設定

### 管理機能

- [ ] Admin::BranchesControllerが実装されている
- [ ] 支店管理画面が正常に動作する
- [ ] ダッシュボードに支店管理へのリンクがある

### 本番デプロイ時

**環境設定**
- [ ] 環境変数の設定（BASIC_AUTH, DATABASE_URL, SMTP設定等）
- [ ] RAILS_MASTER_KEYの設定
- [ ] Basic認証のパスワード変更

**データベース**
- [ ] `RAILS_ENV=production bin/rails db:migrate`
- [ ] `RAILS_ENV=production bin/rails db:seed`（初回のみ）
- [ ] `RAILS_ENV=production bin/rails slots:generate_initial`（初回のみ）

**アセット・静的ファイル**
- [ ] `RAILS_ENV=production bin/rails assets:precompile`
- [ ] Tailwind CSS のビルド確認

**セキュリティ**
- [ ] SSL証明書の設定
- [ ] Basic認証のパスワード変更
- [ ] CSRFトークンの動作確認

**メール設定**
- [ ] SMTP設定の確認
- [ ] メール送信元アドレスの変更（`app/mailers/appointment_mailer.rb`）
- [ ] テストメールの送信確認

**監視・ログ**
- [ ] ログローテーション設定
- [ ] データベースバックアップの設定
- [ ] エラー監視ツールの設定（Sentry等）

---

## Deployment Procedure

### 初回デプロイ手順

```bash
# 1. リポジトリのクローン
git clone [repository_url]
cd [project_name]

# 2. 環境変数の設定
cp .env.example .env.production
# .env.production を編集

# 3. 依存関係のインストール
bundle install --without development test
yarn install

# 4. データベースのセットアップ
RAILS_ENV=production bin/rails db:create
RAILS_ENV=production bin/rails db:migrate
RAILS_ENV=production bin/rails db:seed

# 5. Slot初期データ生成
RAILS_ENV=production bin/rails slots:generate_initial

# 6. アセットのプリコンパイル
RAILS_ENV=production bin/rails assets:precompile

# 7. サーバー起動
RAILS_ENV=production bin/rails server -b 0.0.0.0 -p 3000
```

### 継続的デプロイ

```bash
# 1. 最新コードの取得
git pull origin main

# 2. 依存関係の更新
bundle install
yarn install

# 3. マイグレーション実行
RAILS_ENV=production bin/rails db:migrate

# 4. アセットの再ビルド
RAILS_ENV=production bin/rails assets:precompile

# 5. サーバー再起動
systemctl restart reservation_app
# または
touch tmp/restart.txt  # Passengerの場合
```

---

## Backup & Recovery

### データベースバックアップ

**自動バックアップ（cronで設定）**
```bash
# /etc/cron.d/db_backup
0 3 * * * postgres pg_dump reservation_fujiizu_production > /backup/db_$(date +\%Y\%m\%d).sql
```

**手動バックアップ**
```bash
# バックアップ作成
pg_dump reservation_fujiizu_production > backup_$(date +%Y%m%d).sql

# 圧縮
gzip backup_$(date +%Y%m%d).sql

# リストア
psql reservation_fujiizu_production < backup_20250101.sql
```

### アプリケーションコードのバックアップ

```bash
# Gitタグを使用したバージョン管理
git tag -a v1.0.0 -m "Release version 1.0.0"
git push origin v1.0.0

# 特定バージョンへのロールバック
git checkout v1.0.0
```

---

## Logging & Monitoring

### ログファイル

**ログの種類**
- `log/production.log` - アプリケーションログ
- `log/good_job.log` - バックグラウンドジョブログ
- `/var/log/postgresql/postgresql-*.log` - データベースログ

**ログ確認コマンド**
```bash
# リアルタイムログ監視
tail -f log/production.log

# エラーログの抽出
grep ERROR log/production.log

# GoodJobログの確認
tail -f log/good_job.log | grep SlotGeneratorJob
```

### ログローテーション

**logrotate設定例**
```bash
# /etc/logrotate.d/reservation_app
/path/to/app/log/*.log {
  daily
  missingok
  rotate 30
  compress
  delaycompress
  notifempty
  copytruncate
}
```

### モニタリング

**推奨監視項目**
- [ ] アプリケーションの稼働状態（HTTP 200応答）
- [ ] データベース接続状態
- [ ] GoodJobワーカーのプロセス確認
- [ ] ディスク使用量
- [ ] メモリ使用量
- [ ] Slotの生成状況（月次）

**ヘルスチェックエンドポイント**
```ruby
# config/routes.rb に追加推奨
get '/health', to: proc { [200, {}, ['OK']] }
```

---

## GoodJob Management

### GoodJobワーカーの起動

**開発環境**
```bash
bundle exec good_job start
```

**本番環境（systemd）**
```ini
# /etc/systemd/system/good_job.service
[Unit]
Description=GoodJob Background Worker
After=network.target

[Service]
Type=simple
User=deploy
WorkingDirectory=/var/www/reservation_app
Environment=RAILS_ENV=production
ExecStart=/usr/local/bin/bundle exec good_job start
Restart=always

[Install]
WantedBy=multi-user.target
```

**起動・停止コマンド**
```bash
sudo systemctl start good_job
sudo systemctl stop good_job
sudo systemctl restart good_job
sudo systemctl status good_job
```

### Cron Job確認

```bash
# Railsコンソールでcron設定確認
bin/rails console
> GoodJob.configuration.cron

# 手動で月次Slot生成ジョブを実行
> SlotGeneratorJob.perform_now
```

---

## Git Workflow

推奨されるGitワークフロー:

### ブランチ戦略

```bash
# 機能開発
git checkout -b feature/add-new-feature
# 実装...
git add .
git commit -m "Add new feature description"
git push origin feature/add-new-feature

# バグ修正
git checkout -b fix/bug-description
# 修正...
git commit -m "Fix bug description"
git push origin fix/bug-description

# テスト追加
git checkout -b test/add-feature-tests
# テスト実装...
git commit -m "Add tests for feature"
git push origin test/add-feature-tests

# main/masterブランチへのマージはPRレビュー後
```

### コミットメッセージ規約

- **簡潔で明確に**（50文字以内の要約 + 必要に応じて詳細）
- **英語推奨**（日本語も可）
- **プレフィックス**: Add, Fix, Update, Remove, Refactor等
- **Phase番号を含める**と管理しやすい

**例**:
```bash
git commit -m "Add default_capacity column to branches table"
git commit -m "Fix slot generation bug for year-end holidays"
git commit -m "[Phase 2] Add SlotGeneratorService with holiday_jp"
git commit -m "Update admin dashboard with branch management link"
```

### リリースタグ

```bash
# バージョンタグの作成
git tag -a v1.0.0 -m "Release version 1.0.0 - Initial production release"
git push origin v1.0.0

# タグ一覧確認
git tag -l

# 特定バージョンのチェックアウト
git checkout v1.0.0
```

---

## Error Handling

### よくあるエラーと対処法

**PG::ConnectionBad: could not connect to server**
- PostgreSQLサービスが起動しているか確認
- DATABASE_URLの設定を確認
- ファイアウォール設定を確認

**ActiveRecord::PendingMigrationError**
```bash
RAILS_ENV=production bin/rails db:migrate
```

**Assets not found (404)**
```bash
RAILS_ENV=production bin/rails assets:precompile
RAILS_ENV=production bin/rails assets:clean
```

**GoodJob jobs not processing**
- GoodJobワーカーが起動しているか確認: `ps aux | grep good_job`
- データベース接続を確認
- ログを確認: `tail -f log/good_job.log`

**Slot generation failed**
- holiday_jp gemのインストール確認: `bundle list | grep holiday_jp`
- Branch.default_capacityの設定確認
- ログで詳細エラーを確認: `grep SlotGenerator log/production.log`

---

## Additional Resources

- **Rails Guides**: https://guides.rubyonrails.org/
- **GoodJob Documentation**: https://github.com/bensheldon/good_job
- **GoodJob Cron**: https://github.com/bensheldon/good_job#cron-style-repeatingrecurring-jobs
- **holiday_jp**: https://github.com/holiday-jp/holiday_jp-ruby
- **PostgreSQL Documentation**: https://www.postgresql.org/docs/
- **Tailwind CSS**: https://tailwindcss.com/docs

---

## 関連ドキュメント

- **開発ガイド**: [docs/DEVELOPMENT.md](DEVELOPMENT.md) - セットアップ、コマンド、テスト
- **システム設計**: [docs/ARCHITECTURE.md](ARCHITECTURE.md) - データモデル、コントローラー構造
- **データベース設計**: [docs/DATABASE.md](DATABASE.md) - ER図、テーブル定義
- **実装履歴**: [docs/HISTORY.md](HISTORY.md) - Phase 1-5の詳細実装手順
- **機能仕様**: [docs/FEATURES.md](FEATURES.md) - 利用者・管理者機能
