# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

---

# Workflow

あなたは、以下のステップを実行します。

## Step 1: タスク受付と準備
1. ユーザーから **GitHub Issue 番号**を受け付けたらフロー開始です。`/create-gh-branch` カスタムコマンドを実行し、Issueの取得とブランチを作成します。
2. Issueの内容を把握し、関連するコードを調査します。調査時にはSerenaMCPの解析結果を利用してください。

## Step 2: 実装計画の策定と承認
1. 分析結果に基づき、実装計画を策定します。
2. 計画をユーザーに提示し、承認を得ます。**承認なしに次へ進んではいけません。**

## Step 3: 実装・レビュー・修正サイクル
1. 承認された計画に基づき、実装を行います。
2. 実装完了後、**あなた自身でコードのセルフレビューを行います。**
3. 実装内容とレビュー結果をユーザーに報告します。
4. **【ユーザー承認】**: 報告書を提示し、承認を求めます。
    - `yes`: コミットして完了。
    - `fix`: 指摘に基づき修正し、再度レビューからやり直す。

---

# Rules

以下のルールは、あなたの行動を規定する最優先事項およびガイドラインです。

## 重要・最優先事項 (CRITICAL)
- **ユーザー承認は絶対**: いかなる作業も、ユーザーの明示的な承認なしに進めてはいけません。
- **品質の担保**: コミット前には必ずテスト(`rspec`)を実行し、全てパスすることを確認してください。
- **効率と透明性**: 作業に行き詰まった場合、同じ方法で3回以上試行することはやめてください。
- **SerenaMCP必須**: コードベースの調査・分析には必ずSerenaMCPを使用すること。`Read`ツールでソースファイル全体を読み込むことは原則禁止。

## SerenaMCP 使用ガイド

コード解析は必ず以下のツールを使用してください。

| ツール | 用途 | 使用例 |
|--------|------|--------|
| `find_symbol` | クラス・メソッドの検索、シンボルの定義取得 | 特定メソッドの実装を確認したいとき |
| `get_symbols_overview` | ファイル内のシンボル一覧を取得 | ファイル構造を把握したいとき |
| `find_referencing_symbols` | シンボルの参照箇所を検索 | メソッドがどこから呼ばれているか調べるとき |
| `search_for_pattern` | 正規表現でコード検索 | 特定パターンの使用箇所を探すとき |

### 禁止事項
- ❌ `Read`ツールでソースファイル(.rb)全体を読み込む
- ❌ 目的なくファイル内容を取得する
- ❌ SerenaMCPで取得可能な情報を他の方法で取得する

## 基本理念 (PHILOSOPHY)
- **大きな変更より段階的な進捗**: テストを通過する小さな変更を積み重ねる。
- **シンプルさが意味すること**: クラスやメソッドは単一責任を持つ（Single Responsibility）。

## 技術・実装ガイドライン
- **実装プロセス (TDD)**: Red -> Green -> Refactor のサイクルを厳守する。
- **アーキテクチャ**: Fat Model, Skinny Controller を心がける。
- **完了の定義**:
    - [ ] テストが通っている
    - [ ] RuboCopのエラーがない
    - [ ] Railsアプリが正常に動作する

---

# Project Overview

富士伊豆農業協同組合の相続相談予約システム。来店予約Webアプリケーション

- **Tech Stack**: Rails 8.0, PostgreSQL, Tailwind CSS, GoodJob, holiday_jp
- **Target Users**: 金融機関利用者
- **Current Status**: ✅ **全機能実装完了・本番環境デプロイ可能**

## ✅ 実装完了機能（2024年12月完了）

1. ✅ **Slot自動生成システム** (SlotGeneratorService + SlotGeneratorJob + Rakeタスク)
2. ✅ **支店管理機能** (Admin::BranchesController + ビュー)
3. ✅ **GoodJob定期実行設定** (config/initializers/good_job.rb)
4. ✅ **Branchモデルのdefault_capacityカラム追加** (マイグレーション)
5. ✅ **Nexusデザイン統合** (グラスモーフィズム、アニメーション)
6. ✅ **カレンダー表示と時間選択機能** (2画面構成、1時間刻み、年末年始対応)
7. ✅ **テスト実装完了** (140 examples, 0 failures, 100% success rate)

