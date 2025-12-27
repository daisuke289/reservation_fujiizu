# プロジェクト概要

## プロジェクト名
Sample Organization 相続相談予約システム

## 目的
高齢者向けの来店予約WebアプリケーションとバックオフィスでのA4印刷管理機能を提供する予約管理システム。

## 対象ユーザー
- 高齢者
- 遺族
- Organization members

## 主要機能

### 利用者向け機能
- 地区・支店選択
- 日時選択（30分単位）
- 相談種別選択（6種類）
- お客様情報入力
- 予約確認・完了
- 確認メール送信

### 管理者向け機能
- ダッシュボード（統計情報表示）
- 予約管理（検索・フィルタ・ステータス更新）
- 支店管理（Phase 3で実装予定）
- 印刷機能（A4レイアウト）
- 管理メモ機能

## データモデル
```
Area (8 regions)
  ↓
Branch (1 per area, default_capacity設定可能)
  ↓
Slot (30min intervals, capacity = branch.default_capacity)
  ↓
Appointment
  ↓
AppointmentType (6 consultation types)
```

## 未実装の重要機能
1. **Slot自動生成システム** (SlotGeneratorService + SlotGeneratorJob + Rakeタスク)
2. **支店管理機能** (Admin::BranchesController + ビュー)
3. **GoodJob定期実行設定** (config/initializers/good_job.rb)
4. **Branchモデルのdefault_capacityカラム追加** (マイグレーション)

詳細はCLAUDE.mdの「Implementation Roadmap」セクションを参照。
