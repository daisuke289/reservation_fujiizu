# Codespace Development Container Configuration

このディレクトリにはGitHub Codespace用の開発コンテナ設定が含まれています。

## 📁 ファイル構成

- **devcontainer.json**: Codespaceのメイン設定ファイル
- **setup.sh**: 初回起動時に実行されるセットアップスクリプト
- **README.md**: このファイル

## 🚀 自動セットアップ内容

Codespace起動時に以下が自動的に実行されます：

### 1. 環境構築
- Ruby 3.2.0のインストール
- Node.js (LTS)のインストール
- Docker-in-Dockerのセットアップ

### 2. VS Code拡張機能
以下の拡張機能が自動的にインストールされます：

**Ruby/Rails開発**:
- Shopify Ruby LSP（Ruby言語サーバー）
- Rails DB Schema
- Rails snippets
- Endwise（Ruby構文補完）

**データベース**:
- SQLTools
- SQLTools PostgreSQL Driver

**一般ツール**:
- GitLens（Git履歴可視化）
- Prettier（コードフォーマッタ）
- Tailwind CSS IntelliSense
- ESLint

### 3. プロジェクトセットアップ（setup.sh）
- `bundle install`: Ruby gemのインストール
- PostgreSQLコンテナの起動待機
- データベースの作成・マイグレーション
- Seedデータの投入
- Slot初期データの生成（Phase 2完了後）

### 4. ポートフォワーディング
- **3000**: Rails開発サーバー（自動通知）
- **5432**: PostgreSQL（サイレント）

## 🔧 環境変数

以下の環境変数がCodespace環境で自動的に設定されます：

```bash
DATABASE_HOST=postgres
DATABASE_USERNAME=postgres
DATABASE_PASSWORD=postgres
RAILS_ENV=development
```

これらは`config/database.yml`で参照され、適切なデータベース接続が確立されます。

## 📝 カスタマイズ

### 拡張機能の追加

`devcontainer.json`の`customizations.vscode.extensions`配列に追加：

```json
"customizations": {
  "vscode": {
    "extensions": [
      "your-publisher.your-extension"
    ]
  }
}
```

### 環境変数の追加

`devcontainer.json`の`remoteEnv`オブジェクトに追加：

```json
"remoteEnv": {
  "YOUR_ENV_VAR": "value"
}
```

### セットアップスクリプトの変更

`setup.sh`を編集してカスタムセットアップステップを追加できます。

## 🐛 トラブルシューティング

### セットアップスクリプトが失敗する

1. Codespaceのログを確認：
   - VS Codeのターミナルで「OUTPUT」タブを開く
   - 「Dev Containers」を選択

2. 手動でセットアップを再実行：
   ```bash
   bash .devcontainer/setup.sh
   ```

### PostgreSQLに接続できない

```bash
# PostgreSQLコンテナの状態確認
docker-compose ps

# コンテナを再起動
docker-compose restart postgres

# ログ確認
docker-compose logs postgres
```

### 拡張機能がインストールされない

1. VS Codeのコマンドパレット（Cmd+Shift+P / Ctrl+Shift+P）を開く
2. 「Developer: Reload Window」を実行
3. または、Codespaceを再起動

## 📚 参考資料

- [Dev Containers Documentation](https://containers.dev/)
- [GitHub Codespaces Documentation](https://docs.github.com/en/codespaces)
- [VS Code Dev Containers](https://code.visualstudio.com/docs/devcontainers/containers)

## 🔄 更新履歴

- **2025-12-27**: 初版作成
  - Ruby 3.2.0環境
  - PostgreSQL自動セットアップ
  - VS Code拡張機能の自動インストール
