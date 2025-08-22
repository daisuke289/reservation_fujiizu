require 'rails_helper'

RSpec.describe Area, type: :model do
  describe 'associations' do
    it { should have_many(:branches).dependent(:destroy) }
  end
  
  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_uniqueness_of(:name) }
  end
  
  describe 'basic CRUD' do
    it 'creates a valid area' do
      area = Area.new(name: '東部エリア')
      expect(area).to be_valid
    end
    
    it 'is invalid without a name' do
      area = Area.new(name: nil)
      expect(area).not_to be_valid
      expect(area.errors[:name]).to include("を入力してください")
    end
    
    it 'is invalid with a duplicate name' do
      Area.create!(name: '東部エリア')
      area = Area.new(name: '東部エリア')
      expect(area).not_to be_valid
      expect(area.errors[:name]).to include("はすでに存在します")
    end
  end
end