require 'rails_helper'

RSpec.describe Branch, type: :model do
  describe 'associations' do
    it { should belong_to(:area) }
    it { should have_many(:slots).dependent(:destroy) }
    it { should have_many(:appointments).dependent(:destroy) }
  end
  
  describe 'validations' do
    subject { build(:branch) }

    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:code) }
    it { should validate_uniqueness_of(:code).case_insensitive }
    it { should validate_presence_of(:address) }
    it { should validate_presence_of(:phone) }
    it { should validate_presence_of(:open_hours) }
    
    describe 'phone format' do
      let(:area) { Area.create!(name: '東部エリア', display_order: 1, is_active: true) }

      it 'accepts valid 10-digit phone numbers' do
        branch = Branch.new(
          area: area,
          code: '001',
          name: '富士支店',
          address: '静岡県富士市',
          phone: '0544123456',
          open_hours: '平日 9:00-17:00',
          default_capacity: 1
        )
        expect(branch).to be_valid
      end

      it 'accepts valid 11-digit phone numbers' do
        branch = Branch.new(
          area: area,
          code: '002',
          name: '富士支店',
          address: '静岡県富士市',
          phone: '09012345678',
          open_hours: '平日 9:00-17:00',
          default_capacity: 1
        )
        expect(branch).to be_valid
      end

      it 'rejects phone numbers with less than 10 digits' do
        branch = Branch.new(
          area: area,
          code: '003',
          name: '富士支店',
          address: '静岡県富士市',
          phone: '123456789',
          open_hours: '平日 9:00-17:00',
          default_capacity: 1
        )
        expect(branch).not_to be_valid
        expect(branch.errors[:phone]).to include("は10〜11桁の数字で入力してください")
      end

      it 'rejects phone numbers with more than 11 digits' do
        branch = Branch.new(
          area: area,
          code: '004',
          name: '富士支店',
          address: '静岡県富士市',
          phone: '090123456789',
          open_hours: '平日 9:00-17:00',
          default_capacity: 1
        )
        expect(branch).not_to be_valid
        expect(branch.errors[:phone]).to include("は10〜11桁の数字で入力してください")
      end

      it 'rejects phone numbers with non-numeric characters' do
        branch = Branch.new(
          area: area,
          code: '005',
          name: '富士支店',
          address: '静岡県富士市',
          phone: '090-1234-5678',
          open_hours: '平日 9:00-17:00',
          default_capacity: 1
        )
        expect(branch).not_to be_valid
        expect(branch.errors[:phone]).to include("は10〜11桁の数字で入力してください")
      end
    end
  end
  
  describe 'basic CRUD' do
    let(:area) { Area.create!(name: '東部エリア', display_order: 1, is_active: true) }

    it 'creates a valid branch' do
      branch = Branch.new(
        area: area,
        code: '101',
        name: '富士支店',
        address: '静岡県富士市',
        phone: '0544123456',
        open_hours: '平日 9:00-17:00',
        default_capacity: 1
      )
      expect(branch).to be_valid
    end

    it 'requires unique code' do
      Branch.create!(
        area: area,
        code: '101',
        name: '富士支店',
        address: '静岡県富士市',
        phone: '0544123456',
        open_hours: '平日 9:00-17:00',
        default_capacity: 1
      )
      duplicate_branch = Branch.new(
        area: area,
        code: '101',
        name: '沼津支店',
        address: '静岡県沼津市',
        phone: '0551234567',
        open_hours: '平日 9:00-17:00',
        default_capacity: 1
      )
      expect(duplicate_branch).not_to be_valid
      expect(duplicate_branch.errors[:code]).to include('はすでに存在します')
    end
  end
end