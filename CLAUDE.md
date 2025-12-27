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

## Project Overview

富士伊豆農業協同組合の相続相談予約システム。高齢者向けの来店予約WebアプリケーションとバックオフィスでのA4印刷管理機能を提供。

- **Tech Stack**: Rails 8.0, PostgreSQL, Tailwind CSS, GoodJob, holiday_jp
- **Target Users**: 高齢者、遺族、農協組合員
- **Current Status**: ✅ **全機能実装完了・本番環境デプロイ可能**

### ✅ 実装完了機能（2024年12月完了）
1. ✅ **Slot自動生成システム** (SlotGeneratorService + SlotGeneratorJob + Rakeタスク)
2. ✅ **支店管理機能** (Admin::BranchesController + ビュー)
3. ✅ **GoodJob定期実行設定** (config/initializers/good_job.rb)
4. ✅ **Branchモデルのdefault_capacityカラム追加** (マイグレーション)
5. ✅ **Nexusデザイン統合** (グラスモーフィズム、アニメーション)
6. ✅ **テスト実装完了** (111 examples, 0 failures, 100% success rate)

**最終コミット**: `89541ca` - 2024年12月27日
**テスト状況**: 全111テスト成功（Phase 4完了）
**本番環境**: デプロイ準備完了

---

## Implementation Roadmap

**すべてのPhaseが完了しました（2024年12月27日）** ✅

以下は実装時のロードマップと手順の記録です。将来の機能追加の参考にしてください。

### Phase 1: データベーススキーマ更新 ✅ 完了

**目的**: Branchモデルにdefault_capacityカラムを追加

**実装内容**
1. マイグレーションファイル作成
2. Branchモデルのバリデーション追加
3. Seedデータの更新

**実装手順**
```bash
# 1. マイグレーション作成
bin/rails generate migration AddDefaultCapacityToBranches default_capacity:integer

# 2. マイグレーションファイル編集
# db/migrate/YYYYMMDDHHMMSS_add_default_capacity_to_branches.rb
class AddDefaultCapacityToBranches < ActiveRecord::Migration[8.0]
  def change
    add_column :branches, :default_capacity, :integer, default: 1, null: false
  end
end

# 3. マイグレーション実行
bin/rails db:migrate

# 4. Branchモデルにバリデーション追加
# app/models/branch.rb
validates :default_capacity, presence: true, numericality: { greater_than_or_equal_to: 1 }

# 5. Seedデータ更新（db/seeds.rb）
# Branch.create! に default_capacity: 1 を追加
```

**検証**
```bash
bin/rails console
> Branch.first.default_capacity
=> 1
```

---

### Phase 2: Slot自動生成システム ✅ 完了

**目的**: 月次でSlotを自動生成し、予約可能期間を管理

#### Step 2.1: holiday_jp gemのインストール

```bash
# Gemfile に追加
gem 'holiday_jp'

# インストール
bundle install
```

#### Step 2.2: SlotGeneratorService実装

**ファイル**: `app/services/slot_generator_service.rb`

```ruby
class SlotGeneratorService
  TIME_SLOTS = [
    ["09:00", "09:30"], ["09:30", "10:00"], ["10:00", "10:30"],
    ["10:30", "11:00"], ["11:00", "11:30"], ["11:30", "12:00"],
    # 昼休み 12:00-13:00 は除外
    ["13:00", "13:30"], ["13:30", "14:00"], ["14:00", "14:30"],
    ["14:30", "15:00"], ["15:00", "15:30"], ["15:30", "16:00"],
    ["16:00", "16:30"]
  ].freeze

  # 指定月の全営業日に対してSlot生成
  def self.generate_for_month(year, month)
    start_date = Date.new(year, month, 1)
    end_date = start_date.end_of_month

    Rails.logger.info "Generating slots for #{year}年#{month}月"

    slot_count = 0
    (start_date..end_date).each do |date|
      next unless business_day?(date)

      Branch.find_each do |branch|
        slot_count += generate_slots_for_branch(branch, date)
      end
    end

    Rails.logger.info "Generated #{slot_count} slots for #{year}年#{month}月"
    slot_count
  end

  # 特定の支店・日付に対してSlot生成
  def self.generate_slots_for_branch(branch, date)
    created_count = 0

    TIME_SLOTS.each do |start_time, end_time|
      starts_at = Time.zone.parse("#{date} #{start_time}")
      ends_at = Time.zone.parse("#{date} #{end_time}")

      # 既に存在する場合はスキップ
      next if Slot.exists?(branch_id: branch.id, starts_at: starts_at)

      Slot.create!(
        branch: branch,
        starts_at: starts_at,
        ends_at: ends_at,
        capacity: branch.default_capacity,
        booked_count: 0
      )
      created_count += 1
    end

    created_count
  end

  # 営業日判定
  def self.business_day?(date)
    return false if date.saturday?
    return false if date.sunday?
    return false if HolidayJp.holiday?(date)
    true
  end
end
```

#### Step 2.3: SlotGeneratorJob実装

**ファイル**: `app/jobs/slot_generator_job.rb`

