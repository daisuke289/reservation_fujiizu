require 'rails_helper'

RSpec.describe SlotGeneratorService do
  let(:branch) { create(:branch, default_capacity: 2) }

  describe '.year_end_new_year?' do
    it '12月30日はtrueを返す' do
      expect(described_class.year_end_new_year?(Date.new(2025, 12, 30))).to be true
    end

    it '12月31日はtrueを返す' do
      expect(described_class.year_end_new_year?(Date.new(2025, 12, 31))).to be true
    end

    it '1月1日はtrueを返す' do
      expect(described_class.year_end_new_year?(Date.new(2025, 1, 1))).to be true
    end

    it '1月2日はtrueを返す' do
      expect(described_class.year_end_new_year?(Date.new(2025, 1, 2))).to be true
    end

    it '1月3日はtrueを返す' do
      expect(described_class.year_end_new_year?(Date.new(2025, 1, 3))).to be true
    end

    it '1月4日はfalseを返す' do
      expect(described_class.year_end_new_year?(Date.new(2025, 1, 4))).to be false
    end

    it '12月29日はfalseを返す' do
      expect(described_class.year_end_new_year?(Date.new(2025, 12, 29))).to be false
    end
  end

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

    it '年末年始（12/30）はfalseを返す' do
      year_end = Date.new(2025, 12, 30)
      expect(described_class.business_day?(year_end)).to be false
    end

    it '年末年始（1/1）はfalseを返す' do
      new_year = Date.new(2025, 1, 1)
      expect(described_class.business_day?(new_year)).to be false
    end

    it '年末年始（1/3）はfalseを返す' do
      new_year_3 = Date.new(2025, 1, 3)
      expect(described_class.business_day?(new_year_3)).to be false
    end
  end

  describe '.generate_slots_for_branch' do
    let(:business_day) { Date.new(2025, 1, 6) } # 月曜日

    it '営業日に6個の時間枠を生成する' do
      expect {
        described_class.generate_slots_for_branch(branch, business_day)
      }.to change { Slot.count }.by(6)
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
      # 2025年1月は土日祝・年末年始を除いて営業日を計算
      # 31日中、土日が9日、祝日が2日（元日・成人の日）、年末年始が2日（1/2, 1/3）
      # 営業日: 31 - 9 - 2 - 2 = 18営業日
      # 18日 × 6枠/日 × 支店数
      branch_count = Branch.count
      expected_count = 18 * 6 * branch_count

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