**最終コミット**: `89541ca` - 2024年12月27日
**最新機能追加**: カレンダー表示・時間選択 - 2024年12月28日
**テスト状況**: 全140テスト成功（カレンダー機能完了）
**本番環境**: デプロイ準備完了

---

# よく使うコマンド（トップ10）

```bash
# 1. 開発サーバー起動（バックグラウンドジョブ含む）
bin/dev

# 2. 全テスト実行
bundle exec rspec

# 3. データベースのリセット
bin/rails db:reset

# 4. Slot初期データ生成（3ヶ月分）
bin/rails slots:generate_initial

# 5. コンソール起動
bin/rails console

# 6. ルート一覧確認
bin/rails routes

# 7. マイグレーション実行
bin/rails db:migrate

# 8. RuboCop実行（コードチェック）
bundle exec rubocop

# 9. 特定月のSlot生成
bin/rails slots:generate_month YEAR=2025 MONTH=3

# 10. ログ確認（リアルタイム）
tail -f log/development.log
```

---

# 📚 ドキュメント索引

プロジェクトの詳細情報は以下のドキュメントに整理されています。

## 設計・アーキテクチャ

- **[docs/ARCHITECTURE.md](docs/ARCHITECTURE.md)** - システム設計
  データモデル階層、Controller構造、Service Layer、セキュリティ、ディレクトリ構造

- **[docs/DATABASE.md](docs/DATABASE.md)** - データベース設計
  ER図、全テーブル定義、Slot自動生成システム、データフロー

- **[docs/FEATURES.md](docs/FEATURES.md)** - 機能仕様
  利用者向け機能、管理者向け機能、画面遷移、メールシステム、今後の拡張可能性

## 開発・運用

- **[docs/DEVELOPMENT.md](docs/DEVELOPMENT.md)** - 開発ガイド
  セットアップ手順、開発コマンド、テスト戦略、Coding Conventions、Troubleshooting

- **[docs/OPERATIONS.md](docs/OPERATIONS.md)** - 運用・デプロイ
  環境変数、デプロイチェックリスト、バックアップ、ログ管理、Git Workflow

## 実装履歴

- **[docs/HISTORY.md](docs/HISTORY.md)** - 実装履歴
  Phase 1-5の詳細実装手順、完了済み機能の参考資料

---

# Quick Start

新規開発者向けの初回セットアップ手順:

```bash
# 1. リポジトリのクローン
git clone [repository_url]
cd [project_name]

# 2. 依存関係のインストール
bundle install

# 3. データベースのセットアップ
bin/rails db:create db:migrate db:seed

# 4. Slot初期データ生成
bin/rails slots:generate_initial

# 5. スモークテストで動作確認
bundle exec rspec spec/system/reservations_smoke_spec.rb

# 6. 開発サーバー起動
bin/dev

# 7. ブラウザで動作確認
# http://localhost:3000 - 利用者画面
# http://localhost:3000/admin - 管理画面（admin/password）
```

詳細は **[docs/DEVELOPMENT.md](docs/DEVELOPMENT.md)** を参照してください。

---

# データモデル概要

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

詳細は **[docs/DATABASE.md](docs/DATABASE.md)** を参照してください。

---

# 主要機能フロー

## 利用者向けフロー

```
Public::HomeController (/)
  ↓
Reserve::StepsController
  - area (エリア選択)
  - branch (支店選択)
  - calendar (カレンダー表示)
  - time_selection (時間選択)
  - customer (顧客情報入力)
  ↓
Reserve::ConfirmController (確認画面)
  ↓
Reserve::CompleteController (完了画面)
```

## 管理者向けフロー

```
Basic認証
  ↓
Admin::BaseController
  ├─ Admin::DashboardController (ダッシュボード)
  ├─ Admin::AppointmentsController (予約管理)
  ├─ Admin::BranchesController (支店管理)
  └─ Admin::PrintsController (印刷)
```

詳細は **[docs/ARCHITECTURE.md](docs/ARCHITECTURE.md)** を参照してください。

---

**ドキュメントバージョン**: 3.0
**最終更新日**: 2024年12月
**ステータス**: 全機能実装完了