```ruby
class SlotGeneratorJob < ApplicationJob
  queue_as :default

  def perform
    # 翌々月分のSlotを生成
    target_date = 2.months.from_now

    Rails.logger.info "SlotGeneratorJob started for #{target_date.strftime('%Y年%m月')}"

    slot_count = SlotGeneratorService.generate_for_month(
      target_date.year,
      target_date.month
    )

    Rails.logger.info "SlotGeneratorJob completed: #{slot_count} slots created"
  rescue StandardError => e
    Rails.logger.error "SlotGeneratorJob failed: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
    raise
  end
end
```

#### Step 2.4: Rakeタスク実装

**ファイル**: `lib/tasks/slots.rake`

```ruby
namespace :slots do
  desc "Generate initial slot data for 3 months (current + next 2 months)"
  task generate_initial: :environment do
    puts "Generating slots for 3 months..."

    today = Date.today
    total_slots = 0

    # 今月
    count = SlotGeneratorService.generate_for_month(today.year, today.month)
    puts "✓ Generated #{count} slots for #{today.strftime('%Y年%m月')}"
    total_slots += count

    # 翌月
    next_month = today.next_month
    count = SlotGeneratorService.generate_for_month(next_month.year, next_month.month)
    puts "✓ Generated #{count} slots for #{next_month.strftime('%Y年%m月')}"
    total_slots += count

    # 翌々月
    month_after_next = today.next_month.next_month
    count = SlotGeneratorService.generate_for_month(month_after_next.year, month_after_next.month)
    puts "✓ Generated #{count} slots for #{month_after_next.strftime('%Y年%m月')}"
    total_slots += count

    puts "\nDone! Total slots: #{total_slots}"
    puts "Database total: #{Slot.count}"
  end

  desc "Generate slots for a specific month (YEAR=2025 MONTH=3)"
  task generate_month: :environment do
    year = ENV['YEAR']&.to_i || Date.today.year
    month = ENV['MONTH']&.to_i || Date.today.month

    count = SlotGeneratorService.generate_for_month(year, month)
    puts "Generated #{count} slots for #{year}年#{month}月"
  end

  desc "Clear all future slots (use with caution)"
  task clear_future: :environment do
    count = Slot.where('starts_at > ?', Time.current).delete_all
    puts "Deleted #{count} future slots"
  end
end
```

#### Step 2.5: GoodJob定期実行設定

**ファイル**: `config/initializers/good_job.rb`

```ruby
Rails.application.configure do
  config.good_job.tap do |good_job|
    # 既存の設定...

    # 定期実行ジョブの設定
    good_job.cron = {
      generate_monthly_slots: {
        cron: "0 2 1 * *", # 毎月1日 深夜2:00
        class: "SlotGeneratorJob",
        description: "Generate slots for 2 months ahead"
      }
    }
  end
end
```

**検証**
```bash
# 初回データ生成
bin/rails slots:generate_initial

# 動作確認
bin/rails console
> Slot.where('starts_at >= ?', Date.today).group_by { |s| s.starts_at.to_date.strftime('%Y年%m月') }.transform_values(&:count)

# ジョブの手動実行テスト
> SlotGeneratorJob.perform_now
```

---

### Phase 3: 支店管理機能 ✅ 完了

**目的**: 管理画面から支店のdefault_capacityを変更可能にする

#### Step 3.1: ルーティング追加

**ファイル**: `config/routes.rb`

```ruby
namespace :admin do
  # ...existing routes...
  resources :branches, only: [:index, :edit, :update]
end
```

#### Step 3.2: コントローラー実装

**ファイル**: `app/controllers/admin/branches_controller.rb`

```ruby
class Admin::BranchesController < Admin::BaseController
  before_action :set_branch, only: [:edit, :update]

  def index
    @areas = Area.includes(:branches).order(:id)
  end

  def edit
  end

  def update
    if @branch.update(branch_params)
      redirect_to admin_branches_path,
        notice: "#{@branch.name}の情報を更新しました。新しいデフォルト定員は、今後生成されるSlotから適用されます。"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_branch
    @branch = Branch.find(params[:id])
  end

  def branch_params
    params.require(:branch).permit(:name, :address, :phone, :open_hours, :default_capacity)
  end
end
```

#### Step 3.3: ビュー実装

**ファイル**: `app/views/admin/branches/index.html.erb`

```erb
<div class="container mx-auto px-4 py-8">
  <div class="flex justify-between items-center mb-6">
    <h1 class="text-3xl font-bold">支店管理</h1>
    <%= link_to "ダッシュボードに戻る", admin_dashboard_path, class: "btn btn-secondary" %>
  </div>

  <% @areas.each do |area| %>
    <div class="mb-8">
      <h2 class="text-2xl font-semibold mb-4 text-gray-700"><%= area.name %></h2>

      <div class="bg-white shadow-md rounded-lg overflow-hidden">
        <table class="min-w-full divide-y divide-gray-200">
          <thead class="bg-gray-50">
            <tr>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">支店名</th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">住所</th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">電話番号</th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">デフォルト定員</th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">アクション</th>
            </tr>
          </thead>
          <tbody class="bg-white divide-y divide-gray-200">
            <% area.branches.each do |branch| %>
              <tr>
                <td class="px-6 py-4 whitespace-nowrap"><%= branch.name %></td>
                <td class="px-6 py-4"><%= branch.address %></td>
                <td class="px-6 py-4 whitespace-nowrap"><%= branch.phone %></td>
                <td class="px-6 py-4 whitespace-nowrap">
                  <span class="px-3 py-1 inline-flex text-sm leading-5 font-semibold rounded-full bg-blue-100 text-blue-800">
                    <%= branch.default_capacity %>名
                  </span>
                </td>
                <td class="px-6 py-4 whitespace-nowrap">
                  <%= link_to "編集", edit_admin_branch_path(branch), class: "text-blue-600 hover:text-blue-900" %>
                </td>
              </tr>
            <% end %>
          </tbody>
        </table>
      </div>
    </div>
  <% end %>
</div>
```

