# 開発環境セットアップガイド

このドキュメントは、GitHub CodespaceとローカルMacの両方での開発環境セットアップ手順を説明します。

## 📋 目次

1. [GitHub Codespaceでの開発](#github-codespaceでの開発)
2. [ローカルMacでの開発](#ローカルmacでの開発)
3. [環境間の同期](#環境間の同期)
4. [トラブルシューティング](#トラブルシューティング)

---

## 🌐 GitHub Codespaceでの開発

### 自動セットアップ（推奨）

このプロジェクトには`.devcontainer`設定が含まれています。GitHub Codespaceを起動すると、以下が自動的に実行されます：

1. ✅ Ruby 3.2.0のインストール
2. ✅ Node.js (LTS)のインストール
3. ✅ VS Code拡張機能のインストール（Ruby LSP, Rails snippets等）
4. ✅ `bundle install`の実行
5. ✅ PostgreSQLコンテナの起動
6. ✅ データベースの作成・マイグレーション
7. ✅ Seedデータの投入
8. ✅ Slot初期データの生成（Phase 2完了後）

**初回起動後、すぐに開発を開始できます！**

詳細は`.devcontainer/README.md`を参照してください。

### 手動セットアップ（オプション）

自動セットアップをスキップした場合や、再セットアップが必要な場合：

```bash
# 1. 依存関係のインストール
bundle install

# 2. PostgreSQLの起動（docker-compose使用）
docker-compose up -d postgres

# 3. データベースのセットアップ
bin/rails db:create db:migrate db:seed

# 4. 初回Slotデータ生成（Phase 2完了後）
bin/rails slots:generate_initial

# 5. 開発サーバー起動
bin/dev
```

### 環境変数の設定

Codespaceでは環境変数は不要ですが、カスタマイズしたい場合：

```bash
# .envファイルを作成（.env.exampleをコピー）
cp .env.example .env

# 必要に応じて編集
nano .env
```

### データベース接続

Codespaceでは環境変数が自動的に設定され、PostgreSQLコンテナに接続します：

**環境変数（自動設定）**:
- `DATABASE_HOST=postgres`
- `DATABASE_USERNAME=postgres`
- `DATABASE_PASSWORD=postgres`
- `DATABASE_PORT=5432`

これらの環境変数は`config/database.yml`で参照され、適切なデータベース接続が確立されます。

**Docker Composeコンテナ**:
- コンテナ名: `postgres`
- ポート: `5432`
- ユーザー名: `postgres`
- パスワード: `postgres`

---

## 💻 ローカルMacでの開発

### 前提条件

以下がインストールされている必要があります：

- **Homebrew** (パッケージマネージャー)
- **rbenv** または **asdf** (Rubyバージョン管理)
- **PostgreSQL** (データベース)
- **Node.js** (アセットコンパイル用、Rails 8では不要な場合もあり)

### 1. Rubyのインストール

```bash
# rbenv使用の場合
rbenv install 3.2.0
rbenv local 3.2.0

# asdf使用の場合
asdf install ruby 3.2.0
asdf local ruby 3.2.0

# インストール確認
ruby -v  # => ruby 3.2.0
```

### 2. PostgreSQLのセットアップ

#### オプションA: Homebrewでインストール

```bash
# PostgreSQLインストール
brew install postgresql@16

# サービス起動
brew services start postgresql@16

# ユーザー作成（初回のみ）
createuser -s postgres
```

#### オプションB: Docker Composeを使用

```bash
# PostgreSQLコンテナを起動
docker-compose up -d postgres

# 接続確認
docker-compose exec postgres psql -U postgres -c "SELECT version();"
```

### 3. アプリケーションのセットアップ

```bash
# 1. リポジトリのクローン（初回のみ）
git clone [repository_url]
cd reservation_fujiizu

# 2. 依存関係のインストール
bundle install

# 3. 環境変数の設定（オプション）
cp .env.example .env
# .envファイルを必要に応じて編集

# 4. データベースのセットアップ
bin/rails db:create db:migrate db:seed

# 5. 初回Slotデータ生成（Phase 2完了後）
bin/rails slots:generate_initial

# 6. 開発サーバー起動
bin/dev
```

### 4. ブラウザでアクセス

- 利用者画面: http://localhost:3000
- 管理画面: http://localhost:3000/admin
  - ユーザー名: `admin`
  - パスワード: `password`

---

## 🔄 環境間の同期

### コミット前のチェックリスト

```bash
# 1. git statusを確認
git status

# 2. .DS_Storeが含まれていないか確認
git ls-files | grep .DS_Store
# 何も表示されなければOK

# 3. 機密情報が含まれていないか確認
git diff | grep -E "password|secret|key"

# 4. テストが通ることを確認
bundle exec rspec

# 5. RuboCopエラーがないか確認（オプション）
bundle exec rubocop
```

### Gemfile/Gemfile.lockの管理

```bash
# Codespaceで新しいgemを追加した場合
bundle install

# Gemfile.lockをコミット
git add Gemfile Gemfile.lock
git commit -m "Add new gem: gem_name"

# ローカルMacで最新のgemをインストール
git pull
bundle install
```

### データベースマイグレーションの同期

```bash
# 新しいマイグレーションをpullした後
bin/rails db:migrate

# マイグレーション状態の確認
bin/rails db:migrate:status

# 問題がある場合はデータベースをリセット（注意: データが消えます）
bin/rails db:reset
```

### 環境変数の管理

- `.env`ファイルは**コミットしない**（.gitignoreに含まれています）
- `.env.example`を最新に保つ
- 新しい環境変数を追加した場合：
  ```bash
  # .env.exampleを更新
  nano .env.example

  # コミット
  git add .env.example
  git commit -m "Add new environment variable to .env.example"
  ```

---

## 📊 データベース設定の違い

このプロジェクトの`config/database.yml`は環境変数に対応しています：

```yaml
development:
  adapter: postgresql
  database: reservation_fujiizu_development
  username: <%= ENV.fetch("DATABASE_USERNAME", "postgres") %>
  password: <%= ENV.fetch("DATABASE_PASSWORD", "postgres") %>
  host: <%= ENV.fetch("DATABASE_HOST", "localhost") %>
  port: <%= ENV.fetch("DATABASE_PORT", "5432") %>
```

### Codespace環境

`.devcontainer/devcontainer.json`で以下の環境変数が自動設定されます：

```bash
DATABASE_HOST=postgres      # Docker Composeコンテナ名
DATABASE_USERNAME=postgres
DATABASE_PASSWORD=postgres
DATABASE_PORT=5432
```

### ローカルMac環境

**デフォルト設定（環境変数なし）**:
- Host: `localhost`
- Username: `postgres`
- Password: `postgres`

**カスタム設定（.envファイルを使用）**:

```bash
# .envファイルを作成
cp .env.example .env

# 以下を編集
DATABASE_HOST=localhost
DATABASE_USERNAME=your_username
DATABASE_PASSWORD=your_password
DATABASE_PORT=5432
```

環境変数が設定されていない場合はデフォルト値が使用されるため、既存の開発環境への影響はありません。

---

## 🐛 トラブルシューティング

### Codespace特有の問題

#### 1. PostgreSQLに接続できない

```bash
# PostgreSQLコンテナの状態確認
docker-compose ps

# コンテナが起動していない場合
docker-compose up -d postgres

# ログ確認
docker-compose logs postgres
```

#### 2. ポートが既に使用されている

```bash
# プロセスを確認
lsof -i :3000

# プロセスを終了
kill -9 [PID]
```

### ローカルMac特有の問題

#### 1. bundle installが失敗する

```bash
# Xcodeコマンドラインツールのインストール
xcode-select --install

# pggemのインストール
gem install pg -- --with-pg-config=/opt/homebrew/bin/pg_config
```

#### 2. PostgreSQLに接続できない

```bash
# PostgreSQLサービスの状態確認
brew services list

# サービス再起動
brew services restart postgresql@16

# 接続テスト
psql -U postgres -c "SELECT version();"
```

#### 3. rbenvのRubyバージョンが反映されない

```bash
# rbenvの初期化を確認
echo 'eval "$(rbenv init - bash)"' >> ~/.bash_profile
source ~/.bash_profile

# または zsh使用の場合
echo 'eval "$(rbenv init - zsh)"' >> ~/.zshrc
source ~/.zshrc

# Rubyバージョン確認
rbenv version
ruby -v
```

### 共通の問題

#### 1. マイグレーションエラー

```bash
# データベース状態の確認
bin/rails db:migrate:status

# データベースをリセット（注意: データが消えます）
bin/rails db:drop db:create db:migrate db:seed
```

#### 2. テストDBのセットアップ

```bash
RAILS_ENV=test bin/rails db:drop db:create db:migrate
```

#### 3. GoodJobが動作しない

```bash
# GoodJobワーカーの状態確認
ps aux | grep good_job

# bin/devで起動している場合は自動的に起動します
# 手動で起動する場合:
bundle exec good_job start
```

---

## 🔐 セキュリティのベストプラクティス

### 1. 機密情報の管理

- ❌ **絶対にコミットしない**:
  - `config/master.key`
  - `.env`
  - パスワードやAPIキーを含むファイル

- ✅ **コミットして良い**:
  - `.env.example`（テンプレート、実際の値は含まない）
  - `config/credentials.yml.enc`（暗号化済み）
  - `config/database.yml`（環境変数参照のみ）

### 2. Basic認証の変更

本番環境では必ず強力なパスワードに変更してください：

```bash
# .envファイルまたは環境変数で設定
BASIC_AUTH_USER=your_secure_username
BASIC_AUTH_PASSWORD=your_secure_password
```

### 3. Rails Credentialsの使用

機密情報はRails Credentialsで管理することを推奨：

```bash
# credentials編集
EDITOR="nano" bin/rails credentials:edit

# 本番環境用credentials
EDITOR="nano" bin/rails credentials:edit --environment production
```

---

## 📚 参考リソース

- [Rails Guides - Database Configuration](https://guides.rubyonrails.org/configuring.html#configuring-a-database)
- [GoodJob Documentation](https://github.com/bensheldon/good_job)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [rbenv Documentation](https://github.com/rbenv/rbenv)

---

## 🤝 コントリビューション

開発環境で問題が発生した場合や改善提案がある場合は、以下の手順で報告してください：

1. このドキュメント（DEVELOPMENT_SETUP.md）の該当セクションを確認
2. トラブルシューティングで解決しない場合はIssueを作成
3. 解決策を見つけた場合はPull Requestを作成

---

**最終更新日**: 2025-12-27
**メンテナー**: [Your Team Name]
