require 'rails_helper'

RSpec.describe Area, type: :model do
  describe 'associations' do
    it { should have_many(:branches).dependent(:destroy) }
  end

  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_uniqueness_of(:name) }
    it { should validate_presence_of(:display_order) }
    it { should validate_numericality_of(:display_order).only_integer.is_greater_than_or_equal_to(0) }

    it 'validates is_active is boolean' do
      area = build(:area, is_active: nil)
      expect(area).not_to be_valid
      expect(area.errors[:is_active]).to be_present
    end
  end

  describe 'scopes' do
    let!(:active_area1) { create(:area, name: 'A地区', display_order: 2, is_active: true) }
    let!(:active_area2) { create(:area, name: 'B地区', display_order: 1, is_active: true) }
    let!(:inactive_area) { create(:area, name: 'C地区', display_order: 3, is_active: false) }

    describe '.active' do
      it '有効なエリアのみを返す' do
        expect(Area.active).to contain_exactly(active_area1, active_area2)
      end
    end

    describe '.ordered' do
      it 'display_order順に並ぶ' do
        expect(Area.ordered).to eq([active_area2, active_area1, inactive_area])
      end
    end

    describe '.active_ordered' do
      it '有効かつ順序付き' do
        expect(Area.active_ordered).to eq([active_area2, active_area1])
      end
    end
  end

  describe '#jurisdiction_list' do
    it 'カンマ区切りを配列に変換' do
      area = build(:area, jurisdiction: '下田市、河津町、松崎町')
      expect(area.jurisdiction_list).to eq(['下田市', '河津町', '松崎町'])
    end

    it '半角カンマにも対応' do
      area = build(:area, jurisdiction: '三島市,函南町')
      expect(area.jurisdiction_list).to eq(['三島市', '函南町'])
    end

    it 'jurisdiction が nil の場合は空配列' do
      area = build(:area, jurisdiction: nil)
      expect(area.jurisdiction_list).to eq([])
    end

    it 'jurisdiction が空文字の場合は空配列' do
      area = build(:area, jurisdiction: '')
      expect(area.jurisdiction_list).to eq([])
    end
  end

  describe 'basic CRUD' do
    it 'creates a valid area with all fields' do
      area = Area.new(
        name: '伊豆太陽地区',
        jurisdiction: '下田市、河津町',
        display_order: 1,
        is_active: true
      )
      expect(area).to be_valid
    end

    it 'creates a valid area without jurisdiction' do
      area = Area.new(
        name: '伊豆太陽地区',
        display_order: 1,
        is_active: true
      )
      expect(area).to be_valid
    end

    it 'is invalid without a name' do
      area = Area.new(name: nil, display_order: 1)
      expect(area).not_to be_valid
      expect(area.errors[:name]).to include("を入力してください")
    end

    it 'is invalid with a duplicate name' do
      Area.create!(name: '東部エリア', display_order: 1)
      area = Area.new(name: '東部エリア', display_order: 2)
      expect(area).not_to be_valid
      expect(area.errors[:name]).to include("はすでに存在します")
    end
  end
end