**ファイル**: `app/views/admin/branches/edit.html.erb`

```erb
<div class="container mx-auto px-4 py-8 max-w-2xl">
  <h1 class="text-3xl font-bold mb-6"><%= @branch.name %> - 編集</h1>

  <%= form_with model: @branch, url: admin_branch_path(@branch), method: :patch, local: true do |f| %>
    <% if @branch.errors.any? %>
      <div class="bg-red-50 border border-red-400 text-red-700 px-4 py-3 rounded mb-4">
        <h3 class="font-bold">エラーが発生しました</h3>
        <ul class="list-disc list-inside">
          <% @branch.errors.full_messages.each do |message| %>
            <li><%= message %></li>
          <% end %>
        </ul>
      </div>
    <% end %>

    <div class="mb-4">
      <%= f.label :name, "支店名", class: "block text-sm font-medium text-gray-700 mb-2" %>
      <%= f.text_field :name, class: "w-full px-3 py-2 border border-gray-300 rounded-md" %>
    </div>

    <div class="mb-4">
      <%= f.label :address, "住所", class: "block text-sm font-medium text-gray-700 mb-2" %>
      <%= f.text_field :address, class: "w-full px-3 py-2 border border-gray-300 rounded-md" %>
    </div>

    <div class="mb-4">
      <%= f.label :phone, "電話番号", class: "block text-sm font-medium text-gray-700 mb-2" %>
      <%= f.text_field :phone, class: "w-full px-3 py-2 border border-gray-300 rounded-md" %>
    </div>

    <div class="mb-4">
      <%= f.label :open_hours, "営業時間", class: "block text-sm font-medium text-gray-700 mb-2" %>
      <%= f.text_area :open_hours, rows: 3, class: "w-full px-3 py-2 border border-gray-300 rounded-md" %>
    </div>

    <div class="mb-6">
      <%= f.label :default_capacity, "デフォルト定員", class: "block text-sm font-medium text-gray-700 mb-2" %>
      <%= f.number_field :default_capacity, min: 1, class: "w-full px-3 py-2 border border-gray-300 rounded-md" %>
      <p class="text-sm text-gray-500 mt-1">
        ※ この設定は今後生成される新しいSlotに適用されます。既存のSlotには影響しません。
      </p>
    </div>

    <div class="flex gap-4">
      <%= f.submit "更新する", class: "bg-blue-600 text-white px-6 py-2 rounded-md hover:bg-blue-700" %>
      <%= link_to "キャンセル", admin_branches_path, class: "bg-gray-300 text-gray-700 px-6 py-2 rounded-md hover:bg-gray-400" %>
    </div>
  <% end %>
</div>
```

#### Step 3.4: ダッシュボードへのリンク追加

**ファイル**: `app/views/admin/dashboard/index.html.erb`

既存のダッシュボードに以下のリンクを追加：

```erb
<%= link_to "支店管理", admin_branches_path, class: "btn btn-primary" %>
```

---

### Phase 4: テスト実装 ✅ 完了

**達成**: 全111テスト成功（0 failures, 100% success rate）

#### Step 4.1: SlotGeneratorServiceのテスト

**ファイル**: `spec/services/slot_generator_service_spec.rb`

```ruby
require 'rails_helper'

RSpec.describe SlotGeneratorService do
  let(:branch) { create(:branch, default_capacity: 2) }

  describe '.business_day?' do
    it '平日はtrueを返す' do
      monday = Date.new(2025, 1, 6) # 月曜日
      expect(described_class.business_day?(monday)).to be true
    end

    it '土曜日はfalseを返す' do
      saturday = Date.new(2025, 1, 4)
      expect(described_class.business_day?(saturday)).to be false
    end

    it '日曜日はfalseを返す' do
      sunday = Date.new(2025, 1, 5)
      expect(described_class.business_day?(sunday)).to be false
    end

    it '祝日はfalseを返す' do
      new_year = Date.new(2025, 1, 1) # 元日
      expect(described_class.business_day?(new_year)).to be false
    end
  end

  describe '.generate_slots_for_branch' do
    let(:business_day) { Date.new(2025, 1, 6) } # 月曜日

    it '営業日に13個の時間枠を生成する' do
      expect {
        described_class.generate_slots_for_branch(branch, business_day)
      }.to change { Slot.count }.by(13)
    end

    it '生成されたSlotのcapacityはbranch.default_capacityと一致する' do
      described_class.generate_slots_for_branch(branch, business_day)
      expect(Slot.last.capacity).to eq(2)
    end

    it '既存のSlotは重複生成しない' do
      described_class.generate_slots_for_branch(branch, business_day)
      expect {
        described_class.generate_slots_for_branch(branch, business_day)
      }.not_to change { Slot.count }
    end
  end

  describe '.generate_for_month' do
    it '指定月の営業日分のSlotを生成する' do
      # 2025年1月は22営業日（土日祝を除く）
      # 22日 × 13枠/日 × 支店数
      branch_count = Branch.count
      expected_count = 22 * 13 * branch_count

      described_class.generate_for_month(2025, 1)

      january_slots = Slot.where(
        starts_at: Date.new(2025, 1, 1).beginning_of_day..Date.new(2025, 1, 31).end_of_day
      )

      expect(january_slots.count).to eq(expected_count)
    end
  end
end
```

