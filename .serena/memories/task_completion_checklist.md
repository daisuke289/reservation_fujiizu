# タスク完了時のチェックリスト

## 実装完了の定義

実装が完了したと判断するには、以下の3つの条件を全て満たす必要があります：

### ✅ 1. テストが通っている
```bash
bundle exec rspec
```
- 全てのテストがパスすること
- テストDBは事前に準備しておく: `RAILS_ENV=test bin/rails db:drop db:create db:migrate`

### ✅ 2. RuboCopのエラーがない
```bash
bundle exec rubocop
```
- Lintエラーが0件であること
- 自動修正可能なものは `bundle exec rubocop -a` で修正する

### ✅ 3. Railsアプリが正常に動作する
```bash
bin/dev
```
- 開発サーバーが起動すること
- 主要な画面が表示されること
- 基本的な操作が動作すること

## 追加の確認事項

### セキュリティチェック（推奨）
```bash
bundle exec brakeman
```
- セキュリティの警告がないこと

### データベースマイグレーション
```bash
bin/rails db:migrate:status
```
- 全てのマイグレーションが `up` 状態であること

### GoodJobワーカー
```bash
ps aux | grep good_job
```
- バックグラウンドジョブが必要な機能の場合、ワーカーが起動していること

## コミット前の最終確認

1. **変更内容の確認**
   ```bash
   git status
   git diff
   ```

2. **テスト実行**
   ```bash
   bundle exec rspec
   ```

3. **Lint実行**
   ```bash
   bundle exec rubocop
   ```

4. **動作確認**
   - ブラウザで実際に動作を確認

5. **コミット**
   ```bash
   git add .
   git commit -m "Clear and descriptive commit message"
   ```

## Phase別の完了条件

### Phase 1完了後
- [ ] Branchテーブルにdefault_capacityカラムが追加されている
- [ ] 全てのBranchレコードがdefault_capacity = 1になっている

### Phase 2完了後
- [ ] holiday_jp gemがインストールされている
- [ ] SlotGeneratorService, SlotGeneratorJob, Rakeタスクが実装されている
- [ ] GoodJob cron設定が完了している（config/initializers/good_job.rb）
- [ ] 初回Slotデータが生成されている（bin/rails slots:generate_initial）

### Phase 3完了後
- [ ] Admin::BranchesControllerが実装されている
- [ ] 支店管理画面が正常に動作する
- [ ] ダッシュボードに支店管理へのリンクがある
