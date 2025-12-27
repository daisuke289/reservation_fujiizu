require 'rails_helper'

RSpec.describe Branch, type: :model do
  describe 'associations' do
    it { should belong_to(:area) }
    it { should have_many(:slots).dependent(:destroy) }
    it { should have_many(:appointments).dependent(:destroy) }
  end
  
  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:address) }
    it { should validate_presence_of(:phone) }
    it { should validate_presence_of(:open_hours) }
    
    describe 'phone format' do
      let(:area) { Area.create!(name: '東部エリア') }
      
      it 'accepts valid 10-digit phone numbers' do
        branch = Branch.new(
          area: area,
          name: 'Sample Branch',
          address: 'Sample City',
          phone: '0544123456',
          open_hours: '平日 9:00-17:00'
        )
        expect(branch).to be_valid
      end
      
      it 'accepts valid 11-digit phone numbers' do
        branch = Branch.new(
          area: area,
          name: 'Sample Branch',
          address: 'Sample City',
          phone: '09012345678',
          open_hours: '平日 9:00-17:00'
        )
        expect(branch).to be_valid
      end
      
      it 'rejects phone numbers with less than 10 digits' do
        branch = Branch.new(
          area: area,
          name: 'Sample Branch',
          address: 'Sample City',
          phone: '123456789',
          open_hours: '平日 9:00-17:00'
        )
        expect(branch).not_to be_valid
        expect(branch.errors[:phone]).to include("は10〜11桁の数字で入力してください")
      end
      
      it 'rejects phone numbers with more than 11 digits' do
        branch = Branch.new(
          area: area,
          name: 'Sample Branch',
          address: 'Sample City',
          phone: '090123456789',
          open_hours: '平日 9:00-17:00'
        )
        expect(branch).not_to be_valid
        expect(branch.errors[:phone]).to include("は10〜11桁の数字で入力してください")
      end
      
      it 'rejects phone numbers with non-numeric characters' do
        branch = Branch.new(
          area: area,
          name: 'Sample Branch',
          address: 'Sample City',
          phone: '090-1234-5678',
          open_hours: '平日 9:00-17:00'
        )
        expect(branch).not_to be_valid
        expect(branch.errors[:phone]).to include("は10〜11桁の数字で入力してください")
      end
    end
  end
  
  describe 'basic CRUD' do
    let(:area) { Area.create!(name: '東部エリア') }
    
    it 'creates a valid branch' do
      branch = Branch.new(
        area: area,
        name: 'Sample Branch',
        address: 'Sample City',
        phone: '0544123456',
        open_hours: '平日 9:00-17:00'
      )
      expect(branch).to be_valid
    end
  end
end