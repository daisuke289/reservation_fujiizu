require "rails_helper"

RSpec.describe Appointment, type: :model do
  let!(:area)   { Area.create!(name: "テスト地区") }
  let!(:branch) { Branch.create!(area:, name: "テスト支店", address: "住所", phone: "05599900000", open_hours: "平日") }
  let!(:atype)  { AppointmentType.create!(name: "事前相談") }
  let!(:slot)   { Slot.create!(branch:, starts_at: Time.zone.parse("2099-01-01 10:00"), ends_at: Time.zone.parse("2099-01-01 10:30"), capacity: 4, booked_count: 0) }

  it "電話は10〜11桁の数字のみで有効" do
    a = Appointment.new(
      branch:, slot:, appointment_type: atype,
      name: "山田太郎", furigana: "ヤマダタロウ", phone: "09012345678", accept_privacy: true
    )
    expect(a).to be_valid
  end

  it "9桁以下は無効" do
    a = Appointment.new(
      branch:, slot:, appointment_type: atype,
      name: "山田太郎", furigana: "ヤマダタロウ", phone: "09012345", accept_privacy: true
    )
    expect(a).to be_invalid
  end

  it "数字以外が混ざると無効" do
    a = Appointment.new(
      branch:, slot:, appointment_type: atype,
      name: "山田太郎", furigana: "ヤマダタロウ", phone: "090-1234-5678", accept_privacy: true
    )
    expect(a).to be_invalid
  end

  it "同一電話・同一日で重複予約は無効（仕様に合わせて実装必須）" do
    Appointment.create!(
      branch:, slot:, appointment_type: atype,
      name: "山田太郎", furigana: "ヤマダタロウ", phone: "09012345678", accept_privacy: true
    )
    another_slot_same_day = Slot.create!(branch:, starts_at: Time.zone.parse("2099-01-01 11:00"), ends_at: Time.zone.parse("2099-01-01 11:30"), capacity: 4, booked_count: 0)

    dup = Appointment.new(
      branch:, slot: another_slot_same_day, appointment_type: atype,
      name: "山田次郎", furigana: "ヤマダジロウ", phone: "09012345678", accept_privacy: true
    )

    # モデル側で同日重複を弾くバリデーション/スコープを実装しておくこと
    expect(dup).to be_invalid
  end

  describe 'associations' do
    it { should belong_to(:branch) }
    it { should belong_to(:slot) }
    it { should belong_to(:appointment_type) }
  end
  
  describe 'enums' do
    it { should define_enum_for(:status).with_values(
      booked: 0,
      visited: 1,
      needs_followup: 2,
      canceled: 3
    ).with_prefix(false).backed_by_column_of_type(:integer) }
  end
  
  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:furigana) }
    it { should validate_presence_of(:phone) }
    it { should validate_presence_of(:party_size) }
    it { should validate_numericality_of(:party_size).is_greater_than(0) }
    it { should validate_acceptance_of(:accept_privacy) }
    
    describe 'furigana format' do
      let(:area) { Area.create!(name: '東部エリア') }
      let(:branch) { Branch.create!(
        area: area,
        name: '富士支店',
        address: '静岡県富士市',
        phone: '0544123456',
        open_hours: '平日 9:00-17:00'
      )}
      let(:appointment_type) { AppointmentType.create!(name: '相談') }
      let(:slot) { Slot.create!(
        branch: branch,
        starts_at: 1.day.from_now,
        ends_at: 1.day.from_now + 1.hour,
        capacity: 5
      )}
      
      it 'accepts valid katakana' do
        appointment = Appointment.new(
          branch: branch,
          slot: slot,
          appointment_type: appointment_type,
          name: '山田太郎',
          furigana: 'ヤマダタロウ',
          phone: '09012345678',
          party_size: 1,
          accept_privacy: true
        )
        expect(appointment).to be_valid
      end
      
      it 'accepts katakana with space' do
        appointment = Appointment.new(
          branch: branch,
          slot: slot,
          appointment_type: appointment_type,
          name: '山田太郎',
          furigana: 'ヤマダ　タロウ',
          phone: '09012345678',
          party_size: 1,
          accept_privacy: true
        )
        expect(appointment).to be_valid
      end
      
      it 'accepts katakana with long vowel mark' do
        appointment = Appointment.new(
          branch: branch,
          slot: slot,
          appointment_type: appointment_type,
          name: '佐藤',
          furigana: 'サトー',
          phone: '09012345678',
          party_size: 1,
          accept_privacy: true
        )
        expect(appointment).to be_valid
      end
      
      it 'rejects hiragana' do
        appointment = Appointment.new(
          branch: branch,
          slot: slot,
          appointment_type: appointment_type,
          name: '山田太郎',
          furigana: 'やまだたろう',
          phone: '09012345678',
          party_size: 1,
          accept_privacy: true
        )
        expect(appointment).not_to be_valid
        expect(appointment.errors[:furigana]).to include("は全角カタカナで入力してください")
      end
      
      it 'rejects mixed characters' do
        appointment = Appointment.new(
          branch: branch,
          slot: slot,
          appointment_type: appointment_type,
          name: '山田太郎',
          furigana: 'ヤマダ太郎',
          phone: '09012345678',
          party_size: 1,
          accept_privacy: true
        )
        expect(appointment).not_to be_valid
        expect(appointment.errors[:furigana]).to include("は全角カタカナで入力してください")
      end
    end
    
    describe 'phone format' do
      let(:area) { Area.create!(name: '東部エリア') }
      let(:branch) { Branch.create!(
        area: area,
        name: '富士支店',
        address: '静岡県富士市',
        phone: '0544123456',
        open_hours: '平日 9:00-17:00'
      )}
      let(:appointment_type) { AppointmentType.create!(name: '相談') }
      let(:slot) { Slot.create!(
        branch: branch,
        starts_at: 1.day.from_now,
        ends_at: 1.day.from_now + 1.hour,
        capacity: 5
      )}
      
      it 'accepts 10-digit phone numbers' do
        appointment = Appointment.new(
          branch: branch,
          slot: slot,
          appointment_type: appointment_type,
          name: '山田太郎',
          furigana: 'ヤマダタロウ',
          phone: '0544123456',
          party_size: 1,
          accept_privacy: true
        )
        expect(appointment).to be_valid
      end
      
      it 'accepts 11-digit phone numbers' do
        appointment = Appointment.new(
          branch: branch,
          slot: slot,
          appointment_type: appointment_type,
          name: '山田太郎',
          furigana: 'ヤマダタロウ',
          phone: '09012345678',
          party_size: 1,
          accept_privacy: true
        )
        expect(appointment).to be_valid
      end
      
      it 'rejects invalid phone numbers' do
        appointment = Appointment.new(
          branch: branch,
          slot: slot,
          appointment_type: appointment_type,
          name: '山田太郎',
          furigana: 'ヤマダタロウ',
          phone: '090-1234-5678',
          party_size: 1,
          accept_privacy: true
        )
        expect(appointment).not_to be_valid
        expect(appointment.errors[:phone]).to include("は10〜11桁の数字で入力してください")
      end
    end
    
    describe 'email format' do
      let(:area) { Area.create!(name: '東部エリア') }
      let(:branch) { Branch.create!(
        area: area,
        name: '富士支店',
        address: '静岡県富士市',
        phone: '0544123456',
        open_hours: '平日 9:00-17:00'
      )}
      let(:appointment_type) { AppointmentType.create!(name: '相談') }
      let(:slot) { Slot.create!(
        branch: branch,
        starts_at: 1.day.from_now,
        ends_at: 1.day.from_now + 1.hour,
        capacity: 5
      )}
      
      it 'accepts valid email' do
        appointment = Appointment.new(
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
        expect(appointment).to be_valid
      end
      
      it 'accepts blank email' do
        appointment = Appointment.new(
          branch: branch,
          slot: slot,
          appointment_type: appointment_type,
          name: '山田太郎',
          furigana: 'ヤマダタロウ',
          phone: '09012345678',
          email: '',
          party_size: 1,
          accept_privacy: true
        )
        expect(appointment).to be_valid
      end
      
      it 'rejects invalid email' do
        appointment = Appointment.new(
          branch: branch,
          slot: slot,
          appointment_type: appointment_type,
          name: '山田太郎',
          furigana: 'ヤマダタロウ',
          phone: '09012345678',
          email: 'invalid-email',
          party_size: 1,
          accept_privacy: true
        )
        expect(appointment).not_to be_valid
        expect(appointment.errors[:email]).to include("の形式が正しくありません")
      end
    end
  end
  
  describe 'custom validations' do
    let(:area) { Area.create!(name: '東部エリア') }
    let(:branch) { Branch.create!(
      area: area,
      name: '富士支店',
      address: '静岡県富士市',
      phone: '0544123456',
      open_hours: '平日 9:00-17:00'
    )}
    let(:appointment_type) { AppointmentType.create!(name: '相談') }
    let(:slot) { Slot.create!(
      branch: branch,
      starts_at: 1.day.from_now,
      ends_at: 1.day.from_now + 1.hour,
      capacity: 5,
      booked_count: 0
    )}
    
    describe 'duplicate appointment prevention' do
      it 'prevents duplicate appointments on the same day with same phone' do
        Appointment.create!(
          branch: branch,
          slot: slot,
          appointment_type: appointment_type,
          name: '山田太郎',
          furigana: 'ヤマダタロウ',
          phone: '09012345678',
          party_size: 1,
          accept_privacy: true
        )
        
        # 同じ日の別の時間帯のスロット
        another_slot = Slot.create!(
          branch: branch,
          starts_at: 1.day.from_now + 2.hours,
          ends_at: 1.day.from_now + 3.hours,
          capacity: 5
        )
        
        duplicate_appointment = Appointment.new(
          branch: branch,
          slot: another_slot,
          appointment_type: appointment_type,
          name: '山田花子',
          furigana: 'ヤマダハナコ',
          phone: '09012345678',
          party_size: 1,
          accept_privacy: true
        )
        
        expect(duplicate_appointment).not_to be_valid
        expect(duplicate_appointment.errors[:base]).to include("同じ電話番号で同日の予約が既に存在します")
      end
      
      it 'allows appointments on different days with same phone' do
        Appointment.create!(
          branch: branch,
          slot: slot,
          appointment_type: appointment_type,
          name: '山田太郎',
          furigana: 'ヤマダタロウ',
          phone: '09012345678',
          party_size: 1,
          accept_privacy: true
        )
        
        # 別の日のスロット
        another_slot = Slot.create!(
          branch: branch,
          starts_at: 2.days.from_now,
          ends_at: 2.days.from_now + 1.hour,
          capacity: 5
        )
        
        another_appointment = Appointment.new(
          branch: branch,
          slot: another_slot,
          appointment_type: appointment_type,
          name: '山田太郎',
          furigana: 'ヤマダタロウ',
          phone: '09012345678',
          party_size: 1,
          accept_privacy: true
        )
        
        expect(another_appointment).to be_valid
      end
    end
    
    describe 'slot capacity validation' do
      it 'validates slot has enough capacity' do
        slot.update!(booked_count: 4)
        
        appointment = Appointment.new(
          branch: branch,
          slot: slot,
          appointment_type: appointment_type,
          name: '山田太郎',
          furigana: 'ヤマダタロウ',
          phone: '09012345678',
          party_size: 2,
          accept_privacy: true
        )
        
        expect(appointment).not_to be_valid
        expect(appointment.errors[:base]).to include("予約枠の残り定員が不足しています")
      end
    end
  end
  
  describe 'callbacks' do
    let(:area) { Area.create!(name: '東部エリア') }
    let(:branch) { Branch.create!(
      area: area,
      name: '富士支店',
      address: '静岡県富士市',
      phone: '0544123456',
      open_hours: '平日 9:00-17:00'
    )}
    let(:appointment_type) { AppointmentType.create!(name: '相談') }
    let(:slot) { Slot.create!(
      branch: branch,
      starts_at: 1.day.from_now,
      ends_at: 1.day.from_now + 1.hour,
      capacity: 5,
      booked_count: 0
    )}
    
    describe 'slot booked_count management' do
      it 'increments slot booked_count on create' do
        expect {
          Appointment.create!(
            branch: branch,
            slot: slot,
            appointment_type: appointment_type,
            name: '山田太郎',
            furigana: 'ヤマダタロウ',
            phone: '09012345678',
            party_size: 2,
            accept_privacy: true
          )
        }.to change { slot.reload.booked_count }.from(0).to(2)
      end
      
      it 'decrements slot booked_count when status changes to canceled' do
        appointment = Appointment.create!(
          branch: branch,
          slot: slot,
          appointment_type: appointment_type,
          name: '山田太郎',
          furigana: 'ヤマダタロウ',
          phone: '09012345678',
          party_size: 2,
          accept_privacy: true
        )
        
        expect {
          appointment.update!(status: :canceled)
        }.to change { slot.reload.booked_count }.from(2).to(0)
      end
    end
  end
  
  describe 'instance methods' do
    let(:area) { Area.create!(name: '東部エリア') }
    let(:branch) { Branch.create!(
      area: area,
      name: '富士支店',
      address: '静岡県富士市',
      phone: '0544123456',
      open_hours: '平日 9:00-17:00'
    )}
    let(:appointment_type) { AppointmentType.create!(name: '相談') }
    let(:slot) { Slot.create!(
      branch: branch,
      starts_at: DateTime.parse('2024-12-25 14:00:00'),
      ends_at: DateTime.parse('2024-12-25 15:00:00'),
      capacity: 5,
      booked_count: 0
    )}
    let(:appointment) { Appointment.create!(
      branch: branch,
      slot: slot,
      appointment_type: appointment_type,
      name: '山田太郎',
      furigana: 'ヤマダタロウ',
      phone: '09012345678',
      party_size: 1,
      accept_privacy: true
    )}
    
    describe '#appointment_date' do
      it 'returns the date of the appointment' do
        expect(appointment.appointment_date).to eq(Date.parse('2024-12-25'))
      end
    end
    
    describe '#appointment_time' do
      it 'returns formatted time range' do
        expect(appointment.appointment_time).to eq('14:00 - 15:00')
      end
    end
    
    describe '#can_cancel?' do
      it 'returns true for future booked appointments' do
        allow(Time).to receive(:current).and_return(DateTime.parse('2024-12-24 10:00:00'))
        expect(appointment.can_cancel?).to be true
      end
      
      it 'returns false for past appointments' do
        allow(Time).to receive(:current).and_return(DateTime.parse('2024-12-26 10:00:00'))
        expect(appointment.can_cancel?).to be false
      end
      
      it 'returns false for already canceled appointments' do
        appointment.update!(status: :canceled)
        allow(Time).to receive(:current).and_return(DateTime.parse('2024-12-24 10:00:00'))
        expect(appointment.can_cancel?).to be false
      end
    end
    
    describe '#cancel!' do
      it 'cancels the appointment and updates slot' do
        allow(Time).to receive(:current).and_return(DateTime.parse('2024-12-24 10:00:00'))
        
        expect(appointment.cancel!).to be true
        expect(appointment.reload.status).to eq('canceled')
        expect(slot.reload.booked_count).to eq(0)
      end
      
      it 'returns false if cannot cancel' do
        allow(Time).to receive(:current).and_return(DateTime.parse('2024-12-26 10:00:00'))
        expect(appointment.cancel!).to be false
      end
    end
  end
end