#### Step 4.2: Admin::BranchesControllerのテスト

**ファイル**: `spec/requests/admin/branches_spec.rb`

```ruby
require 'rails_helper'

RSpec.describe "Admin::Branches", type: :request do
  let(:branch) { create(:branch, default_capacity: 1) }

  # Basic認証のヘルパー
  def basic_auth
    username = ENV.fetch('BASIC_AUTH_USER', 'admin')
    password = ENV.fetch('BASIC_AUTH_PASSWORD', 'password')
    { 'HTTP_AUTHORIZATION' => ActionController::HttpAuthentication::Basic.encode_credentials(username, password) }
  end

  describe "GET /admin/branches" do
    it "支店一覧が表示される" do
      get admin_branches_path, headers: basic_auth
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /admin/branches/:id/edit" do
    it "支店編集画面が表示される" do
      get edit_admin_branch_path(branch), headers: basic_auth
      expect(response).to have_http_status(:success)
    end
  end

  describe "PATCH /admin/branches/:id" do
    context "有効なパラメータの場合" do
      it "支店情報が更新される" do
        patch admin_branch_path(branch),
          params: { branch: { default_capacity: 3 } },
          headers: basic_auth

        expect(branch.reload.default_capacity).to eq(3)
        expect(response).to redirect_to(admin_branches_path)
      end
    end

    context "無効なパラメータの場合" do
      it "更新に失敗する" do
        patch admin_branch_path(branch),
          params: { branch: { default_capacity: 0 } },
          headers: basic_auth

        expect(branch.reload.default_capacity).to eq(1)
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end
end
```

---

### 実装の推奨順序まとめ ✅ 全完了

```
✅ 1. Phase 1（完了）
   ├─ Branchテーブルにdefault_capacityカラム追加
   ├─ マイグレーション実行
   └─ Seedデータ更新

✅ 2. Phase 2（完了）
   ├─ holiday_jp gem追加
   ├─ SlotGeneratorService実装
   ├─ SlotGeneratorJob実装
   ├─ Rakeタスク実装
   ├─ 初回データ生成（bin/rails slots:generate_initial）
   └─ GoodJob cron設定

✅ 3. Phase 3（完了）
   ├─ Admin::BranchesController実装
   ├─ ビュー実装
   └─ ダッシュボードへのリンク追加

✅ 4. Phase 4（完了）
   ├─ テスト実装（111 examples, 0 failures）
   └─ Nexusデザイン統合

実装完了日: 2024年12月27日
```

---

## Development Commands

### セットアップ

```bash
# 初回セットアップ
bundle install
bin/rails db:drop db:create db:migrate db:seed

# Slot初期データ生成（Phase 2完了後）
bin/rails slots:generate_initial

# データベースのリセット
bin/rails db:reset

# マイグレーションのみ実行
bin/rails db:migrate

# シードデータの再投入
bin/rails db:seed
```

### Slot管理コマンド（Phase 2完了後）

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

### サーバー起動

```bash
# 開発サーバー（バックグラウンドジョブ含む）
bin/dev

# Railsサーバーのみ
bin/rails server

# GoodJobワーカーのみ
bundle exec good_job start

# コンソール
bin/rails console
```

### テスト

```bash
# テストDBのセットアップ
RAILS_ENV=test bin/rails db:drop db:create db:migrate

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

# Phase 2完了後のテスト
bundle exec rspec spec/services/slot_generator_service_spec.rb
bundle exec rspec spec/requests/admin/branches_spec.rb
```

### デバッグ

```bash
# メール確認（開発環境）
# ブラウザで http://localhost:3000/letter_opener にアクセス

# ログ確認
tail -f log/development.log
tail -f log/test.log
tail -f log/good_job.log

# GoodJobダッシュボード
# config/routes.rb に mount GoodJob::Engine を追加後アクセス
# http://localhost:3000/good_job

# Slot生成ログ確認
tail -f log/development.log | grep SlotGenerator
```

### コードチェック

```bash
# RuboCop（Linter）
bundle exec rubocop

# 自動修正
bundle exec rubocop -a

# Brakeman（セキュリティチェック）
bundle exec brakeman

# Bundle Audit（脆弱性チェック）
bundle exec bundle-audit check --update
```

---

## Architecture Overview

### Data Model Hierarchy

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

**関連の詳細**
- Area: has_many :branches
- Branch: belongs_to :area, has_many :slots, has_many :appointments
  - **属性**: default_capacity (integer, default: 1)
- Slot: belongs_to :branch, has_many :appointments
  - **capacity**: 生成時にbranch.default_capacityを使用
