require 'rails_helper'

RSpec.describe Slot, type: :model do
  describe 'associations' do
    it { should belong_to(:branch) }
    it { should have_many(:appointments).dependent(:destroy) }
  end
  
  describe 'validations' do
    it { should validate_presence_of(:starts_at) }
    it { should validate_presence_of(:ends_at) }
    it { should validate_presence_of(:capacity) }
    it { should validate_numericality_of(:capacity).is_greater_than(0) }
    it { should validate_presence_of(:booked_count) }
    it { should validate_numericality_of(:booked_count).is_greater_than_or_equal_to(0) }
  end
  
  describe 'custom validations' do
    let(:area) { Area.create!(name: '東部エリア') }
    let(:branch) { Branch.create!(
      area: area,
      name: 'Sample Branch',
      address: 'Sample City',
      phone: '0544123456',
      open_hours: '平日 9:00-17:00'
    )}
    
    describe '#ends_at_after_starts_at' do
      it 'is valid when ends_at is after starts_at' do
        slot = Slot.new(
          branch: branch,
          starts_at: 1.day.from_now,
          ends_at: 1.day.from_now + 1.hour,
          capacity: 5
        )
        expect(slot).to be_valid
      end
      
      it 'is invalid when ends_at is before starts_at' do
        slot = Slot.new(
          branch: branch,
          starts_at: 1.day.from_now,
          ends_at: 1.day.from_now - 1.hour,
          capacity: 5
        )
        expect(slot).not_to be_valid
        expect(slot.errors[:ends_at]).to include("は開始時刻より後に設定してください")
      end
      
      it 'is invalid when ends_at equals starts_at' do
        time = 1.day.from_now
        slot = Slot.new(
          branch: branch,
          starts_at: time,
          ends_at: time,
          capacity: 5
        )
        expect(slot).not_to be_valid
        expect(slot.errors[:ends_at]).to include("は開始時刻より後に設定してください")
      end
    end
    
    describe '#booked_count_not_exceed_capacity' do
      it 'is valid when booked_count is less than capacity' do
        slot = Slot.new(
          branch: branch,
          starts_at: 1.day.from_now,
          ends_at: 1.day.from_now + 1.hour,
          capacity: 5,
          booked_count: 3
        )
        expect(slot).to be_valid
      end
      
      it 'is valid when booked_count equals capacity' do
        slot = Slot.new(
          branch: branch,
          starts_at: 1.day.from_now,
          ends_at: 1.day.from_now + 1.hour,
          capacity: 5,
          booked_count: 5
        )
        expect(slot).to be_valid
      end
      
      it 'is invalid when booked_count exceeds capacity' do
        slot = Slot.new(
          branch: branch,
          starts_at: 1.day.from_now,
          ends_at: 1.day.from_now + 1.hour,
          capacity: 5,
          booked_count: 6
        )
        expect(slot).not_to be_valid
        expect(slot.errors[:booked_count]).to include("は定員を超えることはできません")
      end
    end
  end
  
  describe 'scopes' do
    let(:area) { Area.create!(name: '東部エリア') }
    let(:branch) { Branch.create!(
      area: area,
      name: 'Sample Branch',
      address: 'Sample City',
      phone: '0544123456',
      open_hours: '平日 9:00-17:00'
    )}
    
    describe '.available' do
      it 'returns slots with available capacity' do
        available_slot = Slot.create!(
          branch: branch,
          starts_at: 1.day.from_now,
          ends_at: 1.day.from_now + 1.hour,
          capacity: 5,
          booked_count: 3
        )
        full_slot = Slot.create!(
          branch: branch,
          starts_at: 2.days.from_now,
          ends_at: 2.days.from_now + 1.hour,
          capacity: 5,
          booked_count: 5
        )
        
        expect(Slot.available).to include(available_slot)
        expect(Slot.available).not_to include(full_slot)
      end
    end
    
    describe '.future' do
      it 'returns only future slots' do
        future_slot = Slot.create!(
          branch: branch,
          starts_at: 1.day.from_now,
          ends_at: 1.day.from_now + 1.hour,
          capacity: 5
        )
        past_slot = Slot.create!(
          branch: branch,
          starts_at: 1.day.ago,
          ends_at: 1.day.ago + 1.hour,
          capacity: 5
        )
        
        expect(Slot.future).to include(future_slot)
        expect(Slot.future).not_to include(past_slot)
      end
    end
  end
  
  describe 'instance methods' do
    let(:area) { Area.create!(name: '東部エリア') }
    let(:branch) { Branch.create!(
      area: area,
      name: 'Sample Branch',
      address: 'Sample City',
      phone: '0544123456',
      open_hours: '平日 9:00-17:00'
    )}
    let(:slot) { Slot.create!(
      branch: branch,
      starts_at: 1.day.from_now,
      ends_at: 1.day.from_now + 1.hour,
      capacity: 5,
      booked_count: 3
    )}
    
    describe '#available?' do
      it 'returns true when slot has capacity' do
        expect(slot.available?).to be true
      end
      
      it 'returns false when slot is full' do
        slot.update!(booked_count: 5)
        expect(slot.available?).to be false
      end
    end
    
    describe '#full?' do
      it 'returns false when slot has capacity' do
        expect(slot.full?).to be false
      end
      
      it 'returns true when slot is full' do
        slot.update!(booked_count: 5)
        expect(slot.full?).to be true
      end
    end
    
    describe '#remaining_capacity' do
      it 'returns correct remaining capacity' do
        expect(slot.remaining_capacity).to eq(2)
      end
    end
    
    describe '#increment_booked_count!' do
      it 'increments booked_count' do
        expect { slot.increment_booked_count! }.to change { slot.reload.booked_count }.from(3).to(4)
      end
      
      it 'increments by specified count' do
        expect { slot.increment_booked_count!(2) }.to change { slot.reload.booked_count }.from(3).to(5)
      end
      
      it 'raises error when exceeding capacity' do
        expect { slot.increment_booked_count!(3) }.to raise_error("予約枠が満員です")
        expect(slot.reload.booked_count).to eq(3)
      end
    end
    
    describe '#decrement_booked_count!' do
      it 'decrements booked_count' do
        expect { slot.decrement_booked_count! }.to change { slot.reload.booked_count }.from(3).to(2)
      end
      
      it 'decrements by specified count' do
        expect { slot.decrement_booked_count!(2) }.to change { slot.reload.booked_count }.from(3).to(1)
      end
      
      it 'raises error when going below zero' do
        expect { slot.decrement_booked_count!(4) }.to raise_error("予約数が不正です")
        expect(slot.reload.booked_count).to eq(3)
      end
    end
  end
end