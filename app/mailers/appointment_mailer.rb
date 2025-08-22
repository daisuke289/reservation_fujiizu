class AppointmentMailer < ApplicationMailer
  default from: "no-reply@example.com"

  def confirmed(appointment)
    @appointment = appointment
    mail(
      to: appointment.email,
      subject: "【JAふじ伊豆】ご予約を承りました（受付番号: #{appointment.id.to_s.rjust(6,'0')}）"
    )
  end
end