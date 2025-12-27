# コードスタイルと規約

## Rubyスタイル
- **インデント**: 2スペース
- **文字列**: ダブルクォート `"` 優先（補間が必要な場合）、シングルクォート `'` 可（固定文字列）
- **ハッシュ**: 新記法優先 `{ key: value }`
- **命名規則**:
  - クラス: PascalCase
  - メソッド/変数: snake_case
  - 定数: SCREAMING_SNAKE_CASE

## RuboCop設定
- **ベース**: rubocop-rails-omakase（Omakase Ruby styling for Rails）
- 設定ファイル: `.rubocop.yml`

## Railsベストプラクティス

### コントローラー
- 1アクションは薄く保つ（ビジネスロジックはServiceクラスへ）
- Strong Parametersの徹底
- before_actionでの共通処理

### モデル
- **Fat Modelは避ける**（適切にServiceクラスへ移譲）
- バリデーションは必須
- スコープの活用
- コールバックは最小限に

### ビュー
- ロジックはヘルパーかPresenterへ
- Partial活用で再利用性を高める
- Form Objectの活用（複雑なフォームの場合）

### Service Object
- 1クラス1責任（Single Responsibility）
- トランザクション管理の明示
- エラーハンドリングの徹底
- ログ出力の充実

### 命名規則
- Service: `<Domain>Service` (例: AppointmentService, SlotGeneratorService)
- Job: `<Domain>Job` (例: AppointmentMailJob, SlotGeneratorJob)
- Mailer: `<Domain>Mailer` (例: AppointmentMailer)

## データベース

### マイグレーション
- 可逆性を保つ（rollback可能に）
- インデックスの適切な設定
- 外部キー制約の明示
- デフォルト値とNULL制約の明示

### クエリ最適化
- N+1クエリ回避（includes, preload, eager_load）
- 適切なスコープ使用
- pluckの活用（必要な属性のみ取得）

## セキュリティ

### 認証・認可
- 管理画面はBasic認証必須
- テスト環境以外では認証スキップ禁止

### バリデーション
- クライアント側とサーバー側の両方で実施
- Strong Parametersの徹底

### SQLインジェクション対策
- プレースホルダーの使用
- 生SQLは避ける

### CSRF対策
- Rails標準のCSRF保護を有効化（デフォルト）

## 開発の基本理念
- **大きな変更より段階的な進捗**: テストを通過する小さな変更を積み重ねる
- **シンプルさが意味すること**: クラスやメソッドは単一責任を持つ
- **TDD**: Red -> Green -> Refactor のサイクルを厳守
- **アーキテクチャ**: Fat Model, Skinny Controller を心がける