- AppointmentType: has_many :appointments
- Appointment: belongs_to :branch, belongs_to :slot, belongs_to :appointment_type

### Slot Generation & Management

**予約可能期間**
- 月末区切りで2ヶ月後まで（常に3ヶ月分が利用可能）
- 例：12月中は12月・1月・2月の枠が表示
- 例：1月1日以降は1月・2月・3月の枠が表示

**自動生成の仕様**
- タイミング: 毎月1日 深夜2:00に翌々月分を自動生成
- ジョブ: SlotGeneratorJob（GoodJob cron）
- サービス: SlotGeneratorService

**休業日判定**
- holiday_jp gemによる祝日判定
- 土曜日・日曜日は予約枠なし
- 国民の祝日は予約枠なし

**営業時間**
- 9:00-12:00、13:00-16:30（30分刻み）
- 昼休み（12:00-13:00）は予約不可
- 1日あたり13個の時間枠

**定員管理**
- 各Slotのcapacityは生成時にbranch.default_capacityを使用
- 支店ごとにdefault_capacityを設定可能（管理画面）
- 既存Slotには影響せず、新規生成Slotから適用

### Controller Structure

**利用者向けフロー**
```
Public::HomeController (/)
  ↓
Reserve::StepsController
  - area (エリア選択)
  - branch (支店選択)
  - datetime (日時選択)
  - customer (顧客情報入力)
  ↓
Reserve::ConfirmController (確認画面)
  ↓
Reserve::CompleteController (完了画面)
```

**管理者向けフロー**
```
Basic認証
  ↓
Admin::BaseController
  ├─ Admin::DashboardController (ダッシュボード)
  ├─ Admin::AppointmentsController (予約管理)
  ├─ Admin::BranchesController (支店管理) ← Phase 3で実装
  └─ Admin::PrintsController (印刷)
```

### Service Layer

**AppointmentService**
- トランザクション管理
- 楽観的ロック（Slot#increment_booked_count!）
- 空き状況のリアルタイムチェック
- 重複予約防止（同一電話番号・同一日）
- メール送信ジョブのエンキュー

**SlotGeneratorService** ← Phase 2で実装
- 月次Slot生成ロジック
- 営業日判定（holiday_jp使用）
- 支店のdefault_capacityを使用した容量設定
- 重複チェック

**AppointmentMailer**
- 予約確認メール送信
- 受付番号付き件名
- 予約詳細の通知

### Session-based Wizard Flow

Multi-step reservation uses `session[:reservation]` to persist state across:

1. **Area/Branch selection** - `session[:reservation][:area_id]`, `session[:reservation][:branch_id]`
2. **Date/Time slot selection** - `session[:reservation][:slot_id]`
3. **Customer information input** - `session[:reservation][:customer_info]` (hash)
4. **Confirmation screen** - 全情報の確認
5. **Transaction completion** - AppointmentService経由で確定、セッションクリア

### Key Validations

**電話番号**
- 形式: `/\A\d{10,11}\z/`（10-11桁、ハイフンなし）
- 同一日の重複予約禁止（カスタムバリデーション）

**フリガナ**
- 形式: `/\A[ァ-ヶー・＝　]+\z/`（全角カタカナのみ）

**メールアドレス**
- URI::MailTo::EMAIL_REGEXP
- 必須項目（Phase 2で変更）

**来店人数**
- 1人以上の整数

**Slot容量チェック**
- `slot.remaining_capacity >= party_size`
- 楽観的ロックによる競合制御

**Branch default_capacity**
- 1以上の整数
- 必須項目

---

## Admin Features

### 認証

**Basic認証**
- ユーザー名: `ENV['BASIC_AUTH_USER']` || `'admin'`
- パスワード: `ENV['BASIC_AUTH_PASSWORD']` || `'password'`
- セキュリティ: `ActiveSupport::SecurityUtils.secure_compare`
- テスト環境では認証スキップ

### ダッシュボード

**統計情報**
- 本日の予約数
- 翌日の予約数
- 未確認予約数（booked status）

**クイックリスト**
- 本日の予約一覧（最大10件）
- 翌日の予約一覧（最大10件）
- 最近の予約（最新5件）

**ナビゲーション**
- 予約一覧
- 支店管理（Phase 3で追加）
- 印刷画面

### 予約管理

**フィルター**
- today, tomorrow, booked, visited, needs_followup, canceled
- branch_id, date_from, date_to

**検索**
- 氏名・電話番号（部分一致、大文字小文字区別なし）

**ページネーション**
- 20件/ページ（Kaminari）

**ステータス更新**
- booked → visited, needs_followup, canceled
- キャンセル時は自動的にslot.booked_countをデクリメント

**管理者メモ**
- admin_memoフィールドで内部メモを管理

### 支店管理（Phase 3で実装）

**一覧表示**
- 全支店の一覧
- エリア別グループ化
- 各支店の基本情報（名前、住所、電話、デフォルト定員）

**編集機能**
- 支店名
- 住所
- 電話番号
- 営業時間
- デフォルト定員（default_capacity）

**注意事項**
- default_capacityの変更は、変更後に生成される新しいSlotにのみ適用
- 既存Slotには影響しない
- 変更時にメッセージで明示

### 印刷機能

**印刷レイアウト**
- 日付指定（デフォルト: 当日）
- 支店別グループ化
- A4レイアウト（layout: 'print'）
- アクティブな予約のみ（status != canceled）

