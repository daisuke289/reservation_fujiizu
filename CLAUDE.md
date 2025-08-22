# 🚩 JAふじ伊豆 相続相談来店予約システム 開発ガイドライン

## 🎯 プロジェクト概要
- **目的**: 相続相談に関する来店予約をWeb経由で受け付け、支店・本部の事務負担を軽減
- **利用者層**: 遺族・代理人・組合員（高齢者多め）
- **開発スタック**: Ruby on Rails 8 + PostgreSQL + TailwindCSS
- **進行状況**: PROMPT E まで完了（利用者画面〜管理画面の基本フロー構築済）

---

## 📂 命名規約
| 対象 | 規約 |
|------|------|
| モデル | 単数形・先頭大文字 (e.g. `Appointment`) |
| テーブル | 複数形・スネークケース (e.g. `appointments`) |
| コントローラ | 複数形＋Controller (e.g. `AppointmentsController`) |
| ビュー | コントローラ名/アクション名に準拠 |
| サービス | `app/services` に配置、クラス名はCamelCase (e.g. `CalendarNotifier`) |
| パーシャル | `shared/_btn.html.erb` のように用途ごと |

---

## 🎨 UI 方針
- TailwindCSS を基本とし、複雑なCSSは極力避ける
- 共通パーシャルを活用（`shared/_btn.html.erb`, `shared/_card.html.erb`, `shared/_form_error.html.erb`）
- 高齢者配慮：文字大きめ、ボタン大きめ、余白広め
- PC: 横並び・グリッド、スマホ: 縦並び・アコーディオンを基本

---

## 🌐 i18n 方針
- 言語: `ja.yml` を基本
- キー規則: `views.controller.action.label` 形式
- モデル属性名・バリデーションメッセージも i18n に集約

---

## 🧪 テスト方針
- **RSpec + Capybara** を採用
- System Spec を重視（予約完了までのE2Eを担保）
- FactoryBot / Faker を使用
- 最低限のユニットテスト（バリデーション・サービスクラス）

---

## 🔐 認証/認可
- 管理画面 `/admin` に Basic 認証を導入
- ID/PASS は `.env` から読み込み
- Garoon連携は将来拡張のため `CalendarNotifier` サービスを先出し

---

## 📑 運用ルール
- **PR規約**: 1PR=1目的、小さく早く
- **コミットメッセージ**: Conventional Commits準拠 (feat/fix/chore/docs/test)
- **レビュー**: スクショ添付、未完は Draft PR

---

## 🗂️ 今後のロードマップ（残タスク）
1. **PROMPT F**: Seedデータ投入（8エリア/支店/スロット/種別）
2. **PROMPT G**: i18n & メール送信文面
3. **PROMPT H**: System Spec（E2Eと電話番号バリデーション）
4. **Garoon連携**: `CalendarNotifier` をAPI接続に差し替え
5. 本部向け集計ビュー + CSVエクスポート
6. CI整備（RSpec・Rubocop・Brakeman）

---
