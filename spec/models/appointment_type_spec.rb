require 'rails_helper'

RSpec.describe AppointmentType, type: :model do
  describe 'associations' do
    it { should have_many(:appointments).dependent(:restrict_with_error) }
  end
  
  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_uniqueness_of(:name) }
  end
  
  describe 'basic CRUD' do
    it 'creates a valid appointment type' do
      appointment_type = AppointmentType.new(name: '相談')
      expect(appointment_type).to be_valid
    end
    
    it 'is invalid without a name' do
      appointment_type = AppointmentType.new(name: nil)
      expect(appointment_type).not_to be_valid
      expect(appointment_type.errors[:name]).to include("を入力してください")
    end
    
    it 'is invalid with a duplicate name' do
      AppointmentType.create!(name: '相談')
      appointment_type = AppointmentType.new(name: '相談')
      expect(appointment_type).not_to be_valid
      expect(appointment_type.errors[:name]).to include("はすでに存在します")
    end
  end
  
  describe 'dependent restriction' do
    let(:appointment_type) { AppointmentType.create!(name: '相談') }
    let(:area) { Area.create!(name: '東部エリア') }
    let(:branch) { Branch.create!(
      area: area,
      name: '富士支店',
      address: '静岡県富士市',
      phone: '0544123456',
      open_hours: '平日 9:00-17:00'
    )}
    let(:slot) { Slot.create!(
      branch: branch,
      starts_at: 1.day.from_now,
      ends_at: 1.day.from_now + 1.hour,
      capacity: 5
    )}
    
    it 'cannot be deleted when appointments exist' do
      Appointment.create!(
        branch: branch,
        slot: slot,
        appointment_type: appointment_type,
        name: '山田太郎',
        furigana: 'ヤマダタロウ',
        phone: '09012345678',
        email: 'test@example.com',
        party_size: 1,
        accept_privacy: true
      )
      
      expect { appointment_type.destroy }.not_to change { AppointmentType.count }
      expect(appointment_type.errors[:base]).to include("関連するレコードが存在します")
    end
  end
end