**印刷情報**
- 受付番号
- 予約時刻
- 氏名・フリガナ
- 電話番号
- 相談種別
- 来店人数
- 相談目的
- 備考
- 管理者メモ

---

## Email System

**GoodJob**
- バックグラウンドジョブプロセッサー
- データベースベース（PostgreSQL）
- リトライ機能（3回、多項式バックオフ）
- **定期実行機能（cron）** ← Phase 2で使用

**AppointmentMailJob**
- `AppointmentMailJob.perform_later(appointment.id)`
- エラーハンドリング（StandardError）
- ログ出力（送信成功・失敗）

**SlotGeneratorJob** ← Phase 2で実装
- 毎月1日深夜2:00に自動実行
- GoodJob cronで管理
- 翌々月分のSlot生成

**メールテンプレート**
- 件名: `【JAふじ伊豆】ご予約を承りました（受付番号: XXXXXX）`
- ビュー: `app/views/appointment_mailer/confirmed.html.erb`, `confirmed.text.erb`
- 差出人: `no-reply@example.com`（要設定変更）

**Localization**
- `config/locales/ja.yml` で日本語日時フォーマット定義

---

## Testing Strategy

### テストの種類

**モデルテスト（spec/models/）**
- バリデーションテスト
- アソシエーションテスト
- スコープテスト
- インスタンスメソッドテスト

**サービステスト（spec/services/）** ← Phase 4で実装
- SlotGeneratorService
  - business_day?の判定テスト
  - generate_slots_for_branchのテスト
  - generate_for_monthのテスト

**リクエストテスト（spec/requests/）** ← Phase 4で実装
- Admin::BranchesController
  - 一覧表示
  - 編集画面
  - 更新処理

**システムテスト（spec/system/）**
- `reservations_smoke_spec.rb`: 基本的なページアクセスとボタン存在確認
- `reservations_full_flow_spec.rb`: E2Eフルフローテスト
- rescue-based UI text flexibility（エラーメッセージの柔軟なマッチング）

**テストDB**
- 分離された test 環境
- `RAILS_ENV=test bin/rails db:drop db:create db:migrate` で完全リセット

### テストデータ

**FactoryBot（推奨）**
```ruby
# spec/factories/appointments.rb
FactoryBot.define do
  factory :appointment do
    association :branch
    association :slot
    association :appointment_type
    name { "テスト太郎" }
    furigana { "テストタロウ" }
    phone { "09012345678" }
    email { "test@example.com" }
    party_size { 1 }
    accept_privacy { true }
  end
end

# spec/factories/branches.rb (Phase 1で更新)
FactoryBot.define do
  factory :branch do
    association :area
    name { "テスト支店" }
    address { "静岡県テスト市1-2-3" }
    phone { "0551234567" }
    open_hours { "平日 9:00-16:30" }
    default_capacity { 1 }
  end
end
```

**使用例**
```ruby
let(:appointment) { create(:appointment) }
let(:slot) { create(:slot, capacity: 4, booked_count: 0) }
let(:branch) { create(:branch, default_capacity: 2) }
```

---

## Coding Conventions

### Rubyスタイル

- **インデント**: 2スペース
- **文字列**: ダブルクォート `"` 優先（補間が必要な場合）、シングルクォート `'` 可（固定文字列）
- **ハッシュ**: 新記法優先 `{ key: value }`
- **命名規則**:
  - クラス: PascalCase
  - メソッド/変数: snake_case
  - 定数: SCREAMING_SNAKE_CASE

### Railsベストプラクティス

**コントローラー**
- 1アクションは薄く保つ（ビジネスロジックはServiceクラスへ）
- Strong Parametersの徹底
- before_actionでの共通処理

**モデル**
- Fat Modelは避ける（適切にServiceクラスへ移譲）
- バリデーションは必須
- スコープの活用
- コールバックは最小限に

**ビュー**
- ロジックはヘルパーかPresenterへ
- Partial活用で再利用性を高める
- Form Objectの活用（複雑なフォームの場合）

**Service Object**
- 1クラス1責任
- トランザクション管理の明示
- エラーハンドリングの徹底
- ログ出力の充実

**命名規則**
- Service: `<Domain>Service` (例: AppointmentService, SlotGeneratorService)
- Job: `<Domain>Job` (例: AppointmentMailJob, SlotGeneratorJob)
- Mailer: `<Domain>Mailer` (例: AppointmentMailer)

### データベース

**マイグレーション**
- 可逆性を保つ（rollback可能に）
- インデックスの適切な設定
- 外部キー制約の明示
- デフォルト値とNULL制約の明示

**クエリ最適化**
- N+1クエリ回避（includes, preload, eager_load）
- 適切なスコープ使用
- pluckの活用（必要な属性のみ取得）

### セキュリティ

**認証・認可**
- 管理画面はBasic認証必須
- テスト環境以外では認証スキップ禁止

**バリデーション**
- クライアント側とサーバー側の両方で実施
- Strong Parametersの徹底

**SQLインジェクション対策**
- プレースホルダーの使用
- 生SQLは避ける

**CSRF対策**
- Rails標準のCSRF保護を有効化（デフォルト）

---

## Directory Structure

