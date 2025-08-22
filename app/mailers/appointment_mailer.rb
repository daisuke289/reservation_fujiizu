class AppointmentMailer < ApplicationMailer
  default from: 'noreply@fujiizu-ja.example.com'
  
  def confirmed(appointment)
    @appointment = appointment
    @branch = appointment.branch
    @slot = appointment.slot
    @appointment_type = appointment.appointment_type
    @reception_number = format('%08d', appointment.id)
    
    mail(
      to: appointment.email,
      subject: "【富士伊豆農業協同組合】ご予約確認のお知らせ（受付番号：#{@reception_number}）"
    )
  end
end