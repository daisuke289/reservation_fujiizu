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
      # 1月1日(元日)、4,5,11,12,13,18,19,25,26が休日
      # 31日中、土日が8日、祝日が1日（元日）で、22営業日
      branch_count = Branch.count
      expected_count = 22 * 13 * branch_count

      described_class.generate_for_month(2025, 1)

      january_slots = Slot.where(
        starts_at: Date.new(2025, 1, 1).beginning_of_day..Date.new(2025, 1, 31).end_of_day
      )

      expect(january_slots.count).to eq(expected_count)
    end

    it '土日祝日は除外される' do
      described_class.generate_for_month(2025, 1)

      # 土曜日のSlotがないことを確認
      saturday = Date.new(2025, 1, 4)
      saturday_slots = Slot.where(
        starts_at: saturday.beginning_of_day..saturday.end_of_day
      )
      expect(saturday_slots.count).to eq(0)

      # 日曜日のSlotがないことを確認
      sunday = Date.new(2025, 1, 5)
      sunday_slots = Slot.where(
        starts_at: sunday.beginning_of_day..sunday.end_of_day
      )
      expect(sunday_slots.count).to eq(0)

      # 元日のSlotがないことを確認
      new_year = Date.new(2025, 1, 1)
      new_year_slots = Slot.where(
        starts_at: new_year.beginning_of_day..new_year.end_of_day
      )
      expect(new_year_slots.count).to eq(0)
    end
  end
end