```
app/
├── controllers/
│   ├── admin/           # 管理画面コントローラー
│   │   ├── base_controller.rb
│   │   ├── dashboard_controller.rb
│   │   ├── appointments_controller.rb
│   │   ├── branches_controller.rb  ← Phase 3で追加
│   │   └── prints_controller.rb
│   ├── public/          # 公開ページコントローラー
│   ├── reserve/         # 予約フローコントローラー
│   └── application_controller.rb
├── models/              # モデル
│   ├── area.rb
│   ├── branch.rb  ← Phase 1でdefault_capacity追加
│   ├── slot.rb
│   ├── appointment.rb
│   └── appointment_type.rb
├── services/            # ビジネスロジック（サービスオブジェクト）
│   ├── appointment_service.rb
│   └── slot_generator_service.rb  ← Phase 2で追加
├── jobs/                # バックグラウンドジョブ
│   ├── appointment_mail_job.rb
│   └── slot_generator_job.rb  ← Phase 2で追加
├── mailers/             # メーラー
│   └── appointment_mailer.rb
├── views/
│   ├── admin/           # 管理画面ビュー
│   │   ├── dashboard/
│   │   ├── appointments/
│   │   ├── branches/  ← Phase 3で追加
│   │   │   ├── index.html.erb
│   │   │   └── edit.html.erb
│   │   └── prints/
│   ├── public/          # 公開ページビュー
│   ├── reserve/         # 予約フロービュー
│   ├── appointment_mailer/  # メールテンプレート
│   └── layouts/
│       ├── application.html.erb  # デフォルトレイアウト
│       ├── admin.html.erb        # 管理画面レイアウト
│       └── print.html.erb        # 印刷レイアウト
└── helpers/             # ビューヘルパー

config/
├── routes.rb            # ルーティング定義
├── database.yml         # DB接続設定
├── initializers/
│   └── good_job.rb  ← Phase 2でcron設定追加
└── locales/
    └── ja.yml           # 日本語ロケール

db/
├── migrate/             # マイグレーションファイル
│   └── YYYYMMDDHHMMSS_add_default_capacity_to_branches.rb  ← Phase 1で追加
├── schema.rb            # スキーマ定義（自動生成）
└── seeds.rb             # シードデータ

lib/
└── tasks/
    └── slots.rake  ← Phase 2で追加

spec/
├── models/              # モデルテスト
├── services/  ← Phase 4で追加
│   └── slot_generator_service_spec.rb
├── requests/  ← Phase 4で追加
│   └── admin/
│       └── branches_spec.rb
├── system/              # システムテスト（E2E）
├── factories/           # FactoryBot定義
│   ├── appointments.rb
│   ├── branches.rb  ← Phase 1で更新
│   └── ...
└── rails_helper.rb      # RSpec設定

docs/
├── design.md            # 設計仕様書
└── CLAUDE.md            # このファイル
```

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

---

## Deployment Checklist

本番環境デプロイ前の確認事項:

**Phase 1完了後**
- [ ] Branchテーブルにdefault_capacityカラムが追加されている
- [ ] 全てのBranchレコードがdefault_capacity = 1になっている

**Phase 2完了後**
- [ ] holiday_jp gemがインストールされている
- [ ] SlotGeneratorService, SlotGeneratorJob, Rakeタスクが実装されている
- [ ] GoodJob cron設定が完了している（config/initializers/good_job.rb）
- [ ] 初回Slotデータが生成されている（bin/rails slots:generate_initial）

**Phase 3完了後**
- [ ] Admin::BranchesControllerが実装されている
- [ ] 支店管理画面が正常に動作する
- [ ] ダッシュボードに支店管理へのリンクがある

**本番デプロイ時**
- [ ] 環境変数の設定（BASIC_AUTH, DATABASE_URL, SMTP設定等）
- [ ] `RAILS_ENV=production bin/rails db:migrate`
- [ ] `RAILS_ENV=production bin/rails db:seed`（初回のみ）
- [ ] `RAILS_ENV=production bin/rails slots:generate_initial`（初回のみ）
- [ ] GoodJob cron設定の確認（`config/initializers/good_job.rb`）
- [ ] `RAILS_ENV=production bin/rails assets:precompile`
- [ ] GoodJobワーカーの起動設定
- [ ] ログローテーション設定
- [ ] データベースバックアップの設定
- [ ] SSL証明書の設定
- [ ] Basic認証のパスワード変更
- [ ] メール送信元アドレスの変更（`app/mailers/appointment_mailer.rb`）

---

## Troubleshooting

### よくある問題と解決方法

**問題: メールが送信されない**
- GoodJobワーカーが起動しているか確認: `ps aux | grep good_job`
- SMTP設定を確認: `config/environments/development.rb` or `production.rb`
- ジョブキューを確認: `rails console` → `GoodJob::Job.count`

**問題: Slotが生成されない（Phase 2完了後）**
- GoodJobのcron設定を確認: `config/initializers/good_job.rb`
- GoodJobプロセスが起動しているか確認: `ps aux | grep good_job`
- ログを確認: `tail -f log/production.log | grep SlotGeneratorJob`
- 手動で生成を試す: `bin/rails slots:generate_month YEAR=2025 MONTH=1`
- holiday_jp gemがインストールされているか確認: `bundle list | grep holiday_jp`
- Branchにdefault_capacityが設定されているか確認: `Branch.pluck(:id, :default_capacity)`

