require "rails_helper"

RSpec.describe AppointmentMailer, type: :mailer do
  describe "confirmed" do
    let(:area) { Area.create!(name: '東部エリア', display_order: 1, is_active: true) }
    let(:branch) { Branch.create!(
      area: area,
      code: '001',
      name: '富士支店',
      address: '静岡県富士市',
      phone: '0544123456',
      open_hours: '平日 9:00-17:00',
      default_capacity: 1
    ) }
    let(:slot) { Slot.create!(
      branch: branch,
      starts_at: Time.zone.parse('2024-12-25 14:00:00'),
      ends_at: Time.zone.parse('2024-12-25 15:00:00'),
      capacity: 5,
      booked_count: 0
    ) }
    let(:appointment_type) { AppointmentType.create!(name: '相談') }
    let(:appointment) { Appointment.create!(
      branch: branch,
      slot: slot,
      appointment_type: appointment_type,
      name: '山田太郎',
      furigana: 'ヤマダタロウ',
      phone: '09012345678',
      email: 'test@example.com',
      party_size: 1,
      accept_privacy: true
    ) }
    let(:mail) { AppointmentMailer.confirmed(appointment) }

    it "renders the headers" do
      expect(mail.subject).to include("【JAふじ伊豆】ご予約を承りました")
      expect(mail.to).to eq(["test@example.com"])
      expect(mail.from).to eq(["no-reply@example.com"])
    end

    it "renders the body" do
      # エンコードされたメールをデコードしてから確認
      expect(mail.text_part.decoded).to match("山田太郎")
    end
  end

end
