# Implementation History

**すべてのPhaseが完了しました（2024年12月27日）** ✅

このドキュメントは実装時のロードマップと手順の記録です。将来の機能追加の参考にしてください。

---

## Phase 1: データベーススキーマ更新 ✅ 完了

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

## Phase 2: Slot自動生成システム ✅ 完了

**目的**: 月次でSlotを自動生成し、予約可能期間を管理

### Step 2.1: holiday_jp gemのインストール

```bash
# Gemfile に追加
gem 'holiday_jp'

# インストール
bundle install
```

### Step 2.2: SlotGeneratorService実装

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

### Step 2.3: SlotGeneratorJob実装

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

### Step 2.4: Rakeタスク実装

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

### Step 2.5: GoodJob定期実行設定

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

## Phase 3: 支店管理機能 ✅ 完了

**目的**: 管理画面から支店のdefault_capacityを変更可能にする

### Step 3.1: ルーティング追加

**ファイル**: `config/routes.rb`

```ruby
namespace :admin do
  # ...existing routes...
  resources :branches, only: [:index, :edit, :update]
end
```

### Step 3.2: コントローラー実装

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

### Step 3.3: ビュー実装

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

### Step 3.4: ダッシュボードへのリンク追加

**ファイル**: `app/views/admin/dashboard/index.html.erb`

既存のダッシュボードに以下のリンクを追加：

```erb
<%= link_to "支店管理", admin_branches_path, class: "btn btn-primary" %>
```

---

## Phase 4: テスト実装 ✅ 完了

**達成**: 全111テスト成功（0 failures, 100% success rate）

### Step 4.1: SlotGeneratorServiceのテスト

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

### Step 4.2: Admin::BranchesControllerのテスト

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

## Phase 5: カレンダー表示と時間選択機能 ✅ 完了

**実装日**: 2024年12月28日

**目的**: 予約日時選択を2画面構成に変更し、ユーザビリティを向上

**主な変更点**:
- 時間枠: 30分刻み（13枠/日）→ 1時間刻み（6枠/日）
- 営業時間: 9:00-16:30 → 9:00-15:00
- UI: リスト表示 → カレンダー表示 + 時間選択の2画面
- 年末年始: 12/30-1/3を休業日として追加
- 表示期間: 直近2週間 → 今月・来月のみ

**実装内容**

1. **SlotGeneratorService更新** (`app/services/slot_generator_service.rb`)
   - TIME_SLOTS定数を6枠に変更（1時間刻み）
   - year_end_new_year?メソッド追加（12/30-1/3判定）
   - business_day?メソッドに年末年始チェック追加

2. **ルーティング更新** (`config/routes.rb`)
   - `reserve_steps_datetime_path` 削除
   - `reserve_steps_calendar_path` 追加
   - `reserve_steps_time_selection_path` 追加

3. **コントローラー更新** (`app/controllers/reserve/steps_controller.rb`)
   - `datetime`アクション削除
   - `calendar`アクション追加（カレンダー表示）
   - `time_selection`アクション追加（時間選択）
   - `calculate_available_dates`プライベートメソッド追加

4. **ビュー作成**
   - `app/views/reserve/steps/calendar.html.erb`（カレンダーUI）
   - `app/views/reserve/steps/time_selection.html.erb`（時間選択UI）
   - `app/views/reserve/steps/datetime.html.erb` 削除

5. **テスト更新**
   - `spec/services/slot_generator_service_spec.rb`（年末年始、6枠対応）
   - `spec/requests/reserve/steps_spec.rb`（新規作成）
   - `spec/system/reservations_full_flow_spec.rb`（フロー更新）
   - テスト結果: 140 examples, 0 failures

6. **データ再生成**
   - 既存Slot全削除
   - 36,540個の新Slot生成（2025年12月〜2026年2月）

**実装手順**
```bash
# 1. データ削除
Appointment.destroy_all
Slot.destroy_all

# 2. SlotGeneratorService更新
# TIME_SLOTS, year_end_new_year?, business_day?を修正

# 3. データ再生成
bin/rails slots:generate_initial

# 4. ルーティング・コントローラー更新
# routes.rb, reserve/steps_controller.rb を編集

# 5. ビュー作成
# calendar.html.erb, time_selection.html.erb を新規作成
# datetime.html.erb を削除

# 6. テスト更新・実行
bundle exec rspec  # 140 examples, 0 failures
```

**検証**
```bash
bin/rails console
> Slot.count  # => 36540
> Slot.first.ends_at - Slot.first.starts_at  # => 3600.0 (1時間)
> SlotGeneratorService.year_end_new_year?(Date.new(2025, 12, 30))  # => true
```

---

## 実装の推奨順序まとめ ✅ 全完了

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

✅ 5. Phase 5（完了 - 2024年12月28日）
   ├─ SlotGeneratorService更新（30分→1時間、年末年始対応）
   ├─ カレンダー画面実装（calendar.html.erb）
   ├─ 時間選択画面実装（time_selection.html.erb）
   ├─ コントローラー更新（Reserve::StepsController）
   ├─ ルーティング更新（datetime削除、calendar/time_selection追加）
   ├─ テスト更新・追加（140 examples, 0 failures）
   └─ データ再生成（36,540 slots）

実装完了日: 2024年12月27日（Phase 1-4）、2024年12月28日（Phase 5）
```