**問題: 予約可能期間が正しく表示されない**
- Slotが正しく生成されているか確認: `bin/rails console` → `Slot.where('starts_at >= ?', Date.today).count`
- 月末までのSlotが存在するか確認: `Slot.where(starts_at: Date.today.beginning_of_month..Date.today.end_of_month).count`
- 3ヶ月分のSlotが存在するか確認: `Slot.where('starts_at >= ?', Date.today).group_by { |s| s.starts_at.strftime('%Y年%m月') }.keys`

**問題: 支店のdefault_capacityが更新されない（Phase 3完了後）**
- Strong Parametersで:default_capacityが許可されているか確認
- バリデーションエラーがないか確認: `branch.errors.full_messages`
- ログを確認: `tail -f log/development.log`

**問題: 予約が重複する**
- `slot.increment_booked_count!` でロックが取得されているか確認
- `appointments` テーブルの `phone + slot_id` ユニークインデックスを確認

**問題: テストが失敗する**
- テストDBをリセット: `RAILS_ENV=test bin/rails db:drop db:create db:migrate`
- FactoryBotの定義を確認（特にBranchのdefault_capacity）
- システムテストの場合、セレクタが変更されていないか確認

**問題: ページが表示されない**
- ルーティングを確認: `bin/rails routes | grep <path>`
- ログを確認: `tail -f log/development.log`
- Basic認証が正しく設定されているか確認（管理画面の場合）

---

## Useful Rails Commands

```bash
# ルート一覧
bin/rails routes

# 特定のコントローラーのルート
bin/rails routes -c admin/appointments
bin/rails routes -c admin/branches  # Phase 3完了後

# マイグレーション状態確認
bin/rails db:migrate:status

# ロールバック
bin/rails db:rollback
bin/rails db:rollback STEP=3

# コンソールでのデバッグ
bin/rails console
> Appointment.last
> Slot.available.count
> AppointmentService.new.create_appointment(params)

# Phase 2完了後のコンソール確認
> SlotGeneratorService.business_day?(Date.today)
> SlotGeneratorService.generate_for_month(2025, 1)
> Slot.where('starts_at >= ?', Date.today).group_by { |s| s.starts_at.strftime('%Y年%m月') }.transform_values(&:count)

# Phase 3完了後のコンソール確認
> Branch.first.default_capacity
> Branch.first.update(default_capacity: 3)

# データベースのクリーンアップ
bin/rails db:reset  # drop → create → migrate → seed
```

---

## Git Workflow

推奨されるGitワークフロー:

```bash
# Phase 1: default_capacity追加
git checkout -b feature/add-default-capacity-to-branches
# 実装...
git add .
git commit -m "Add default_capacity column to branches table"
git push origin feature/add-default-capacity-to-branches

# Phase 2: Slot自動生成
git checkout -b feature/add-slot-auto-generation
# 実装...
git commit -m "Add slot auto-generation system with GoodJob cron"
git push origin feature/add-slot-auto-generation

# Phase 3: 支店管理
git checkout -b feature/add-branch-management
# 実装...
git commit -m "Add branch management UI for admins"
git push origin feature/add-branch-management

# Phase 4: テスト追加
git checkout -b test/add-slot-generator-tests
# 実装...
git commit -m "Add tests for SlotGeneratorService and Admin::BranchesController"
git push origin test/add-slot-generator-tests

# main/masterブランチへのマージはPRレビュー後
```

**コミットメッセージ規約**
- 簡潔で明確に
- 英語推奨（日本語も可）
- プレフィックス: Add, Fix, Update, Remove, Refactor等
- Phase番号を含めると管理しやすい（例: "[Phase 2] Add SlotGeneratorService"）

---

## Additional Resources

- **Rails Guides**: https://guides.rubyonrails.org/
- **GoodJob Documentation**: https://github.com/bensheldon/good_job
- **GoodJob Cron**: https://github.com/bensheldon/good_job#cron-style-repeatingrecurring-jobs
- **holiday_jp**: https://github.com/holiday-jp/holiday_jp-ruby
- **Tailwind CSS**: https://tailwindcss.com/docs
- **RSpec**: https://rspec.info/
- **設計仕様書**: `docs/design.md`

---

## Quick Start Guide for New Developers

既存の機能を理解し、未実装機能の開発を始めるための手順:

```bash
# 1. リポジトリのクローン
git clone [repository_url]
cd [project_name]

# 2. 依存関係のインストール
bundle install

# 3. データベースのセットアップ
bin/rails db:create db:migrate db:seed

# 4. スモークテストで動作確認
bundle exec rspec spec/system/reservations_smoke_spec.rb

# 5. 開発サーバー起動
bin/dev

# 6. ブラウザで動作確認
# http://localhost:3000 - 利用者画面
# http://localhost:3000/admin - 管理画面（admin/password）

# 7. 未実装機能の確認
# このファイルの「Implementation Roadmap」セクションを参照

# 8. Phase 1から順に実装開始
```

---

**ドキュメントバージョン**: 2.0
**最終更新日**: 2024年12月
**未実装機能**: Phase 1-4（Implementation Roadmapを参照）
