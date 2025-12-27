# 開発コマンド集

## セットアップ

### 初回セットアップ
```bash
bundle install
bin/rails db:drop db:create db:migrate db:seed
```

### データベースのリセット
```bash
bin/rails db:reset  # drop → create → migrate → seed
```

### マイグレーション
```bash
bin/rails db:migrate
bin/rails db:rollback
bin/rails db:rollback STEP=3
bin/rails db:migrate:status
```

## 開発サーバー

### 開発サーバー起動（推奨）
```bash
bin/dev  # Rails + GoodJob + Tailwind CSS watch
```

### 個別起動
```bash
bin/rails server                # Railsサーバーのみ
bundle exec good_job start      # GoodJobワーカーのみ
```

### アクセスURL
- 利用者画面: http://localhost:3000
- 管理画面: http://localhost:3000/admin (admin/password)

## テスト

### テストDB準備
```bash
RAILS_ENV=test bin/rails db:drop db:create db:migrate
```

### テスト実行
```bash
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
```

## コード品質

### RuboCop（Linter）
```bash
bundle exec rubocop           # チェック実行
bundle exec rubocop -a        # 自動修正
```

### セキュリティチェック
```bash
bundle exec brakeman                          # セキュリティチェック
bundle exec bundle-audit check --update      # 脆弱性チェック
```

## Railsユーティリティ

### コンソール
```bash
bin/rails console
```

### ルート確認
```bash
bin/rails routes
bin/rails routes -c admin/appointments
bin/rails routes | grep <path>
```

### ログ確認
```bash
tail -f log/development.log
tail -f log/test.log
tail -f log/good_job.log
```

## Git操作

### ブランチ作成（推奨フロー）
```bash
git checkout -b feature/<feature-name>
git add .
git commit -m "Add feature description"
git push origin feature/<feature-name>
```

### コミットメッセージ規約
- 簡潔で明確に
- 英語推奨（日本語も可）
- プレフィックス: Add, Fix, Update, Remove, Refactor等

## Phase 2完了後の追加コマンド

### Slot管理
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

## Linux システムコマンド

### ファイル操作
```bash
ls -la                    # ファイル一覧表示
cd <directory>            # ディレクトリ移動
grep -r "pattern" .       # ファイル内検索
find . -name "*.rb"       # ファイル検索
```

### プロセス管理
```bash
ps aux | grep rails       # プロセス確認
ps aux | grep good_job    # GoodJobワーカー確認
kill -9 <PID>             # プロセス終了
```
