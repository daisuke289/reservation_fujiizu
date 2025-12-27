# Preview all emails at http://localhost:3000/rails/mailers/appointment_mailer
class AppointmentMailerPreview < ActionMailer::Preview

  # Preview this email at http://localhost:3000/rails/mailers/appointment_mailer/confirmed
  def confirmed
    # サンプルデータを作成してプレビュー
    area = Area.new(id: 1, name: '東部エリア')
    branch = Branch.new(
      id: 1,
      area: area,
      name: 'Sample Branch',
      address: 'Sample City中央町2-7-1',
      phone: '0544123456',
      open_hours: "平日 9:00-17:00\n土曜 9:00-12:00"
    )
    
    appointment_type = AppointmentType.new(id: 1, name: '相続相談')
    
    slot = Slot.new(
      id: 1,
      branch: branch,
      starts_at: 1.week.from_now.change(hour: 14, min: 0),
      ends_at: 1.week.from_now.change(hour: 15, min: 0),
      capacity: 5,
      booked_count: 2
    )
    
    appointment = Appointment.new(
      id: 123,
      branch: branch,
      slot: slot,
      appointment_type: appointment_type,
      name: '山田太郎',
      furigana: 'ヤマダタロウ',
      phone: '09012345678',
      email: 'yamada@example.com',
      party_size: 2,
      purpose: '父の相続手続きについて相談したいと思います。必要な書類や手続きの流れについて教えていただきたいです。',
      notes: '車椅子でお伺いします。駐車場の確保をお願いします。',
      accept_privacy: true,
      status: :booked
    )
    
    AppointmentMailer.confirmed(appointment)
  end

end
